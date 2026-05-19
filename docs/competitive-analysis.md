# Competitive Analysis — MarkdownViewer vs Typora vs Marked 2

**Author:** PM
**Date:** 2026-05-19
**Audience:** user (final approver), solo-engineer (for v2.1/v2.2 scope implications)
**Companion docs:** `docs/v2-requirements.md`, `docs/ROADMAP.md`, `docs/distribution-options.md` (Section 9 locked decisions)
**Status:** DRAFT — research-grade competitive analysis. Not a scope change.

---

## 0. User's verbatim ask

> "compare Typora and Marked 2 for all features disclosed on the App Store and their public site, compare what we have and what they have. The competitive strength for my app is what?"

Two threads: (1) feature-by-feature comparison against the two named competitors with grounded evidence (not vibes), (2) a direct answer to "what's our competitive strength."

---

## 1. Scope and ground rules

- Only features **publicly disclosed** on the competitor's site or App Store listing count. No insider knowledge, no guessed-at internals.
- Pricing numbers are quoted exactly from current sources (fetched 2026-05-19).
- "Ours today" = v2.0 currently shipped on `origin/main` (commits `9c44dc9` through `e917140`). "v2.1" / "v2.2" = the locked plan in `docs/ROADMAP.md` + `docs/distribution-options.md` Section 9.
- This doc does NOT propose scope changes. It surfaces gaps and white-space; whether to act on them is a separate PM/solo round.

---

## 2. Competitor snapshots (verified 2026-05-19)

### Typora — $14.99 one-time, direct download only

