import SwiftUI

struct MarkdownView: View {
    let document: MarkdownDocument

    var body: some View {
        WebViewRepresentable(markdown: document.text)
            .ignoresSafeArea()
    }
}
