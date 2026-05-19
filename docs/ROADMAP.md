# Markdown Viewer v2 — Roadmap

**Author:** PM
**Date:** 2026-05-18 (round 2, post-solo-feedback)
**Companion doc:** `docs/v2-requirements.md` (per-feature spec) + `docs/pm-response-v2.md` (round-2 delta)
**Status:** DRAFT v2 — incorporates solo-engineer feedback v1.

---

## TL;DR

Four releases, **~10-13 weeks** of solo evening/weekend work, ending with a paid Plus tier and a streaming-AI polish patch.

| Release | Theme | Effort (calendar) | Pricing | Headline features |
|---|---|---|---|---|
| **v2.0** | "Live & Findable" | **4-5 weeks** | Free | Live reload, find, drag-drop, zoom, Cmd+R reload, `mdv` CLI |
| **v2.1** | "Themes, Print, Voice" | **4-5 weeks** | Free | Custom CSS, 2 built-in themes, PDF export, TOC, code polish, footnotes, **Read Aloud** |
| **v2.2** | "Plus" | **5-6 weeks** | Free + $12 Plus | AI summary, AI chat (blocking), license key, status bar, image lightbox, **app icon** |
| **v2.2.1** | "Streaming polish" | **1-2 weeks** | Free + Plus | AI chat → streaming SSE; bug fixes from v2.2 dogfood |
| **v3 / parked** | — | — | — | KaTeX, Mermaid (only if dogfooding reveals need) |

**Round-2 calendar reset:** PM round-1 said 7-8w. Solo flagged it as 30% under and called specific risks (FSEvents editor-matrix, print CSS bikeshedding, license + AI-2 + first-time-buyer support all stacking). PM accepted. **10-13w realistic; 7-8w only if AI-2 chat is cut entirely.**

---

## v2.0 — "Live & Findable" (4-5 weeks)

### Goal in one sentence
Make the viewer feel alive — when the user saves in their editor, the viewer shows it. Plus the table-stakes find / drag-drop / zoom polish, plus power-user CLI shim.

### Features (round 2: added F-19 + F-21)

| ID | Feature | Effort | Priority |
|---|---|---|---|
| F-01 | Live reload on file change | M (4-6 days; round-2 bump) | MUST |
| F-02 | Find in page (Cmd+F) | S (1-2 days) | MUST |
| F-03 | Scroll preservation on reload (percentage) | S (1 day) | MUST |
| F-04 | Drag & drop to open | S (1 day) | MUST |
| F-05 | Recent files menu (verify free, 1d fallback) | S (≤0.5-1 day) | MUST |
| F-16 | Font size zoom (Cmd+= / - / 0) | S (≤0.5 day) | MUST |
| **F-19** | **Cmd+R manual reload** (NEW round 2) | XS (0.25 day) | MUST |
| **F-21** | **`mdv` CLI shim** (NEW round 2) | XS (0.25 day) | SHOULD |

**Total estimated effort:** ~9-13 working days. At 2 evenings/week + weekend bursts → **4-5 calendar weeks** (round-2 reset; round-1 said 2-3w, solo flagged +30%).

### Week 1 dogfood task (NEW round 2)

Run **before** any code: `grep -lr '\$\$\|\$[^$]*\$\|^\`\`\`mermaid' ~/Projects ~/Documents/screenshots`. If ≥3 docs hit, reopen F-11 and/or F-12 for scoping. If <3 hits, both stay PARKED. Resolves Q-01 + Q-02 deterministically in <5 seconds.

### Validation plan ("how do we know it's good")

1. **Dogfood for 1 week.** User edits docs in VS Code/nvim while viewer is open. If user reflexively reaches for "reload" once, F-01 has failed.
2. **Smoke test corpus:** `build/test.md` must render. Then 5 real-world docs from user's day-to-day (working-doc.md, etc.) must render with live reload.
3. **Find correctness:** open a 20-page doc, find a term that appears 12 times — count must be 12, all highlights navigable.
4. **Drag-drop multi-file:** drop 3 `.md` files at once on the window — each opens (1 in current window, 2 new).
5. **No regressions** on existing v1 rendering. Compare side-by-side screenshots vs v1 on test.md.

### Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| **Atomic-rename pattern (vim/VS Code save) fires `.delete` on watched fd** (solo's #1 silent-fail) | High if untested | Live reload silently breaks for major editors | Re-`open()` by path on every rename event; explicit test for vim/VS Code save |
| DispatchSource misses some editor's write pattern | Medium | Live reload silently breaks for that editor | Test against VS Code, nvim, TextEdit, Obsidian, BBEdit before ship |
| Scroll preservation jumps weirdly on shortened docs | Low | Annoying but recoverable | Percentage approach (round 2) clamps automatically |
| **Render-throw on reload blanks the view** | Medium | Mid-edit malformed doc kills view | Preserve last-good HTML, yellow banner (F-01 acceptance) |
| WKWebView find API behaves differently across macOS 13 / 14 / 15 | Medium | Highlighting flickers on older OS | macOS 13 is min; test on 13 + current |
| Recent-files menu doesn't actually come "free" from SwiftUI | Low | +1 day to build manually | Verify on day 1; budget contingency |

### Ship criterion
v2.0 ships when: all 8 features hit acceptance criteria (F-01, F-02, F-03, F-04, F-05, F-16, F-19, F-21), dogfooded for 7 consecutive days with no "ugh, I miss v1" moments, README updated, DMG built, version bumped to 2.0.0. Bonus: `mdv` CLI installed and used at least once by user.

---

## v2.1 — "Themes, Print, Voice" (4-5 weeks)

### Goal in one sentence
Make the viewer pretty, printable, and ear-friendly — the "I'd actually share output from this app" release, with a Read Aloud headline beyond themes.

### Features (round 2: 2 built-in themes; F-18 voice added)

| ID | Feature | Effort | Priority |
|---|---|---|---|
| F-06 | Print / Export to PDF | M (2-3 days) | SHOULD |
| F-07 | Custom CSS themes (folder-watched) | M (2-3 days) | SHOULD |
| F-08 | **2** built-in theme variants (round 2: GitHub + Paper-or-Sepia) | S (1 day; was 2d for 4) | SHOULD |
| F-09 | Code-block enhancements (lang label, copy, line nums) | S (1 day) | SHOULD |
| F-10 | Table of contents sidebar (Cmd+\\, NavigationSplitView) | M (2-3 days) | SHOULD |
| F-13 | Footnotes + task lists (markdown-it plugins) | S (0.5 day) | SHOULD |
| **F-18** | **Read Aloud (voice narration, free)** (NEW round 2 — moved from F-17/AI-3) | S (2 days) | SHOULD |

**Total estimated effort:** ~11-14 working days. → **4-5 calendar weeks** (round-2 reset; round-1 said 2w, solo flagged +30%).

### Validation plan

1. **PDF export quality:** print a 30-page real doc to PDF. Open it in Preview. Code blocks must not break across pages. Links must be readable on paper.
2. **Theme contract robustness:** write a 4th custom theme yourself (e.g. nord.css) using only the documented CSS variables. If it works without touching app source, the contract is solid.
3. **TOC accuracy:** open a doc with 20 nested headings. TOC tree must match outline. Click each → scroll lands within 5px of target heading.
4. **Footnote roundtrip:** doc with 5 footnotes — all render at bottom, all click-jump correctly, all backlinks work.
5. **Built-in themes A/B:** show GitHub vs Paper vs Sepia screenshots to user. Get a "yeah, all 3 are usable" sign-off before ship.

### Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Print CSS bikeshedding eats more time than budgeted | Medium | Slip by 2-3 days | Set hard cutoff: if `@media print` isn't done in 1.5 days, ship "good enough" and iterate in v2.1.1 |
| Theme CSS contract isn't future-proof | Medium | Breaking v2.2 themes hurts users | Write the contract spec in README; semver the contract |
| TOC sidebar fights with status bar (v2.2 feature) for layout | Low | Refactor in v2.2 | Plan layout for status bar from v2.1 |
| ~~4th built-in theme is "fine" but not great~~ | — | — | **Resolved round 2: ship 2, not 4.** |
| Read Aloud (F-18) stops/restarts ugly on F-01 file reload | Low | Annoying | Stop synth on reload; user re-triggers Cmd+Shift+V |

### Ship criterion
v2.1 ships when: all 7 features hit acceptance criteria, PDF export of a 20-page doc looks publication-grade, 2 polished built-in themes shipped, theme contract documented in README, Read Aloud works on a 1-page doc end-to-end, DMG built, version 2.1.0.

---

## v2.2 — "Plus" (5-6 weeks)

### Goal in one sentence
Launch the paid tier with two AI features behind a license key, branded by a real app icon — the monetization moment.

### Features (round 2: AI-3 voice gone from this release; F-20 icon added; AI-2 blocking-only)

| ID | Feature | Effort | Priority | Tier |
|---|---|---|---|---|
| F-PRICE-1 | License-key activation (Lemon Squeezy API + 90d Keychain cache) | S-M (2 days; round-2 simplification, was 3-4d) | MUST | Infra |
| F-17 / AI-1 | Doc summary (Cmd+Shift+S) — blocking | M (3 days) | MUST | Plus |
| F-17 / AI-2 | Ask doc — sidebar chat (Cmd+Shift+A) — **blocking + spinner** | M (4 days; round-2 cut from 5-6 by deferring SSE) | MUST | Plus |
| ~~F-17 / AI-3~~ | ~~Voice narration~~ → **moved to F-18 in v2.1 (free)** | — | — | — |
| **F-20** | **App icon** (NEW round 2 — ship-blocking) | S (0.5 day + design taste) | MUST | Free |
| F-15 | Word count / reading time status bar | S (0.5 day) | COULD | Free |
| F-14 | Image lightbox / zoom | S (1 day) | COULD | Free |

**Total estimated effort:** ~11-13 working days of code + 2-4 days of ops (Lemon Squeezy storefront, FAQ, screencast). → **5-6 calendar weeks** (round-2 reset; round-1 said 3w, solo flagged +30% plus support-prep overhead).

### Pre-work (non-coding, before ship)

Solo-engineer is not on the hook for these but they block ship:
- Set up **Lemon Squeezy storefront** for "Markdown Viewer Plus — $12 one-time" product with built-in license-key generation enabled.
- ~~Generate Ed25519 keypair / Cloudflare Worker signer.~~ **CUT in round 2 — Lemon Squeezy's built-in license API replaces this entirely.** Re-add only on future-hardening trigger (see F-PRICE-1).
- Write the user-facing **"How to get a Plus license" page** (one HTML page on a static host).
- Write a **7-minute screencast** showing: click buy → paste license key → paste Anthropic API key → first summary in 60 seconds. Per solo: critical for the BYO friction wall.
- Write a **public FAQ** covering "where do I get an Anthropic API key", "what's the typical cost", "refund policy", "how to deactivate", "what happens if my key gets compromised".
- Update README and DESCRIBE.md to document the Plus tier and BYO API key flow.
- **App icon** (F-20): DIY first or commission; must ship before launch.

### Validation plan

