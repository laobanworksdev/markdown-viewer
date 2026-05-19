# Markdown Viewer v2 — Requirements (PM doc)

**Author:** PM
**Date:** 2026-05-18 (round 2, post-solo-feedback)
**Audience:** solo-engineer (primary reviewer), user (final approver)
**Status:** DRAFT v2 — incorporates solo-engineer feedback v1. See `pm-response-v2.md` for the round-by-round delta.

**Round-2 changes from round 1 (summary):**
- F-11 KaTeX, F-12 Mermaid → **WON'T-v2** (was COULD). Reopen condition documented.
- AI-3 voice narration → **F-18 (free in v2.1)**. Removed from AI section.
- F-17 AI-2 chat → **blocking-with-spinner in v2.2.0; streaming in v2.2.1.**
- Pricing model → **Lemon Squeezy built-in license API + 90-day cached phone-home** (was Ed25519 + Cloudflare Worker).
- Added **F-19** Cmd+R manual reload (v2.0 MUST), **F-20** app icon (v2.2 MUST), **F-21** `mdv` CLI shim (v2.0 SHOULD).
- F-03 scroll preservation: **percentage-based**, not pixel scrollY.
- F-10 TOC: **path (a) — SwiftUI NavigationSplitView**, locked.
- F-08 built-in themes: ship **2** at v2.1 (was 4); add more once F-07 contract proven by external theme.
- F-PRICE-1: drop "Deactivate" button from v2.2 acceptance (defers ~0.5d).
- Calendar realism: +30% per solo's read. v2.0 4-5w, v2.1 4-5w, v2.2 5-6w, v2.2.1 1-2w. Total 10-13w.

---

## 0. User's verbatim ask

> "engage PM to view app store mark2 application features and create a roadmap for this app — we need most important features that that supports as well as Typora. Need to build what they have. create next version requirement statement. let the solo engineer view and provide feedback and then PM repropose to solo engineer. Then, solo engineer start the work.
>
> One big feature I MUST have is the 'real time' updates — when the file gets edited, the viewer should show the updates. currently typora has it. I bet vscode or other major ide has it too.
>
> and, hints to PM: think about customization. think about some UI tricks. drag / drop?
>
> last thing to think about is AI. AI is great BUT need to find a niche or find an angle to provide a dedicated value to this small market, with minimal potential token usage. Well, think about the pricing model as well. if we do AI, then we do a plus version too."

Three explicit demands: (1) feature parity with Marked 2 + Typora's most important capabilities, (2) live reload on external edit is a hard MUST, (3) think about customization, drag-drop, AI, and a pricing model that includes a "plus" tier if AI is in.

---

## 1. Where v1 sits today (one paragraph)

v1 is a 4-file SwiftUI app that wraps WKWebView around vendored markdown-it + highlight.js. It opens a `.md` from Finder, renders it, follows system dark/light. No editing, no live reload, no find, no print, no themes, no AI. Ships as an unsigned DMG. v1's CHARTER explicitly listed math/Mermaid/file-watching/print/find-in-page/icon/signing as non-goals — v2 relaxes most of them, but the "no editing" line stays bright. This is a **viewer**. Adding an editor is a different product.

---

## 2. Competitor evidence (anchored)

### Marked 2 — $13.99 Mac App Store / $14.99 direct ([marked2app.com](https://marked2app.com), [App Store](https://apps.apple.com/us/app/marked-2-markdown-preview/id890031187))

- Positioning: **"Marked is a previewer (*not an editor*) for Markdown."** This is exactly our positioning, validating the niche exists.
- Live preview from any external editor — "picks up your changes every time you save in any editor, scrolls to your most recent edit automatically."
- Export to HTML / PDF / RTF / Word; self-contained HTML.
- Document analytics: word count, reading time, Fog Index, Flesch-Kincaid, repetition/density highlighting, overused-word detection.
- Auto TOC with typeahead jump; collapsible sections; Vim-style nav.
- Custom CSS + 9 built-in styles (GitHub among them); live CSS updates.
- MultiMarkdown, GitHub Flavored, Fountain, CriticMarkup, MathJax, custom shell-script processors.
- Scrivener / Ulysses / MarsEdit integration.
- IAP for "Spelling and Grammar" at $1.99 — **proof a viewer-only app can sustain a paid add-on tier.**

### Typora — $14.99 one-time, up to 3 devices, 15-day trial ([typora.io](https://typora.io))

- Positioning: WYSIWYG editor with seamless live preview, no separate preview pane.
- Math via MathJax (mhchem, AMSmath, BBox), auto-numbered equations.
- Diagrams via Mermaid (flowchart/sequence/Gantt/radar/treemap) + flowchart.js + SVG sequence.
- Tables with mouse-drag resize, quick reorder.
- ~100 languages syntax highlighting.
- File tree + articles list + outline panel.
- Custom CSS, `[TOC]`, internal header links, CJK, emoji auto-complete, focus + typewriter modes.
- Export to PDF (with bookmarks), DOCX, OpenOffice, LaTeX, MediaWiki, ePub.
- Word/char/line count, reading time, auto-pair brackets, footnotes, YAML front matter.

### VS Code Markdown preview ([VS Code docs](https://code.visualstudio.com/docs/languages/markdown))

- Updates instantly as you type — but VS Code is the editor too; it doesn't file-watch, it observes the buffer.
- Bidirectional scroll sync (preview ↔ editor).
- Double-click element in preview → jumps editor cursor.
- We can't borrow the buffer-observation trick (we're not the editor). We must file-watch.

### What this tells us

- **Both top competitors are $14-15 one-time, no subscription.** This is the market anchor.
- **Marked 2's positioning is identical to ours** ("previewer, not editor") and it has survived 10+ years at $13.99 with paid IAP — there is real demand.
- **Typora's heavy features (Mermaid, math, file tree) are editor-territory** — they're for someone authoring docs. A viewer doesn't need them on day one.
- **Neither has integrated AI.** This is the user's "angle." A small but real differentiation surface.

---

## 3. Pricing model recommendation (BEFORE features, because it gates AI scope)

### Constraint that drives everything

The app is distributed as an **unsigned DMG outside the Mac App Store**. This means:
- ❌ No in-app purchase (StoreKit requires App Store distribution).
- ❌ No subscriptions on-device.
- ❌ No "free in App Store, pay to unlock" via IAP.
- ✅ External one-time purchase (Lemon Squeezy) + license key.
- ✅ License validated via **Lemon Squeezy's built-in license API** (one phone-home on activation; result cached in Keychain for 90 days; re-verify on next launch after expiry).

### Recommended model: One-time purchase, free tier + Plus tier, BYO API key for AI

