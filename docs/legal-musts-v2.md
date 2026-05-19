# Markdown Viewer — Legal MUSTs (mechanical-compliance scan + forward register)

**Author:** legal-eagle (US software-copyright triage counsel, in-workshop)
**Date:** 2026-05-18
**Scope:** v2.0 shipped state (now) + v2.1 / v2.2 forward-look + parked features
**Method:** Mechanical-compliance scan of vendored assets and a forward risk register for planned features.

> *This is general information, not legal advice. For a real dispute, registration, contract, or takedown, consult a US-licensed attorney.*

---

## Section 1 — Hard MUSTs **right now** (v2.0 shipped state)

### 1.1 markdown-it 14.1.0 (vendored)

- **Path:** `Sources/MarkdownViewer/Resources/markdown-it.min.js`
- **License (SPDX):** `MIT`
- **Header preserved in file?** YES — line 1 reads: `/*! markdown-it 14.1.0 https://github.com/markdown-it/markdown-it @license MIT */`
- **MIT mechanical condition:** keep the copyright + permission notice in copies. The minified bundle does **not** carry the full MIT text (it carries only an `@license MIT` SPDX tag), so the canonical MIT text + copyright line ("Copyright (c) 2014 Vitaly Puzrin, Alex Kocharin") must live somewhere shipped to end users.

**Verdict:** Caution
**Risk:** Low → Medium (purely mechanical; easy to fix; ship-blocker once distributed publicly)

**Why** —
1. `MIT` requires the **copyright notice AND the permission notice** in "all copies or substantial portions of the Software." The `@license MIT` SPDX tag in the minified header is the SPDX *identifier*, not the permission text. Industry-standard reading: SPDX tag alone is insufficient — the full notice block must be reproduced somewhere shipped with the binary.
2. The DMG ships the bundle (including the minified JS) inside `.app/Contents/Resources/`. The end user receives the software, so MIT's "in copies" clause is satisfied for the JS file's header — but the **full permission text + copyright line is not present anywhere in the repo or the bundle.**
3. There is no `LICENSE`, `NOTICE`, `THIRD_PARTY_LICENSES`, or equivalent file at the repo root, in the DMG, or accessible in-app.

