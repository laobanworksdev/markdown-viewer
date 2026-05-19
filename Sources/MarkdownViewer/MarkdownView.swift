import SwiftUI
import UniformTypeIdentifiers

/// View shown for each open document.
///
/// Owns:
///   F-01 live-reload (`FileWatcher`), F-19 Cmd+R manual reload — via `LiveReloadModifier`.
///   F-02 find-in-page — via `FindBar` overlay + `WebViewRepresentable`'s coordinator.
///   F-03 scroll-percentage preservation — handled in render.js.
///   F-04 drag-and-drop file replace — via `.onDrop`.
///   F-16 zoom — `@AppStorage("pageZoom")` mirrored onto `WKWebView.pageZoom`.
struct MarkdownView: View {
    let initialText: String
    let fileURL: URL?

    @State private var currentText: String
    @State private var coordinator: WebViewRepresentable.Coordinator?
    @State private var isFindBarVisible: Bool = false
    @State private var findQuery: String = ""
    @State private var findHasMatch: Bool = true
    @State private var isDragHovering: Bool = false

    /// Persisted across launches. Default 1.0 (100%).
    @AppStorage("pageZoom") private var pageZoom: Double = 1.0

    init(initialText: String, fileURL: URL?) {
        self.initialText = initialText
        self.fileURL = fileURL
        _currentText = State(initialValue: initialText)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            WebViewRepresentable(
                markdown: currentText,
                pageZoom: pageZoom,
                coordinatorRef: $coordinator
            )
            .ignoresSafeArea()
            .modifier(LiveReloadModifier(fileURL: fileURL, text: $currentText))

            // F-04 drag highlight — a subtle accent border while a file is hovering.
            if isDragHovering {
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(Color.accentColor, lineWidth: 3)
                    .padding(2)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            // F-02 find bar — overlay docked to top-trailing.
            if isFindBarVisible {
                FindBar(
                    query: $findQuery,
                    hasMatch: $findHasMatch,
                    onChange: { runFind(forward: true, resetToTop: true) },
                    onNext: { runFind(forward: true, resetToTop: false) },
                    onPrev: { runFind(forward: false, resetToTop: false) },
                    onDismiss: dismissFind
                )
                .padding(.top, 8)
                .padding(.trailing, 12)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .onDrop(of: [.fileURL], isTargeted: $isDragHovering) { providers in
            handleDrop(providers: providers)
        }
        // F-02 — Cmd+F shows the bar; Esc inside the bar hides it.
        .onReceive(NotificationCenter.default.publisher(for: .markdownViewerFindRequested)) { _ in
            showFindBar()
        }
        .onReceive(NotificationCenter.default.publisher(for: .markdownViewerFindNextRequested)) { _ in
            if isFindBarVisible { runFind(forward: true, resetToTop: false) }
        }
        .onReceive(NotificationCenter.default.publisher(for: .markdownViewerFindPrevRequested)) { _ in
            if isFindBarVisible { runFind(forward: false, resetToTop: false) }
        }
        // F-16 zoom — menu commands bump the persisted @AppStorage value.
        .onReceive(NotificationCenter.default.publisher(for: .markdownViewerZoomInRequested)) { _ in
            pageZoom = clampZoom(pageZoom * 1.1)
        }
        .onReceive(NotificationCenter.default.publisher(for: .markdownViewerZoomOutRequested)) { _ in
            pageZoom = clampZoom(pageZoom / 1.1)
        }
        .onReceive(NotificationCenter.default.publisher(for: .markdownViewerZoomResetRequested)) { _ in
            pageZoom = 1.0
        }
    }

    // MARK: - F-02 find helpers

    private func showFindBar() {
        withAnimation(.easeOut(duration: 0.12)) {
            isFindBarVisible = true
        }
        // Reset match state to neutral; actual search fires on next keystroke.
        findHasMatch = true
    }

    private func dismissFind() {
        withAnimation(.easeOut(duration: 0.12)) {
            isFindBarVisible = false
        }
        findQuery = ""
        findHasMatch = true
    }

    /// `resetToTop` is true when the query string changed — WKWebView's `find`
    /// already restarts from the current selection on every call, so the flag is
    /// mostly a no-op today; it stays for clarity.
    private func runFind(forward: Bool, resetToTop _: Bool) {
        guard let c = coordinator else { return }
        guard !findQuery.isEmpty else {
            findHasMatch = true
            return
        }
        c.find(findQuery, forward: forward) { ok in
            DispatchQueue.main.async {
                findHasMatch = ok
            }
        }
    }

    // MARK: - F-04 drop

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        // v2 is single-doc — ignore drops past the first URL.
        guard let provider = providers.first else { return false }
        guard provider.canLoadObject(ofClass: URL.self) else { return false }
        _ = provider.loadObject(ofClass: URL.self) { url, _ in
            guard let url else { return }
            DispatchQueue.main.async {
                openDroppedFile(url)
            }
        }
        return true
    }

    private func openDroppedFile(_ url: URL) {
        // Hand off to NSWorkspace so DocumentGroup's open pipeline runs (recent-files,
        // re-uses window for same doc, etc). This is the right macOS-idiomatic path.
        NSWorkspace.shared.open(url)
    }

    // MARK: - F-16 zoom helpers

    private func clampZoom(_ z: Double) -> Double {
        max(0.5, min(3.0, z))
    }
}

// MARK: - F-02 find bar UI

private struct FindBar: View {
    @Binding var query: String
    @Binding var hasMatch: Bool
    let onChange: () -> Void
    let onNext: () -> Void
    let onPrev: () -> Void
    let onDismiss: () -> Void

