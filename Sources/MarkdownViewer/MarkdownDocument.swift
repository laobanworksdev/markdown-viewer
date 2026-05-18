import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static var markdown: UTType {
        UTType(importedAs: "net.daringfireball.markdown")
    }
}

struct MarkdownDocument: FileDocument {
    // Accept the standard markdown UTI plus plain text (for .txt / unknown).
    static var readableContentTypes: [UTType] = [
        .markdown,
        .plainText,
    ]

    // View-only. We never write back.
    static var writableContentTypes: [UTType] = []

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        // Try UTF-8 first; fall back to system default.
        if let s = String(data: data, encoding: .utf8) {
            self.text = s
        } else if let s = String(data: data, encoding: .isoLatin1) {
            self.text = s
        } else {
            self.text = ""
        }
    }

    // Required by the protocol but never used (writableContentTypes is empty).
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw CocoaError(.fileWriteUnknown)
    }
}