| Tier | Price | Includes |
|---|---|---|
| **Free** | $0 | All non-AI features. Live reload, themes, TOC, PDF export, find, drag-drop, scroll preservation, code copy, word count — the whole viewer. Forever free, no degradation, no nag. |
| **Plus** | **$12 one-time** (anchored below Typora/Marked 2 to undercut on price-of-entry) | Unlocks the AI menu (F-17). User supplies their own Anthropic API key in Preferences. Lifetime updates within the v2.x line. v3 is a separate purchase or upgrade discount, TBD. |

**Pros**
1. **Zero ongoing infra cost.** No hosted LLM relay, no key management, no abuse risk. User pays Anthropic directly.
2. **Honest pricing.** $12 is real money for the viewer's tier; AI cost is whatever the user makes of it (a single doc summary is ~$0.002 at Haiku 4.5 rates). No hidden token cap, no fair-use claim to enforce.
3. **License-key delivery is trivial.** Lemon Squeezy emits a key on purchase. App calls Lemon Squeezy's `/v1/licenses/activate` once; caches the "valid" result in Keychain for 90 days. Total Swift code: ~40 LOC.
4. **Free tier is durable.** Existing users / early adopters never feel pushed. The "viewer" market stays accessible.
5. **Anchored below competitors.** $12 < $14-15 makes the "I might as well buy it" math easier.

**Cons / risks**
1. **BYO API key is a friction step.** Some users will bounce off "go get an Anthropic API key and paste it here." Mitigation: in-app deep-link to console.anthropic.com with a 60-second how-to.
2. **No recurring revenue.** A one-time $12 sale per user is the entire monetization. Compounds slowly.
3. **Cached phone-home is online-required on first activation.** A user activating offline on day-1 cannot. Mitigation: re-validation only happens at 90-day boundary; in steady state the app is fully offline.

   **Revocation works** for leaked keys (Lemon Squeezy can disable a key; the next 90-day re-check fails and the seat deactivates). This is a real win vs the round-1 Ed25519-only model where revocation was impossible without rotating the public key.
4. **macOS Gatekeeper friction stays.** "Right-click → Open" the first time. Out of scope — see CLAUDE.md.

### Alternative considered: Hosted AI with subscription

Reject. Requires dev to (a) run a relay server, (b) pay per-call to Anthropic, (c) build subscription billing + dunning, (d) handle abuse. Solo-dev cost-of-operations is wildly disproportionate for this market size.

### My net recommendation

**Free + $12 Plus + BYO API key**, fulfilled via **Lemon Squeezy** (better TOS than Gumroad for international sellers, automatic VAT/Merchant-of-Record handling, built-in license-key issuance + activation API). License validation: one phone-home call on activation, result cached in Keychain for 90 days. Ship Plus alongside v2.2; v2.0 and v2.1 are free-only.

**Future hardening if piracy becomes real:** upgrade to Ed25519-signed offline tokens via a small Cloudflare Worker on the purchase webhook. Estimated trigger: ≥3 leaked keys observed in the wild, OR >1% of activations failing the geo-heuristic. Not built speculatively. At <100 sales the Lemon Squeezy API is sufficient.

**Condition under which this changes:** if dogfooding shows AI is wildly more useful than expected and users ask for hosted/managed mode → consider adding a "Pro-hosted" tier at $5/month for users who don't want to manage their own key. Don't build it speculatively.

---

## 4. AI features — Niche & token budget (F-17 expanded — 2 features, voice moved to F-18 free)

### Frame

User said: "AI is great BUT need to find a niche or find an angle to provide a dedicated value to this small market, with minimal potential token usage." Three rules I'm enforcing:

1. **Viewer-frame only.** Anything that requires editing the source file is out. (No "rewrite this paragraph," no "fix grammar in place.")
2. **User-invoked, never auto-triggered.** A doc opening doesn't fire AI. Every call is a deliberate menu-pick or shortcut.
3. **Hard token cap per call.** ≤16K input (trimmed/truncated past that with a status message), ≤512 output for summary-style features.

### Reference cost (Claude Haiku 4.5: $1/M input, $5/M output, [source](https://devtk.ai/en/models/claude-haiku-4-5/))

| Call type | Input | Output | Cost / call |
|---|---|---|---|
| Summarize doc (3 bullets) | 4K | 200 | $0.005 |
| Q&A on doc (one question) | 6K | 400 | $0.008 |
| Glossary extraction | 8K | 500 | $0.010 |
| Translate doc (3K input) | 3K | 4K | $0.023 |

A power-user firing 20 calls/day spends ~$0.20/day = $6/month. Most users will be <10 calls total per month. **The BYO model is honest because the cost is genuinely low.**

### Picked 2 AI features (with rationale)

Round-1 had 3 "AI" features but solo-engineer correctly called out that AVSpeechSynthesizer-based narration is not LLM-based and re-labeling it as "AI" was marketing fluff. Voice narration is now **F-18 (v2.1 free feature)**.

#### AI-1 — Doc summary (Cmd+Shift+S)

- **What:** Reads the current rendered doc, calls Haiku 4.5 with the markdown source and the prompt "Summarize this document in 3-5 bullets, optimized for skim-reading," shows the bullets in a non-modal panel docked to the right.
- **Why viewer-frame:** You're reading a long doc and want the TL;DR before committing. This is exactly what a *viewer* user wants. Doesn't modify the file.
- **Why niche:** Marked 2 has document statistics (word count, reading level) but no LLM summary. Typora has neither.
- **Token est:** ~4K in / ~200 out, $0.005/call.

#### AI-2 — Ask anything about this doc (sidebar chat)

- **What:** A right-side panel with a text input. User asks a question; we send `[full doc] + [user question]` to Haiku; render response in markdown. Conversation history kept in memory only (no disk). Cmd+Shift+A toggles panel.
- **Why viewer-frame:** Long technical docs, contracts, papers — "where does it say X?" / "what does section 3.2 imply?" The reader is consuming, not authoring.
- **Why niche:** This is the killer feature. Neither Marked 2 nor Typora has it. Closest analogue is ChatGPT with file upload, but the workflow is clunky — copy doc, switch app, paste, ask. Here it's inline against the doc you're already reading.
- **Token est:** ~6K in / ~400 out, $0.008/call.
- **v2.2.0 transport: blocking response + spinner.** Single `URLSession.shared.data(for:)` call. User sees a spinner; response renders when complete. Acceptable for 1-5 sec responses on Haiku.
- **v2.2.1 transport: streaming SSE.** Promote to streaming once v2.2.0 is in the wild and AsyncSequence/cancellation edge cases can be designed against real usage. ~2 days of SSE work, deferred.

