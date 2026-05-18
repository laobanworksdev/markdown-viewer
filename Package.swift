// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MarkdownViewer",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "MarkdownViewer",
            path: "Sources/MarkdownViewer",
            resources: [
                .copy("Resources/viewer.html"),
                .copy("Resources/viewer.css"),
                .copy("Resources/render.js"),
                .copy("Resources/markdown-it.min.js"),
                .copy("Resources/highlight.min.js"),
                .copy("Resources/highlight-theme-light.css"),
                .copy("Resources/highlight-theme-dark.css"),
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
