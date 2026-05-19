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
            // We're a viewer — no "New" item.
            CommandGroup(replacing: .newItem) {}

            // F-19: Cmd+R re-reads the front-most document from disk and re-renders.
            // Posts a notification; every open MarkdownView observes it and re-reads
            // from its URL. SwiftUI's responder chain limits this to the key window
            // in practice — observers in background windows will harmlessly re-read
            // their own file too, which is fine.
            CommandGroup(after: .toolbar) {
                Button("Reload") {
                    NotificationCenter.default.post(
                        name: .markdownViewerReloadRequested,
                        object: nil
                    )
                }
                .keyboardShortcut("r", modifiers: [.command])
            }
        }
    }
}