### Rejected AI candidates (with reasons)

| Candidate | Reject reason |
|---|---|
| Smart link preview (hover URL → AI 1-liner) | Requires fetching the link's content (network, slow, viewer should be offline) or AI hallucinates about URLs it hasn't seen. |
| Reading-level / clarity flag | Flesch-Kincaid is a 10-line local computation. No LLM needed. Possibly include as a non-AI free-tier feature. |
| Glossary extractor | Useful but overlaps with AI-2 (you can just ask "what jargon is in here?"). Cut for v2.2; revisit in v2.3 if AI-2 doesn't satisfy. |
| Translate doc | Useful but unbounded output size = unbounded cost. Defer until we see how AI-2 plays out. |

### Open questions for solo-engineer (AI)

- **Q-AI-1:** Should the API key live in Keychain or a plain pref file? Keychain is correct but adds Swift complexity. PM rec: Keychain. Solo's call.
- ~~**Q-AI-2:** Streaming vs. blocking response for AI-1/AI-2?~~ **RESOLVED in round 2:** blocking + spinner for v2.2.0; streaming in v2.2.1 sub-milestone. Per solo's pushback.
- **Q-AI-3:** AI-2 (chat) — do we want a per-doc conversation history that persists to disk, or session-only? PM recommendation: session-only for v2.2, persist in v2.3 if asked.
- **Q-AI-4 (new):** BYO API key first-run flow — solo proposed a 3-step wizard ("Open Anthropic Console" → "Paste key here" → "Run a test summary"). PM concurs; lock in for v2.2 ship checklist.

---

## 5. Functional requirements

Note on the table: each `F-NN` is the **PM's recommended MoSCoW**. Solo-engineer is invited to push back on any of them, especially the MUSTs vs SHOULDs split.

---

### F-01 — Live reload on file change

- **What:** When the file on disk changes (saved by external editor, e.g. VS Code / nvim / Obsidian), the viewer re-reads the file and re-renders within 500ms. No user action required.
- **Why:** User's explicit MUST. Marked 2's flagship feature ("picks up your changes every time you save"). Without this, the app remains a toy.
- **MoSCoW:** **MUST** (v2.0)
- **Effort:** M (~4-6 days, round 2 bump per solo). `DispatchSource.makeFileSystemObjectSource(fileDescriptor:eventMask:[.write,.extend,.delete,.rename], queue:)` — solo's preferred API over FSEvents (lighter, single-file). Debounce 100ms. Re-read, re-render, preserve scroll (F-03 dependency). **+1d budgeted for editor matrix test** (VS Code, nvim, Obsidian, TextEdit, BBEdit).
- **Risk:**
  - **Atomic-rename pattern** (vim/VS Code: write tempfile, rename over original) fires `.delete` on the old fd. Must re-`open()` by path on every rename event, not on first open only. Solo flagged this as the #1 silent-fail mode.
  - File renamed/moved/deleted (by user): handle gracefully (show "file no longer at original path, last rendered at HH:MM").
  - Big files (>1MB): debounce harder so saves don't pile up.
  - **Render-throw on reload:** if `render.js` throws on the new content (malformed doc mid-edit), viewer currently blanks. **New requirement:** preserve last-good HTML; show non-blocking yellow banner "Render error — showing last good version. Save again to retry."
- **Acceptance criteria:**
  - Open `test.md` in viewer. Edit it in another editor (VS Code, nvim, TextEdit), save. Within 500ms, viewer shows new content.
  - Edit + save 5x in a row over 2 seconds — viewer renders the final state, not all 5.
  - Atomic-rename save (vim `:w`, VS Code save) — viewer re-opens by path after rename, content updates.
  - Rename file in Finder while viewer is open — viewer shows a one-line non-blocking status; doesn't crash.
  - Scroll position preserved across reload (F-03).
  - Mid-edit malformed doc (e.g. unclosed code fence) — viewer keeps last good render and shows yellow banner.
  - Toggle in Preferences: "Watch file for changes [on/off]" defaulting to ON.
- **Open questions:**
  - **Q-01-a:** What's the failure mode UX when file is deleted? PM rec: small banner "File no longer exists at <path>" with a "Reopen…" button. Solo's call.

---

### F-02 — Find in page

- **What:** Cmd+F opens a find bar at the top of the window. Types-to-search. Shows match count ("3 of 17"), Enter / Shift+Enter for next/prev, Esc to close. Highlights current match yellow, others light yellow.
- **Why:** Table stakes. CHARTER said "defer until WKWebView wiring is ≤20 lines" — WKWebView 13+ exposes `findString(_:configuration:completionHandler:)` natively. It's now <50 lines including the SwiftUI bar.
- **MoSCoW:** **MUST** (v2.0)
- **Effort:** S (1-2 days). Native WKWebView API.
- **Risk:** Minor. The native API is solid; UI work dominates.
- **Acceptance criteria:**
  - Cmd+F focuses search box. Typing 1 char highlights matches. Match count displays.
  - Enter advances. Shift+Enter goes back. Wraps around at ends.
  - Esc closes; clears highlight.
  - Find state survives file reload (F-01).
  - Case-insensitive by default; case-sensitive toggle in the bar.
- **Open questions:** None.

---

### F-03 — Scroll position preservation on reload

- **What:** When the file reloads (F-01 or Cmd+R), the viewer maintains the user's scroll position rather than jumping to the top.
- **Why:** Without this, F-01 is annoying — every save while reading a long doc bounces you to the top.
- **MoSCoW:** **MUST** (v2.0, dependency for F-01)
- **Effort:** S (1 day).
- **Approach (round 2, per solo):** Capture **scroll percentage** (`scrollY / (scrollHeight - innerHeight)`) before re-render; restore after by computing the new pixel position from the new heights. One-line implementation each side. Handles doc shortening automatically via clamp.
- **Why not pixel scrollY (round-1 approach):** pixel values go stale on font reflow (theme switch, zoom, content delta). Percentage is reflow-robust.
- **Why not heading-anchored:** solo flagged round-1 Q-03-a as overthinking — percentage works fine. Heading-anchored is a v3 polish if percentage ever feels off.
- **Risk:** If doc shortens drastically (>80%), the percentage will park user near the new bottom — acceptable; user re-scrolls.
- **Acceptance criteria:**
  - Open long doc, scroll to ~50%. External edit → save. Re-render keeps view at ~50% of new doc.
  - Doc shortens dramatically (delete half) → view lands near new bottom, no scroll-past-end.
  - Cmd+R (F-19) also preserves scroll percentage.
  - Theme switch (F-07) preserves scroll percentage (regression-test this once F-07 lands).
