import SwiftUI
import WebKit

/// Wraps a `WKWebView` rendering the vendored markdown-it template.
///
/// Talks to the SwiftUI side via:
/// - `markdown` (input): rendered into the page on every update.
/// - `pageZoom` (input): mirrored onto `WKWebView.pageZoom` (macOS 11+).
/// - `coordinatorRef` (output): binding that captures the live `Coordinator`
///   so the parent view can call `find(...)`, `findNext()`, `findPrev()` and
///   refocus the webview from the find-bar.
struct WebViewRepresentable: NSViewRepresentable {
    let markdown: String
    let pageZoom: Double
    @Binding var coordinatorRef: Coordinator?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptCanOpenWindowsAutomatically = false

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = false
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        webView.pageZoom = CGFloat(pageZoom)
        context.coordinator.webView = webView
        context.coordinator.pendingMarkdown = markdown
        loadTemplate(into: webView)

        // Surface the coordinator up to the SwiftUI side once. Use async so we
        // don't mutate state during a view-update.
        DispatchQueue.main.async {
            coordinatorRef = context.coordinator
        }
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.pendingMarkdown = markdown
        if context.coordinator.isReady {
            context.coordinator.render(markdown: markdown)
        }
        if webView.pageZoom != CGFloat(pageZoom) {
            webView.pageZoom = CGFloat(pageZoom)
        }
    }

    private func loadTemplate(into webView: WKWebView) {
        guard let htmlURL = ViewerResources.bundle.url(forResource: "viewer", withExtension: "html") else {
            webView.loadHTMLString("<h1>viewer.html missing</h1>", baseURL: nil)
            return
        }
        let baseURL = htmlURL.deletingLastPathComponent()
        webView.loadFileURL(htmlURL, allowingReadAccessTo: baseURL)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        weak var webView: WKWebView?
        var pendingMarkdown: String = ""
        var isReady = false
        private var lastQuery: String = ""

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isReady = true
            render(markdown: pendingMarkdown)
        }

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
            let data = try? JSONSerialization.data(withJSONObject: [markdown], options: [])
            guard let data = data,
                  let jsonArray = String(data: data, encoding: .utf8) else { return }
            let js = "window.renderMarkdown(\(jsonArray)[0]);"
            webView.evaluateJavaScript(js, completionHandler: nil)
        }

        // MARK: - F-02 Find

        /// Search the web view for `query`. `forward` controls direction; on a new
        /// query string the search starts fresh from the top.
        /// Calls `completion` with `true` when at least one match exists.
        func find(_ query: String, forward: Bool = true, completion: ((Bool) -> Void)? = nil) {
            guard let webView = webView else { completion?(false); return }
            let config = WKFindConfiguration()
            config.caseSensitive = false
            config.backwards = !forward
            config.wraps = true
            lastQuery = query
            if query.isEmpty {
                // Clear any existing selection-as-highlight by searching for an empty string.
                completion?(false)
                return
            }
            webView.find(query, configuration: config) { result in
                completion?(result.matchFound)
            }
        }

        func findNext(completion: ((Bool) -> Void)? = nil) {
            guard !lastQuery.isEmpty else { completion?(false); return }
            find(lastQuery, forward: true, completion: completion)
        }

        func findPrev(completion: ((Bool) -> Void)? = nil) {
            guard !lastQuery.isEmpty else { completion?(false); return }
            find(lastQuery, forward: false, completion: completion)
        }
    }
}