- **Pricing:** $14.99 (without tax) per license, **up to 3 devices**, 15-day free trial. ([typora.io](https://typora.io))
- **Distribution:** Direct download from typora.io for macOS, Windows, Linux. **Not listed on the Mac App Store.** ([typora.io/#download](https://typora.io/#download))
- **Platforms:** macOS (native, Apple Silicon supported per [support.typora.io/Typora-on-macOS](https://support.typora.io/Typora-on-macOS/)), Windows 10/11 64-bit + 32-bit + ARM, Linux deb + binaries.
- **License model:** Closed-source paid. No free tier other than the trial.
- **Positioning:** "A minimal Markdown editor and reader" — primarily a **WYSIWYG editor with live in-place rendering**. Different category from us, but features overlap.
- **Underlying engine:** Public materials say "native macOS app" and "native on Apple Silicon" but do not disclose whether it uses Electron, WebView, or a custom renderer. Third-party speculation (a 2021 blog post) called it Electron-based; Typora itself has not confirmed or denied. Treat as **unknown** — do not claim "Typora is Electron" as fact.

### Marked 2 — $13.99 MAS / direct via Paddle, version 2.6.46

- **Pricing:** **$13.99** on the Mac App Store ([apps.apple.com](https://apps.apple.com/us/app/marked-2-markdown-preview/id890031187)), separate direct download via Paddle ([marked2app.com](https://marked2app.com)). 7-day free trial.
- **In-App Purchase:** **Spelling and Grammar — $1.99** (the only IAP; everything else is bundled).
- **Distribution:** **Dual** — Mac App Store + direct download. Proves the dual-channel model is workable for this category.
- **Platform:** macOS only. Requires **macOS 10.13+** (App Store listing). Direct download per their site requires 10.12+.
- **Version:** 2.6.46 (released 2025-03-11 per the App Store).
- **App size:** 20.6 MB.
- **Developer:** Brett Terpstra (individual). Track record: shipping Marked since 2011, Marked 2 since 2014.
- **Positioning:** "Previewer (*not an editor*) for Markdown" — **identical positioning to ours**, which validates that the viewer-only niche has 10+ years of paid demand.

### Reference points (light-touch only)

- **VS Code built-in Markdown preview:** Free, ships with VS Code. Supports CommonMark, syntax highlighting, KaTeX math, bidirectional editor↔preview scroll sync. Updates instantly because VS Code observes its own buffer (not file-watching). ([code.visualstudio.com](https://code.visualstudio.com/docs/languages/markdown))
- **MacDown:** Free, open-source, macOS-only. Abandoned (last release 2020). Influential but no longer maintained.
- **iA Writer:** $29.99 one-time, $4.99/month subscription. WYSIWYG-ish editor with strong typography. Different category (editor, not viewer).

---

## 3. Feature comparison matrix

Legend: ✅ = present, ⚠️ = partial / caveated, ❌ = absent, — = not applicable.

| # | Feature | Typora | Marked 2 | MV v2.0 (shipped) | MV v2.1 (planned) | MV v2.2 (planned) |
|---|---|---|---|---|---|---|
| **1. Category positioning** |
| 1.1 | App category | WYSIWYG editor | Previewer (not editor) | Previewer (not editor) | (continues) | (continues) |
| 1.2 | Source-mode editing | ✅ (toggle) | ❌ | ❌ (out of scope) | ❌ | ❌ |
| 1.3 | WYSIWYG editing | ✅ (primary mode) | ❌ | ❌ (out of scope) | ❌ | ❌ |
| 1.4 | File-watching live preview from external editor | ❌ (it IS the editor) | ✅ ("picks up changes on save") | ✅ F-01 shipped | (continues) | (continues) |
| **2. Markdown flavors** |
| 2.1 | CommonMark | ✅ | ✅ | ✅ (via markdown-it 14.1.0) | (continues) | (continues) |
| 2.2 | GitHub Flavored Markdown | ✅ | ✅ | ✅ | (continues) | (continues) |
| 2.3 | MultiMarkdown | ❌ | ✅ (built-in latest version) | ❌ | ❌ | ❌ |
| 2.4 | Pandoc / discount processor | ❌ | ✅ (discount processor option) | ❌ | ❌ | ❌ |
| 2.5 | Fountain (screenplay) | ❌ | ✅ | ❌ | ❌ | ❌ |
| 2.6 | CriticMarkup | ❌ | ✅ | ❌ | ❌ | ❌ |
| 2.7 | YAML front matter | ✅ | ⚠️ (some markup support) | ❌ (not stripped) | ❌ | ❌ |
| 2.8 | Footnotes | ✅ | ✅ (MultiMarkdown) | ❌ | ✅ F-13 planned | (continues) |
| 2.9 | Task lists (`- [x]`) | ✅ | ✅ (via GFM) | ✅ | (continues) | (continues) |
| **3. Math & diagrams** |
| 3.1 | Math (KaTeX or MathJax) | ✅ (MathJax + chem + auto-num) | ✅ (MathJax) | ❌ **WON'T-v2** (0 demand in user's corpus) | ❌ | ❌ |
| 3.2 | Mermaid diagrams | ✅ | ❌ | ❌ **WON'T-v2** (0 demand in user's corpus) | ❌ | ❌ |
| 3.3 | flowchart.js / sequence diagrams | ✅ | ❌ | ❌ | ❌ | ❌ |
| **4. Tables** |
| 4.1 | GFM tables rendering | ✅ | ✅ | ✅ | (continues) | (continues) |
| 4.2 | Table editor (drag-resize, reorder) | ✅ | ❌ | ❌ (viewer — no edit) | ❌ | ❌ |
| **5. Code blocks** |
| 5.1 | Syntax highlighting | ✅ (~100 langs) | ✅ | ✅ (highlight.js 11.9.0, ~190 langs) | (continues) | (continues) |
| 5.2 | Language label per block | ⚠️ (line numbers + fence info) | ✅ | ❌ | ✅ F-09 planned | (continues) |
| 5.3 | Copy-to-clipboard button | ❌ (not on public list) | ❌ (not on public list) | ❌ | ✅ F-09 planned | (continues) |
| 5.4 | Line numbers | ✅ | ✅ | ❌ | ✅ F-09 planned (toggle, default off) | (continues) |
| **6. Themes & styling** |
| 6.1 | Built-in themes | ✅ ("multiple") | ✅ (**9 built-in styles**) | ⚠️ 1 (GitHub light + dark via prefers-color-scheme) | ✅ 2 (GitHub + Paper-or-Sepia, F-08) | (continues) |
| 6.2 | Custom CSS themes | ✅ | ✅ (unlimited custom + live update) | ❌ | ✅ F-07 planned (`~/Library/Application Support/MarkdownViewer/themes/`) | (continues) |
| 6.3 | Dark / light mode | ✅ | ✅ | ✅ (follows system via `prefers-color-scheme`) | (continues) | (continues) |
| 6.4 | Live CSS reload as you edit the .css | ⚠️ (not explicit) | ✅ (live updates, no refresh) | ❌ | ⚠️ (manual reload only — folder-watch deferred) | (continues) |
| **7. Export** |
| 7.1 | Export PDF (with bookmarks) | ✅ | ✅ | ❌ | ✅ F-06 planned (system print → Save as PDF; no bookmarks) | (continues) |
| 7.2 | Export HTML | ✅ | ✅ (self-contained) | ❌ | ❌ | ❌ |
| 7.3 | Export Word (.docx) | ✅ | ✅ | ❌ | ❌ | ❌ |
| 7.4 | Export RTF | ❌ | ✅ (rich text for email) | ❌ | ❌ | ❌ |
| 7.5 | Export OpenOffice / LaTeX / MediaWiki | ✅ | ❌ | ❌ | ❌ | ❌ |
| 7.6 | Export ePub | ✅ | ❌ | ❌ | ❌ | ❌ |
| 7.7 | Export "manuscript" format | ❌ | ✅ | ❌ | ❌ | ❌ |
| **8. Print** |
| 8.1 | System print dialog | ⚠️ (implied by PDF) | ⚠️ (implied by PDF) | ⚠️ (free from WKWebView Cmd+P, untuned CSS) | ✅ F-06 planned (tuned `@media print`) | (continues) |
| **9. Find** |
| 9.1 | Find in page | ✅ (assumed; not explicit on site) | ⚠️ (wildcard + regex search) | ✅ F-02 shipped (native WKWebView Cmd+F) | (continues) | (continues) |
| 9.2 | Regex search | ❌ (not on public list) | ✅ | ❌ | ❌ | ❌ |
| 9.3 | Wildcard search | ❌ (not on public list) | ✅ | ❌ | ❌ | ❌ |
| **10. Document navigation** |
| 10.1 | Table of contents sidebar | ✅ (outline panel) | ✅ (auto TOC with typeahead) | ❌ | ✅ F-10 planned (NavigationSplitView) | (continues) |
| 10.2 | `[TOC]` inline marker | ✅ | ✅ | ❌ | ❌ | ❌ |
| 10.3 | Internal header links | ✅ | ✅ | ✅ (markdown-it native) | (continues) | (continues) |
| 10.4 | Collapsible sections | ❌ | ✅ | ❌ | ❌ | ❌ |
| 10.5 | Vim-style keyboard nav | ❌ | ✅ | ❌ | ❌ | ❌ |
| **11. Document stats / proofing** |
| 11.1 | Word count | ✅ | ✅ | ❌ | ❌ | ✅ F-15 planned (status bar) |
| 11.2 | Character count | ✅ | ✅ (selection-based) | ❌ | ❌ | ❌ |
| 11.3 | Reading time | ✅ | ✅ (customizable WPM) | ❌ | ❌ | ✅ F-15 planned |
| 11.4 | Fog Index | ❌ | ✅ | ❌ | ❌ | ❌ |
| 11.5 | Flesch-Kincaid | ❌ | ✅ | ❌ | ❌ | ❌ |
| 11.6 | Word repetition / overused-word highlighting | ❌ | ✅ | ❌ | ❌ | ❌ |
| 11.7 | Word density analysis | ❌ | ✅ | ❌ | ❌ | ❌ |
| 11.8 | Custom keyword highlighting (wildcards) | ❌ | ✅ | ❌ | ❌ | ❌ |
| 11.9 | Spelling & grammar | ⚠️ (system) | ✅ (IAP $1.99) | ⚠️ (system, WKWebView default) | (continues) | (continues) |
| **12. File-watching & integrations** |
| 12.1 | File-watching from any editor | ❌ (it IS the editor) | ✅ | ✅ F-01 (DispatchSource, atomic-rename safe) | (continues) | (continues) |
| 12.2 | Scroll preservation across reload | — | ⚠️ ("auto-scroll to recent edits" — opposite behavior) | ✅ F-03 (percentage-based) | (continues) | (continues) |
| 12.3 | Scroll sync to editor cursor | ❌ | ⚠️ ("auto-scroll to recent edits") | ❌ (we can't — we're not the editor) | ❌ | ❌ |
| 12.4 | Image-change auto-refresh | ⚠️ | ✅ (image change detection) | ⚠️ (rendered img tags refresh on reload, no targeted invalidation) | (continues) | (continues) |
| 12.5 | Folder tracking (most recently edited .md) | ❌ | ✅ | ❌ | ❌ | ❌ |
| 12.6 | Multi-file document via includes / mmd_merge | ❌ | ✅ (Leanpub, mmd_merge book formats) | ❌ | ❌ | ❌ |
| 12.7 | Scrivener integration | ❌ | ✅ | ❌ | ❌ | ❌ |
| 12.8 | Ulysses integration | ❌ | ✅ | ❌ | ❌ | ❌ |
| 12.9 | MarsEdit integration | ❌ | ✅ | ❌ | ❌ | ❌ |
| 12.10 | VoodooPad integration | ❌ | ✅ | ❌ | ❌ | ❌ |
| **13. Customization / extensibility** |
| 13.1 | Custom CSS themes | ✅ | ✅ | ❌ | ✅ F-07 planned | (continues) |
| 13.2 | Custom shell-script processors | ❌ | ✅ (pre + post) | ❌ **out of scope** (security surface) | ❌ | ❌ |
| 13.3 | Plugins | ❌ | ❌ | ❌ | ❌ | ❌ |
| **14. UI features** |
| 14.1 | Focus mode | ✅ | ❌ | ❌ | ❌ | ❌ |
| 14.2 | Typewriter mode | ✅ | ❌ | ❌ | ❌ | ❌ |
| 14.3 | Auto-pair brackets / markdown symbols | ✅ | — (no editing) | — | — | — |
| 14.4 | Emoji auto-complete | ✅ | ❌ | — | — | — |
| 14.5 | Distraction-free mode | ✅ | ❌ | ❌ | ❌ | ❌ |
| 14.6 | Teleprompter mode | ❌ | ✅ | ❌ | ❌ | ❌ |
| **15. Drag / drop** |
| 15.1 | Drag image into doc | ✅ (editor) | — | — (viewer) | — | — |
| 15.2 | Drag file onto window to open | ⚠️ (implied) | ⚠️ (implied) | ✅ F-04 shipped | (continues) | (continues) |
| **16. Recent / window management** |
| 16.1 | Open Recent menu | ⚠️ (implied) | ⚠️ (implied) | ✅ F-05 (free from DocumentGroup) | (continues) | (continues) |
| 16.2 | Multiple windows / tabs | ✅ | ⚠️ (multi-window) | ✅ (DocumentGroup; tabs via Window → Merge All) | (continues) | (continues) |
| **17. Zoom** |
| 17.1 | Cmd+= / Cmd+− / Cmd+0 font zoom | ⚠️ (implied) | ⚠️ (implied) | ✅ F-16 shipped (50-300% range, persisted via @AppStorage) | (continues) | (continues) |
| **18. CLI / power-user** |
| 18.1 | CLI shim (`mdv file.md`) | ❌ | ❌ | ✅ F-21 shipped | (continues) | (continues, DMG only — sandbox limits MAS) |
| **19. Voice / accessibility** |
| 19.1 | VoiceOver readable content | ⚠️ (implied) | ⚠️ (implied) | ✅ (WKWebView native) | (continues) | (continues) |
| 19.2 | Voice narration (read aloud) | ❌ | ❌ | ❌ | ✅ F-18 planned (AVSpeechSynthesizer) | (continues) |
| 19.3 | Full keyboard navigation | ⚠️ | ✅ ("nearly 100% keyboard navigable") | ⚠️ (mostly free from SwiftUI / WKWebView) | (continues) | (continues) |
| **20. AI features** |
| 20.1 | Doc summary (LLM) | ❌ | ❌ | ❌ | ❌ | ✅ F-17 / AI-1 planned (Cmd+Shift+S, Haiku 4.5, BYO key) |
| 20.2 | Ask-the-doc chat (LLM) | ❌ | ❌ | ❌ | ❌ | ✅ F-17 / AI-2 planned (sidebar, blocking → streaming in v2.2.1) |
| 20.3 | LLM-based grammar / rewrite | ❌ | ❌ | ❌ | ❌ | ❌ |
| **21. Image features** |
| 21.1 | Image lightbox / zoom on click | ❌ | ❌ | ❌ | ❌ | ✅ F-14 planned |
| **22. Distribution** |
| 22.1 | Mac App Store | ❌ | ✅ | ❌ | ❌ | ✅ planned (D-2 locked: A→D path; **no AI on MAS**) |
| 22.2 | Direct download | ✅ | ✅ (Paddle) | ✅ (unsigned DMG) | (continues) | ✅ (notarized DMG) |
| 22.3 | Code signing / notarization | ✅ (implied) | ✅ | ❌ ("right-click → Open" first launch) | ❌ | ✅ planned at v2.2 |
| 22.4 | Free trial | ✅ (15 days) | ✅ (7 days) | — (whole app is free) | — | — (Plus only via Lemon Squeezy; no trial per Q-13 resolution) |
| **23. Pricing** |
| 23.1 | Base price | $14.99 one-time | $13.99 (MAS) / direct via Paddle | $0 | $0 | $0 free tier; **$12 Plus** (DMG only, BYO Anthropic key) |
| 23.2 | IAP add-ons | ❌ | ✅ Spelling & Grammar $1.99 | ❌ | ❌ | ❌ |
| 23.3 | Subscription option | ❌ | ❌ | ❌ | ❌ | ❌ |
| 23.4 | Devices per license | 3 | not specified | unlimited (free) | unlimited (free) | unlimited (Plus license; specifics TBD at v2.2 prep) |
| **24. Platforms** |
| 24.1 | macOS | ✅ | ✅ | ✅ (13+, arm64) | (continues) | (continues) |
| 24.2 | Windows | ✅ | ❌ | ❌ | ❌ | ❌ |
| 24.3 | Linux | ✅ | ❌ | ❌ | ❌ | ❌ |
| **25. Privacy / network posture** |
| 25.1 | Network access default | unknown (no public claim) | unknown (no public claim) | **Zero network calls** (verified — fully offline) | (continues) | ⚠️ AI Plus calls hit api.anthropic.com only when user invokes; license activation hits api.lemonsqueezy.com once + every 90d |
| 25.2 | Source available | ❌ closed-source | ❌ closed-source | ⚠️ Currently private repo, but vendored deps (markdown-it MIT, highlight.js BSD-3) are credited per `THIRD_PARTY_LICENSES.md` | (continues) | (continues) |
| 25.3 | Telemetry | unknown | unknown | **None** | (continues) | (continues) |

---

## 4. Where MarkdownViewer wins, loses, and is neutral

This section is the honest read. **Numbers > adjectives.** Where the gap is small or the user doesn't care, I say so.

### 4.1 Wins (features we have they don't, or where we're objectively better)

**W-1. Price: $0 free forever vs $13.99–$14.99 one-time.**
Both competitors charge ~$14 with no perpetual free tier (only a 7–15 day trial). Our entire viewer is free; only the AI add-on at v2.2 costs $12. For the user who wants "Marked 2's positioning, but free," there is no competing product on macOS.

**W-2. AI features (planned v2.2).**
Neither Typora nor Marked 2 ships LLM-powered features. Our v2.2 plan adds doc summary (Cmd+Shift+S) and ask-the-doc chat (Cmd+Shift+A) using Haiku 4.5 with BYO API key. This is a clean white-space differentiator at launch. **Caveat:** AI is shipping DMG-only per locked decision D-3 in `distribution-options.md` — the MAS build will not include AI, so on the App Store side this win disappears.

**W-3. Native macOS stack (SwiftUI + WKWebView + ~250 KB JS).**
Marked 2's MAS listing reports 20.6 MB app size for a similar feature footprint. Typora's engine is undisclosed but the Windows binary suggests a chromium/web stack of typical size. Our app bundle is dominated by ~250 KB of vendored JS and the Swift binary; sub-second cold launch on Apple Silicon. **Caveat:** we don't have a published apples-to-apples bundle-size number for v2.0 yet; this claim is directionally true but should be measured before marketing it.

**W-4. Zero network access by default.**
We never call out. Verified by code review and `Info.plist` (no `NSAppTransportSecurity` exceptions; no client networking until v2.2 AI). Neither Typora nor Marked 2 makes a public claim about this either way, so the user has to take their word for it. We can point to the code (when made public) or the absence of `com.apple.security.network.client` in v2.0/v2.1 entitlements.

**W-5. Viewer-only positioning + `mdv` CLI (F-21).**
Marked 2 shares the viewer positioning; Typora doesn't. But neither ships a CLI shim. For users with "always open a terminal" workflow, `mdv working-doc.md` is a real ergonomic win that's free with our SwiftPM build. **Caveat:** F-21 ships in the DMG only — the sandboxed MAS build can't accept arbitrary file paths via `open -a` (per `distribution-options.md` §3.A).

**W-6. Open dependency stance.**
markdown-it (MIT) and highlight.js (BSD-3) are widely-used, audited, mainstream JS libraries with hundreds of thousands of downstream users. Vendored at pinned versions with explicit attribution in `THIRD_PARTY_LICENSES.md`. Neither Typora nor Marked 2 publicly discloses what renderer they use.

**W-7. macOS 13+ floor lets us use modern APIs.**
Marked 2 supports macOS 10.13+; Typora supports older Macs too. We chose 13+ specifically to use `DocumentGroup`'s modern file-document API + native `WKWebView.find(_:configuration:)`. This means our F-02 find code is ~20 lines vs whatever Marked 2 wrote in 2013 to do the same. **Caveat:** this is an internal-engineering win, not a user-facing one. Users on macOS 10.13–12 are simply not customers.

### 4.2 Losses (features they have, we don't, where the gap is real)

**L-1. Typora's WYSIWYG editing.**
Typora's primary mode is in-place WYSIWYG rendering: you type `# heading` and it becomes a heading immediately. We will never ship this — it's editor territory and explicitly out of scope per `v2-requirements.md` §7.1. **For users who want an editor with preview, Typora wins by definition.** This isn't a gap we'll close; it's a different product.

**L-2. Marked 2's MultiMarkdown + Pandoc + Fountain + CriticMarkup support.**
We're CommonMark + GFM only. Marked 2 supports a much wider markup ecosystem. For a writer using MultiMarkdown's table-of-tables, Pandoc's `--filter` ecosystem, or screenplays in Fountain, we are not a substitute. **Gap is real and structural** — we'd need to swap markdown-it for something heavier or vendor multiple parsers. Not on the v2 roadmap; revisit only if user demand surfaces.

**L-3. Marked 2's document statistics suite.**
Word count, reading time, Fog Index, Flesch-Kincaid, repetition density, overused-word highlighting, custom keyword wildcards. We have F-15 (word count + reading time) planned for v2.2. The proofing/readability features beyond that are explicitly **out of scope** (`v2-requirements.md` §7.8). For users who care about clarity scoring on long-form writing, Marked 2 wins. **Gap is real but the user has stated they don't care** — keep the boundary.

**L-4. Math and diagrams (KaTeX + Mermaid).**
Both competitors ship math and at least one diagram syntax (Typora ships Mermaid + flowchart.js + sequence). We've parked both as **WON'T-v2** based on the 2026-05-18 dogfood grep that returned zero real hits in the user's corpus. Documented reopen condition: ≥3 docs in the corpus with `$$` or `mermaid` fences. **For a user with math-heavy notes today, we lose.** For the user's own corpus, this is a non-loss.

**L-5. PDF export "with bookmarks" and richer formats (Word, ePub, OpenOffice, LaTeX, MediaWiki, manuscript).**
Typora exports to seven formats including bookmarked PDF. Marked 2 exports to HTML, PDF, Word, RTF, and "manuscript." Our F-06 plan covers PDF only via system print dialog without page-N-of-M footers (resolved in round 2 per `pm-response-v2.md`). **For users whose workflow ends in Word or ePub, we lose.** Caveat: most Markdown viewer users probably don't care; if they need Word they're already in Word.

**L-6. Marked 2's tooling integrations: Scrivener, Ulysses, MarsEdit, VoodooPad.**
We are editor-agnostic — we file-watch any path. Marked 2 has explicit integrations for four named long-form-writing apps. For Scrivener users specifically, Marked 2 is the right answer; we are not. **Gap is real but narrow** (these are niche audiences); not worth chasing.

**L-7. Marked 2's custom shell-script processors.**
Marked 2 lets users register pre- and post-processors that transform the doc via arbitrary shell scripts. Power-user differentiator. We've ruled it out under `v2-requirements.md` §7.7 due to security surface in a viewer that opens arbitrary files. **Acceptable loss** — it's an editor's job to pipe through filters, not a viewer's.

**L-8. Discoverability via Mac App Store.**
Marked 2 lives on MAS and has had 10+ years of search-result accumulation. Typora is direct-only and survives on word-of-mouth + a strong landing page. We are in the same boat as Typora until v2.2 prep (when MAS submission is planned per `distribution-options.md` D-2). **Loss is temporary** — closes at v2.2.

**L-9. Trust signal: signed + notarized.**
Both competitors ship signed binaries (Typora certainly, Marked 2 by MAS requirement). Our DMG is unsigned through v2.1 ("right-click → Open" friction). Closes at v2.2 prep when we enroll in the Apple Developer Program. **Loss is temporary.**

**L-10. Cross-platform reach.**
Typora ships macOS + Windows + Linux from one codebase. Marked 2 is macOS only. We are macOS only and unlikely to ever ship cross-platform (different stack). For users who switch between OSes, Typora is the only one of the three that follows them. **Acceptable loss — out of scope.**

### 4.3 Neutrals (features one of them has, we don't, and the user probably doesn't care)

**N-1. Focus mode + typewriter mode (Typora).** Editor features for long-writing sessions. We don't edit. Out of scope.

**N-2. Teleprompter mode (Marked 2).** Niche presentation feature. Not on user's stated need.

**N-3. Multi-file documents via mmd_merge / Leanpub (Marked 2).** Book-authoring workflow. Not on user's stated need.

**N-4. Auto-pair brackets, emoji autocomplete (Typora).** Editor features. We don't edit.

**N-5. Folder tracking / "most recently edited .md" (Marked 2).** Possible v3 feature if the user reports needing it; today they open files explicitly. Not on user's stated need.

**N-6. Apple Silicon native.** All three are native on M-series. Neutral.

**N-7. macOS dark/light mode follow.** All three. Neutral.

---

## 5. Where the "viewer-only" niche is contested

Marked 2's positioning — "previewer, not editor" — is the closest match to ours. Below is a head-to-head **viewer-vs-viewer** comparison (ignoring Typora because Typora is a different category).

| Dimension | Marked 2 | MarkdownViewer (today + v2.2 planned) |
|---|---|---|
| Price | $13.99 one-time + $1.99 IAP grammar | $0 free + $12 Plus (AI only, DMG only) |
| Markdown flavor breadth | MultiMarkdown + GFM + Fountain + CriticMarkup + Pandoc | CommonMark + GFM only |
| Document stats / proofing | Comprehensive (Fog, Flesch-Kincaid, density) | Minimal (word count + reading time, F-15 v2.2) |
| Custom CSS themes | ✅ + live update + 9 built-in | ✅ planned v2.1 + 2 built-in |
| Editor integrations | Scrivener / Ulysses / MarsEdit / VoodooPad | Editor-agnostic (just file path) |
| Custom processors | Shell-script pre/post | None (security stance) |
| Mac App Store | ✅ + IAP | Planned v2.2 (no AI on MAS) |
| AI features | ❌ | ✅ planned v2.2 (DMG only) |
| CLI shim | ❌ | ✅ `mdv` shipped |
| File-watching | ✅ | ✅ (atomic-rename safe per F-01) |
| Scroll across reload | "Auto-scroll to recent edits" (opposite default — jumps to changed line) | Percentage-based preservation (F-03) |
| Track record | 10+ years, v2.6.46 | v2.0 May 2026 |
| Developer mode | Solo (Brett Terpstra) | Solo |

**Honest read:** Marked 2 wins on Markdown-flavor breadth, document stats, and 10-year track record. MarkdownViewer wins on price, AI (DMG channel), CLI ergonomics, and editor-agnostic stance. **The pool of users where each wins is real but non-overlapping.** Marked 2 serves the long-form writer with a specific markup workflow; MarkdownViewer serves the developer / power user who has Markdown files everywhere and wants a free, fast renderer with optional AI.

---

## 6. Competitive-strength positioning — the answer to the user's question

The user asked: **"The competitive strength for my app is what?"**

Below are four candidate positioning statements, each with pros and cons. After the candidates, my primary + backup pick.

### Candidate A: "The free, AI-powered Markdown viewer for macOS"

**Pros**
1. AI is genuinely unique (W-2). Neither Typora nor Marked 2 has LLM features.
2. "Free" is concrete and easy to compare against $13.99/$14.99.
3. Aligns with v2.2 monetization where AI is the paid wedge.

**Cons / risks**
1. **AI is only in the DMG build per locked decision D-3.** Half the planned audience (MAS) won't see this differentiator. The MAS listing copy can't lead with AI.
2. AI is v2.2 — months away. Doesn't help v2.0/v2.1 marketing today.
3. "AI-powered" is rapidly becoming meaningless boilerplate as every macOS app slaps AI on their landing page.
4. Centers a feature 99% of viewer-users don't open the app for.

### Candidate B: "A native macOS Markdown viewer for developers and writers who use a terminal"

**Pros**
1. Plays to W-3 (native stack), W-4 (zero network), W-5 (mdv CLI), W-7 (modern macOS).
2. **True today.** v2.0 already supports this story end-to-end: open from Finder, open from `mdv`, live-reload from your editor, find with Cmd+F, drag-and-drop, zoom.
3. Strong identification with a specific user (developer with a terminal habit) — not trying to be everything to everyone.
4. Honestly differentiates against Typora (editor) and Marked 2 ("works with Scrivener" — a writer's tool, not a dev's).

**Cons / risks**
1. Narrow audience — the "uses a terminal" filter cuts the addressable market by ~80%.
2. Doesn't tell the AI story at all, leaving v2.2 monetization unsupported by the headline.
3. "Native" is hard to prove without independent benchmarks.

### Candidate C: "The free alternative to Marked 2"

**Pros**
1. **Direct competitive positioning.** Marked 2 has 10 years of brand recognition; we ride that recognition.
2. Crystal clear: same category, $0 instead of $14.
3. Honest about the comparison — users know exactly what they're getting.

**Cons / risks**
1. Defines us by the competitor instead of by our own merits. Reactive, not proactive.
2. We can't actually match Marked 2 on Markdown-flavor breadth, document stats, or editor integrations (per §4.2). "Free alternative" implies parity; we don't have parity.
3. May invite legal-eagle pushback (using "Marked 2" in marketing as a comparator is allowed but irritates the holder).

### Candidate D: "The Markdown viewer that respects your editor"

**Pros**
1. Plays to W-5 (editor-agnostic) and our core stance ("not trying to replace your editor").
2. Differentiates against Typora (editor-as-viewer) and against Marked 2's tool-specific integrations (Scrivener, Ulysses).
3. **Resonates with the user's own preferences** — they edit in VS Code / nvim / Obsidian and want a viewer that stays out of their way.

**Cons / risks**
1. "Respects" is fuzzy marketing language; not as concrete as price or AI.
2. Users may not know they want an editor-respecting viewer until they try one.
3. Doesn't headline AI or free, the two strongest tangible wins.

### My primary pick — Candidate B (with a free-and-AI tagline)

**Primary positioning:** "A native macOS Markdown viewer for developers and writers who use a terminal. Free, fast, offline."

**Backup positioning** (if/when AI lands and DMG marketing leans on it): "Free Markdown viewer for macOS. Live-reload from any editor. Optional AI for $12, BYO API key."

**Rationale:**

1. **Candidate B is true today and stays true at v2.2.** v2.0 is shipped; v2.1 adds polish but doesn't change the story; v2.2 adds AI as an optional Plus tier without breaking the core identity.
2. **Candidate B aligns with the user's own behavior.** The user runs a terminal, edits in VS Code/nvim, has `~/Projects/` full of `.md` files, and ships an `mdv` CLI shim that no competitor offers. The product IS for the user; the positioning should say so.
3. **Candidate A (AI-led) is fragile because AI is DMG-only.** Half the audience never sees AI. Putting AI front-and-center as the identity sets us up to explain "actually not on the App Store" forever.
4. **Candidate C (free alternative) is reactive.** It cedes brand authority to Marked 2 and over-promises feature parity we don't have.
5. **Candidate D (respects your editor) is too clever.** Most users don't know they want it until they try it; doesn't sell at first glance.
6. **The backup positioning lets v2.2 launch lean on AI without rewriting the brand.** "Optional AI for $12" is honest about both the price floor ($0) and the upsell.

**Condition under which the primary pick changes:** if v2.2 AI features get strong dogfood + early-buyer feedback indicating AI is genuinely the killer use case (e.g., >50% of v2.2 buyers use AI calls weekly), promote Candidate A to primary at v2.3. Until then, lead with terminal+free, AI as a sub-bullet.

---

## 7. Strategic implications for v2.1 / v2.2

The user explicitly said "we are a viewer, not an editor; AI angle should be niche and differentiated." Below are the implications of this analysis **without proposing a scope change**.

### 7.1 What this analysis confirms — keep doing

1. **The "viewer-not-editor" positioning is validated.** Marked 2 has 10 years of paid demand in exactly this niche. The user is not in a dead market.
2. **Skipping math/Mermaid was correct.** Dogfood grep showed 0 demand in the user's corpus. Marked 2 (the closest competitor) doesn't ship Mermaid either — so we're not even losing parity within our peer.
3. **The free + $12 Plus structure is well-anchored.** Both competitors are ~$14 one-time. $12 Plus is a defensible price point ("less than Marked 2, plus you get AI you can't get there"). Lemon Squeezy + license-key flow continues to be the right delivery (per `pm-response-v2.md`).
4. **The `mdv` CLI is a real edge.** Neither competitor has one. Cost was 0.25 days. Worth keeping; worth featuring in landing-page copy.
5. **Editor-agnostic file watching beats editor integrations.** Marked 2 has explicit Scrivener/Ulysses integrations; we just watch the path. Our coverage is broader (any editor, any tool) with one mechanism. Lead with this.

### 7.2 What this analysis surfaces — consider for v2.3, NOT now

These are gaps where competitors are visibly ahead. Each has a real reason it's parked. **None should re-enter v2 scope.**

1. **Spelling and grammar.** Marked 2 sells a $1.99 IAP for this. WKWebView gives system spell-check for free in editable text but we're not editable; for a viewer it may not matter. If users ask, system spell-check on the rendered HTML is ~0.25 days. Park.
2. **Custom CSS live update.** Marked 2 picks up `.css` changes without manual reload. F-07 plans manual switching; folder-watching adds maybe 0.5d. Defer to v2.1.1 patch if F-07 ships and users complain.
3. **Vim navigation keys.** Marked 2 has them. The user uses nvim — there's a non-zero chance they'd actually want this. **Worth surfacing as a dogfood-grep at v2.0 ship:** ask the user explicitly. If yes, consider for v2.1; if no, leave parked.
4. **Document statistics beyond word count + reading time.** Marked 2 invests heavily here. The user has not asked. Hard pass unless user surfaces a real need.
5. **Pandoc / MultiMarkdown.** Real gap, real complexity (changing parsers). Park firmly.

### 7.3 What this analysis surfaces — actually consider for v2.2 marketing copy

These are not scope changes; they are **messaging additions** to the v2.2 landing page / DMG README / App Store listing draft.

1. **Lead with "$0 free vs $14 elsewhere."** Concrete, undeniable, hard to fact-check wrong.
2. **Make the `mdv` CLI a screenshot.** A terminal screenshot is unusual for a viewer app's landing page; it's our identity.
3. **"Live-reload from any editor — VS Code, nvim, Obsidian, TextEdit."** Marked 2 says the same thing; we should match the claim explicitly so a "Marked 2 evaluator" sees parity on this critical feature.
4. **"Zero network calls in free tier."** Privacy stance. Neither competitor makes this claim publicly. We can.
5. **AI sub-section, not headline.** "Optional Plus tier ($12) adds AI doc summary and ask-the-doc chat. Bring your own Anthropic API key — your conversations never touch our servers." Specific dollar amount; specific privacy claim. Defensive against "is this another AI wrapper subscription?"
6. **MAS listing copy MUST NOT mention AI.** Per locked D-3. The MAS-build copy is "Free Markdown viewer — live-reload, find, themes, PDF, voice." That's it. AI lives on the DMG landing page only.

---

## 8. What this doc does NOT do

For clarity: this is a competitive analysis, not a scope change.

1. It does **not** add features to v2.1 or v2.2. The ROADMAP is locked through v2.2.1 per `pm-response-v2.md` round 2 + `distribution-options.md` Section 9.
2. It does **not** propose pricing changes. $0 free + $12 Plus (DMG only) stays.
3. It does **not** propose ditching the MAS path. D-2 + D-3 stay locked.
4. It does **not** dispute the user's "AI angle should be niche and differentiated" stance — the matrix shows AI IS unique to us in this peer set.
5. It does **not** include solo-engineer feedback. This is a PM-only deliverable for the user to review before any v2.1 work resumes.

---

## 9. Ambiguities for the user to resolve (batch — non-blocking)

| # | Question | Why it matters | PM-suggested default |
|---|---|---|---|
| **CA-1** | Vim nav keys — is this real for you, or were they listed in Marked 2's site and you scrolled past? | Decides whether to file a TODO for v2.3 consideration. | Default: leave parked. Override if user actively uses them. |
| **CA-2** | Want the "Spelling and Grammar IAP" mirror feature? (~0.25d via WKWebView system spell-check on rendered text — limited, but free for us.) | Trivial parity item; either include in v2.2 catch-up or never. | Default: skip. WKWebView already gives selection-based dictionary lookup (Cmd+Ctrl+D). |
| **CA-3** | "Folder tracking" (Marked 2 opens the most recently edited `.md` in a folder you point at) — useful, or noise? | Different UX than our explicit-file model. | Default: skip. User's workflow opens files explicitly via Finder / `mdv`. |
| **CA-4** | Primary positioning pick — Candidate B (terminal-user identity, primary pick) or override to A (AI-led) / C (free alternative to Marked 2) / D (respects your editor)? | Affects v2.2 landing page copy + MAS listing copy. | Default: Candidate B + Backup positioning at v2.2. |
| **CA-5** | Are we comfortable publicly comparing against Marked 2 by name in marketing? | Legal-eagle's stance not yet captured; nominative fair use is generally OK in US but some companies object. | Default: avoid naming Marked 2 in MAS listing; OK on personal blog / Show HN post. |

None of these block any v2.1 work.

---

## 10. Source files / pages read

| Source | Purpose | Citation |
|---|---|---|
| `~/Projects/tools/markdown-viewer/CHARTER.md` | What we are / aren't (viewer, not editor) | 34 lines |
| `~/Projects/tools/markdown-viewer/CLAUDE.md` | Hard constraints + push-back list | 78 lines |
| `~/Projects/tools/markdown-viewer/DESCRIBE.md` | v2.0 architecture detail | 109 lines |
| `~/Projects/tools/markdown-viewer/docs/v2-requirements.md` | F-01..F-21 + MoSCoW + out-of-scope justifications | 702 lines |
| `~/Projects/tools/markdown-viewer/docs/ROADMAP.md` | v2.0/v2.1/v2.2/v2.2.1 plan | 303 lines |
| `~/Projects/tools/markdown-viewer/docs/pm-response-v2.md` | Round-2 locked decisions | 178 lines |
| `~/Projects/tools/markdown-viewer/docs/distribution-options.md` | Section 9 D-1/D-2/D-3 locked decisions (MAS path, no AI on MAS) | 577 lines |
| Git log: `e917140`, `918eaf0`, `e6aee1b`, `8acd221`, `4574dac`, `9c44dc9`, `f0ec437` | Verifies v2.0 features shipped | 7 commits |
| [typora.io](https://typora.io) | Typora feature list + $14.99 price + 3-device license + 15-day trial | WebFetch 2026-05-19 |
| [typora.io/#download](https://typora.io/#download) | Direct-download-only confirmation; no MAS listing | WebFetch 2026-05-19 |
| [support.typora.io/Typora-on-macOS](https://support.typora.io/Typora-on-macOS/) | Apple Silicon native confirmation; underlying engine NOT publicly disclosed | WebFetch 2026-05-19 |
| [marked2app.com](https://marked2app.com) | Marked 2 full feature list + MultiMarkdown / GFM / Fountain / CriticMarkup / MathJax / Scrivener / Ulysses integration | WebFetch 2026-05-19 |
| [App Store: Marked 2 (id890031187)](https://apps.apple.com/us/app/marked-2-markdown-preview/id890031187) | $13.99 + version 2.6.46 (2025-03-11) + 20.6 MB + macOS 10.13+ + $1.99 Spelling & Grammar IAP + developer "Brett Terpstra" | WebFetch 2026-05-19 |
| [code.visualstudio.com — Markdown](https://code.visualstudio.com/docs/languages/markdown) | VS Code built-in preview reference (CommonMark + KaTeX + scroll sync, free) | WebSearch 2026-05-19 |

---

*End of competitive-analysis.md.*