- **Open questions:** ~~Q-03-a~~ RESOLVED (percentage > pixel > heading-anchored).

---

### F-04 — Drag & drop to open

- **What:** Drag a `.md` file (or any markdown-flavored UTI) from Finder onto an open viewer window. Window switches to that file. Multiple files dropped → open each in its own window.
- **Why:** User explicitly hinted at this. Natural macOS UX. Currently must use Cmd+O or "Open With."
- **MoSCoW:** **MUST** (v2.0)
- **Effort:** S (1 day). SwiftUI `.onDrop(of:)` on the WebView container.
- **Risk:** Low.
- **Acceptance criteria:**
  - Drop one `.md` on the window → window swaps to that file.
  - Drop 3 `.md`s on the window → first one swaps in current window, other two open in new windows.
  - Drop a non-markdown file → show a one-line refusal banner, no crash.
  - Dropping a folder → open the first `.md` found in it; if none, refusal banner.
- **Open questions:**
  - **Q-04-a:** When user drops file on existing window, should it (a) replace the current doc in the window, or (b) always open in a new window? PM rec: (a) replace; macOS DocumentGroup gives Cmd+N for new window already. Solo's call.

---

### F-05 — Recent files menu

- **What:** File → Open Recent submenu with last 20 opened files. "Clear Recent Documents" entry.
- **Why:** SwiftUI's `DocumentGroup` mostly gives this for free already — DESCRIBE.md notes "recent-files menu" comes "free." May already work; verify, polish if not.
- **MoSCoW:** **MUST** (v2.0) but might just be "verify free behavior + polish."
- **Effort:** S (≤0.5 day) if free; M if we need to build it.
- **Risk:** Low.
- **Acceptance criteria:**
  - Open 5 different `.md` files over a session. File → Open Recent shows all 5.
  - Click a recent entry → opens that file.
  - "Clear Recent Documents" works.
  - Files that no longer exist on disk are greyed/removed.
- **Open questions:** None — solo to verify free behavior first.

---

### F-06 — Print / Export to PDF

- **What:** File → Print (Cmd+P) opens system print dialog with current doc rendered. "Save as PDF" from print dialog produces a PDF with reasonable margins and pagination. File → Export → PDF… is a shortcut that goes straight to PDF save.
- **Why:** Marked 2 has it. Reasonable ask for a viewer. WKWebView's `printOperation(with:)` does most of the work.
- **MoSCoW:** **SHOULD** (v2.1 — not blocking v2.0)
- **Effort:** M (2-3 days). WKWebView print API exists but `@media print` CSS needs tuning so code blocks don't overflow page width and links print as URLs.
- **Risk:** Print CSS is tedious. Page breaks across code blocks look ugly without explicit `break-inside: avoid`.
- **Acceptance criteria:**
  - Cmd+P opens system print dialog. Doc renders with margins ≥0.5".
  - "Save as PDF" produces a multi-page PDF for a 20-page doc, no content cut off.
  - Code blocks don't break across pages (use `break-inside: avoid; page-break-inside: avoid`).
  - Links print as `text (https://url)` so paper readers can find them.
  - File → Export → PDF… is a shortcut directly to "save as PDF" without dialog detour.
- **Open questions:** ~~Q-06-a (page-N-of-M footer)~~ **RESOLVED in round 2: no footer.** WebKit doesn't expose page-number callbacks cleanly; the workaround is fragile. Per solo.

---

### F-07 — Custom CSS themes

