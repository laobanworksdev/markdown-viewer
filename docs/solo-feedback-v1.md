# solo-engineer feedback on v2 plan — v1

## Verdict
Ship v2.0 mostly as-is. Cut KaTeX/Mermaid permanently. AI in v2.2 only if dogfooded weekly.

## Confidence in PM's plan
**4/5** — well-scoped, MoSCoW is sane, parks the right stuff. Knocking one point because AI-2 streaming chat + license-key infra in one milestone is the kind of thing that quietly slips 2x and the user is on weekend cadence.

## Reality-checks (per item)

**F-01 live reload —** Ship. Use `DispatchSource.makeFileSystemObjectSource(fileDescriptor:eventMask:.write|.extend|.delete|.rename, queue:)`. **PM under-estimated.** 3-5d is right *only if* you also handle the atomic-rename pattern (vim/VS Code: write tempfile, rename over). That case fires `.delete` on the old fd — you must re-`open()` by path on every rename event, not on first open. Add 1d for the editor matrix test (VS Code, nvim:w, Obsidian, TextEdit, BBEdit). Don't use FSEvents framework — heavier API, designed for directory trees, overkill for one file.

**F-02 find —** Ship. `webView.find(_:configuration:completionHandler:)` since macOS 11, returns match count. Concur with PM — ≤50 LOC including SwiftUI bar. 1-2d realistic.

**F-03 scroll preservation —** Ship, but cleaner than PM's approach. Don't restore `window.scrollY` (pixel value goes stale on font reflow). Instead: capture the **scroll percentage** OR the **first visible heading id** before re-render; restore after. The percentage approach is one line and handles doc shortening for free (clamp via max). Skip Q-03-a — heading-anchored is the right default, not "next version."

**F-04 drag & drop —** Ship. `.onDrop(of: [.fileURL])` in SwiftUI. 0.5-1d. Concur with PM's "replace current doc" default (Q-04-a) — matches macOS Preview behavior.

**F-05 recent files —** Mostly free with DocumentGroup. Budget 0.5d to verify. If it's broken under SwiftPM-without-Xcode (sometimes the bundle ID isn't picked up correctly without an `.xcodeproj`), budget 1d to wire up `NSDocumentController.shared.noteNewRecentDocumentURL`.

**F-06 print/PDF —** Ship. `WKWebView.createPDF(configuration:completionHandler:)` since macOS 11. Concur with PM. The 2-3d budget is mostly `@media print` CSS tuning, which is real work — code blocks that break across pages look terrible without `break-inside: avoid; page-break-inside: avoid`. Drop "footer with page N of M" (Q-06-a default no) — WebKit doesn't expose page-number callbacks cleanly, the workaround is fragile.

**F-07 custom CSS themes —** Ship. PM's design is fine. **One correction:** "switching applies live (no reload)" — easiest impl is just `evaluateJavaScript` to swap a `<link>` href; don't try to hot-swap CSS variable values, that path is brittle when a theme redefines block-level styles. Q-07-a: app-wide. Concur.

**F-10 TOC sidebar —** Path (a) (parse in JS, post to Swift, render Swift sidebar). Reason: SwiftUI sidebar is free in DocumentGroup via `NavigationSplitView`, you get proper keyboard nav, accessibility, and the toggle persists naturally. Path (b) (JS aside) means re-implementing keyboard nav and looks like a webpage. **PM didn't specify which path; you should pick (a).** Skip Q-10-a (200 cap) — virtualize is trivial in SwiftUI's `List` (lazy by default). Just render all of them.

**F-11 KaTeX / F-12 Mermaid —** **PARK both, permanently for v2.** Concur with PM. Bundle hit (2x and 10x respectively) is the dealbreaker on top of zero proven demand. Override only if the user grep's their `.md` corpus and finds `\$\$` or `mermaid` blocks. Add a "dogfood check" task to v2.0 week 1: `grep -lr '\$\$\|^\`\`\`mermaid' ~/Documents ~/Projects` — answers Q-01/Q-02 in 5 seconds.

**F-13 footnotes/task lists —** Ship. Footnotes: vendor `markdown-it-footnote` (~4KB minified from jsdelivr, pinned), one `md.use()` call. Task lists already exist in `render.js` as a post-process — **leave the current impl alone**, don't swap to `markdown-it-task-lists`, you already paid the cost. 0.5d concur.

**F-17 AI features —**
- **AI-2 sidebar chat — start BLOCKING with spinner.** SSE in URLSession is workable but the AsyncSequence API isn't free; you'll spend a day on edge cases (cancellation, partial chunks, error frames). Blocking is one `URLSession.shared.data(for:)` call. Ship blocking in v2.2, add streaming in v2.2.1 once you've seen the latency in practice. PM's risk register actually flags this ("blocking fallback") — promote it from fallback to plan-of-record.
- **Voice narration is not AI** — it's `AVSpeechSynthesizer`, plain Foundation. PM calling it "AI-ish for marketing" is honest but slightly cute. **Move it to v2.1 as a free feature** ("Read Aloud"). That frees v2.2 to focus on the two actual LLM features + license plumbing, and gives v2.1 a third headline beyond themes.
- **BYO Anthropic API key — concur.** The friction is real but the alternative (hosted relay) is wildly worse for a solo dev. Mitigation: when Plus is activated but no API key set, show a *first-run flow* with a button "Open Anthropic Console" + "Paste key here" — make it a wizard, not just a Preferences field.