    @FocusState private var queryFocused: Bool

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField("Find", text: $query)
                .textFieldStyle(.plain)
                .frame(minWidth: 160, maxWidth: 220)
                .focused($queryFocused)
                .onSubmit { onNext() }
                .onChange(of: query) { _ in
                    onChange()
                }
                .foregroundColor(query.isEmpty || hasMatch ? .primary : .red)

            Button(action: onPrev) {
                Image(systemName: "chevron.up")
            }
            .buttonStyle(.borderless)
            .keyboardShortcut("g", modifiers: [.command, .shift])
            .disabled(query.isEmpty)
            .help("Previous match (Cmd+Shift+G)")

            Button(action: onNext) {
                Image(systemName: "chevron.down")
            }
            .buttonStyle(.borderless)
            .keyboardShortcut("g", modifiers: [.command])
            .disabled(query.isEmpty)
            .help("Next match (Cmd+G)")

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.borderless)
            .keyboardShortcut(.escape, modifiers: [])
            .help("Close (Esc)")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.secondary.opacity(0.25), lineWidth: 0.5)
        )
        .onAppear { queryFocused = true }
    }
}

/// Wires a `FileWatcher` and a manual-reload notification observer to the view.
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

                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 60 * 1_000_000_000)
                }
            }
    }

    private func reloadFromDisk(url: URL) {
        do {
            let data = try Data(contentsOf: url, options: .uncached)
            let s = String(data: data, encoding: .utf8)
                ?? String(data: data, encoding: .isoLatin1)
                ?? ""
            if s != text {
                text = s
            }
        } catch {
            // Swallow — watcher will re-fire on next stable write.
        }
    }
}

extension Notification.Name {
    /// F-19 Cmd+R.
    static let markdownViewerReloadRequested = Notification.Name("MarkdownViewerReloadRequested")

    /// F-02 Cmd+F / Cmd+G / Cmd+Shift+G.
    static let markdownViewerFindRequested = Notification.Name("MarkdownViewerFindRequested")
    static let markdownViewerFindNextRequested = Notification.Name("MarkdownViewerFindNextRequested")
    static let markdownViewerFindPrevRequested = Notification.Name("MarkdownViewerFindPrevRequested")

    /// F-16 zoom.
    static let markdownViewerZoomInRequested = Notification.Name("MarkdownViewerZoomInRequested")
    static let markdownViewerZoomOutRequested = Notification.Name("MarkdownViewerZoomOutRequested")
    static let markdownViewerZoomResetRequested = Notification.Name("MarkdownViewerZoomResetRequested")
}
