# Markdown Viewer Smoke Test

A minimal native macOS viewer for `.md` files. Built with **SwiftUI** + `WKWebView`, rendered by [markdown-it](https://github.com/markdown-it/markdown-it) and [highlight.js](https://highlightjs.org).

## Headings work

### h3
#### h4
##### h5
###### h6

## Inline formatting

This is **bold**, this is *italic*, this is ~~strikethrough~~, and this is `inline code`.

A link to [Daring Fireball](https://daringfireball.net). Auto-linkified URL: https://www.apple.com.

## Lists

- one
- two
  - nested
  - nested again
- three

1. first
2. second
3. third

## Task list (GFM)

- [x] Scaffold the project
- [x] Wire up SwiftUI + WKWebView
- [x] Render with markdown-it
- [ ] Ship a signed build (deferred — needs Apple Developer cert)
- [ ] App icon (deferred)

## Code block with syntax highlighting

```swift
import SwiftUI

@main
struct MarkdownViewerApp: App {
    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { file in
            MarkdownView(document: file.document)
        }
    }
}
```

```python
def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a
```

## Table

| Feature              | Status   | Notes                          |
|----------------------|----------|--------------------------------|
| GFM tables           | works    | what you're looking at         |
| Code highlighting    | works    | highlight.js, github theme     |
| Dark mode            | works    | follows system appearance      |
| Math / Mermaid       | deferred | not in v1                      |
| Find-in-page         | deferred | use Cmd+L to copy, for now     |

## Blockquote

> The best code is the code you didn't write.
>
> Every dependency is a future maintenance tax.

## Horizontal rule

---

That's it. If you can read this with nice typography, dark/light mode tracking, and the code blocks are colorized, the viewer works.
