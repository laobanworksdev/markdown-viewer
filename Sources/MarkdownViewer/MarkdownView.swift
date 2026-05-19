import SwiftUI

/// View shown for each open document.
///
/// Owns the live-reload pipeline: a `FileWatcher` tied to the on-disk URL (F-01),
/// a Cmd+R / NotificationCenter manual reload (F-19), and the JS-side scroll-percentage
/// preservation (F-03) which is handled inside `renderMarkdown` in render.js.
struct MarkdownView: View {
    let initialText: String
    let fileURL: URL?

    /// Mutable copy of the document text. SwiftUI passes the value-typed
    /// `MarkdownDocument` in; we keep our own copy so live-reload can refresh
    /// it without round-tripping through `@Binding`.
    @State private var currentText: String

    init(initialText: String, fileURL: URL?) {
        self.initialText = initialText
        self.fileURL = fileURL
        _currentText = State(initialValue: initialText)
    }

    var body: some View {
        WebViewRepresentable(markdown: currentText)
            .ignoresSafeArea()
            .modifier(LiveReloadModifier(fileURL: fileURL, text: $currentText))
    }
}

/// Wires a `FileWatcher` and a manual-reload notification observer to the view.
///
/// `task(id:)` ties the watcher's lifetime to view presence: when the URL appears
/// the watcher starts; when the URL changes or the view disappears the closure
/// is cancelled and we tear down.
private struct LiveReloadModifier: ViewModifier {
    let fileURL: URL?
    @Binding var text: String

    func body(content: Content) -> some View {
        content
            .task(id: fileURL) {
                guard let url = fileURL else { return }

                let watcher = FileWatcher(url: url) {
                    reloadFromDisk(url: url)
                }
                watcher.start()

                // Manual Cmd+R reload (F-19). Posted by the Reload menu command.
                let observer = NotificationCenter.default.addObserver(
                    forName: .markdownViewerReloadRequested,
                    object: nil,
                    queue: .main
                ) { _ in
                    reloadFromDisk(url: url)
                }

                defer {
                    watcher.stop()
                    NotificationCenter.default.removeObserver(observer)
                }

                // Park until the task is cancelled (view goes away or URL changes).
                // We can't use `try? await Task.sleep(...)` with .nanoseconds(.max)
                // because the runtime caps that; loop on a long sleep that gets
                // cancelled cleanly.
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
                }
            }
    }

    private func reloadFromDisk(url: URL) {
        // Re-read from disk and push into the binding. If the read fails (file is
        // mid-rewrite, gone temporarily), keep the current text — the next event
        // will retry. Don't blank the view.
        do {
            let data = try Data(contentsOf: url, options: .uncached)
            let s = String(data: data, encoding: .utf8)
                ?? String(data: data, encoding: .isoLatin1)
                ?? ""
            // Avoid spurious re-renders on no-op writes (touch, mtime-only update).
            if s != text {
                text = s
            }
        } catch {
            // Swallow — file is transiently unavailable (atomic rename in-flight, etc).
            // Watcher will re-fire on the next stable write.
        }
    }
}

extension Notification.Name {
    /// Posted by the Reload menu item (Cmd+R, F-19). Every open `MarkdownView`
    /// observes this; whichever document is currently focused will reload from disk.
    static let markdownViewerReloadRequested = Notification.Name("MarkdownViewerReloadRequested")
}
