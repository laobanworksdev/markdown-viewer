import SwiftUI

@main
struct MarkdownViewerApp: App {
    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { file in
            MarkdownView(initialText: file.document.text, fileURL: file.fileURL)
                .frame(minWidth: 480, minHeight: 360)
        }
        .windowToolbarStyle(.unified(showsTitle: true))
        .defaultSize(width: 900, height: 700)
        .commands {
            // Viewer — no "New" item.
            CommandGroup(replacing: .newItem) {}

            // F-19 — Reload (Cmd+R) lives just under File → Save in the menu.
            // F-05 — File → Open Recent comes free from DocumentGroup; no code needed.
            CommandGroup(after: .toolbar) {
                Button("Reload") {
                    NotificationCenter.default.post(name: .markdownViewerReloadRequested, object: nil)
                }
                .keyboardShortcut("r", modifiers: [.command])
            }

            // F-02 — Find menu (replaces the system default so we route through the
            // WebView's native `find(_:configuration:)` instead of the responder
            // chain's text-system find).
            CommandGroup(replacing: .textEditing) {
                Button("Find…") {
                    NotificationCenter.default.post(name: .markdownViewerFindRequested, object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command])

                Button("Find Next") {
                    NotificationCenter.default.post(name: .markdownViewerFindNextRequested, object: nil)
                }
                .keyboardShortcut("g", modifiers: [.command])

                Button("Find Previous") {
                    NotificationCenter.default.post(name: .markdownViewerFindPrevRequested, object: nil)
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
            }

            // F-16 — Zoom under View menu.
            CommandGroup(after: .toolbar) {
                Divider()
                Button("Zoom In") {
                    NotificationCenter.default.post(name: .markdownViewerZoomInRequested, object: nil)
                }
                .keyboardShortcut("=", modifiers: [.command])

                Button("Zoom Out") {
                    NotificationCenter.default.post(name: .markdownViewerZoomOutRequested, object: nil)
                }
                .keyboardShortcut("-", modifiers: [.command])

                Button("Actual Size") {
                    NotificationCenter.default.post(name: .markdownViewerZoomResetRequested, object: nil)
                }
                .keyboardShortcut("0", modifiers: [.command])
            }
        }
    }
}