1. **Free tier still works.** Confirm AI menu items show "Plus required" with deep-link; doesn't crash; doesn't degrade any free-tier feature.
2. **Buy-flow end-to-end.** Use a real Lemon Squeezy test purchase. Receive license key in email. Paste into Preferences. AI menu unlocks. Quit app, relaunch — still unlocked.
3. **AI-1 (summary) on a 10-page real doc.** Bullets should be useful, not generic. Token cost from API console matches our $0.005 estimate (±20%).
4. **AI-2 (chat blocking) usability.** Ask 5 real questions about a real doc. Each answer is grounded in the doc and not hallucinated. Spinner appears within 100ms of submit; response renders within 3-5s typical.
5. ~~AI-3 (voice).~~ **Tested in v2.1 as F-18.**
6. **API key in Keychain.** Quit app, restore from Time Machine, relaunch — Keychain entry persists. Wrong-key error is graceful.
7. **Cost sanity on user's own docs.** Run AI-1 + AI-2 on user's daily docs (working-doc.md etc.) for 1 week — confirm daily spend < $0.50 unless heavily used.
8. **License re-verify (NEW round 2).** Set Keychain cache timestamp to 91 days ago; relaunch; confirm app phones home, re-validates, updates cache. Disable internet during re-verify; confirm 7-day grace window kicks in.
9. **App icon visible (NEW round 2).** Fresh install on a clean Mac (or a second user account). Icon appears in Finder, Dock, Cmd+Tab. Legible at 16px.

### Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| ~~Lemon Squeezy license-key generation doesn't natively support Ed25519~~ | — | — | **Resolved round 2: use Lemon Squeezy built-in license API; no Ed25519, no Worker.** |
| Keychain access requires entitlements that break unsigned build | Medium | License key falls back to UserDefaults (less secure) | Test Keychain access in unsigned build early; decide before AI-2 lands |
| AI-2 chat panel layout fights TOC sidebar (v2.1) | Medium | Window cramped on small displays | Make panels mutually-exclusive: TOC OR chat, not both |
| ~~Streaming SSE handling is more Swift code than expected~~ | — | — | **Resolved round 2: ship blocking + spinner in v2.2.0; streaming in v2.2.1.** |
| **License re-verify on day 91 fails due to network issue** | Medium | Legitimate user gets locked out mid-session | 7-day grace window; show banner not modal; fall back to cached state until grace expires |
| First Plus user can't activate / hits friction wall | High at launch | Buyer remorse, refund request | Friendly error messages; **first-run wizard "Open Anthropic Console" → "Paste here"** (Q-AI-4); 7-min screencast on landing page; written FAQ |
| Token cost is higher than the $0.005-$0.008 estimate | Low | User unhappy with bill | Show "approx cost: $X" in the AI response footer for transparency |
| Refund / dispute volume | Medium for a new paid product | Support burden on solo-dev | 7-day no-questions-asked refund policy (Lemon Squeezy supports this); ship with low expectations on volume |
| **App icon (F-20) bikeshedding eats >0.5d** | Medium | Slip by 1-2 days | Hard cutoff: 2 hours DIY → commission for $50-200 |

### Ship criterion
v2.2 ships when: license-key flow tested with 3 different fake purchases, **2 AI features** (AI-1 summary + AI-2 chat-blocking) hit acceptance criteria on real user docs for 1 week, refund policy documented, public Plus landing page live + 7-min screencast + FAQ, **app icon shipping**, DMG built, version 2.2.0.

### Marketing / launch (not solo-eng's job, but on the timeline)

- Soft launch: solo-eng + PM use it for 2 weeks; no public announcement.
- Public launch: post to r/MacApps, Show HN, lobste.rs. Position: "Marked 2 but with AI and BYO API key."
- Initial price: $9 first-week launch discount → settle at $12 after.

---

## v2.2.1 — "Streaming polish" (1-2 weeks) — NEW in round 2

### Goal in one sentence
Upgrade AI-2 chat from blocking + spinner to streaming SSE for better perceived latency; ship the inevitable v2.2 bug-fix backlog from real-user dogfood.

### Features

| ID | Feature | Effort | Priority | Tier |
|---|---|---|---|---|
| F-17 / AI-2-stream | Replace blocking response with SSE streaming | M (2 days) | SHOULD | Plus |
| — | v2.2 bug-fix backlog (whatever surfaces during launch week) | S-M (2-4 days) | MUST | — |

**Total estimated effort:** ~4-6 working days. → **1-2 calendar weeks.**

