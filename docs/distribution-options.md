# Distribution options — Mac App Store, notarization, and what's left of the v2 plan

**Author:** PM
**Date:** 2026-05-18 (round 3 — distribution strategy)
**Audience:** solo-engineer (primary reviewer), user (final approver)
**Companion docs:** `docs/v2-requirements.md`, `docs/ROADMAP.md`, `docs/pm-response-v2.md`, `docs/legal-musts-v2.md`
**Status:** DRAFT — needs solo-engineer review before any toolchain decision is locked.

---

## 0. User's verbatim ask

> "what does it take to launch this on the Mac App Store, and what are all release options?"

Two threads: (1) the App Store path specifically, (2) the full menu of distribution channels so the user can choose with eyes open.

This is a real direction shift from the v2 plan. The plan assumed unsigned DMG + Lemon Squeezy license keys + BYO Anthropic API key. App Store distribution breaks all three assumptions and forces a rethink of the v2.2 monetization plan.

---

## 1. Apple Developer Program enrollment

### Cost & posture

- **$99/year, individual enrollment.** No D-U-N-S Number required for individual/sole-proprietor enrollment. ([Apple D-U-N-S help](https://developer.apple.com/help/account/membership/D-U-N-S/))
- Organization enrollment is $99/year too — same cost, but adds the D-U-N-S Number step (free but takes 1-5 business days to obtain). Organization enrollment lets you list a company name on the App Store, but for a solo dev the legal-name listing under Individual is fine.
- The $299/year Enterprise Program is **NOT** the path here — that's for private internal-employee distribution and explicitly cannot ship to the App Store. ([Apple Developer Program](https://developer.apple.com/programs/))

**Recommendation: enroll as Individual.** Saves the D-U-N-S step; the App Store seller name will be the user's legal name (visible on the listing). If the project ever incorporates, switching from Individual to Organization is supported and preserves App Store Connect history.

### What $99/year unlocks (same set whether you ship to App Store or just notarize)

| Capability | Why it matters here |
|---|---|
| Developer ID Application certificate | Code-sign the `.app` bundle for direct-download distribution (Option B) |
| Notarization service (`xcrun notarytool`) | Submit the signed `.app` / `.dmg` to Apple for malware scan; receive a stapled ticket so Gatekeeper allows it with no "right-click → Open" friction |
| App Store Connect access | Submit, configure metadata, manage TestFlight, view sales/analytics for App Store distribution (Option C/D) |
| TestFlight | Free beta-testing channel for up to 10,000 external testers (App Store path only) |
| In-App Purchase via StoreKit | The ONLY way to charge for digital content/features inside an App Store-distributed app (Option C/D) |
| App Store / search / featured | Built-in distribution & discovery (Option C/D) |

### Enrollment timeline

- **Individual:** typically 24-48 hours after submitting the form, though identity-verification holds can push it to a week. ([Apple Developer help — Enrollment](https://developer.apple.com/help/account/membership/program-enrollment/))
- **Organization (D-U-N-S):** plan for **1-3 weeks** end-to-end (D-U-N-S lookup/registration + Apple's call-back to verify the listed phone number).

For a solo dev under time pressure, Individual is the lower-friction path. Decision is reversible at the cost of a re-enrollment process.

---

## 2. The four distribution options at a glance

| | **A. Status quo** | **B. Notarized DMG** | **C. Mac App Store only** | **D. Dual: Notarized DMG + MAS** |
|---|---|---|---|---|
| **Channel** | Unsigned DMG, direct download | Signed + notarized DMG, direct download | Mac App Store | Both |
| **Dev Program cost** | $0 | $99/yr | $99/yr | $99/yr (one membership covers both) |
| **Revenue share** | 100% to dev (minus storefront cut — Lemon Squeezy ~5%) | Same as A | 30% to Apple year 1; 15% after Small Business Program ($1M/yr cap) | Mixed: DMG = 100% minus storefront; MAS purchases = 70/85% |
| **Time-to-launch from today** | Now | ~1-2 weeks after enrollment | **~6-10 weeks for first submission** (enrollment + sandbox refactor + screenshots + metadata + review cycles) | ~6-10 weeks (parallel) |
| **First-launch UX friction** | "Right-click → Open" once | Zero | Zero | Zero on both |
| **App Store discoverability** | None (your own website + word of mouth) | None | Yes (search, categories, featured potential) | Partial (MAS visible; DMG is your own marketing) |
| **In-App Purchase available** | No (must use Lemon Squeezy + license key) | No (must use Lemon Squeezy + license key) | **Yes (required for digital unlocks)** | DMG: license key; MAS: IAP |
| **Auto-update** | None (redownload DMG) | None (or Sparkle bolted on) | Built-in (App Store updates) | Built-in for MAS; redownload for DMG |
| **Toolchain change** | None | Add `codesign` + `notarytool` to `make-dmg.sh` | **Requires `xcodebuild` for packaging** (Xcode CLT alone is not enough for an `.xcarchive`) | Both required |
| **Sandbox required** | No | No | **Yes — non-negotiable** | DMG version no; MAS version yes |
| **Review/rejection risk** | None | None (notarization is automated scan, not human review) | Real (Guideline 3.1.1, 4.7, 5.1.2 all apply) | Inherits MAS review risk for that build |
| **BYO Anthropic API key (v2.2 AI plan)** | OK | OK | **High rejection risk under 3.1.1** — see §3.D | DMG: OK; MAS: rejected → must change pricing model |

---

### A. Status quo — unsigned DMG (current)

- **What ships:** what we already build. `scripts/build.sh` → `MarkdownViewer.app` → `scripts/make-dmg.sh` → `MarkdownViewer-<version>.dmg`. No signing, no notarization, no sandbox.
- **Gatekeeper:** first-launch friction is "right-click → Open" once. Documented in README.
- **Pricing fit:** Lemon Squeezy + BYO API key (current v2.2 plan) works as-is.
- **Pros**
  1. **Zero new cost.** No $99/year fee.
  2. **Zero new toolchain.** SwiftPM stays the only build system.
  3. **Zero ongoing Apple-relationship overhead.** No enrollment, no review queue, no metadata churn, no surprise rejections.
  4. **Full revenue keep** minus storefront cut (~5% Lemon Squeezy).
  5. **AI feature plan survives untouched.** BYO API key is contractually clean outside the App Store.
- **Cons / risks**
  1. **First-launch friction is real.** "Right-click → Open" is the #1 reason non-technical Mac users abandon installation. Estimate: **20-40% drop-off** for non-technical buyers, near-zero for power users who already know the dance.
  2. **No discoverability.** Sales come from word-of-mouth, blog posts, HN/Reddit launch posts, and the project's own website. Marked 2's 10-year App Store listing is its discovery engine; we have nothing.
  3. **No auto-update.** v2.1 → v2.2 means re-download.
  4. **Trust signal is low.** Unsigned binaries register as malware-suspect to many users (some corp-managed Macs refuse to launch them at all).

**When this option is right:** if user wants to ship v2.0 immediately and validate demand before paying $99/year. Re-evaluate Option B once first 10 paying users exist.

---

### B. Notarized DMG — the "middle path"

- **What ships:** Same `.app` and `.dmg` as Option A, but the `.app` is code-signed with a Developer ID Application cert, the `.dmg` is then signed too, then submitted to Apple's notarization service via `xcrun notarytool`, then `xcrun stapler` attaches the approval ticket. First-launch UX is zero-friction — Gatekeeper sees a signed-and-notarized bundle and allows it normally. ([Apple Developer — Developer ID](https://developer.apple.com/developer-id/))
- **What enters the toolchain:** A new `scripts/notarize.sh` step that runs after `make-dmg.sh`. ~30 lines of shell calling `codesign --deep --options=runtime -s "Developer ID Application: <Name>"`, then `xcrun notarytool submit --wait`, then `xcrun stapler staple`. The toolchain is **Command Line Tools only — no Xcode required** for the notarize step itself. ([SuccessfulSoftware — How to notarize on macOS](https://successfulsoftware.net/2018/11/16/how-to-notarize-your-software-on-macos/))
- **What you need:** Developer ID Application cert (free with $99/yr Dev Program), an app-specific password for `notarytool`, and the team ID. One-time setup.
- **What changes in the codebase:** Add `hardened runtime` to the codesign step (`--options=runtime`). May need a basic entitlements file to allow JIT in WKWebView (`com.apple.security.cs.allow-jit`) — **TBD, solo-engineer to verify**. **No sandbox required for Developer-ID notarization.** File-watching, file-reading from arbitrary paths, network access — all unrestricted.
- **Pricing fit:** Lemon Squeezy + BYO API key continues to work cleanly.
- **Notarization round-trip:** typically 5-30 minutes, fully automated, free. No human review.
- **Pros**
  1. **Zero first-launch friction.** Users double-click the `.dmg`, drag to Applications, launch. No Gatekeeper prompt.
  2. **No sandbox limits.** Our DispatchSource file watcher (F-01), arbitrary themes folder reads (F-07), and direct network calls all work as planned.
  3. **No App Review.** Apple's notarization is automated malware scanning — it doesn't reject for product design choices, only for actual malware signatures and missing-signature errors.
  4. **Same revenue model as Option A.** Lemon Squeezy stays. BYO API key stays. v2.2 monetization plan survives.
  5. **Real upgrade in trust signal.** "Signed & notarized by <legal name>" appears in macOS app inspector. Corp-managed Macs accept it. Press / blog reviewers take you more seriously.
  6. **Reversible.** Can always layer Option D (MAS) on top later without losing the DMG channel.
- **Cons / risks**
  1. **$99/year recurring.** Cert renewal is annual; if you let the cert lapse, future builds aren't notarized but existing installs keep working.
  2. **Still no App Store discoverability.** Same marketing problem as Option A.
  3. **Auto-update still requires Sparkle** or equivalent — not in v2 plan, not adding it.
  4. **One-time toolchain setup pain.** First successful notarization run typically takes 1-3 hours of fighting `codesign` errors (entitlements, `--deep` quirks, hardened-runtime restrictions).
  5. **Trust signal is "individual," not "company."** App inspector shows your legal name, not a company. Some users prefer the latter; most won't notice.

**When this option is right:** the user wants to charge money (v2.2 Plus) but doesn't want to commit to the App Store's sandbox + review + IAP overhead. **This is the strict upgrade from Option A.** Everything Option A does, this does better, for $99/year.

---

### C. Mac App Store only

- **What ships:** A sandboxed `.app` packaged as a `.pkg` (or `.xcarchive` upload), submitted via App Store Connect, reviewed by Apple, and listed on the Mac App Store. ([Apple Developer — Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/))
- **Hard requirements that change the project:**
  1. **`xcodebuild` enters the toolchain.** SwiftPM alone cannot produce an `.xcarchive` suitable for App Store submission. Two options to address this without abandoning SwiftPM as the dev build:
      - **(C-1)** Keep SwiftPM for `swift build`-based dev iteration; add a minimal `.xcodeproj` or `Package.swift`-driven `xcodebuild` target solely for the release-cut step. ~half-day of one-time setup; the dev loop stays SwiftPM. (Tradeoff: the project now has two build systems for one app, which the current CLAUDE.md explicitly bans.)
      - **(C-2)** Migrate fully to a `.xcodeproj`. SwiftPM dies. **This violates the current CLAUDE.md hard constraint** "No Xcode. Only `swift build` / SwiftPM."
      - **Recommendation: (C-1)**, and update CLAUDE.md to allow `xcodebuild` for release-cut only.
  2. **App Sandbox is non-negotiable.** Mac App Store apps **MUST** run sandboxed. ([App Sandbox guideline 2.5.4](https://developer.apple.com/app-store/review/guidelines/#software-requirements))
      - **F-01 live reload via `DispatchSource`:** **WORKS IN SANDBOX**, but with one constraint. The user must explicitly open the file via DocumentGroup / NSOpenPanel / drag-drop (which our current code already does). After the user picks the file, we get a security-scoped URL and must call `startAccessingSecurityScopedResource()` before opening the file descriptor. The DispatchSource watcher works on that fd. Solo-engineer needs to verify the live-reload code paths obtain and persist the security scope correctly. ([Apple — Accessing files from the macOS App Sandbox](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox))
      - **F-07 custom CSS themes folder:** the planned `~/Library/Application Support/MarkdownViewer/themes/` is in the app's container under sandbox — **fully writable/readable by the app**. No entitlement needed for the container itself. Listing themes works; loading external `.css` works. Provisioning to also read `~/Library/Application Support/<elsewhere>` is harder; container-only is fine.
      - **F-17 AI calls to api.anthropic.com:** needs `com.apple.security.network.client` entitlement. Trivial to add.
      - **F-PRICE-1 Lemon Squeezy license API:** Apple's Guideline 3.1.1 **prohibits license keys for unlocking digital content/features in Mac App Store apps.** See §3 below — this is a real blocker for the v2.2 plan.
  3. **App Store Review.** Human review. First submission is typically **3-10 days** wall-clock when you count the inevitable 1-2 rejection rounds and resubmission. Apple's median for new apps is 24-48 hours per submission round; first-time apps from new devs face stricter review and more rejections. ([Lowcode.agency — App Store Review Time 2026](https://www.lowcode.agency/blog/app-store-review-time))
  4. **App Store metadata.** Screenshots (1280×800 and 2880×1800 PNG), feature graphic, description (4000 chars), keywords (100 chars), categories, age rating, support URL, privacy policy URL, Privacy Nutrition Labels questionnaire. Estimate: **2-3 days of pre-submission work** assembled fresh.
- **Pricing fit — this is where it breaks:**
  - **License keys not allowed under 3.1.1.** Apple is explicit: "If you want to unlock features or functionality within your app, you must use in-app purchase. You cannot use ... license keys."
  - **In-App Purchase IS allowed and is the only path.** $12 one-time non-consumable IAP is fully supported.
  - **30% commission year 1; 15% after enrolling in Apple Small Business Program** (free, automatic if under $1M/yr lifetime). ([Apple Small Business Program](https://developer.apple.com/app-store/small-business-program/)) For a solo dev, the 15% rate kicks in essentially immediately on enrollment.
  - **BYO Anthropic API key is at high rejection risk.** See §3.D — Guideline 5.1.2(i) requires explicit disclosure and consent for third-party AI, and reviewers have historically rejected wrappers that look like they're routing the user around IAP by having them pay a third party for the AI value.
- **Pros**
  1. **Built-in discoverability.** Marked 2 lives on Mac App Store search; it's the largest source of new installs in this space.
  2. **Built-in payments + IAP.** No Lemon Squeezy, no license-key plumbing, no Keychain caching. Apple handles taxes, refunds, fraud, currencies, EU VAT.
  3. **Zero install friction.** One click, signed by Apple.
  4. **Auto-update built in.** v2.0 → v2.1 → v2.2 just appear.
  5. **Trust signal is maximum.** "From the App Store" = green-light to even the most cautious Mac users (older users, corp Macs).
  6. **EULA is Apple's standard.** No custom EULA needed; legal-eagle's §2.4 ($200-800 EULA cost) goes away. ([Apple Standard EULA](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/))
- **Cons / risks**
  1. **15-30% revenue cut.** $12 IAP nets $10.20 (Small Business 15%) or $8.40 (standard 30%). Worse than Lemon Squeezy's ~5%.
  2. **App Review is a black box.** Rejections can hit anything from icon design to one ambiguous menu label. Median first-submission has 1-2 rejection cycles. **Plan for 4-6 weeks from first submission to "live."**
  3. **Sandbox forces real refactor.** Even though our existing code is already mostly sandbox-compatible (we always open files via DocumentGroup), the live-reload watcher needs explicit security-scoped resource accounting. Estimate: **2-4 days of solo-eng time**, plus a real risk of one Apple-rejection cycle on this specific point.
  4. **BYO API key model is at risk.** See §3 — the AI feature plan may need to flip to hosted/managed with token caps, or drop AI from MAS entirely.
  5. **`xcodebuild` enters the build pipeline.** Violates the current CLAUDE.md hard constraint. Has to be relaxed.
  6. **Sparkle / auto-update goes away (replaced by App Store updates).** Good, except: the MAS update cadence is at Apple's mercy — first-week post-submission, your release is delayed by review every time. A 1-line bug fix can wait 2-3 days for approval.
  7. **Vendor lock-in.** If Apple changes policy (3.1.1 enforcement is notoriously inconsistent), users on MAS have no fallback. Direct-DMG users keep using whatever version they installed.
  8. **No TestFlight for Mac is awkward.** TestFlight does support Mac apps but the workflow is clunkier than iOS — most macOS devs ship to a private group via direct-DMG, then publish to MAS. Means we'd want Option D, not pure C.
- **When this option is right (alone, without D):** the user has zero interest in maintaining direct-download infrastructure and wants maximum discoverability at the cost of 15% rev share and review-cycle friction. Rare choice for an indie Mac dev with technical-user audience; common choice for consumer-facing apps with non-technical audience.

---

### D. Dual: Notarized DMG + Mac App Store

- **What ships:** Two builds from one codebase. The DMG build is signed-and-notarized, distributes via your website, uses Lemon Squeezy + license key for Plus. The MAS build is sandboxed, distributes via App Store, uses StoreKit IAP for Plus.
- **Codebase:** one source tree, two product configurations. Conditional compilation (`#if MAS_BUILD`) for the license-vs-IAP unlock check. Sandbox entitlements only apply to the MAS build. Network entitlement applies to both (notarization with hardened runtime also requires explicit entitlements for some operations).
- **Build pipeline:**
  - `scripts/build-dmg.sh` → unsandboxed `.app` → notarized `.dmg`. Existing pipeline + notarize step.
  - `scripts/build-mas.sh` → sandboxed `.app` → signed with **Mac App Distribution** cert → packaged with `productbuild` → uploaded via `xcrun altool` (or Transporter). **Requires `xcodebuild` for the archive step.**
- **Cost:** $99/year covers both (one Dev Program membership emits both certs).
- **Pricing:**
  - **DMG users buy via Lemon Squeezy** → $12 → $11.40 net (5% storefront fee). License key activates AI.
  - **MAS users buy via IAP** → $12 → $10.20 net (15% Small Business). StoreKit unlock activates AI.
  - **Different unlock paths must coexist.** App detects which build it is and shows the appropriate unlock UI.
  - **AI features are the same on both,** subject to whatever §3.D rejection-risk resolution we land on (BYO key vs hosted vs hybrid).
- **Pros**
  1. **Best of both worlds.** Discoverability via MAS + full margins on DMG + flexibility on AI pricing if MAS rejects BYO key.
  2. **Power users / corp users still served by DMG channel** without sandbox limits (full disk access, larger themes folder, etc.).
  3. **Insurance against MAS rejection.** If Apple's review goes sideways on AI, the DMG channel still ships.
  4. **Marked 2 is the proof point.** Marked 2 maintains both for ~10 years with same one-time pricing.
- **Cons / risks**
  1. **Two unlock systems to maintain.** Lemon Squeezy + license keys + Keychain cache for DMG; StoreKit + receipt validation for MAS. Estimated **+3-5 days of solo-eng time** in v2.2 vs Option B alone.
  2. **Two build pipelines.** Plus the MAS-build pipeline still requires `xcodebuild`.
  3. **Two privacy / EULA postures.** MAS uses Apple's standard EULA + Privacy Nutrition Labels questionnaire. DMG needs custom EULA per legal-eagle §2.4 + a self-hosted privacy policy. **Both need to exist.**
  4. **Twice the support surface.** "I bought it on the DMG, can I get the MAS version free?" "I'm on MAS and my Anthropic API key has friction; can I use the DMG version instead?" Real questions, real time.
  5. **Pricing arbitrage opportunity.** If DMG is $12 and MAS is also $12 but nets less, why does the dev want MAS sales? Answer: discoverability + Apple-trust signal. Some devs price MAS at $14.99 to compensate for the 15% — but that creates "MAS users pay more for less (sandbox)" optics. Risky.
- **When this option is right:** the user is committed to long-term ownership of this product (5+ years) and wants discoverability without abandoning the direct channel. The right answer for Marked 2 — the right answer here too IF the user wants to commit.

---

## 3. App Store-specific MUSTs (only relevant if Option C or D)

### 3.A — Sandboxing

- **Hard requirement.** Cannot opt out. Mac App Store apps run with `com.apple.security.app-sandbox` entitlement set to TRUE.
- **What works in sandbox without changes:**
  - DocumentGroup-based file opening (already used). User picks file → app gets security-scoped URL → we can read.
  - WKWebView loading bundled HTML/JS/CSS (resource bundle access is always allowed).
  - App's own container at `~/Library/Containers/<bundle-id>/Data/Library/Application Support/` for themes, settings, license cache.
- **What needs new entitlements:**
  - `com.apple.security.files.user-selected.read-write` — for files the user picks via NSOpenPanel/DocumentGroup. **Required for our use case.**
  - `com.apple.security.files.bookmarks.app-scope` — to persist file access across launches (recent-files functionality, F-05). **Required.**
  - `com.apple.security.network.client` — outbound HTTPS to api.anthropic.com (F-17) and IAP receipt validation. **Required.**
- **What needs code changes:**
  - **F-01 live reload.** Current plan: `open()` the path → `DispatchSource.makeFileSystemObjectSource(fileDescriptor:...)`. In sandbox: the file URL we got from DocumentGroup is security-scoped. We must call `url.startAccessingSecurityScopedResource()` before `open()`, hold the access alive for the watcher's lifetime, and call `stopAccessingSecurityScopedResource()` on close. Solo-engineer needs to verify our re-`open()`-on-rename pattern handles the security-scope lifecycle correctly. ([CODEBIT — File System Access in macOS Sandboxed Apps](https://codebit-inc.com/blog/mastering-file-access-macos-sandboxed-apps/))
  - **F-05 recent files.** Sandbox cannot read arbitrary recent-files paths after relaunch unless we stored security-scoped bookmarks for them. SwiftUI's DocumentGroup may handle this automatically — solo to verify; otherwise we explicitly serialize bookmarks per recent file.
- **What gets harder:**
  - **Symlinks pointing outside the sandbox** — the watcher follows them, but the sandbox blocks the actual file read. User opening a `.md` that's symlinked from `~/Documents/notes.md` to `~/external-drive/notes.md` works only if the *original* user-selected path is preserved through symlink resolution. Solo to test.
  - **The `mdv` CLI shim (F-21).** A sandboxed MAS app launched via `open -a` cannot receive arbitrary file paths as launch arguments without those paths being security-scoped. F-21 likely **does not work** in the MAS build. (It works fine in the DMG build.) Cut from MAS-only release, keep in DMG release.

### 3.B — Required entitlements (Mac App Store build)

```xml
<key>com.apple.security.app-sandbox</key><true/>
<key>com.apple.security.files.user-selected.read-write</key><true/>
<key>com.apple.security.files.bookmarks.app-scope</key><true/>
<key>com.apple.security.network.client</key><true/>
```

That's the minimum set. Each one we add expands the "permissions" line Apple shows in our review. We don't need any more for the v2 feature set.

### 3.C — Privacy Nutrition Labels (Guideline 5.1.1 + App Store Connect)

When submitting via App Store Connect, we fill out the privacy questionnaire. For our app, the answers are mostly "No":

| Question | Answer |
|---|---|
| Does the app collect data linked to the user? | No (no analytics, no telemetry, no PII collected by us) |
| Does the app collect data not linked to the user? | No |
| Does the app share data with third parties? | **YES — Anthropic (when user invokes AI feature)** |
| What data is shared with Anthropic? | "User Content (document text the user has opened, sent only when the user explicitly invokes an AI command)" |
| Is the Anthropic share tied to user identity? | No (the Anthropic key is the user's own; we don't link to the user's Apple identity) |
| Is the Anthropic share used for tracking? | No |

The label that prints on the App Store listing will say: **"Data Used to Track You: None. Data Linked to You: None. Data Not Linked to You: User Content (document text)."** ([Apple — App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/))

**Privacy policy URL is required** as part of the submission. Legal-eagle §2.3-C already flagged this; the policy text is the same single-pager we'd need for Option B's Lemon Squeezy listing anyway.

### 3.D — The Guideline 3.1.1 + 5.1.2(i) AI problem

This is the single biggest unknown for App Store distribution. Three pieces:

**Guideline 3.1.1** says: *"If you want to unlock features or functionality within your app, you must use in-app purchase. ... You may not use ... license keys ... or other mechanisms to enable users to unlock additional features or functionality."*

This **kills the Lemon Squeezy license-key approach for an MAS build.** Plus tier in MAS must be an IAP. Fine — StoreKit supports a non-consumable $12 IAP cleanly.

**Guideline 5.1.2(i)** (added/updated late 2025) requires: *"You must clearly disclose where personal data will be shared with third parties, including with third-party AI, and obtain explicit permission before doing so."* ([Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/))

For our AI features, this means:
- The first time a user invokes "Doc Summary" or "Ask Doc," show a modal: **"This feature sends the contents of the open document to Anthropic's API. Anthropic is a third-party AI provider. Continue? [Allow] [Cancel]"**. Persist the consent. ([dev.to — Guideline 5.1.2(i)](https://dev.to/arshtechpro/apples-guideline-512i-the-ai-data-sharing-rule-that-will-impact-every-ios-developer-1b0p))
- Disclose "Anthropic" by name in the Privacy Nutrition Labels and the in-app privacy policy.
- This is **trivial** to implement (~1 day of work). It does not block App Store distribution.

**The harder question — BYO API key:**

Apple has not published an explicit rule banning BYO API keys for AI wrappers. But Guideline 3.1.1 includes broad language about "unlocking functionality" and **reviewers have rejected wrapper apps in the past for routing users to pay a third party for the value the app delivers.** The standard reading:

- **Lower risk:** if AI is presented as "you're consuming your own Anthropic credits via a UI we provide" — i.e., the AI value comes from the user's existing Anthropic relationship, and the app is just a convenience wrapper. The IAP unlocks "the convenience of the UI," not the AI itself.
- **Higher risk:** if AI is presented as the primary value of the Plus tier with no app-side IAP cost — Apple may say "you're using a third-party paid service to deliver app functionality, and that bypasses our IAP."

**Three viable paths for MAS-build AI:**

1. **Drop AI from the MAS build entirely.** v2.2 Plus on MAS is "future-features-when-they-ship"; AI ships on DMG only. Cleanest from a rejection-risk view. Worst from a "users buy MAS but get a worse product" view.
2. **MAS-build AI = hosted with dev's key, capped.** App is free or $12 paid-up-front; AI features run via dev-side relay with a fair-use cap (e.g., 200 AI calls/month per buyer). Dev eats Anthropic cost up to the cap. At Haiku 4.5 rates ($1/M input, $5/M output) and ~$0.008/call, 200 calls = $1.60/buyer/month — sustainable at $12 lifetime if buyers average <6 months of active use, dangerous if they average more.
3. **MAS-build AI = BYO key with clear "your Anthropic, your cost" framing.** Risk an Apple rejection; have plan #1 or #2 ready as the resubmit. **Recommended path:** submit as BYO; if rejected, fall back to hosted-with-cap; if that's rejected, drop AI from MAS.

### 3.E — Guideline 4.7 (Mini Apps / Streaming) — does it apply?

- **No.** We don't load third-party plugins, we don't download code at runtime, our markdown-it and highlight.js are vendored at build time, and the rendered HTML is *the user's own document*, not third-party content. 4.7 targets apps that *primarily* display third-party content with dynamic loading (think: emulators, web browsers with extensions, app-within-an-app frameworks). Our profile is closer to Preview.app or TextEdit. Verified against the guideline text — no triggers fire.

### 3.F — Guideline 5.2 (IP) — covered

- markdown-it (MIT) and highlight.js (BSD-3) are vendored with attribution per legal-eagle's `THIRD_PARTY_LICENSES.md` ask. No 5.2 issue.

---

## 4. Pricing model revisited for App Store

Current plan (Option A/B): $12 one-time, Lemon Squeezy + license key, BYO Anthropic API key.

In Option C or D, the MAS build needs a different unlock model. Here are the four viable models:

### Model 1: App is paid up front; no IAP; AI uses dev-hosted key with cap

- **MAS listing price:** $12.
- **AI:** dev-hosted relay; cap N calls/month per buyer; over-cap = "out of monthly AI quota, resets on the 1st."
- **Net to dev:** $12 × 85% = **$10.20** (Small Business 15%).
- **AI cost to dev:** ~$0.008/call. At N=200/month: $1.60/buyer/month worst-case.
- **Rejection risk:** Low. Apple wants exactly this kind of paid-app + hosted-feature model.
- **Pros**
  1. Cleanest review posture — Apple loves paid-up-front apps with no IAP weirdness.
  2. No free-vs-Plus tier UX in the app.
  3. AI feels like a feature, not an add-on.
- **Cons**
  1. **Free-tier users disappear.** Currently the plan is "the viewer is free forever; AI is the paid add-on." Model 1 means even non-AI users pay $12. Loses the free-acquisition funnel.
  2. **Dev now eats AI cost.** A new ongoing operational expense + a relay server to operate (~$5/month + maintenance).
  3. **Cap UX is fraught.** "You hit your monthly limit" is a bad message for a one-time-purchase app.
  4. **Anthropic API cost can spike** if a user becomes a power user. Cap protects against the worst case but not the median.

### Model 2: App is free; non-consumable IAP unlocks Plus; AI uses dev-hosted key with cap

- **MAS listing price:** Free.
- **In-app:** "Markdown Viewer Plus — $12 one-time" non-consumable IAP unlocks AI + future Plus features.
- **AI:** dev-hosted relay; cap N calls/month per Plus buyer.
- **Net to dev:** Same as Model 1, $10.20 per Plus IAP.
- **Pros**
  1. **Preserves free-tier funnel.** Viewer is free; users discover via App Store; they upgrade to Plus when they want AI.
  2. **Better App Store discoverability** (free apps get more downloads → more discovery signals).
  3. **Closest match to the current v2 plan structure** (free viewer + paid AI tier).
- **Cons**
  1. Same dev-hosted relay + cap UX issues as Model 1.
  2. **Two SKUs to maintain** (free app + Plus IAP) vs Model 1's single SKU.
  3. **IAP receipt validation code** needs to ship. Apple provides StoreKit2; ~50 LOC.

### Model 3: App is free; non-consumable IAP unlocks Plus features; AI uses user's own Anthropic key (BYO)

- **MAS listing price:** Free.
- **In-app:** $12 IAP unlocks "the AI feature panel" (UI access). AI calls themselves use the user's own Anthropic key from Settings.
- **Net to dev:** $10.20 per Plus IAP.
- **Framing for review:** "$12 unlocks the AI UI, search index, summary persistence, and Plus features. AI calls themselves are made directly from the app to Anthropic using your own API key — Anthropic charges you for actual token usage."
- **Pros**
  1. **Closest to current v2 plan economics.** Dev eats no AI cost; rev/sale stays at $10.20.
  2. **Honest framing.** "We're selling you the UI; the AI is your relationship with Anthropic."
  3. **No relay server, no ops surface.**
- **Cons**
  1. **Highest 3.1.1 rejection risk.** Apple reviewers may decide the IAP "unlocks the AI" and therefore the user is being routed to pay a third party for app value. Outcome unpredictable.
  2. **BYO friction wall** — same as Option A/B. User has to get an Anthropic key. (7-min screencast mitigation from v2.2 plan still applies.)

### Model 4: MAS build ships WITHOUT AI; only DMG has AI

- **MAS listing price:** $12 one-time (or Free if we want IAP for "Plus" = themes / future features).
- **AI:** Not available in MAS build at all. AI feature is exclusive to the direct-download notarized DMG, which uses Lemon Squeezy + BYO API key.
- **Net to dev:** $10.20 for MAS sales; $11.40 for DMG sales.
- **Pros**
  1. **Zero MAS rejection risk on AI.** No AI in the build = nothing for Apple to scrutinize.
  2. **MAS becomes the "stable, sandboxed" channel; DMG is the "power user" channel.** Clear product positioning.
  3. **No dev-hosted relay needed.**
- **Cons**
  1. **MAS users get the worse product.** Likely confusion: "I downloaded it from the App Store and AI isn't there?"
  2. **Doubles the explanatory surface in marketing** — "buy DMG for AI, MAS for everything else."
  3. **AI is the centerpiece of v2.2 monetization.** If MAS can't offer it, MAS sales are essentially viewer-only at $12. Possibly fine; possibly bad.

### Pricing model — net recommendation

| Model | Recommended for | Year-1 net per sale | Risk |
|---|---|---|---|
| **Model 1: Paid-up-front + hosted AI cap** | Apps where AI is core but BYO is too much friction | $10.20 | Low review risk; medium ops risk |
| **Model 2: Free + IAP + hosted AI cap** | **Best fit for a free-discovery-funnel app** | $10.20 per Plus IAP | Low review risk; medium ops risk |
| **Model 3: Free + IAP + BYO key** | Direct ports of the existing DMG plan | $10.20 per Plus IAP | High review risk; low ops risk |
| **Model 4: MAS without AI** | Cheapest path to listing; AI exclusive to DMG | $10.20 (or $11.40 DMG) | Zero review risk for AI; product-clarity risk |

**PM recommendation: Model 2 for the MAS build if we go Option C or D.** It mirrors the free-viewer + paid-AI structure of the existing plan, sustains the App Store discoverability funnel, and routes around the BYO-3.1.1 rejection risk.

**The cost is real:** dev now operates an AI relay server. Cheapest path is Cloudflare Worker proxy (~$5/month at low volume + free tier covers up to 100k requests/day) that proxies api.anthropic.com with a single shared key, validated against an IAP receipt server-side. ~1 weekend of Cloudflare Worker work. Cap at 200 calls/month per buyer = $1.60 worst-case monthly cost per buyer. Break-even on a $10.20 sale is ~6 months of capped usage; users who don't use AI heavily extend the runway.

---

## 5. Toolchain & build pipeline changes per option

| Option | What changes |
|---|---|
| **A** | Nothing. SwiftPM stays. |
| **B (notarize-only)** | New `scripts/notarize.sh` (~30 lines shell). Uses `codesign` + `xcrun notarytool` + `xcrun stapler` — all CLT-native, **no Xcode required**. New file: `MarkdownViewer.entitlements` for hardened-runtime allowances. CLAUDE.md updated to allow `codesign`/`notarytool`/`stapler` in the build pipeline. |
| **C / D (MAS build)** | **Xcode enters the picture.** Need `xcodebuild` to produce an `.xcarchive` for App Store submission. Minimal `.xcodeproj` (or SwiftPM-shimmed via `xcodebuild -package-path .`) for the release-cut step only. Dev iteration stays SwiftPM. CLAUDE.md hard-constraint "No Xcode" needs explicit relaxation: "Xcode allowed for MAS release-cut only; dev loop stays SwiftPM-only." Plus the entitlements file, the sandbox-aware code paths (security-scoped bookmarks), and StoreKit IAP plumbing. |

### What stays on SwiftPM regardless

The dev workflow. `swift build` continues to produce a workable `.app` for testing. `scripts/build.sh` continues to be the everyday command. Xcode/`xcodebuild` only runs at release-cut time when packaging for App Store submission.

### Concrete release-cut workflow (Option D — the most complex)

```
# Daily dev (no change):
scripts/build.sh                            # SwiftPM build → build/MarkdownViewer.app
open build/MarkdownViewer.app

# Release-cut — DMG channel:
scripts/build.sh                            # produce unsandboxed .app
scripts/sign-and-notarize.sh                # codesign + notarytool + stapler
scripts/make-dmg.sh                         # build/MarkdownViewer-X.Y.Z.dmg
# → upload to your website

# Release-cut — MAS channel:
scripts/build-mas.sh                        # xcodebuild archive with sandbox entitlements
                                             #   produces build/MarkdownViewer-MAS.xcarchive
xcodebuild -exportArchive ... -exportOptionsPlist mas-export.plist
xcrun altool --upload-package ... --type macos
# → App Store Connect → submit for review
```

Estimate to scaffold all of this: **3-5 days of solo-eng time at the v2.2-pre-launch boundary.** The Xcode side is the riskiest because it's brand-new territory for this project; the notarize side is well-trodden (lots of public examples).

---

## 6. Updated v2 roadmap (assumes recommended path: **Option B → Option D**, see §7)

The recommended path is to **enroll in the Apple Developer Program now, ship v2.0 + v2.1 as notarized DMG only (Option B), then add the Mac App Store channel at the v2.2 boundary (Option D).** This gives us discoverability when we have something to sell, without paying the App Store overhead during free-only releases.

### Updated calendar

| Week | Activity | Distribution context |
|---|---|---|
| 0 (pre-coding) | Apple Developer Program individual enrollment ($99); Developer ID Application cert; app-specific password; one-shot notarization smoke test on current v1 build | Adds notarized v1 DMG as proof-of-concept |
| 1 | v2.0 dogfood-grep, F-19 (Cmd+R), F-21 (mdv CLI), F-01 setup; **add `scripts/notarize.sh`** | Notarized DMG channel live |
| 2 | v2.0 — F-01 (live reload + atomic-rename test matrix) | — |
| 3 | v2.0 — F-03 (scroll %) + F-02 (find) | — |
| 4 | v2.0 — F-04 (drag-drop) + F-05 (recent) + F-16 (zoom) | — |
| 5 | v2.0 — dogfood + DMG ship (now signed + notarized) | First user-facing release with zero-friction install |
| 6 | v2.1 — F-06 (PDF) + F-09 (code polish) | — |
| 7 | v2.1 — F-07 + F-08 (2 themes) + F-13 (footnotes) | — |
| 8 | v2.1 — F-10 (TOC) + F-18 (Read Aloud) | — |
| 9 | v2.1 — dogfood + DMG ship | — |
| **10** | **v2.2 pre-launch sprint:** privacy policy + EULA (per legal-eagle §2.4) + Lemon Squeezy storefront setup + **Mac App Store Connect setup** + screenshots (1280×800 + 2880×1800) + app description + keywords + Privacy Nutrition Label questionnaire + **`xcodebuild` integration (1-2 days, solo)** + **sandbox refactor of F-01 watcher to use security-scoped bookmarks (1-2 days, solo)** + **StoreKit IAP scaffolding for MAS build (1-2 days, solo)** | App Store Connect listing prepared |
| 11 | v2.2 — F-PRICE-1 (Lemon Squeezy license, DMG-build) + StoreKit unlock (MAS-build) + F-20 (icon) | Both unlock paths in parallel |
| 12 | v2.2 — AI-1 (summary) + first-run wizard + FAQ draft + **dev-hosted AI relay (Cloudflare Worker, ~1 weekend) for MAS-build Model 2** | Relay live; both build configurations call AI cleanly |
| 13 | v2.2 — AI-2 (chat, blocking + spinner) + 5.1.2(i) consent modal | — |
| 14 | v2.2 — F-14 (lightbox) + F-15 (status bar) + screencast + **DMG ship; MAS submission to App Store Review** | DMG v2.2 live; MAS in review |
| 15-16 | **Apple review cycle.** Expect 1-2 rejection rounds. Fix and resubmit. | MAS goes live at the end of this window |
| 17 | v2.2.1 — AI-2 streaming SSE + v2.2 bug-fix backlog | — |

**Total: ~17 calendar weeks** vs ROADMAP.md's 14 weeks. **+3 weeks for App Store pre-launch + review.**

### What moves earlier

- **Apple Developer Program enrollment** — week 0, before any v2 code starts. $99 spent at the start.
- **Notarization integration** — week 1, replaces the unsigned-DMG ship target as soon as enrollment completes.

### What gets added (new work)

- **`scripts/notarize.sh`** — week 1. ~0.5 day.
- **`xcodebuild` integration for MAS build** — week 10. ~1-2 days.
- **Sandbox refactor of F-01 watcher** — week 10. ~1-2 days.
- **StoreKit IAP plumbing for MAS build** — week 10-11. ~1-2 days.
- **Cloudflare Worker AI relay** — week 12. ~1 weekend.
- **Privacy policy + EULA** — week 10. ~1 day + ~$200-500 legal review.
- **App Store screenshots, metadata, Privacy Nutrition Labels** — week 10. ~1-2 days.
- **Apple review cycle** — weeks 15-16. ~2 weeks wall-clock, 0 days solo work (waiting + handling rejections).

### What gets cut from the original plan

- **Custom EULA** — partially absorbed by Apple's standard EULA for the MAS build. Still need a custom EULA for the DMG build, per legal-eagle.
- **F-21 `mdv` CLI shim** — kept in DMG build only; sandboxed MAS build won't accept arbitrary file paths via `open -a`. Solo-engineer decides whether to keep F-21 as a DMG-only feature or cut entirely (PM rec: keep DMG-only; document the constraint in README).
- **Free-tier perpetual model on MAS** — depends on which §4 pricing model is chosen. PM rec: Model 2 (free MAS app + $12 IAP for Plus, hosted AI with cap).

---

## 7. PM recommendation — Option B now, Option D at v2.2

### Pros of the staged path (B-then-D)

1. **Lowest risk at v2.0/v2.1.** Notarized DMG gets zero-friction installs immediately. No App Review breath-holding while the free version matures.
2. **$99/year spent now is amortized.** Same membership covers Option B today and Option D at week 10. No additional cost for the dual-channel move.
3. **Validates the user's instinct.** The user asked about App Store specifically — by week 10, we'll have a real product to submit, real users on the DMG, and concrete dogfood evidence to back our choice of pricing model on MAS.
4. **Reversible.** If the App Store review path goes badly (Apple rejects on AI grounds and we can't resolve), the DMG channel is already shipping; we don't lose months of work.
5. **Solo-dev time-to-launch is reasonable.** ~17 calendar weeks to a paid product on both channels — adds 3 weeks vs DMG-only path, but the upside (App Store discoverability + Apple-trust signal) is real.
6. **Future-proofs the AI plan.** Model 2 on MAS forces us to build the hosted-relay infrastructure that legal-eagle and solo-engineer both flagged as eventually-needed if BYO friction is real.

### Cons of the staged path

1. **+3 calendar weeks** vs DMG-only.
2. **Solo-eng commits to sandbox work** (1-2 days), StoreKit work (1-2 days), Xcode integration (1-2 days), Cloudflare Worker (1 weekend). Real new surface area.
3. **MAS rejection risk on AI is not zero.** Best mitigation (Model 2) requires the relay; rejection still possible if reviewer disagrees with the framing.
4. **Privacy Nutrition Labels and Apple standard EULA add to the v2.2 pre-launch checklist.** Both are mechanical but each takes hours.
5. **Two unlock systems to maintain.** Lemon Squeezy + license for DMG; StoreKit IAP for MAS. Conditional compilation. Real ongoing cost.
6. **Ongoing AI cost on MAS** if Model 2. At $1.60/buyer/month worst-case, sustainable but not free.

### Net recommendation

**Enroll now ($99). Ship Option B (notarized DMG) at v2.0. Add Option D (MAS) at v2.2 pre-launch (week 10). Use Model 2 for the MAS pricing (free app + $12 IAP + dev-hosted AI relay with monthly cap).**

The user explicitly asked about App Store. The honest answer is: **yes, you can do it, here's what it takes, and the path that fits a solo dev best is a phased one that ships free-tier on DMG fast and adds App Store at the monetization moment.** Going straight to Option C (App Store only) trades 6 weeks of review-cycle uncertainty against the entire viewer's free-tier release; Option B alone gives up the discoverability the user is clearly intrigued by; Option A alone leaves $99/year of "right-click → Open" friction money on the table.

**Condition under which this changes:**
- If solo-engineer flags `xcodebuild` integration as more invasive than 1-2 days → reconsider Option B-only and skip MAS.
- If Apple rejects the Model 2 framing during review → fall back to Model 4 (MAS without AI; AI exclusive to DMG).
- If user's calendar drops below the 17-week budget by week 10 → ship v2.2 DMG-only; defer MAS to v2.3.

---

## 8. Open questions for solo-engineer

1. **Q-D1 — Sandbox compatibility of F-01 watcher.** Does our planned `DispatchSource.makeFileSystemObjectSource(fileDescriptor:eventMask:[.write,.extend,.delete,.rename])` watcher work inside the sandbox if we wrap the `open()` call in a `startAccessingSecurityScopedResource()` / `stopAccessingSecurityScopedResource()` block around the watcher's lifetime? Specifically: does the atomic-rename pattern (where we re-`open()` after `.rename` fires) still work when the new path's security scope was inherited from the original NSOpenPanel-picked URL? Test on a sandbox-entitled local build before committing to Option D.
2. **Q-D2 — Single bundle or split build targets?** Two ways to ship Option D from one codebase:
    - **(a)** Single `.app` source, conditional compilation (`#if MAS_BUILD`) for the unlock system. One Package.swift, one build script per channel.
    - **(b)** Two separate build configurations in `xcodebuild`, sharing source files but with different `Info.plist`, entitlements, and SKUs.
    Solo-engineer's call. (a) is closer to our SwiftPM-first ethos; (b) is more Xcode-idiomatic. PM rec: (a) if possible.
3. **Q-D3 — `xcodebuild` integration.** What's the minimum overhead to add `xcodebuild` for the MAS release-cut without abandoning SwiftPM? Two options: maintain a minimal `.xcodeproj` checked into the repo; or use `xcodebuild -package-path .` directly against the SwiftPM manifest (newer support). The latter would be cleaner if it works for our needs. Solo to investigate.
4. **Q-D4 — Pricing Model 2 ops:** comfort level with operating a Cloudflare Worker AI relay? The Worker validates an App Store receipt server-side, caps to N calls/month per receipt, and proxies api.anthropic.com. Estimate ~150 LOC TypeScript + the Cloudflare free tier ($0/month at our expected volume). PM rec: yes, this is the right call. Solo's lane.
5. **Q-D5 — F-21 (`mdv` CLI) on MAS.** Confirm the sandboxed MAS build cannot accept arbitrary file paths via `open -a`. If confirmed: keep F-21 as a DMG-only feature, document in README. If somehow it works (unlikely): ship to both.
6. **Q-D6 — F-05 recent-files in sandbox.** SwiftUI DocumentGroup may auto-serialize security-scoped bookmarks for recent files; needs verification. If not free, +1-2 days to wire up `URL.bookmarkData(options:.withSecurityScope)` for each recent.
7. **Q-D7 — Hardened-runtime entitlements for DMG build.** WKWebView under hardened runtime sometimes needs `com.apple.security.cs.allow-jit` or `com.apple.security.cs.allow-unsigned-executable-memory`. Solo to test the notarized DMG end-to-end on a clean Mac before week 5 ship.
8. **Q-D8 — Existing CLAUDE.md hard constraints to relax.** This proposal violates these lines:
    - "No Xcode. Only `swift build` / SwiftPM." → relax to "Xcode/`xcodebuild` allowed at MAS release-cut step only; dev loop stays SwiftPM."
    - "No code signing / notarization." → relax to "Code signing + notarization required for Option B/D; uses CLT-native `codesign` + `notarytool` + `stapler`."
    - "Mac App Store distribution" listed as anti-feature in v2-requirements.md §7.6 → remove if Option D adopted.
    Confirm solo-engineer accepts these CLAUDE.md relaxations as load-bearing for the distribution path. **Should be the first thing solo-engineer agrees to or pushes back on.**

---

## 9. Glossary (additions)

| Term | Meaning |
|---|---|
| **Notarization** | Apple's automated malware-scanning service. Free with $99/year Dev Program. Required for direct-DMG zero-friction install. |
| **Stapling** | `xcrun stapler` attaches the notarization ticket to the `.dmg` / `.app` so Gatekeeper can verify offline. |
| **Hardened runtime** | macOS feature that restricts what a signed binary can do (no unsigned dylibs, no library injection, etc.). Required for notarization. Configured via entitlements. |
| **App Sandbox** | macOS feature that restricts an app to a per-bundle container. Required for Mac App Store. Configured via entitlements. |
| **Security-scoped bookmark** | A persistable reference to a file the user explicitly picked, used inside the sandbox to re-access that file after relaunch. |
| **StoreKit** | Apple framework for IAP. Replaces Lemon Squeezy on the MAS build. |
| **Small Business Program** | Free Apple program: 15% commission instead of 30% for devs under $1M/yr lifetime revenue from App Store. Functionally automatic for solo devs. |
| **Privacy Nutrition Labels** | App Store listing-page disclosure of what data the app collects/shares. Required for all App Store submissions. |
| **Reader app entitlement** | Specific Apple program for apps that primarily display previously-purchased content. **Does NOT apply to our app** — we display the user's own files. |
| **MOR (Merchant of Record)** | Lemon Squeezy handles VAT, refunds, and chargebacks on the DMG channel. Apple is the MOR for the MAS channel. |
| **Developer ID Application cert** | The signing cert for direct-download `.app` files. Different from "Mac App Distribution" cert, which signs for App Store submission. |
| **xcrun altool / Transporter** | Apple tools to upload an `.xcarchive` or `.pkg` to App Store Connect for review. |

---

## 10. Source files / pages read

| Source | Purpose | Citation |
|---|---|---|
| `~/Projects/tools/markdown-viewer/CHARTER.md` | v1 non-goals (signing, MAS) — what's being reconsidered | 34 lines |
| `~/Projects/tools/markdown-viewer/CLAUDE.md` | Hard constraints (No Xcode, No code signing) — being relaxed | 78 lines |
| `~/Projects/tools/markdown-viewer/DESCRIBE.md` | Architecture: WKWebView + DocumentGroup are sandbox-compatible | 109 lines |
| `~/Projects/tools/markdown-viewer/docs/v2-requirements.md` | 17 features, Lemon Squeezy + BYO key plan being revisited | 702 lines |
| `~/Projects/tools/markdown-viewer/docs/ROADMAP.md` | Round-2 calendar; rewritten in §6 above | 303 lines |
| `~/Projects/tools/markdown-viewer/docs/pm-response-v2.md` | Round-2 decisions, including license-API choice | 178 lines |
| `~/Projects/tools/markdown-viewer/docs/solo-feedback-v1.md` | Solo's pricing analysis | 88 lines |
| `~/Projects/tools/markdown-viewer/docs/legal-musts-v2.md` | Privacy, EULA, AI ToS forward-look | 362 lines |
| [Apple Developer Program](https://developer.apple.com/programs/) | $99/yr cost, capabilities | WebFetch |
| [Apple D-U-N-S help](https://developer.apple.com/help/account/membership/D-U-N-S/) | Individual enrollment doesn't need D-U-N-S | WebSearch |
| [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) | 1.2, 2.5, 3.1.1, 4.7, 5.1, 5.2 — covered in §3 | WebFetch |
| [Apple — App Sandbox file access](https://developer.apple.com/documentation/security/accessing-files-from-the-macos-app-sandbox) | Security-scoped bookmarks for F-01 watcher | WebSearch |
| [Apple Small Business Program](https://developer.apple.com/app-store/small-business-program/) | 15% commission, $1M/yr threshold | WebSearch |
| [Apple — Reader app entitlement](https://developer.apple.com/support/reader-apps/) | Not applicable to our app | WebSearch |
| [Apple — App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/) | Privacy Nutrition Labels questionnaire | WebSearch |
| [dev.to — Guideline 5.1.2(i) analysis](https://dev.to/arshtechpro/apples-guideline-512i-the-ai-data-sharing-rule-that-will-impact-every-ios-developer-1b0p) | Third-party AI disclosure requirement (Nov 2025 update) | WebSearch |
| [Apple — Developer ID](https://developer.apple.com/developer-id/) | Direct-download notarization path | WebSearch |
| [Apple — Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/) | xcodebuild + altool/Transporter | WebSearch |
| [SuccessfulSoftware — Notarization workflow](https://successfulsoftware.net/2018/11/16/how-to-notarize-your-software-on-macos/) | notarytool + stapler practical example | WebSearch |
| [CODEBIT — File access in macOS sandboxed apps](https://codebit-inc.com/blog/mastering-file-access-macos-sandboxed-apps/) | startAccessingSecurityScopedResource lifecycle | WebSearch |
| [Lowcode.agency — App Store Review time 2026](https://www.lowcode.agency/blog/app-store-review-time) | First-submission timeline (3-10 days expected) | WebSearch |
| [Apple Standard EULA](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/) | EULA covered by Apple for MAS build | WebSearch |
| [TechLila — Mac App Store vs Direct Downloads 2026](https://www.techlila.com/mac-app-store-vs-direct-downloads-dmg/) | Dual-distribution business model context | WebSearch |
| [Marked 2 on Mac App Store](https://apps.apple.com/us/app/marked-2-markdown-preview/id890031187) | Real-world dual-distribution example | (re-fetched from v2 docs) |

---

## Section 9 — Locked decisions (user, 2026-05-18)

The user reviewed Sections 1–8 and locked three gate decisions. These override PM's earlier recommendations where they differ.

| # | Decision | What it means |
|---|---|---|
| **D-1** | **Relax CLAUDE.md** "No Xcode" + "No code signing/notarization" hard rules | SwiftPM stays the daily dev build. Xcode tooling (`xcodebuild`, `notarytool`, `xcrun stapler`, App Store Connect) is permitted ONLY in the release pipeline starting at v2.2 prep. Daily code-writing workflow is unchanged. CLAUDE.md edited 2026-05-18 to reflect this. |
| **D-2** | **Path: A → D, skipping B** | The intermediate "notarized DMG at v2.0/v2.1" stop is NOT taken. v2.0 (shipped) and v2.1 continue as unsigned DMG ("right-click → Open" first-launch friction stays for free users). v2.2 cuts both channels at once: **Notarized DMG + Mac App Store**. Apple Developer Program enrollment ($99/yr) happens at v2.2 prep, not before. **Implication:** all Apple-side setup (enrollment, sandbox audit, IAP wiring, Privacy Nutrition Labels, App Review submission) is deferred to a single v2.2-prep block — higher risk concentration there, lower complexity in between. |
| **D-3** | **No AI features on the Mac App Store build** | The MAS version of v2.2 ships **viewer features only** (live reload, find, drag-drop, zoom, themes, PDF, voice — everything from v2.0/v2.1). **No F-17 menu items** (no doc summary, no ask-the-doc chat). AI features ship **only in the direct-download DMG build**, with BYO Anthropic API key + Lemon Squeezy license-key unlock as originally planned. **Reason:** the BYO-key model has a real Guideline 3.1.1 rejection risk on the App Store; the dev-hosted relay alternative adds Cloudflare Worker infra. User chose to keep MAS simple and route AI through the direct channel only. |

### Cascade — what these decisions imply downstream

Solo-engineer / future PM rounds should treat the following as locked unless the user re-opens them:

1. **Two product variants from one codebase at v2.2.** Either (a) a compile-time flag (`#if MAS_BUILD`) that excludes AI files + menu items from the MAS target, or (b) a runtime check on `Bundle.main.appStoreReceiptURL` to detect MAS-receipt vs direct-DMG. Solo to pick the simpler one when v2.2 prep starts.
2. **No Apple cost incurred until v2.2 prep.** The $99 Dev Program enrollment is parked. v2.0 and v2.1 ship at $0/yr cost. This matches a "validate demand before committing infra" stance.
3. **MAS pricing model question — DEFERRED.** Since MAS has no AI, the "what's the Plus tier on MAS" question is open. Options to revisit at v2.2 prep:
   - **MAS = free (loss-leader for discovery)**, money flows only through direct DMG + Lemon Squeezy.
   - **MAS = $X paid-up-front** for the same viewer features that are free in the DMG (unusual — same software, two price points by channel).
   - **MAS = free + IAP for Plus** where Plus on MAS unlocks themes/PDF/voice (i.e. the v2.1 polish bundle), and AI stays direct-only.
   The third option is the most natural — discuss at v2.2 prep round.
4. **App icon (F-20) and app metadata (screenshots, marketing copy, App Privacy Nutrition Labels) become hard MUSTs at v2.2 prep**, not optional polish. Solo already shipped F-20 early in `8acd221`, so the icon is done.
5. **Legal docs at v2.2 prep:** Privacy Policy (for both channels — Anthropic data flow disclosure on DMG; Lemon Squeezy on DMG; MAS gets a simpler "no data collected" stance since no AI). EULA: Apple's standard EULA covers the MAS build; DMG still needs a custom EULA (~$200-800 lawyer review). See `docs/legal-musts-v2.md`.
6. **Steering off-platform from MAS:** Apple historically forbids "Get the AI version at our website" links inside MAS apps (Guideline 3.1.1(a)). Verify current state at v2.2 prep — the *Epic v. Apple* ruling + Apple's 2024 response loosened some external-link rules but with disclosure requirements. PM to research at v2.2 prep round.

### Solo-engineer review on this section

Not requested for now. The decisions above are gate-level (user-only). Solo's input will be requested at **v2.2 prep**, not now. v2.1 work proceeds on the current plan without touching any of this.

### Immediate next step

**None on the App Store front.** Continue with v2.1 work when ready (themes / print / voice). Re-open this doc at v2.2 prep (estimated ~10-12 weeks out).

*End of distribution-options.md.*
