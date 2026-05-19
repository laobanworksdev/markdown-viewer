# PM Response to solo-engineer feedback v1 — round 2

**Author:** PM
**Date:** 2026-05-18
**Inputs:** `docs/v2-requirements.md` (round 1), `docs/ROADMAP.md` (round 1), `docs/solo-feedback-v1.md`
**Outputs:** `docs/v2-requirements.md` (round 2, in-place edits), `docs/ROADMAP.md` (round 2, in-place edits), this doc (new).

## Headline
Accepted all 6 of solo's headline pushbacks plus most smaller items. v2.2 splits into v2.2.0 (blocking AI) + v2.2.1 (streaming). Voice moves to v2.1 free. Calendar reset to 10-13 weeks.

## Decision table

| # | Solo's pushback | PM decision | Reasoning |
|---|---|---|---|
| 1 | Cut KaTeX/Mermaid permanently (was COULD-v2) | **ACCEPT** | Zero proven demand + 2x/10x bundle hit. Reopen condition documented (dogfood grep in v2.0 week 1; ≥3 hits reopens). |
| 2 | Voice narration → v2.1 free (was v2.2 Plus AI-3) | **ACCEPT** | Solo correctly flagged that AVSpeechSynthesizer is not LLM-based. Re-labeling it as "AI" was marketing fluff. Honest framing: free quality-of-life feature in v2.1 as F-18. Frees v2.2 to focus on actual LLM features + license. |
| 3 | AI-2 chat — blocking-with-spinner first, streaming in v2.2.1 | **ACCEPT** | SSE in URLSession is ~2 days of edge-case Swift work. Blocking is one `data(for:)` call. Promote the round-1 "fallback" to plan-of-record. Streaming becomes a 1-2w v2.2.1 polish patch after real users see the latency. |
| 4 | Pricing — Lemon Squeezy built-in license API + cached phone-home, not Ed25519 + Cloudflare Worker | **ACCEPT** | ~40 LOC vs ~150 LOC + ops surface. **Plus: revocation actually works** (round 1 Ed25519-only could not revoke). Ed25519 stays as future hardening only — trigger documented (≥3 leaked keys or piracy signal). |
| 5 | Calendar +30% (v2.0 2-3w→4-5w; v2.1 2w→4-5w; v2.2 3w→5-6w; total 7-8w→10-13w) | **ACCEPT** | Solo has skin in delivery; calendar realism is solo's specialty. Round-1 numbers were optimistic. Updated all per-feature effort + the weekly Gantt. |
| 6a | Add F-19 Cmd+R manual reload (v2.0 MUST) | **ACCEPT** | 0.25 day. Useful when F-01 watcher misbehaves. Should exist before F-01 anyway. |
| 6b | Add F-20 app icon (v2.2 MUST, before paid launch) | **ACCEPT** | Shipping a paid app with default icon erodes credibility. Was a v1 non-goal; v2.2 paid-tier is the reason to flip it. DIY 2h then commission if needed. |
| 6c | Add F-21 `mdv` CLI shim (v2.0 SHOULD) | **ACCEPT** | 0.25 day. Solo dogfooding aid; power-user nicety. Zero ongoing maintenance. |

### Smaller items also addressed

| Solo item | PM decision | Notes |
|---|---|---|
| F-03 scroll → percentage, not pixel scrollY | ACCEPT | Reflow-robust; one-line impl; handles doc shortening for free. Q-03-a (heading-anchored) closed as overthought. |
| F-06 PDF — drop "page N of M" footer | ACCEPT | WebKit doesn't expose page callbacks cleanly. Workaround is fragile. Q-06-a closed. |
| F-07 theme switching via `<link>` href swap, not CSS-var hot-swap | ACCEPT | Documented in F-07 acceptance. |
| F-10 TOC — path (a) NavigationSplitView | ACCEPT | Locked in. Free keyboard nav + a11y; no JS-pretending-to-be-native. |
| F-10 — render all headings, no 200 cap | ACCEPT | SwiftUI `List` is lazy by default. Q-10-a closed. |
| F-13 — keep existing task-list post-process; only add `markdown-it-footnote` | ACCEPT | Don't pay a cost we already paid. |
| F-08 — ship 2 themes not 4 | ACCEPT | Bikeshedding hole. Add more after F-07 contract validated by user-submitted theme. |
| F-PRICE-1 — drop "Deactivate" button from acceptance | ACCEPT | Saves ~0.5d. Add when a user actually asks. |
| F-01 — render-throw preserves last-good HTML + yellow banner | ACCEPT | New acceptance line. |
| BYO API key first-run wizard | ACCEPT | New Q-AI-4; locked in for v2.2 ship checklist. |
| Crash-log opt-in to `~/Library/Logs/MarkdownViewer/` | ACCEPT | Added to NFR table; default ON; toggle in Preferences → Privacy. |
| v2.0 week-1 dogfood grep for KaTeX/Mermaid | ACCEPT | Deterministic Q-01/Q-02 resolver. Added to v2.0 calendar week 1. |
| 7-min screencast + FAQ before v2.2 launch | ACCEPT | New Q-17 resolved Yes. Added to v2.2 pre-work. |