### Validation plan

1. **Stream renders incrementally.** Open chat, ask a question, watch tokens appear as they arrive (not at the end). First token within 1s; full response time same or better than blocking.
2. **Cancellation works.** Mid-stream Cmd+. or close panel cancels the request cleanly; no orphan URLSession tasks.
3. **Partial chunk handling.** Network blip mid-stream → graceful error, last partial render preserved, retry button.
4. **Cost parity.** Streaming response token count matches blocking response token count (Anthropic counts the same way regardless of transport).

### Risk register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| AsyncSequence cancellation has hidden edge cases | Medium | Memory leak or orphan tasks | Use `URLSession.shared.bytes(for:)` and structured concurrency; cancel via Task cancellation |
| SSE parse fails on Anthropic API change | Low | Streaming breaks | Fall back to blocking on parse error (graceful degrade) |

### Ship criterion
v2.2.1 ships when: streaming works on 5 real chat sessions, cancellation tested, no regression vs v2.2.0 blocking mode, DMG built, version 2.2.1.

---

## v3 / Parked

These are explicitly NOT planned. They move to a "v3" milestone only if dogfooding reveals need (i.e., user opens a `.md` and gets annoyed something doesn't render).

| ID | Feature | Park reason | Reopen condition |
|---|---|---|---|
| F-11 | KaTeX math | +270KB bundle hit; speculative. | v2.0 grep finds ≥3 `.md` files with `$$` or inline `$...$`. |
| F-12 | Mermaid diagrams | +880KB-2.6MB bundle hit; speculative. | v2.0 grep finds ≥3 `.md` files with `\`\`\`mermaid` blocks. |
| — | Marked 2-style document analytics (Flesch-Kincaid, Fog Index, repetition density) | Editor-territory; not viewer-priority. | User asks. |
| — | Auto-update via Sparkle | Redownload friction is acceptable for v2. | User reports DMG-redownload friction as actual annoyance. |
| — | Per-document theme | App-wide theme satisfies. | Multi-user / per-doc workflow scenarios emerge. |
| — | AI: glossary extractor, translate, link preview | Cut for v2.2 scope discipline; AI-2 chat covers most of glossary use. | AI-2 dogfood shows recurring "I wish I could just X" pattern. |
| — | Folder / workspace view | Different product; that's an editor's job. | Never (out of scope by definition). |
| — | License "Deactivate" button (cut from F-PRICE-1 round 2) | Half-day saved; no user has asked. | User actually asks to deactivate a seat. |
| — | Ed25519 + Cloudflare Worker license signing | Future hardening only. | ≥3 leaked keys observed in the wild, OR >1% activation geo-anomaly. |
| — | More built-in themes beyond GitHub + Paper/Sepia | F-08 round-2 scope-down. | F-07 contract proven by user-submitted theme. |

---

## Cross-release risk: scope drift

The single biggest threat to this roadmap is **adding "just one more thing" mid-milestone.** PM and solo-engineer enforce:

1. Anything not on the milestone's feature list defers to the next milestone.
2. Bugs surfaced during dogfooding fix in-milestone; UX polish that's not bug-level defers.
3. v2.0 ships before v2.1 starts. No parallel work.
4. KaTeX / Mermaid stay parked. If a user actually requests them (with a real doc that needs them), reopen the discussion — not before.

---

## Timeline (calendar, assuming 2 evenings + 1 weekend = ~10 hours/week — round 2 reset)

| Week | Activity |
|---|---|
| 1 | v2.0 — dogfood-grep (KaTeX/Mermaid), F-19 (Cmd+R), F-21 (mdv CLI), F-01 setup |
| 2 | v2.0 — F-01 (live reload + atomic-rename test matrix) |
| 3 | v2.0 — F-03 (scroll %) + F-02 (find) |
| 4 | v2.0 — F-04 (drag-drop) + F-05 (recent) + F-16 (zoom) |
| 5 | v2.0 — dogfood week + DMG ship |
| 6 | v2.1 — F-06 (PDF) + F-09 (code polish) |
| 7 | v2.1 — F-07 + F-08 (2 themes) + F-13 (footnotes) |
| 8 | v2.1 — F-10 (TOC) + F-18 (Read Aloud) |
| 9 | v2.1 — dogfood + DMG ship |
| 10 | v2.2 — F-PRICE-1 (license, 2d) + Lemon Squeezy storefront setup + F-20 (icon) |
| 11 | v2.2 — AI-1 (summary) + first-run wizard + FAQ draft |
| 12 | v2.2 — AI-2 (chat, blocking + spinner) |
| 13 | v2.2 — F-14 (lightbox) + F-15 (status bar) + screencast + DMG ship |
| 14 | v2.2.1 — AI-2 streaming SSE + v2.2 bug-fix backlog |

**~14 calendar weeks end-to-end** at the budgeted cadence. Round 1 said 7-8w; round-2 reset to 10-13w nominal, 14w with v2.2.1 polish patch included. **Could compress to 9-10 with focused weekends and skipping v2.2.1.**

### Cadence-risk note (per solo)
Solo flagged that historical evening/weekend project cadence often slips 2-3x not 1.3x. If user's real availability drops to 4-5 hrs/week (vs assumed 10), every number above doubles. **PM accepts this as a known unknown.** Mitigation: ship v2.0 hard before starting v2.1 — locked in by the "no parallel work" rule below.

---

## Open questions for solo-engineer (roadmap level — round 2)

Mostly resolved. Remaining:

1. ~~v2.0 / v2.1 / v2.2 split correct?~~ **RESOLVED — solo concurred, with the v2.1 voice-feature shift.**
2. **Should we ship v2.0 unannounced or announce it?** PM rec: silent bump; announce v2.2 when Plus launches. Solo's call — likely concurs.
3. ~~Lemon Squeezy vs alternatives?~~ **RESOLVED — Lemon Squeezy + built-in license API.**
4. ~~v2.2 budget for streaming SSE?~~ **RESOLVED — blocking in v2.2.0, SSE in v2.2.1.**
5. **First-launch "v2 is here" notification — yes or no?** PM rec: no. First open of a v1 file with the v2 binary just shows the new chrome. Solo's call.
6. **(NEW round 2)** F-19 Cmd+R — is the DocumentGroup default already wired, or do we need to write the menu+action ourselves? Solo to verify in week 1.
7. **(NEW round 2)** F-20 app icon — DIY vs commission? Decision-by-date: v2.2 week 10 start.
8. **(NEW round 2)** Crash log toggle (NFR addition) — Preferences → Privacy → "Write crash logs to ~/Library/Logs/MarkdownViewer/" defaults ON. OK?

---

## What ships first if time is cut in half — round 2

If solo-engineer has only 6-7 calendar weeks total (half the plan), the cut order:

1. **Ship v2.0 fully.** The live-reload MUST cannot be cut. F-19 (Cmd+R) is too cheap to cut.
2. **From v2.1:** ship F-06 (PDF) + F-09 (code polish) + F-13 (footnotes) + **F-18 (Read Aloud)**. Cut F-07 / F-08 (themes) / F-10 (TOC) — defer to v2.1.x.
3. **From v2.2:** cut AI-2 (chat — biggest item) entirely. Ship F-PRICE-1 + AI-1 (summary) + **F-20 app icon** as the Plus tier. v2.2.1 streaming becomes "v2.3 maybe."
4. **Drop the screencast for first launch.** FAQ stays.

This still delivers the MUSTs and gets a Plus tier launched, just with less surface area. **Net: $12 Plus tier launches with AI summary only; AI chat ships in v2.3.**

If time is **cut to a quarter** (3-4 weeks) — ship only v2.0. No Plus tier in this calendar quarter. User has a much better viewer, no monetization yet.

---

*End of ROADMAP.md.*
