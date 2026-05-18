import Foundation

enum ViewerResources {
    static let bundle: Bundle = {
        if let url = Bundle.main.resourceURL?.appendingPathComponent("MarkdownViewer_MarkdownViewer.bundle"),
           let b = Bundle(url: url) {
            return b
        }
        return Bundle.module
    }()
}