**Acceptance rate: 6 of 6 headline pushbacks ACCEPT (0 ACCEPT-MOD, 0 COUNTER). Plus 13 smaller items accepted.**

## Updated v2 scope (after solo's feedback)

- **v2.0 — Live & Findable (~4-5 weeks):** F-01, F-02, F-03, F-04, F-05, F-16, **F-19 (Cmd+R, new), F-21 (mdv CLI, new)**
- **v2.1 — Themes, Print, Voice (~4-5 weeks):** F-06, F-07, F-08 (2 themes only), F-09, F-10, F-13, **F-18 (voice, moved from F-17)**
- **v2.2 — Plus tier (~5-6 weeks):** F-PRICE-1 (Lemon Squeezy + 90d cache), F-17/AI-1 (summary, blocking), F-17/AI-2 (chat, blocking + spinner), **F-20 (app icon, new)**, F-14, F-15, monetization launch
- **v2.2.1 — Streaming polish (~1-2 weeks):** F-17/AI-2 → streaming SSE upgrade + v2.2 bug-fix backlog
- **Parked / WON'T-v2:** F-11 KaTeX, F-12 Mermaid (reopen condition: v2.0 grep ≥3 hits)

**Total nominal: 14 weeks calendar with v2.2.1; 10-13 weeks without v2.2.1 polish.**

## Open questions back to solo-engineer

Before code starts on v2.0:

1. **F-05 recent files** — verify whether DocumentGroup gives it free under SwiftPM-without-Xcode. If not, +1 day to wire `NSDocumentController.shared.noteNewRecentDocumentURL`.
2. **F-19 Cmd+R** — same verification (DocumentGroup default vs custom menu item).
3. **F-21 `mdv` install path** — `/usr/local/bin` (sudo prompt) vs `~/.local/bin` (PATH setup). PM rec: `/usr/local/bin`.

Before v2.1 starts:

4. **F-08 second built-in theme** — Paper or Sepia? Solo's design call.
5. **F-18 voice — Cmd+Shift+V vs different shortcut?** PM rec: Cmd+Shift+V.

Before v2.2 starts:

6. **F-20 app icon — DIY or commission?** Decision-by date: v2.2 week 10 start.
7. **Crash log default on or off?** PM rec: ON; opt-out in Preferences.

Operational (whenever):

8. **Plus tier launch — first 100 sales realistic timeline?** Solo asked in feedback. Affects whether the future-hardening Ed25519 path matters in v2.x at all (probably not).

## What's locked (solo can start building these — no further round needed)

- F-01 live reload via `DispatchSource.makeFileSystemObjectSource`, eventMask `[.write,.extend,.delete,.rename]`, re-`open()` on rename, render-throw preserves last-good HTML.
- F-02 find via WKWebView native `find(_:configuration:)`.
- F-03 scroll preservation via percentage (not pixel).
- F-04 drag-drop via `.onDrop(of: [.fileURL])`, replace current doc default.
- F-05 verify DocumentGroup recent-files default; 1d fallback budgeted.
- F-16 zoom via CSS `font-size` on body, persist UserDefaults.
- F-19 Cmd+R verify DocumentGroup default; cheap fallback.
- F-21 `mdv` CLI shim.
- v2.1 features all approach-locked (F-07 link-href swap, F-08 2 themes, F-10 NavigationSplitView).
- v2.2 license flow locked (Lemon Squeezy `/v1/licenses/activate` + 90d Keychain cache, no Ed25519/Worker).
- AI-2 v2.2.0 blocking + spinner; streaming deferred to v2.2.1.
- F-18 voice via AVSpeechSynthesizer, free in v2.1.

## What's still open (not blocking v2.0 start)

- F-08 second theme (Paper vs Sepia) — solo picks.
- F-20 app icon design path (DIY vs commission).
- v2.2 first-run wizard exact UX (wireframe at v2.2 start).
- Crash log default state.

None of these block v2.0 coding starting now.

---

## Pros/Cons trail for the major round-2 decisions

