# Markdown Viewer

A minimal native macOS app for viewing Markdown files. Like Preview, but for `.md`.

- Native SwiftUI window. System font. Tracks system light/dark mode.
- GFM rendering (tables, task lists, strikethrough, fenced code) with syntax highlighting.
- Offline — no network calls, ever. JavaScript renderer is vendored.
- Document-based: one window per file. Cmd+O opens another. Cmd+W closes one.
- Find in page (Cmd+F, Cmd+G / Cmd+Shift+G), live reload on save (Cmd+R to force), zoom (Cmd+= / Cmd+- / Cmd+0), drag-and-drop a `.md` onto the window.
- Optional `mdv` terminal command (`scripts/install-cli.sh`).
- Built without Xcode (CommandLineTools is enough). Shipped as an unsigned DMG.

Requires macOS 13+ on Apple Silicon (arm64).

## Demo

The repo ships with a smoke-test corpus at [`docs/test.md`](docs/test.md) that exercises every feature the viewer supports. After building, point the app at it:

```sh
scripts/build.sh
open -a build/MarkdownViewer.app docs/test.md
```

What you should see in the window:

- **Typography** — system font, ~720px centered column, Typora-ish spacing.
- **Headings h1–h6** with a thin underline under h1/h2.
- **Inline** — **bold**, *italic*, ~~strikethrough~~, `inline code`, [auto-linkified URLs](https://www.apple.com).
- **Lists** — bulleted, numbered, two-level nested.
- **GFM task lists** — rendered as real `<input type=checkbox disabled>` boxes (checked / unchecked).
- **Fenced code blocks** with syntax highlighting — Swift, Python, and ~190 other languages via highlight.js auto-detection. GitHub theme in light mode, github-dark in dark mode.
- **Tables** with header row + alignment.
- **Blockquotes** with a left rule.
- **Horizontal rules**, **links** (external links open in the default browser, not inside the viewer).
- **Light / dark tracking** — switch macOS Appearance (System Settings → Appearance) while the window is open; colors flip immediately via CSS `prefers-color-scheme`. No reload needed.

To verify the offline guarantee: turn Wi-Fi off, then reopen `docs/test.md`. The page should render identically — `markdown-it` and `highlight.js` are vendored into the app bundle, no network calls happen at render time.

### Sample input → rendered output

A taste of what `docs/test.md` contains (the source on the left, the viewer renders the typeset version on the right):

````markdown
## Task list (GFM)

- [x] Scaffold the project
- [x] Wire up SwiftUI + WKWebView
- [ ] Ship a signed build

```swift
@main
struct MarkdownViewerApp: App {
    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { file in
            MarkdownView(document: file.document)
        }
    }
}
```

| Feature           | Status   |
|-------------------|----------|
| GFM tables        | works    |
| Code highlighting | works    |
| Dark mode         | works    |
````

Drop your own `.md` next to it and `open -a build/MarkdownViewer.app yours.md` — that's the whole loop.

## Install (end user)

1. Double-click `MarkdownViewer-0.1.0.dmg`.
2. Drag `MarkdownViewer.app` to the `Applications` folder shortcut in the same window.
3. Eject the DMG.
4. **First launch only:** because the app is not code-signed by Apple, Gatekeeper will block a regular double-click. Right-click `MarkdownViewer.app` in Applications → **Open** → confirm. macOS remembers this choice; future launches are normal.
5. To open a `.md` file: right-click the file in Finder → Open With → Markdown Viewer. Or `open -a "Markdown Viewer" path/to/file.md` from a terminal.

To make Markdown Viewer the default for `.md` files: Finder → select a `.md` file → Get Info → Open With → Markdown Viewer → **Change All…**

## Build from source

Prerequisites: macOS 13+, Apple CommandLineTools (`xcode-select --install`). Full Xcode is **not** required.

```sh
# Compile + assemble the .app bundle
scripts/build.sh
# → build/MarkdownViewer.app

# Wrap into a DMG
scripts/make-dmg.sh
# → build/MarkdownViewer-0.2.0-dev.dmg

# Launch
open build/MarkdownViewer.app

# Open a doc
open -a build/MarkdownViewer.app docs/test.md
```

That's it. No `npm`, no `pod`, no `brew`, no external toolchain.

## Vendored dependencies

Both bundled into the app — no network at runtime.

| Library         | Version | Source                                                                                       |
|-----------------|---------|----------------------------------------------------------------------------------------------|
| markdown-it     | 14.1.0  | `https://cdn.jsdelivr.net/npm/markdown-it@14.1.0/dist/markdown-it.min.js`                    |
| highlight.js    | 11.9.0  | `https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/highlight.min.js`          |
| github theme    | 11.9.0  | `https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/styles/github.min.css`     |
| github-dark     | 11.9.0  | `https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.9.0/build/styles/github-dark.min.css`|

To bump: re-download each file from the same URL with the new version, replace under `Sources/MarkdownViewer/Resources/`, update this table and `DESCRIBE.md`.

## Project layout

```
Package.swift                       SwiftPM manifest, macOS 13+
Sources/MarkdownViewer/
  MarkdownViewerApp.swift           @main, DocumentGroup
  MarkdownDocument.swift            FileDocument; reads .md/.txt
  MarkdownView.swift                SwiftUI wrapper
  WebViewRepresentable.swift        NSViewRepresentable around WKWebView
  Resources/
    viewer.html                     page shell
    viewer.css                      Typora-ish typography
    render.js                       Swift→JS glue + GFM task lists
    markdown-it.min.js              vendored
    highlight.min.js                vendored
    highlight-theme-light.css       github theme
    highlight-theme-dark.css        github-dark theme
assets/
  AppIcon.icns                      app icon (regenerated by scripts/make-icon.swift on every build)
scripts/
  build.sh                          .app assembly
  make-icon.swift                   procedural CoreGraphics icon generator
  make-dmg.sh                       DMG packaging
build/                              generated artifacts (gitignored)
```


## Known limitations

- No print or PDF export.
- No math (KaTeX), Mermaid diagrams, footnotes, or other non-GFM extensions.
- Raw HTML inside `.md` is **stripped** by markdown-it (`html: false`) for safety.
- Unsigned binary — Gatekeeper friction on first launch.
- Apple Silicon only by default (x86_64 fat-binary build would be a one-line script change).