**What I'd do** —
1. Create `THIRD_PARTY_LICENSES.md` at the repo root containing the full MIT text for markdown-it 14.1.0 (the upstream `LICENSE` file at https://github.com/markdown-it/markdown-it/blob/14.1.0/LICENSE — copy verbatim, including the `Copyright (c) 2014 Vitaly Puzrin, Alex Kocharin` line and the standard MIT permission block).
2. Make sure this file ships with the binary. Two acceptable ways:
   - Include `THIRD_PARTY_LICENSES.md` (or `.txt`) inside the DMG alongside `MarkdownViewer.app` (simplest — `scripts/make-dmg.sh` would stage it next to the `Applications` symlink).
   - Or ship it inside the bundle at `Contents/Resources/THIRD_PARTY_LICENSES.txt` and expose it via a Help → Acknowledgements menu item (more macOS-native; defer until you have an Acknowledgements UI).
3. Do **not** strip the `/*! markdown-it 14.1.0 ... @license MIT */` comment from the minified file. It is the in-file attribution and must remain.

**Citations** — MIT License, SPDX `MIT`, OSI text. Upstream source: https://github.com/markdown-it/markdown-it (npm package metadata declares MIT).

---

### 1.2 highlight.js 11.9.0 (vendored)

- **Path:** `Sources/MarkdownViewer/Resources/highlight.min.js`
- **License (SPDX):** `BSD-3-Clause`
- **Header preserved in file?** YES — first bytes read: `/*! Highlight.js v11.9.0 (git: f47103d4f1) (c) 2006-2023 undefined and other contributors License: BSD-3-Clause */`. Note the `undefined` placeholder is a known cosmetic bug in the upstream build script, not a content issue.
- **BSD-3-Clause mechanical conditions:** (a) reproduce the copyright notice + this list of conditions + the disclaimer in source-form redistributions, (b) reproduce them in binary-form redistributions in the documentation and/or other materials, (c) **do not use the names of contributors to endorse or promote products** without prior written permission.

**Verdict:** Caution
**Risk:** Low → Medium (same shape as markdown-it; +1 endorsement-clause flag)

**Why** —
1. BSD-3-Clause requires the full notice + 3 conditions to be reproduced in binary distributions. The minified bundle header carries only the SPDX line + copyright; the full license text is **not present** anywhere shipped.
2. Clause 3 ("no endorsement") is a substantive obligation, not a placeholder — using the names "highlight.js" or any contributor name in marketing copy in a way that implies endorsement would violate it. Using the name **descriptively** ("uses highlight.js for syntax highlighting") is fine — that's not an endorsement claim.
3. The README, DESCRIBE, and v2 docs all reference "highlight.js" — that's accurate descriptive use, not an endorsement violation.

**What I'd do** —
1. Add the full BSD-3-Clause text for highlight.js 11.9.0 to `THIRD_PARTY_LICENSES.md` (same file as in 1.1). Source: https://github.com/highlightjs/highlight.js/blob/11.9.0/LICENSE. Include the `Copyright (c) 2006, Ivan Sagalaev` line verbatim.
2. Do **not** strip the in-file license header from the minified file.
3. Marketing copy rule of thumb for v2.2 paid launch: it's fine to say "powered by highlight.js," "uses highlight.js under the hood," "syntax highlighting via highlight.js." It is **not** fine to say things like "endorsed by highlight.js," "the highlight.js team recommends," or to use highlight.js's logo (if any) in product chrome. None of the current docs cross that line; flag for future marketing.

**Citations** — BSD-3-Clause, SPDX `BSD-3-Clause`, clause 3 (no endorsement). Upstream: https://github.com/highlightjs/highlight.js.

---

### 1.3 highlight.js GitHub themes (light + dark)

- **Paths:** `Sources/MarkdownViewer/Resources/highlight-theme-light.css`, `highlight-theme-dark.css`
- **License (SPDX):** `BSD-3-Clause` (inherits from highlight.js project; the `styles/github*.css` files in the highlight.js cdn-release ship under the same license as the parent project)
- **Header preserved?** Partial. The CSS files carry a *theme metadata* block (`Theme: GitHub / Description / Author: github.com / Maintainer: @Hirse / Updated: 2021-05-15 / Outdated base version: github.com/primer/github-syntax-light`) but **do not carry an explicit SPDX license tag inside the CSS file itself.** The license inheres from the parent repo's `LICENSE`.

**Verdict:** Caution
**Risk:** Low (covered by the same `THIRD_PARTY_LICENSES.md` entry as 1.2; minor footnote)

**Why** —
1. The themes are part of the highlight.js cdn-release repository under the umbrella BSD-3-Clause. The theme metadata block credits `github.com` as the original color source and `@Hirse` as maintainer.
2. The "Author: github.com" line is a credit to GitHub's open-source `primer/github-syntax-light` repository (also MIT, by the way — see https://github.com/primer/github-syntax-light/blob/master/LICENSE). This means the themes have a *layered* provenance: BSD-3-Clause from highlight.js + MIT from primer (the color values themselves are functional and arguably not copyrightable under §102(b) idea/expression, but the safe move is to credit both).
3. The header you preserved in the CSS is sufficient as *in-file* attribution. The umbrella license file (1.1/1.2 plan) covers the legal "show me the permission text" requirement.

**What I'd do** —
1. Add a short note to `THIRD_PARTY_LICENSES.md` under the highlight.js entry: "Bundled `github` and `github-dark` themes from the highlight.js cdn-release distribution. Color values originally from GitHub's open-source `primer/github-syntax-light` and `primer/github-syntax-dark` (MIT). Theme files licensed BSD-3-Clause via the parent highlight.js project."
2. Do not strip the in-file theme metadata blocks.

**Citations** — BSD-3-Clause (parent). MIT (primer upstream, mentioned for completeness). 17 U.S.C. §102(b) (color values as functional/non-copyrightable, supportive but not load-bearing).

---

### 1.4 The Markdown name / UTI / brand

- **Where used:**
  - `MarkdownDocument.swift:6` — `UTType(importedAs: "net.daringfireball.markdown")`
  - `scripts/build.sh:80` — `<key>CFBundleTypeName</key><string>Markdown Document</string>`
  - `scripts/build.sh:85, 92, 93` — `net.daringfireball.markdown` as UTType identifier and `Markdown Document` as UTTypeDescription
  - The app name "Markdown Viewer" itself

**Verdict:** Safe
**Risk:** Low

**Why** —
1. "Markdown" is the generally-accepted **generic name** of the markup format, originally specified by John Gruber and Aaron Swartz in 2004. It is widely used descriptively across the industry (GitHub, Stack Overflow, Discord, every code editor) as the format name. There is no registered trademark on the word "Markdown" for software in commerce (USPTO TESS searches consistently come back negative for live word marks on "Markdown" in software/IT classes). Generic-descriptive use of a format name in a product name and document-type declaration is the **textbook** Lanham-Act-safe path.
2. `net.daringfireball.markdown` is the **canonical Apple-system UTI** for Markdown documents, assigned by convention to the originator's reverse-domain (daringfireball.net = John Gruber). Importing a UTI via `UTType(importedAs:)` is **declaratively interoperating with the OS's type system**, not making a brand claim. Apple's own UTI documentation expects third-party apps to import this exact UTI to declare they handle `.md`.
3. `CFBundleTypeName = "Markdown Document"` is a human-readable label that appears in Finder ("Open With" menus, Get Info). It's a descriptive label, not a brand. There is no implication of affiliation with daringfireball.net or John Gruber.
4. The product name "Markdown Viewer" is descriptive (format + function). Like "PDF Viewer," "Word Viewer," "PNG Viewer" — descriptive names of file-format viewers are routine and not trademark-actionable.

**What I'd do** —
1. **No change required.** This usage is standard.
2. **Future flag (only if it ever arises):** if at any point the app name pivots from "Markdown Viewer" to a name that includes another company's trademark (e.g., calling a feature "Notion-compatible" in marketing copy, or shipping with "for Obsidian" in the name), that becomes a trademark conversation. Not in scope now.

**Citations** — Lanham Act, 15 U.S.C. §1125(a) (false-affiliation standard); industry-standard generic-descriptive use of format names; Apple's UTI documentation re `net.daringfireball.markdown`.

---

### 1.5 App icon — claim is "drawn from scratch, no third-party mark"

- **Source script:** `scripts/make-icon.swift`
- **Output:** `assets/AppIcon.icns`
- **Claim:** Inline comment, lines 5-7: "The glyph (M + down arrow) is drawn from scratch with our own coordinates — not traced from any third-party mark — so no attribution / licensing issue."
- **Verification:** Source script inspected. The M-glyph is built from 12 explicit `addLine(to: CGPoint(x:, y:))` calls in a `CGMutablePath` with hand-picked integer coordinates (lines 92-105). The down-arrow is 7 explicit `addLine` calls (lines 110-117). No SVG `<path d="...">` data was imported. No file was traced. The bounding boxes and proportions chosen are generic ("M" inside a rounded rectangle, down-arrow to its right).
- **Comparison to the canonical Markdown mark (Dustin Curtis, CC BY 3.0):** the canonical mark has a similar conceptual layout (M + arrow inside a rounded rectangle), but the specific path geometry differs. Under 17 U.S.C. §102(b), the **idea** of "M + down-arrow inside a rounded rectangle" is not copyrightable (it's the format-icon concept); only the **expression** (the specific path coordinates) is. Hand-coordinates differ from Curtis's SVG paths, and the documented record (`DESCRIBE.md` decision 5 + `make-icon.swift` header) establishes independent creation.

**Verdict:** Safe
**Risk:** Low

**Why** —
1. **Independent creation is the gold standard.** A drawn-from-coordinates glyph with no path-import step is the cleanest possible posture. The script + the DESCRIBE.md design-decision-5 entry create a documented trail of independent creation.
2. **The idea/expression dichotomy** (17 U.S.C. §102(b)) explicitly excludes "any idea, procedure, process, system, method of operation, concept, principle, or discovery" from copyright. The concept "letter M next to a down-arrow inside a squircle" is exactly such an idea. Only the specific path-data expression is protected.
3. The icon is a gradient squircle + 2 simple geometric paths. Even if substantial-similarity analysis were applied, the abstraction-filtration-comparison test (*Computer Associates v. Altai*) would filter out the unprotectable idea and leave only path coordinates — which differ from Curtis's mark.

**What I'd do** —
1. **Keep the inline comment in `make-icon.swift`** (lines 5-7). It is the contemporaneous record of independent creation. Do not delete it as cleanup — it is load-bearing evidence.
2. **Keep the DESCRIBE.md decision 5 entry verbatim.** Same reason.
3. If the icon ever changes (commissioned or otherwise), retain the same "independently created, not traced" provenance in writing.

**Citations** — 17 U.S.C. §102(b) (idea/expression dichotomy); *Computer Associates Int'l v. Altai*, 982 F.2d 693 (2d Cir. 1992) (abstraction-filtration-comparison); CC BY 3.0 (the Dustin Curtis mark license, noted but inapplicable here).

---

### 1.6 Section 1 — Summary punch-list

The **only** open MUST at v2.0 ship state is the one in 1.1/1.2/1.3:

- **CREATE** `THIRD_PARTY_LICENSES.md` (or `.txt`) at the repo root containing:
  - The full MIT text for markdown-it 14.1.0
  - The full BSD-3-Clause text for highlight.js 11.9.0
  - A short note crediting the GitHub themes' lineage (primer/highlight.js)
- **SHIP** that file inside the DMG. Update `scripts/make-dmg.sh` to stage it alongside `MarkdownViewer.app` and the `Applications` symlink.
- **KEEP** all in-file license headers in `markdown-it.min.js`, `highlight.min.js`, and the two theme CSSes. They are already correctly preserved — don't accidentally minify them out in any future build step.
- **NO CHANGE** required for the Markdown brand usage or the app icon.

Estimated effort: **<30 minutes.**

---

## Section 2 — Forward MUSTs (will trigger when v2.1 / v2.2 ships)

### 2.1 F-13 footnotes + task lists (v2.1)

**Plan per `v2-requirements.md`:** vendor `markdown-it-footnote` minified (~3KB). Task lists already partly in v1 via custom JS post-process in `render.js` — no plugin needed there. Footnotes is the new vendor.

**Verdict:** Safe (with mechanical condition)
**Risk:** Low

**Why** —
1. `markdown-it-footnote` is the official `@markdown-it/markdown-it-footnote` plugin, licensed `MIT`. Same license family as markdown-it itself. No compatibility issue.
2. Task lists are being rendered by the project's own `render.js` (not a vendored plugin), so no third-party license enters there. (If at any point you switch to `markdown-it-task-lists` — also MIT — same mechanical step applies.)

**What I'd do (at the point of vendoring, not before)** —
1. Vendor the minified file from jsdelivr the same way as markdown-it: `https://cdn.jsdelivr.net/npm/markdown-it-footnote@<VERSION>/dist/markdown-it-footnote.min.js`. Pin the exact version.
2. **Keep the in-file license header** (markdown-it plugins routinely carry `/*! markdown-it-footnote ... @license MIT */` in their minified output). If the minified file doesn't include one, prepend the standard MIT notice manually before vendoring.
3. **Add an entry to `THIRD_PARTY_LICENSES.md`** with the full MIT text + copyright line. Use the upstream `LICENSE` file at the repo (`https://github.com/markdown-it/markdown-it-footnote/blob/master/LICENSE`).
4. Same routine for any other markdown-it plugin you add later (`-task-lists`, `-deflist`, `-anchor`, `-emoji`, etc.) — all of them in the markdown-it ecosystem are MIT, so the mechanical step is identical: vendor → keep header → append to NOTICE.

**Citations** — MIT License, SPDX `MIT`; markdown-it plugin ecosystem conventions.

---

### 2.2 F-18 voice narration via `AVSpeechSynthesizer` (v2.1)

**Verdict:** Safe
**Risk:** Low

**Why** —
1. `AVSpeechSynthesizer` is a first-party Apple framework. Apple's macOS SDK License (the license you accepted when installing CommandLineTools/Xcode) grants the right to call its APIs from apps. There is no third-party-asset issue.
2. The synthesized speech output is *not* a copyrighted work output by Apple in the relevant sense. Apple's terms don't restrict normal app use of TTS output (you're not redistributing voice samples; you're playing them through the user's speakers at request time).
3. There is **no copyright issue** with reading aloud the contents of the user's own `.md` file — that's the user reading their own document via a system-provided assistive technology. Accessibility carve-outs (17 U.S.C. §121, §1201(f)) are doubly supportive but unnecessary here.

**What I'd do** —
1. **No action required.** Ship as planned.
2. (Optional, cosmetic): if you want to credit the system synthesis engine in an Acknowledgements pane, "Speech synthesis provided by Apple's AVSpeechSynthesizer" is accurate descriptive use — not required, just transparent.

**Citations** — macOS SDK License (the license bundled with CommandLineTools); 17 U.S.C. §121 (accessibility); no specific AVSpeechSynthesizer EULA quirk per industry practice.

---

### 2.3 F-17 AI features — Anthropic API via BYO user key (v2.2)

This has three sub-MUSTs that compound. Address each separately.

#### 2.3-A Anthropic API ToS posture

**Verdict:** Caution
**Risk:** Medium

**Why** —
1. The Anthropic Commercial Terms (and the Usage Policy by reference) govern API access. The general posture, applicable across major LLM-API vendors and consistent with Anthropic's published terms:
   - The **user (key-holder) is the contracting party** with Anthropic. Their BYO key creates *their* relationship with Anthropic, not yours.
   - **Outputs belong to the user** — Anthropic disclaims ownership of generated content (subject to legal limits like §102 copyrightability — see 2.3-B).
   - **No use of outputs to train competing models** is a near-universal clause in commercial-AI ToS.
   - **Usage Policy** prohibitions (CSAM, weapons, etc.) flow through to the end user, but the API-wrapping app should also have a thin disclaimer pointing at these.
2. Because *you ship a wrapper app that calls api.anthropic.com on the user's behalf with their key*, you are operating as a developer/integrator. Anthropic's Commercial Terms typically allow this with a few mechanical conditions:
   - **Don't impersonate Anthropic.** Clear branding that the AI feature is "powered by Anthropic" or similar — descriptive, not affiliated.
   - **Don't strip safety mitigations** (you're not — you're not even modifying the model output).
   - **Pass through reasonable rate-limiting / abuse signals** (the key-holder gets rate-limited by Anthropic directly; you don't need to add your own).
3. The "BYO key" structure significantly reduces your legal exposure compared to a hosted/relay model: you're not the contracting party for the API, you're not paying Anthropic, and you're not warehousing user prompts on your servers.

**What I'd do** —
1. **In Preferences → AI** (the BYO-key entry pane), add a 1-2 sentence disclosure: *"AI features call Anthropic's API directly using your own API key. By using these features, you agree to Anthropic's [Usage Policy](https://www.anthropic.com/legal/aup) and [Commercial Terms of Service](https://www.anthropic.com/legal/commercial-terms). The contents of the open document are sent to Anthropic's servers when you invoke an AI command."* Link both URLs.
2. **In `THIRD_PARTY_LICENSES.md` or a new `AI_NOTICE.md`**, declare: "AI features (Doc Summary, Ask Doc) are powered by Anthropic's Claude models via the Anthropic API. This product is not endorsed by or affiliated with Anthropic, PBC. Users supply their own API key and are responsible for their use of the API under Anthropic's terms."
3. **Re-read Anthropic's Commercial Terms** before v2.2 ship. Terms evolve. If at any point Anthropic adds an explicit prohibition on third-party wrapper apps with BYO keys (no current public indication of this), you'd need to revisit.

**Citations** — Anthropic Commercial Terms (https://www.anthropic.com/legal/commercial-terms); Anthropic Usage Policy (https://www.anthropic.com/legal/aup); industry-standard BYO-key wrapper posture.

#### 2.3-B AI provenance / copyright of LLM output

**Verdict:** Caution
**Risk:** Low → Medium (depends on what the user does with the output downstream)

**Why** —
1. *Thaler v. Perlmutter*, No. 22-cv-1564 (D.D.C. Aug. 18, 2023), held that **work generated entirely without human creative input is not copyrightable** under U.S. law. The Copyright Office's Registration Guidance (March 2023, updated 2024) operationalizes this: human-authored *portions* of a hybrid work are copyrightable; pure AI-generated portions are not.
2. **For your viewer use case (Doc Summary):** the user sees an AI summary inline. They are *consuming*, not publishing. No copyright filing is implicated. No legal action needed inside the app.
3. **For the downstream paste-into-publication case (foreseeable):** if a user copies the AI-generated summary into a blog post / paper / report they publish, the AI-generated portion is uncopyrightable. The *user's selection, arrangement, edits, and surrounding original prose* can confer human authorship on the combined work. This is the user's problem, not yours, but a small disclosure prevents user confusion and limits downstream "you misled me about ownership" claims.

**What I'd do** —
1. **No code change required for v2.2 ship.**
2. **In the AI feature's UI** (small footer text under the summary panel and the chat panel), add a one-liner: *"AI-generated content. Under current U.S. law, fully AI-generated text is not copyrightable; your edits, selections, and surrounding prose contribute human authorship."* This is consumer-friendly, defensible, and matches USPTO/Copyright Office guidance.
3. **Do not warrant** that outputs are "original" or "free of third-party rights." Anthropic's terms place that risk on the user; your app should mirror that.

**Citations** — *Thaler v. Perlmutter*, No. 22-cv-1564 (D.D.C. 2023); U.S. Copyright Office, "Copyright Registration Guidance: Works Containing Material Generated by Artificial Intelligence," 88 Fed. Reg. 16190 (Mar. 16, 2023); USPTO 2024 inventorship guidance (parallel doctrine).

#### 2.3-C Disclosure to end users (privacy / consumer-disclosure)

**Verdict:** Talk-to-a-real-lawyer (light flag — defer until paid launch)
**Risk:** Low → Medium (state-law-specific; not a copyright issue but adjacent and worth flagging)

**Why** —
1. Sending the user's open document to Anthropic when they invoke an AI command is **data transmission to a third-party processor**. Under CCPA/CPRA (California), CDPA (Virginia), CPA (Colorado), CTDPA (Connecticut), UCPA (Utah), and a growing list of state privacy regimes, *consumer notice* about third-party data sharing is generally required for commercial software.
2. Because this is a single-user macOS app with no analytics, no remote telemetry, and no PII collected by you, your direct privacy exposure is minimal. The Anthropic API call is the only outbound data flow, and it's user-initiated.
3. **However:** once you charge money (v2.2 Plus), some state consumer-protection regimes start scrutinizing pre-purchase disclosures more strictly. The bar is mostly procedural ("disclose clearly before purchase") rather than substantive.

**What I'd do** —
1. **Privacy policy** — write a short one (one page) covering:
   - What the app does (renders local Markdown files).
   - What data flows out of the app and when: "When you use AI features, the open document is sent to Anthropic's API for processing using your API key." "When you activate a Plus license, the license key is sent to Lemon Squeezy for validation."
   - What data **you** (the developer) collect: nothing. No analytics, no telemetry, no crash beacons. Crash log is local-only (per `v2-requirements.md` Section 6 NEW round-2 entry).
   - Contact email for privacy requests.
   - Link in Help menu + on the purchase page.
2. **Pre-purchase disclosure on the Lemon Squeezy product page**: "AI features send your open document to Anthropic. Requires your own Anthropic API key."
3. **A real lawyer should review the privacy policy before paid launch.** This is the part where a $200-500 attorney review pays for itself. (Don't ask me which lawyer.)

**Citations** — CCPA/CPRA Cal. Civ. Code §1798.100 et seq.; Virginia CDPA §59.1-575 et seq.; equivalent state statutes; FTC Section 5 (deceptive-trade-practice baseline for any commercial software).

---

### 2.4 F-PRICE-1 Lemon Squeezy + license-key validation (v2.2)

**Verdict:** Talk-to-a-real-lawyer (for the EULA + refund policy specifically); Caution for the mechanical pieces
**Risk:** Medium (paid software without an EULA is the single highest forward risk — see Section 5 below)

**Why** —
1. **Default copyright posture:** if you distribute software for money with no license agreement, your software is licensed by default under "all rights reserved" — *but that doesn't tell the user what they CAN do.* They have no contractually-defined rights to use, install on N machines, redistribute, reverse-engineer, etc. This is a vacuum the user fills with their own assumptions, and a vacuum *you* fill with no contractual protection.
2. **Minimum-viable EULA shapes for a paid macOS app:**
   - License grant: "personal, non-exclusive, non-transferable license to install and use one copy per Lemon Squeezy seat purchased."
   - Restrictions: no resale of license keys, no commercial redistribution, no reverse-engineering except as permitted by law (this preserves §1201(f) interop carve-outs and §117 software-specific limits).
   - Warranty disclaimer (UCC §2-316 boilerplate, capital letters required for conspicuousness).
   - Limitation of liability (cap at purchase price, conventional carve-outs for gross negligence).
   - Governing law + venue (your state).
   - Term + termination.
   - Refund policy (or pointer to Lemon Squeezy's MOR refund policy + your own overlay if you offer one).
3. **Lemon Squeezy as Merchant of Record (MOR)** takes some of this off your plate — they handle VAT, dunning, refund mechanics within their policy window (typically 14-30 days). But Lemon Squeezy's MOR terms govern the *purchase transaction*; your EULA governs the *use of the software after purchase*. Different contracts, both needed.
4. **State consumer-protection nuances:** California (Cal. Civ. Code §1789.3 et seq.), Massachusetts (M.G.L. ch. 93A), New York (GBL §349) have stronger consumer-protection regimes. A baseline EULA covers most of this; California specifically requires certain disclosures for "automatic-renewal" subscriptions (n/a for one-time purchase, but flag if you ever pivot).

**What I'd do** —
1. **Before v2.2 paid launch:** commission an EULA. Two paths:
   - **Template + real-lawyer review** (~$200-500): start from a known template (e.g., the "Mac App Sample EULA" published by various tech-law blogs, or `https://choosealicense.com`-adjacent paid-app boilerplate), then have a US-licensed attorney review for your specific posture (single-developer, BYO-API-key AI, Lemon Squeezy MOR, unsigned binary). Cheaper but slower.
   - **Bespoke EULA from a real lawyer** ($800-2000): for a hobby-grade paid app, overkill; for anything that might scale, the right move.
2. **Ship the EULA in two places:**
   - Inside the DMG (`EULA.txt` or `LICENSE_AGREEMENT.txt` next to the `.app`).
   - In-app on first launch after a Plus activation: a modal that displays the EULA, requires an "I agree" click before AI features become usable. This creates the **manifestation-of-assent** required for contract formation under common-law contracts.
3. **Refund policy:** mirror Lemon Squeezy's default unless you have a reason to be more generous; document it on the purchase page and in the EULA.
4. **Talk to a real lawyer for the EULA itself.** I will not draft contract language for you, and I won't paper over the fact that this is the part that genuinely benefits from an hour of attorney time.

**Citations** — UCC §2-316 (warranty disclaimers); 17 U.S.C. §117 (software-specific user rights — not waivable by EULA in some courts); 17 U.S.C. §1201(f) (interop reverse-engineering exception — most EULAs cannot override); *ProCD v. Zeidenberg*, 86 F.3d 1447 (7th Cir. 1996) (shrinkwrap enforceability, foundational); Cal. Civ. Code §1789.3; M.G.L. ch. 93A; NY GBL §349.

---

## Section 3 — Parked features (KaTeX/Mermaid) — MUSTs IF un-parked

Both are **WON'T-v2** per `v2-requirements.md` Section 5 (F-11, F-12) with a documented reopen condition (dogfood-grep). Brief flag in case the user ever flips them.

### 3.1 KaTeX (F-11) — IF un-parked

- **License:** `MIT` (https://github.com/KaTeX/KaTeX/blob/main/LICENSE)
- **MUST if vendored:** same routine as markdown-it (Section 1.1) — keep the in-file license header in `katex.min.js` and `katex.min.css`, add the full MIT text + copyright line ("Copyright (c) 2013-2020 Khan Academy and other contributors") to `THIRD_PARTY_LICENSES.md`.
- **Font files:** KaTeX ships ~10 `.woff2` font files (KaTeX_Main, KaTeX_Math, KaTeX_AMS, etc.). The fonts are subsets derived from `Computer Modern` (a TeX-system font); KaTeX's `LICENSE` covers their distribution under MIT. **No separate font-license entry needed beyond the umbrella MIT entry.** Document the font files in `THIRD_PARTY_LICENSES.md` as "KaTeX font assets, MIT-licensed via the KaTeX project."

### 3.2 Mermaid (F-12) — IF un-parked

- **License:** `MIT` (https://github.com/mermaid-js/mermaid/blob/develop/LICENSE)
- **MUST if vendored:** same routine. Note Mermaid's minified bundle is 880KB-2.6MB depending on which features are included; whichever build is chosen, the in-file header must be preserved and the full MIT text added to `THIRD_PARTY_LICENSES.md`.
- **Transitive deps:** Mermaid's full build bundles several sub-libraries (`d3`, `dagre-d3`, `dompurify`, `lodash-es`, `khroma`, `cytoscape`, etc.) — all MIT or BSD-family. The Mermaid project's umbrella `LICENSE` and its `LICENSES` directory / `package.json` lists the third-party-asset attributions. If vendoring the full Mermaid build, copy Mermaid's bundled third-party attribution block verbatim into your `THIRD_PARTY_LICENSES.md`.

---

## Section 4 — Project license (whole repo)

### 4.1 Current state (private repo, no LICENSE)

- **Repo visibility:** private on GitHub per CLAUDE.md context.
- **LICENSE file at repo root:** none.
- **Sole-author posture:** all commits authored by `laobanworks.dev@gmail.com` with Claude as co-author on some. No external contributors.

**Verdict:** Safe (for now, while the repo stays private and pre-paid)
**Risk:** Low immediate, Medium forward (becomes Medium-High at v2.2 paid launch if not addressed)

**Why** —
1. **U.S. copyright attaches automatically on creation** under 17 U.S.C. §102(a) to original works of authorship fixed in a tangible medium. The user owns the human-authored portions of the codebase without any LICENSE file. No "all rights reserved" notice is required.
2. **Private repo = no public distribution = no third-party-contributor question.** With no external contributors, there's no contributor-IP-assignment ambiguity. Solo authorship is the cleanest possible posture.
3. **AI co-authorship in commits:** the `Co-Authored-By: Claude` trailer is transparent and good practice. Per *Thaler v. Perlmutter* (D.D.C. 2023), AI-generated portions are not independently copyrightable. The user's prompts, reviews, edits, and selections provide the human creative contribution that anchors the copyright in the codebase as a whole. **This is the correct posture — keep the co-author tags for transparency; the user retains copyright in the human-authored portions and the curatorial selection/arrangement.**

**What I'd do** —
1. **For v2.0 / v2.1 (free, possibly still private repo):** no immediate change needed. The `THIRD_PARTY_LICENSES.md` ask in Section 1 is the only must-do.
2. **Before v2.2 paid launch (forward MUST):**
   - **Decide license posture for the repo itself.** Two clean paths:
     - **Path A: Proprietary, source-available-but-not-OSS.** Keep repo private (or make it source-visible read-only on GitHub for transparency); ship a proprietary EULA in the DMG (see Section 2.4). No `LICENSE` file in the repo, but a clear `COPYRIGHT.md` at the root saying "Copyright (c) 2026 <Your Name>. All rights reserved. End users license per EULA shipped with the application." This is the typical posture for a paid macOS app.
     - **Path B: Permissive OSS + commercial license dual-stack.** Add a `LICENSE` file (MIT or Apache-2.0) covering the source, and a separate paid EULA covering the AI-features-unlocked binary distribution. Lets free-tier users build from source if they want; Plus features are the paid value-add. More complex; only worth it if the user actively wants community contributions or marketing the "open source" angle.
   - **My net recommendation: Path A.** Simpler. Closer to how Marked 2 and Typora are licensed. Doesn't preclude opening source later. Keeps the value-extraction surface clean for the paid tier.
3. **Once external contributions become a thing** (PRs from non-user accounts): adopt a Contributor License Agreement (CLA) or use the DCO (Developer Certificate of Origin) sign-off pattern. Defer until a real outside PR arrives.

**Citations** — 17 U.S.C. §102(a) (subject matter); 17 U.S.C. §201 (ownership, sole-authorship); *Thaler v. Perlmutter*, No. 22-cv-1564 (D.D.C. 2023); U.S. Copyright Office AI Registration Guidance (88 Fed. Reg. 16190).

---

## Section 5 — Risk register summary

| Risk | When it opens | Severity | Mitigation |
|---|---|---|---|
| Missing `THIRD_PARTY_LICENSES.md` for markdown-it / highlight.js / themes | **NOW** | Medium | 30-min fix per Section 1.6 |
| markdown-it-footnote MIT notice | v2.1 ship day | Low | Same routine as 1.1 |
| Anthropic ToS disclosure in Preferences UI | v2.2 ship day | Medium | 1-2 sentences + 2 URL links |
| AI-output-copyright disclosure footer in summary/chat panels | v2.2 ship day | Low | 1-sentence footer text |
| Privacy policy (state-law disclosure) | v2.2 paid launch | Medium | 1-page policy + lawyer review (~$200-500) |
| **EULA for paid Plus tier** | v2.2 paid launch | **High** | Template + lawyer review (~$200-800). **This is the biggest single forward risk.** |
| Refund policy alignment with Lemon Squeezy MOR | v2.2 paid launch | Low | Documented on purchase page + in EULA |
| Repo-level `COPYRIGHT.md` / `LICENSE` decision | v2.2 paid launch | Low | Pick Path A (proprietary) per Section 4 |

---

## Section 6 — Refusal floor

For completeness: I will not draft EULA contract language, will not opine on the merits of any specific lawyer or law firm, will not advise on non-US jurisdictions beyond noting where they're relevant, and will not help strip attribution from any vendored asset. The DMG-distribution + unsigned-binary friction is a pure-product question and not legal-eagle's lane (CLAUDE.md handles that.)

---

*This is general information, not legal advice. For a real dispute, registration, contract, or takedown, consult a US-licensed attorney.*