### Pricing model swap: Lemon Squeezy built-in (round 2) vs Ed25519 + Worker (round 1)

**Pros of switching (round 2 approach):**
1. ~40 LOC Swift + zero infra ops; vs ~150 LOC + Cloudflare Worker setup + Ed25519 keypair management.
2. **Revocation works** (Lemon Squeezy admin can disable a key; next 90-day re-check fails). Round-1 Ed25519-only model could not revoke without bricking all legit users.
3. Less moving parts to fail: no Worker outage, no signing-secret rotation worry.
4. ~1.5-2 days of solo's time saved.

**Cons / risks:**
1. **Requires network on first activation** (and day 91+). Round-1 Ed25519 was fully offline after issuance. A user on a plane on day 1 can't activate. Mitigated by 7-day grace window on re-verify.
2. **Vendor lock-in to Lemon Squeezy.** If LS goes down or changes pricing, license check fails for active users. Mitigated by 90-day cache (90 days of LS downtime would be a different kind of disaster).
3. **Future hardening required if piracy real.** Ed25519 + Worker remains the "if abuse arises" path. Build cost deferred but not eliminated.

**Net:** Round-2 approach is correct at <100 sales. Future hardening trigger is documented. Worth the 1.5-2 days.

### Voice narration: free in v2.1 (round 2) vs Plus in v2.2 (round 1)

**Pros of moving to v2.1 free:**
1. **Honest labeling.** It's `AVSpeechSynthesizer`, not LLM. Calling it "AI" was marketing fluff.
2. v2.1 gets a third headline feature beyond themes + print — strengthens that release's user story.
3. v2.2 becomes a tighter, more focused "two real AI features + license" release.
4. Free-tier value increases without cost to Plus value prop (Plus is still LLM-only).

**Cons / risks:**
1. **Plus tier loses a feature.** v2.2 Plus is now 2 features (summary + chat) not 3. May feel thin to some users.
2. **Marketing surface narrower** for v2.2 launch ("two LLM features" vs "three AI features").
3. Solo had to do the calling-out; PM's round 1 labeling was sloppy.

**Net:** Right call. The dishonesty cost (calling AVSpeech "AI") was higher than the marketing cost. Users will notice the misdirection eventually; better to ship honestly.

### Streaming SSE: deferred to v2.2.1 (round 2) vs in v2.2 (round 1)

**Pros of deferring:**
1. Saves ~2 days in v2.2 critical path.
2. Real-user latency observed before designing the cancellation/error UX.
3. v2.2 ships sooner; monetization starts sooner.
4. Blocking + spinner is acceptable for typical 1-5s responses on Haiku.

**Cons / risks:**
1. **First Plus users see worse UX** than they would with streaming. Negative first impression.
2. **v2.2.1 is a "promised but not yet" sub-milestone** — if user's cadence slips, it may never ship.
3. Streaming is genuinely nicer; users who've used ChatGPT/Claude.ai will notice the missing first-token-fast feel.

**Net:** Acceptable tradeoff. Spinner with sub-5s responses is fine for a viewer app. v2.2.1 is a small enough scope that it should land. If it doesn't, the app still works.

---

## Corpus grep results (v2.0 week-1 deliverable)

**Run date:** 2026-05-18 (during v2.0 implementation sweep, solo-engineer).

**Command:**

```sh
grep -rl --include='*.md' -E '\$\$|^[[:space:]]*```mermaid' \
  /Users/nidaye/Projects /Users/nidaye/Documents/screenshots 2>/dev/null
```

**Raw match count (before false-positive triage):** 4 docs.

**After excluding `node_modules/` and this repo's own `docs/` (which discuss `$$` syntax meta-textually):**

| Pattern | Hits (docs) | Notes |
|---|---|---|
| `$$` (KaTeX display-math fence) | 4 | **All false positives.** Inspection shows: (a) one trip restaurant guide using "$$ - $$$" as price-range notation, (b) two financial/trading retros using `$$` as shorthand for "dollars" ("more wins than wrongs by $$", "concentration $$ amount"), (c) zero docs with real math. |
| `^```mermaid` (Mermaid fenced block) | 0 | No Mermaid usage anywhere in the corpus. |

**True hits requiring math/diagram rendering: 0 KaTeX, 0 Mermaid.**

**Park decision holds.** Thresholds were ≥5 docs with `$$` to reopen KaTeX and ≥3 docs with `mermaid` fences to reopen Mermaid. Neither threshold is approached. **F-11 KaTeX and F-12 Mermaid stay WON'T-v2.** Re-run the grep on a future v2.x cycle if user behavior shifts.

---

*End of pm-response-v2.md.*