**Pricing model (Lemon Squeezy + Ed25519 offline) —** Over-engineered for a first paid app, but defensibly so. Trade-off:
- **Pros of Ed25519 offline:** zero phone-home, can't be DoS'd by your own infra, no server cost, key validation is ~30 LOC with CryptoKit.
- **Cons:** if a single key leaks to a piracy forum, you can't revoke without rotating the public key (which would brick legit users on the old key). And the user's Lemon Squeezy account doesn't natively emit Ed25519 keys — you'd need a small Cloudflare Worker to sign on purchase webhook.

**My counter:** start with **Lemon Squeezy's built-in license API + single phone-home on activation, then cache the verification result in Keychain for 90 days.** That's ~40 LOC total, no Ed25519, no Worker, revocation works. Once you have a real piracy problem (you won't at <100 sales), upgrade to signed tokens. Don't build the Worker speculatively.

**3-milestone calendar (PM says ~7-8 weeks weekend/evening) —** **UNDER-estimated by ~30%.** Specifically:
- v2.0 (2-3w stated): realistic at 3-4 calendar weeks. FSEvents/DispatchSource has editor-matrix testing that always takes longer than budgeted.
- v2.1 (2w stated): realistic at 2.5-3w. Print CSS plus 4 built-in themes plus TOC = three "small" things that each eat half a day in bikeshedding.
- v2.2 (3w stated): realistic at 4-5w. License plumbing + Lemon Squeezy setup + AI-2 chat panel + first-time-buyer support emails. **This is the slip risk.**

Realistic end-to-end: **10-13 calendar weeks** at the stated cadence, not 7-8. PM's "could compress to 6-7 with focused weekends" is optimistic-marketing.

**What's MISSING from the plan**

Add:
- **Cmd+R manual reload.** Should exist *before* F-01 file-watcher even works. 10 lines. Useful when watcher misbehaves.
- **Error state when render.js throws.** Today the `render.js` catch shows "Render error: …" — fine for v1. With live reload, a malformed doc could blank the view mid-read. Render errors should preserve the last-good HTML and show a yellow non-blocking banner.
- **`mdv` CLI shim** in the DMG or via `brew --cask` writeup. Trivial — `/usr/local/bin/mdv` → `open -a MarkdownViewer.app "$@"`. Power users want this. 0.25d.
- **An app icon.** v1 said "defer" — it's now embarrassing for a paid app to ship default icon. Move from "yak shave" to "must before v2.2." 0.5d to draw something simple + `iconutil`.
- **Crash-report opt-in** before charging users money. Even a `~/Library/Logs/MarkdownViewer/` file the user can attach to a bug report.

Cut:
- **F-08 4 built-in themes.** Ship **2** (current GitHub + one Paper/Sepia). Bikeshedding eats time and design taste is a hole. Add more once F-07 contract is proven by a user-submitted theme.
- **Q-13 trial period.** Concur with PM default — no trial. $12 doesn't justify the buy-flow complexity. Refund policy covers buyer remorse.
- **License-key "Deactivate" button** in F-PRICE-1 acceptance. v2.2 doesn't need this. Cuts ~half a day.

## Pricing & AI gut-check

Pricing math is sound. $12 anchored below $14.99 competitors is right. BYO key is the only viable AI model for solo dev — concur. **Real risk isn't pricing, it's the BYO friction wall.** A non-trivial fraction of buyers will get their $12 charged, paste a license key, then bounce off "go get an Anthropic API key." Mitigation that the PM didn't budget: a *7-minute screencast* on the Plus landing page showing "click here → paste here → first summary in 60 seconds." Make this part of the v2.2 launch checklist.

AI selection (1 summary, 1 chat, 1 voice) is well-disciplined. **My one push: ship voice in v2.1 free, ship summary alone in v2.2 Plus, ship chat in v2.2.1.** Smaller v2.2 means a real Plus launch can happen 2 weeks sooner with less stress.

## Open questions back to PM

1. **Dogfood check on KaTeX/Mermaid** — has user grep'd their actual `.md` corpus for `\$\$` or `\`\`\`mermaid`? 5-second test that resolves Q-01/Q-02 deterministically.
2. **Plus tier launch tier-1 estimate** — what's the realistic "first 100 sales" timeline? Affects whether Ed25519 vs phone-home is worth the engineering.
3. **Is "Read Aloud" voice the kind of feature that should be free?** I'd move it; PM bundled it in Plus for the marketing surface. User's call.
4. **Crash-report mechanism** — is it OK to write to `~/Library/Logs/MarkdownViewer/`, or do we need to ask permission first? (Unsigned app + Library writes shouldn't need prompts, but worth confirming.)
5. **Is app icon now in scope for v2.2 ship-blocking?** Currently absent from both docs.

## Calendar reality

PM says 7-8 weeks; I say 10-13 calendar weeks at 10 hr/week. If user wants to ship Plus this calendar quarter, **drop AI-2 chat from v2.2** (ship in v2.2.1) and the original 7-8 week budget becomes achievable.

## Escalation

**No escalation needed.** This is an evening-project view-only app, not money-touching in a way that needs design review (license-key flow is well-understood; AI calls are stateless URLSession). I have enough confidence to start coding v2.0 on my own. Will escalate to staff-engineer **at the v2.2 boundary** specifically to review the license-key flow + Keychain integration before any real money changes hands.

## What I'm underweighting

I'm probably under-weighting the "10 calendar weeks at user's actual cadence" risk — historical evidence is that personal projects on evening/weekend time slip 2-3x, not 1.3x. If user actually has only 4-5 hours/week reliably (vs the assumed 10), every estimate above doubles.
