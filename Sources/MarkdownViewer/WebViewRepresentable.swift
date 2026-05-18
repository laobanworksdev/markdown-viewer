import SwiftUI
import WebKit

struct WebViewRepresentable: NSViewRepresentable {
    let markdown: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Allow file:// loads to read sibling resources.
        config.preferences.javaScriptCanOpenWindowsAutomatically = false

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = false
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        context.coordinator.webView = webView
        context.coordinator.pendingMarkdown = markdown
        loadTemplate(into: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.pendingMarkdown = markdown
        if context.coordinator.isReady {
            context.coordinator.render(markdown: markdown)
        }
    }

    private func loadTemplate(into webView: WKWebView) {
        guard let htmlURL = ViewerResources.bundle.url(forResource: "viewer", withExtension: "html") else {
            webView.loadHTMLString("<h1>viewer.html missing</h1>", baseURL: nil)
            return
        }
        // Read from bundle then load with the resources directory as baseURL so
        // <link>/<script> tags resolve to sibling files.
        let baseURL = htmlURL.deletingLastPathComponent()
        webView.loadFileURL(htmlURL, allowingReadAccessTo: baseURL)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?
        var pendingMarkdown: String = ""
        var isReady = false

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isReady = true
            render(markdown: pendingMarkdown)
        }

        // Open http(s) links in the user's default browser instead of inside the WebView.
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               navigationAction.navigationType == .linkActivated,
               let scheme = url.scheme,
               (scheme == "http" || scheme == "https" || scheme == "mailto") {
                NSWorkspace.shared.open(url)
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }

        func render(markdown: String) {
            guard let webView = webView else { return }
            // Pass the markdown as JSON-encoded string to avoid any escaping issues.
            let data = try? JSONSerialization.data(withJSONObject: [markdown], options: [])
            guard let data = data,
                  let jsonArray = String(data: data, encoding: .utf8) else { return }
            // jsonArray is `["..."]` — index [0] gives us a JS string literal of the markdown.
            let js = "window.renderMarkdown(\(jsonArray)[0]);"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