- **What:** Users drop `.css` files into `~/Library/Application Support/MarkdownViewer/themes/`. View → Theme submenu lists them by filename. Switching applies live (no reload). Includes a "Reveal Themes Folder…" menu entry to open the folder in Finder.
- **Why:** Marked 2's most-praised customization feature. Power users love it. Low complexity if we ship 1 stable CSS variable contract.
- **MoSCoW:** **SHOULD** (v2.1)
- **Effort:** M (2-3 days). Mostly a settled CSS-variable contract + file enumeration.
- **Risk:** API stability — once we ship the CSS variable contract, breaking it breaks users' themes. Document it in README.
- **Acceptance criteria:**
  - Drop `solarized.css` in themes folder. Restart app (or use "Reload Themes" menu) → it appears in View → Theme.
  - Selecting it applies styles immediately, no flicker. **Implementation:** `evaluateJavaScript` swaps the `<link>` href (don't try to hot-swap CSS variable values — brittle when a theme redefines block-level styles, per solo).
  - Last-selected theme persists across launches (app-wide).
  - "Reveal Themes Folder…" opens the folder in Finder; creates folder if missing.
  - Theme switch preserves scroll percentage (F-03 contract).
- **Open questions:** ~~Q-07-a~~ **RESOLVED: app-wide.** Solo concurs with PM round-1 rec.

---

### F-08 — Built-in theme variants

- **What (round 2, scoped down):** Ship **2** built-in themes alongside the default: GitHub (current, kept) and **one of {Paper, Sepia}** (solo picks). System Dark/Light split is preserved. All driven by the same CSS-variable contract from F-07.
- **Why scoped down from 4:** solo flagged bikeshedding cost. Two themes is enough to prove the F-07 contract works for external themes. More can ship in v2.1.x patches once a user-submitted theme validates the contract.
- **Why:** Most users won't write their own CSS; built-ins give immediate value. Validates the F-07 contract.
- **MoSCoW:** **SHOULD** (v2.1)
- **Effort:** S (1 day for 2 themes vs round-1 M of 2d for 4).
- **Risk:** Bikeshedding. Solo-engineer is the design authority; PM defers.
- **Acceptance criteria:**
  - View → Theme lists 2 built-ins (GitHub Default + Paper-or-Sepia).
  - Each looks polished in both light and dark mode.
  - Switching is instantaneous.
- **Open questions:** None — solo picks the second theme. Add more themes only if F-07 gets used (user-submitted theme is the proof point).

---

### F-09 — Code-block enhancements

- **What:** Each `<pre><code>` block in the rendered doc gets: (a) language label in top-right ("python", "rust"), (b) copy-to-clipboard button on hover, (c) optional line numbers (toggle in View menu).
- **Why:** Marked 2 has language hints + line numbers. Daily-use polish. Trivial in JS post-process.
- **MoSCoW:** **SHOULD** (v2.1)
- **Effort:** S (1 day). Pure JS post-process in `render.js`.
- **Risk:** Low.
- **Acceptance criteria:**
  - Language label shows when highlight.js detects a language; "text" otherwise.
  - Copy button copies the raw code (no syntax-highlighting HTML).
  - Hover-only visibility for copy button so it doesn't add visual noise.
  - Line numbers toggle persists across launches.
- **Open questions:** None.

---

### F-10 — Table of contents sidebar

- **What:** Optional collapsible left sidebar showing heading hierarchy (H1-H4). Click → jump to that section. Hides if doc has <3 headings. Toggle: View → Show Table of Contents (Cmd+\\).
- **Why:** Marked 2 + Typora both have it. Essential for long docs.
- **MoSCoW:** **SHOULD** (v2.1)
- **Effort:** M (2-3 days). Parse headings in JS → post array to Swift via `WKScriptMessageHandler` → render Swift sidebar in `NavigationSplitView`.
- **Approach (round 2, locked per solo):** **Path (a) — SwiftUI `NavigationSplitView`.** Reason: free keyboard nav, free accessibility, toggle persists naturally, looks native (not webpage-shaped). Path (b) (JS aside) was implicitly considered in round 1; solo correctly flagged that we must pick one — locking (a).
- **Risk:** Low.
- **Acceptance criteria:**
  - Open doc with 10 headings → sidebar shows tree, indented by level.
  - Click "Section 3.2" → smooth scrolls to that heading.
  - Current section highlighted as user scrolls (Intersection-observer in JS, posts current id to Swift).
  - Sidebar toggle persists per-window (not per-doc).
  - Keyboard arrow-up/down navigates the TOC; Enter scrolls main view.
- **Open questions:** ~~Q-10-a (200 cap vs virtualize)~~ **RESOLVED: render all headings.** SwiftUI `List` is lazy by default — no cap needed. Per solo.

---

### F-11 — Math (KaTeX) support

- **What:** Render `$...$` and `$$...$$` blocks as typeset math via vendored KaTeX. Inline + display modes.
- **Why:** Typora has it. Marked 2 has MathJax. **But:** v1's CLAUDE.md explicitly listed math as a "push back on" item. The user did NOT mention math in their ask.
- **MoSCoW (round 2):** **WON'T-v2** (was COULD round 1). Solo concurred: bundle hit + zero proven demand.
- **Reopen condition:** if the v2.0 dogfood grep (`grep -lr '\$\$\|\$[^$]*\$' ~/Projects ~/Documents/screenshots`) returns ≥3 docs with math, reopen for v2.3. Run the grep in v2.0 week 1 as a deterministic Q-01 resolver.

**Pros of including (in v2.x):**
1. Parity with Typora + Marked 2.
2. Useful for technical writers / academic notes.
3. KaTeX is faster than MathJax and ~270KB minified ([source](https://katex.org/)).

**Cons / risks:**
1. **+270KB to the JS bundle** (more than 2x our current ~246KB). First-load slows.
2. **Fonts** — KaTeX needs ~10 .woff2 font files to be vendored or it falls back to system fonts and looks bad. Pinning is real overhead.
3. **User didn't ask for it.** Adding speculative features = scope creep per CLAUDE.md.
4. **Dogfood check:** does the user actually have `.md` files with math in them? If 0%, then 0 demand.

**My net recommendation: PARKED (WON'T-v2).** Reopens only on the dogfood-grep condition.

- **Effort if reversed:** M (2-3 days to vendor + integrate + test fonts).
- **Acceptance criteria (if included):**
  - `$a^2 + b^2 = c^2$` renders inline math.
  - `$$\\int_0^1 x^2 dx$$` renders display math.
  - Macros work (e.g. `\\frac`, `\\sum`).
  - Renders in <50ms for typical doc.
- **Open questions:**
  - **Q-11-a:** Does the user have `.md` files with `$...$` math in them today? If yes → reconsider. If no → keep parked.

---

### F-12 — Mermaid diagrams

- **What:** Render \`\`\`mermaid blocks as SVG diagrams.
- **Why:** Typora has it. Some users love it.
- **MoSCoW (round 2):** **WON'T-v2.** Solo concurred — parked harder than F-11 due to severe bundle hit.
- **Reopen condition:** if the v2.0 dogfood grep (`grep -lr '^\`\`\`mermaid' ~/Projects ~/Documents/screenshots`) returns ≥3 docs with Mermaid fenced blocks, reopen for v2.3.

**Pros:**
1. Parity with Typora.
2. Cool factor for technical docs.

**Cons:**
1. **Mermaid is ~880KB to 2.6MB minified depending on version** ([source](https://github.com/orgs/mermaid-js/discussions/4314)). The "tiny" build at ~440KB drops Mindmap/Architecture/KaTeX. Either way, **3-10x our current bundle size**.
2. WKWebView + ~2MB JS = slower first render. Noticeably.
3. User didn't ask for it.
4. Mermaid syntax errors → ugly red error overlays in the doc. UX hit.
5. Dogfood check: same as F-11. Probably 0 docs with Mermaid in user's corpus.

**My net recommendation: PARKED (WON'T-v2).** Reopens only on the dogfood-grep condition.

---

### F-13 — Footnotes & task lists

- **What:** Footnotes (`[^1]` → bottom-of-doc reference) and GFM task lists (`- [ ]`, `- [x]`). Task lists are partially in v1 already (DESCRIBE.md confirms). Footnotes need `markdown-it-footnote` plugin (~3KB).
- **Why:** Cheap addition. Both Marked 2 + Typora have them. Trivial.
- **MoSCoW:** **SHOULD** (v2.1)
- **Effort:** S (0.5 day). Vendor `markdown-it-footnote` minified.
- **Risk:** Trivial.
- **Acceptance criteria:**
  - `text[^1]` and `[^1]: footnote content` → in-doc footnote with click-to-jump.
  - Backlink at bottom returns to citation.
  - Task lists render as checkboxes (already in v1, but verify after refactor).
- **Open questions:** None.

---

### F-14 — Image lightbox / zoom

- **What:** Click any `<img>` in the doc → modal lightbox overlay shows the image at full size with dim backdrop. Esc or click outside closes.
- **Why:** Standard pattern. Doc has a screenshot at 200px wide; user wants to see it at full size without losing scroll position.
- **MoSCoW:** **COULD** (v2.2)
- **Effort:** S (1 day). Pure JS + CSS in render.js.
- **Risk:** Low.
- **Acceptance criteria:**
  - Click image → fades to lightbox in <200ms.
  - Pinch-zoom inside lightbox.
  - Esc / outside-click / Cmd+W closes.
  - SVG images zoom cleanly (no blur).
- **Open questions:** None.

---

### F-15 — Word count / reading time

- **What:** Status bar at bottom of window: "1,234 words • 5 min read • <filename>". Hide via View → Hide Status Bar.
- **Why:** Marked 2 + Typora both have it. Reading time = words / 200 wpm.
- **MoSCoW:** **COULD** (v2.2)
- **Effort:** S (0.5 day). Strip markdown → count words → divide.
- **Risk:** Trivial.
- **Acceptance criteria:**
  - Bar shows accurate word count (±5% vs `wc -w` after stripping markdown syntax).
  - Reading time formatted "5 min read" not "5.0 minutes."
  - Hide/show persists.
- **Open questions:** None.

---

### F-16 — Font size zoom

- **What:** Cmd+= zooms in (110%), Cmd+- zooms out (90%), Cmd+0 resets (100%). Range 50%-300%. Persists per-app (not per-doc).
- **Why:** Universal expectation. Trivial via CSS `font-size` on `body`.
- **MoSCoW:** **MUST** (v2.0)
- **Effort:** S (≤0.5 day).
- **Risk:** None.
- **Acceptance criteria:**
  - Cmd+= / Cmd+- / Cmd+0 work as expected.
  - View menu has the entries with shortcuts displayed.
  - Setting persists across launches.
- **Open questions:** None.

---

### F-17 — AI features (round 2: 2 LLM features, voice moved to F-18)

See Section 4 above for full breakdown. Summary:

- **AI-1 — Doc summary** (Cmd+Shift+S). MUST in v2.2 Plus tier. ~$0.005/call. Blocking (no spinner needed — typically <1s).
- **AI-2 — Ask doc (sidebar chat)** (Cmd+Shift+A). MUST in v2.2.0 Plus tier. ~$0.008/call. **Blocking + spinner in v2.2.0; streaming in v2.2.1.**

Both behind a license check (F-PRICE-1). Free tier sees the menu items but they show "Plus required" with a deep-link to purchase.

- **MoSCoW:** **MUST** (v2.2 Plus launch)
- **Effort:** M-L (~8-10 days for both + license-key plumbing in v2.2.0; +2 days for streaming in v2.2.1).
- **Risk:**
  - API key storage in Keychain (Q-AI-1).
  - SwiftUI side-panel layout that doesn't break window resize.
  - AI-2 chat panel layout conflicts with F-10 TOC sidebar → make mutually exclusive (TOC OR chat, not both).
- **Acceptance criteria:** see Section 4 per-feature.
- **Open questions:** see Section 4.

---

### F-PRICE-1 — License-key activation (round 2: phone-home + 90d cache)

- **What:** Preferences pane "License" with text field for license key. On entry, app calls **Lemon Squeezy's `/v1/licenses/activate` endpoint** with the key. On `valid` response: store the activation result + timestamp in Keychain, mark Plus unlocked. Re-verify on app launch only if cache is >90 days old.
- **Why:** Required infra for Plus tier (F-17). One-time price model. Phone-home + cache approach (round 2, per solo) is ~40 LOC vs round-1's Ed25519 + Cloudflare Worker stack (~150 LOC + ops surface).
- **MoSCoW:** **MUST** (v2.2)
- **Effort:** S-M (2 days, down from round-1 M of 3-4 days). Plain URLSession call to Lemon Squeezy's documented endpoint. No CryptoKit, no Worker.
- **Risk:**
  - **First activation requires network.** Users buying on a plane: deferred-activation message. Acceptable.
  - **Revocation now works.** Lemon Squeezy admin can disable a key; next 90-day re-check fails and the seat deactivates. (Round 1 Ed25519-only model could not revoke.)
- **Acceptance criteria:**
  - Valid key + network → unlocks AI menu items.
  - Invalid key → red "Invalid key" message, AI items remain locked.
  - Cached activation valid for 90 days offline; on day 91 launch, re-verify; on transient network failure during re-verify, keep current state with a 7-day grace window.
  - Open in dev mode without a key → AI items disabled but visible with "Plus required."
  - ~~"Deactivate" button~~ **CUT in round 2 per solo (~0.5d saved).** Re-add in v2.3 if a user actually asks.
- **Future hardening (if piracy real):** upgrade to Ed25519 signed tokens via Cloudflare Worker on purchase webhook. Trigger: ≥3 leaked keys in the wild or >100 sales without observed piracy → no rush.
- **Open questions:**
  - ~~Q-PRICE-1-a:~~ **RESOLVED: Lemon Squeezy.** Solo concurred.

---

### F-18 — Voice narration (Read Aloud) — MOVED FROM F-17/AI-3 in round 2

- **What:** Uses `AVSpeechSynthesizer` (system speech) to read the current doc aloud. Play / pause / skip-paragraph. Voice picker uses system voices.
- **Why moved (round 2):** Solo correctly noted this is not AI — it's plain Foundation API, zero LLM tokens. Re-labeling it as "AI" was marketing fluff that inflated the v2.2 paid bucket. Better honest framing: free quality-of-life feature in v2.1, alongside themes and PDF.
- **Why viewer-frame:** Eyes-free reading of long-form docs. Pure viewer use case.
- **MoSCoW:** **SHOULD** (v2.1 — free tier)
- **Effort:** S (2 days). `AVSpeechSynthesizer` + a small controller; markdown stripped to plain text per paragraph for clean prosody.
- **Risk:** Low. AVSpeechSynthesizer is stable since macOS 10.14.
- **Acceptance criteria:**
  - Menu: View → Read Aloud (Cmd+Shift+V). Plays from current scroll position.
  - Play/pause via same shortcut; Cmd+. stops.
  - Cmd+→ skip paragraph; Cmd+← back paragraph.
  - Voice and speech rate selectable in Preferences → Read Aloud pane.
  - Stops on file reload (F-01) without crashing.
  - No network calls.
- **Open questions:** None.

---

### F-19 — Cmd+R manual reload — NEW in round 2

- **What:** Cmd+R re-reads the current file from disk and re-renders. Works whether or not the F-01 file-watcher is enabled.
- **Why (per solo):** Should exist *before* F-01 file-watcher is wired up — useful when watcher misbehaves and as a deterministic fallback. 10 LOC. The DocumentGroup default may already give it; verify on day 1.
- **MoSCoW:** **MUST** (v2.0)
- **Effort:** XS (0.25 day).
- **Risk:** None.
- **Acceptance criteria:**
  - Cmd+R re-reads file from disk and re-renders.
  - Scroll percentage preserved (F-03 contract).
  - Works when F-01 watcher is toggled off in Preferences.
  - Menu item: View → Reload (Cmd+R).
- **Open questions:** None.

---

### F-20 — App icon — NEW in round 2

- **What:** A simple, distinctive app icon at all required sizes (16, 32, 64, 128, 256, 512, 1024 @1x/@2x), built into the `.app` via `iconutil` from a `.iconset`.
- **Why (per solo):** v1's CHARTER listed "app icon" as a v1 non-goal. v2.2 ships a paid tier — shipping with the default macOS app icon erodes credibility ("does this person even care about polish?"). Move from "yak shave" to "ship-blocking for v2.2."
- **MoSCoW:** **MUST** (v2.2 — before paid launch)
- **Effort:** S (0.5 day). Design taste required, but a 2-symbol monogram or "MD" with a paper-corner motif suffices. SF Symbols can underpin a DIY attempt.
- **Risk:** Bikeshedding on aesthetics. PM defers to solo's design taste; if needed, commission a $50-200 piece from a freelancer rather than infinite revisions.
- **Acceptance criteria:**
  - `MarkdownViewer.app` shows custom icon in Finder, Dock, Cmd+Tab.
  - Icon legible at 16px (Finder list view).
  - Icon distinct enough that it doesn't get confused with default-document or default-app icons.
- **Open questions:**
  - **Q-20-a:** DIY (SF Symbols + simple Sketch/Figma) vs commission? PM rec: DIY first attempt; commission if not happy after 2 hours. **Decision locked: solo's call by v2.2 start.**

---

### F-21 — `mdv` CLI shim — NEW in round 2

- **What:** A tiny shell shim installed (optionally) at `/usr/local/bin/mdv` that runs `open -a MarkdownViewer.app "$@"`. Ships in the DMG with an "Install CLI" menu item (or a `scripts/install-mdv.sh`).
- **Why (per solo):** Solo dogfooding aid. Power users want `mdv working-doc.md` from terminal. 0.25d. Zero ongoing maintenance.
- **MoSCoW:** **SHOULD** (v2.0)
- **Effort:** XS (0.25 day). Three-line shell script + install path.
- **Risk:** `/usr/local/bin` needs `sudo` on some setups. Install script asks once.
- **Acceptance criteria:**
  - `mdv test.md` opens that file in the viewer.
  - `mdv` with no args launches the app empty.
  - Multiple file args: each opens (consistent with F-04 drag-drop multi-file behavior).
  - Install script handles "already installed" gracefully.
- **Open questions:**
  - **Q-21-a:** Install to `/usr/local/bin` (needs sudo) or `~/.local/bin` (needs PATH)? PM rec: `/usr/local/bin` with sudo prompt; document `~/.local/bin` as alternative.

---

## 6. Non-functional requirements

| Concern | Requirement |
|---|---|
| **Performance** | Cold-launch + render small doc (~5KB) in <500ms. Live reload latency <500ms. Bundle size cap: total `Resources/` ≤1.5MB (currently ~250KB). |
| **Persistence** | Settings (theme choice, zoom, sidebar visibility, status-bar visibility, watch-file toggle) persist via `UserDefaults`. License key + activation cache in Keychain. Anthropic API key in Keychain. |
| **Offline** | No network on launch. No network for any free-tier feature. Network ONLY for: (a) Plus AI calls, (b) initial license activation, (c) license re-verification at 90-day boundary. |
| **Single-user** | App is per-user. No multi-user accounts. |
| **macOS support** | macOS 13+ (Ventura). arm64 only by default. |
| **Accessibility** | VoiceOver-readable content (WKWebView inherits accessibility). Keyboard navigation for all menu items (no mouse-only features). |
| **Dependencies** | No new Swift packages. AI calls via `URLSession` direct to api.anthropic.com. License calls via `URLSession` direct to api.lemonsqueezy.com. New JS plugins (markdown-it-footnote etc.) vendored as minified files. |
| **Signing** | Still unsigned DMG. No notarization. First-launch friction documented. |
| **Crash logging (NEW round 2)** | Per solo: opt-in local crash log at `~/Library/Logs/MarkdownViewer/crashes.log` for users to attach to bug reports. No remote telemetry. Toggle in Preferences → Privacy. Default ON. Unsigned-app Library writes don't need prompts. |

---

## 7. Out of scope (explicit anti-features)

Numbered to make pushback easy.

1. **Editing.** Even a tiny "fix typo" mode. This is a viewer. Editing means rope-data-structure undo stack, cursor management, IME, syntax highlighting in the source view — none of which we want to own. Hard boundary.
2. **Tabs.** macOS DocumentGroup already provides them via Window → Merge All Windows. No custom tab UI.
3. **Folder / workspace view (Typora-style file tree).** Viewer opens one file at a time. Anyone who wants a workspace already has VS Code or Obsidian.
4. **Mermaid (F-12) and KaTeX (F-11)** are parked. See those entries.
5. **Code signing / notarization.** No Apple Developer cert. Right-click-Open friction stays.
6. **Mac App Store distribution.** Sandboxing restrictions would break file-watching across arbitrary file paths. Also: no IAP needed since we're going BYO API key.
7. **Custom shell-script processors (Marked 2 has this).** Solo-dev maintenance burden too high; security surface bad in a viewer that opens arbitrary files.
8. **Document statistics beyond word count + reading time** (Flesch-Kincaid, Fog Index, repetition density — Marked 2 has them). Out of scope unless dogfooding shows demand. They're editor-territory features.
9. **CriticMarkup / Fountain / MultiMarkdown extensions.** GFM + footnotes + task lists is enough. Niche markup ≠ priority.
10. **Hosted AI / SaaS subscription.** Pricing model rejects this. BYO API key only.
11. **Auto-update mechanism.** No Sparkle integration in v2. Users redownload the DMG. Reconsider in v3 if friction is real.
12. **iOS / iPadOS port.** Mac only. Different platform = different project.
13. **(Round 2) License "Deactivate" button.** Cut from F-PRICE-1 v2.2 acceptance per solo. Re-add if a user actually asks. Saves ~0.5d.
14. **(Round 2) Streaming SSE for AI in v2.2.0.** Deferred to v2.2.1. Blocking + spinner ships first.
15. **(Round 2) 4 built-in themes.** Ship 2 in v2.1 (F-08). More on a v2.1.x patch only after F-07 contract is validated by a user-submitted theme.
16. **(Round 2) Ed25519 + Cloudflare Worker license signing.** Future-hardening only; not built speculatively. See F-PRICE-1.

---

## 8. Ambiguities to resolve (batch — solo-engineer / user to answer)

Numbered for batch response. Each has a PM-suggested default if no answer is given.

**Resolution status as of round 2** (R = resolved by solo or PM agreement; O = still open):

| # | Question | Why it matters | PM default / round-2 resolution | Status |
|---|---|---|---|---|
| **Q-01** | F-11 KaTeX — does the user have any `.md` files with `$...$` math? | Decides whether KaTeX is parked or shipped. | Park; dogfood-grep in v2.0 week 1 (`grep -lr '\$\$\|\$[^$]*\$' ~/Projects ~/Documents/screenshots`). Reopen if ≥3 hits. | O (until grep runs) |
| **Q-02** | F-12 Mermaid — does the user have `\`\`\`mermaid` blocks anywhere? | Same as Q-01 for Mermaid. | Same grep, same threshold (≥3 hits to reopen). | O (until grep runs) |
| **Q-03** | Plus tier price — $12 vs $14.99 (matching Typora/Marked 2)? | $12 anchors below; $14.99 keeps full margin. | **$12** (anchor strategy). | R |
| **Q-04** | Lemon Squeezy vs Gumroad vs Paddle for license fulfillment? | Affects integration code + ops burden. | **Lemon Squeezy.** Solo concurred. | R |
| **Q-05** | AI-2 chat history — persist to disk per-doc, or session-only? | Disk persistence adds ~50 lines + state management. | **Session-only for v2.2.** Persist in v2.3 if asked. | R |
| **Q-06** | F-07 theme scope — app-wide or per-document? | Per-doc is more "right" but doubles state complexity. | **App-wide.** Solo concurred. | R |
| **Q-07** | F-10 TOC — cap at 200 headings or virtualize? | Solo-eng's call. Cap is simpler. | **Render all** (SwiftUI `List` is lazy by default). Solo override. | R |
| **Q-08** | F-04 drag-drop on existing window — replace doc or open new window? | macOS-idiomatic could go either way. | **Replace** (matches macOS Preview). Solo concurred. | R |
| **Q-09** | API key storage — Keychain (correct, complex) or UserDefaults (simple, less secure)? | Keychain is the right answer but adds code. | **Keychain.** | R |
| **Q-10** | AI-1/AI-2 — streaming response or block-and-show? | Streaming is nicer UX; adds SSE handling. | **Blocking + spinner in v2.2.0; streaming in v2.2.1.** Per solo. | R |
| **Q-11** | License revocation — implement online check, or accept offline-only honor system? | Online check requires server + dunning logic. | **Phone-home + 90-day cache (Lemon Squeezy built-in API).** Revocation works. Per solo. | R |
| **Q-12** | F-09 line numbers default — on or off? | Aesthetic call. | Off. Toggle in View. | R |
| **Q-13** | Does the user want a free trial for Plus (15-day, like Typora)? | Affects license-key logic + storefront UX. | No trial. $12 doesn't justify buy-flow complexity. Refund policy covers buyer remorse. Solo concurred. | R |
| **Q-14 (new)** | Voice narration tier — free in v2.1 or Plus in v2.2? | Affects v2.2 Plus value prop. | **Free in v2.1 as F-18.** Solo pushed for honest framing; PM accepts. | R |
| **Q-15 (new)** | F-20 app icon — DIY or commission? | Aesthetic; solo's design taste vs $50-200. | DIY first 2 hours; commission if not happy. Solo's call by v2.2 start. | O (low urgency) |
| **Q-16 (new)** | F-21 `mdv` install path — `/usr/local/bin` (sudo) or `~/.local/bin` (PATH)? | Friction tradeoff. | `/usr/local/bin` with sudo prompt; document alternative. | O (solo's call) |
| **Q-17 (new)** | First-time-buyer support volume — does solo need a written FAQ + 7-min screencast before launch? | Affects v2.2 launch checklist. | **Yes — both required.** Per solo's "BYO friction wall" concern. | R |

---

## 9. Glossary

| Term | Meaning |
|---|---|
| **Live reload** | When the file on disk changes (any external editor), viewer re-renders within 500ms. |
| **FSEvents** | macOS-native filesystem event API. Used for file-watching. |
| **BYO API key** | "Bring Your Own" — user provides their own Anthropic API key in Preferences. App pays nothing. |
| **Ed25519** | Modern public-key signature scheme. Used to sign license keys so app can verify them offline. |
| **MoSCoW** | Must / Should / Could / Won't — prioritization framework. |
| **WKWebView** | macOS native browser engine. Renders our markdown via vendored markdown-it. |
| **Plus tier** | Paid one-time-purchase tier ($12 PM rec) that unlocks AI features. |
| **Free tier** | Default state. All non-AI features work forever, no nag. |
| **Lemon Squeezy** | Storefront / Merchant of Record for digital downloads. Handles VAT internationally. |
| **DocumentGroup** | SwiftUI's document-based-app primitive. Gives free Open/Recent/Tabs. |
| **NavigationSplitView** | SwiftUI primitive for sidebar+main panes. Used for F-10 TOC. Free keyboard nav + accessibility. |
| **DispatchSource (file watching)** | `DispatchSource.makeFileSystemObjectSource(fileDescriptor:eventMask:queue:)` — lightweight single-file watcher. Preferred over FSEvents for F-01. |
| **Atomic-rename save** | Editor save pattern that writes a tempfile then renames over the original. Fires `.delete` on the watched fd. Solo's #1 silent-fail mode for F-01. |
| **mdv** | CLI shim shipped in v2.0 (F-21). `mdv file.md` opens the file in the viewer. |

---

## 10. Source files / pages read

| Source | Purpose | Lines / fetched |
|---|---|---|
| `~/Projects/tools/markdown-viewer/CHARTER.md` | v1 non-goals + scope | 34 lines |
| `~/Projects/tools/markdown-viewer/CLAUDE.md` | Hard env constraints + push-back list | 76 lines |
| `~/Projects/tools/markdown-viewer/DESCRIBE.md` | v1 architecture | 106 lines |
| [marked2app.com](https://marked2app.com) | Feature catalog + positioning | WebFetch summary |
| [App Store: Marked 2](https://apps.apple.com/us/app/marked-2-markdown-preview/id890031187) | $13.99 confirmation + IAP precedent | WebFetch summary |
| [typora.io](https://typora.io) | Feature catalog + $14.99 confirmation | WebFetch summary |
| [VS Code Markdown docs](https://code.visualstudio.com/docs/languages/markdown) | Live-reload mechanism | WebSearch summary |
| [Lemon Squeezy License API docs](https://docs.lemonsqueezy.com/api/license-api) | License-key feasibility | WebSearch summary |
| [pricepertoken — Haiku 4.5](https://devtk.ai/en/models/claude-haiku-4-5/) | $1/$5 per M tokens for cost math | WebSearch summary |
| [KaTeX bundle size](https://bundlephobia.com/package/katex) | 270-347KB + fonts | WebSearch summary |
| [Mermaid bundle size](https://github.com/orgs/mermaid-js/discussions/4314) | 880KB-2.6MB | WebSearch summary |

---

*End of v2-requirements.md. ROADMAP.md (sibling file) holds milestone packaging.*
