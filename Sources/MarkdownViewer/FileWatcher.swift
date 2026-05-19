import Foundation

/// Single-file watcher tuned for F-01 live-reload.
///
/// Uses `DispatchSource.makeFileSystemObjectSource` keyed on a file descriptor.
/// The descriptor is bound to an inode at `open()` time, so when an editor saves
/// via the atomic-rename pattern (vim, VS Code, `sed -i`) the watched inode is
/// unlinked and a new file appears at the same path — the watcher receives
/// `.delete` / `.rename` events, and we must re-`open()` by path to keep watching.
///
/// Events are coalesced on a background queue and delivered to `onChange` on the
/// main queue after a 200ms debounce.
final class FileWatcher {
    private let url: URL
    private let debounce: TimeInterval
    private let onChange: () -> Void

    private var source: DispatchSourceFileSystemObject?
    private var fd: Int32 = -1
    private let queue = DispatchQueue(label: "MarkdownViewer.FileWatcher", qos: .utility)
    private var debounceWorkItem: DispatchWorkItem?
    private var reopenAttempts = 0

    init(url: URL, debounce: TimeInterval = 0.2, onChange: @escaping () -> Void) {
        self.url = url
        self.debounce = debounce
        self.onChange = onChange
    }

    deinit {
        stop()
    }

    func start() {
        queue.async { [weak self] in
            self?.attach()
        }
    }

    func stop() {
        queue.sync { [weak self] in
            self?.tearDown()
        }
    }

    // MARK: - Private

    private func attach() {
        tearDown()
        let path = url.withUnsafeFileSystemRepresentation { ptr -> String in
            guard let ptr = ptr else { return url.path }
            return String(cString: ptr)
        }
        let fileDescriptor = open(path, O_EVTONLY)
        guard fileDescriptor >= 0 else {
            // File doesn't exist (yet). Retry with exponential backoff up to a few times.
            scheduleReopen()
            return
        }
        self.fd = fileDescriptor
        self.reopenAttempts = 0

        let mask: DispatchSource.FileSystemEvent = [.write, .extend, .delete, .rename, .revoke]
        let src = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: mask,
            queue: queue
        )
        self.source = src

        src.setEventHandler { [weak self] in
            guard let self = self else { return }
            let event = src.data
            // .delete or .rename means the inode we're watching is gone or has been
            // unlinked from the path. The new file (post atomic-rename) is at the same
            // path but is a different inode — we must re-open.
            let needsReopen = event.contains(.delete) || event.contains(.rename) || event.contains(.revoke)
            self.fireChangeSoon()
            if needsReopen {
                self.attach()
            }
        }

        src.setCancelHandler { [weak self] in
            guard let self = self else { return }
            if self.fd >= 0 {
                close(self.fd)
                self.fd = -1
            }
        }

        src.resume()
    }

    private func scheduleReopen() {
        reopenAttempts += 1
        // Cap the retry — if file is gone for >~3s we stop trying and wait for a
        // change event we'll never receive. Caller can re-start() if needed.
        guard reopenAttempts < 10 else { return }
        let delay = min(0.5, Double(reopenAttempts) * 0.1)
        queue.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.attach()
        }
    }

    private func fireChangeSoon() {
        debounceWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { self.onChange() }
        }
        debounceWorkItem = work
        queue.asyncAfter(deadline: .now() + debounce, execute: work)
    }

    private func tearDown() {
        debounceWorkItem?.cancel()
        debounceWorkItem = nil
        if let src = source {
            src.cancel()
            source = nil
        }
        // The cancel handler closes the fd, but if the source was never created (early
        // bailout on open() failure) we still need to be safe.
        if fd >= 0 && source == nil {
            close(fd)
            fd = -1
        }
    }
}
