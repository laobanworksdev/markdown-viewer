# Third-Party Licenses

This product, **MarkdownViewer**, bundles unmodified copies of the following third-party open-source software. Their license texts are reproduced verbatim below as required by their respective license terms.

The in-file SPDX license headers in the minified JavaScript and CSS files have been preserved unchanged.

---

## markdown-it 14.1.0

- **Source:** https://github.com/markdown-it/markdown-it (release tag `14.1.0`)
- **Bundled at:** `Sources/MarkdownViewer/Resources/markdown-it.min.js`
- **License:** MIT (SPDX: `MIT`)

```
Copyright (c) 2014 Vitaly Puzrin, Alex Kocharin.

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
```

---

## highlight.js 11.9.0

- **Source:** https://github.com/highlightjs/highlight.js (release tag `11.9.0`)
- **Bundled at:** `Sources/MarkdownViewer/Resources/highlight.min.js`
- **License:** BSD-3-Clause (SPDX: `BSD-3-Clause`)

```
BSD 3-Clause License

Copyright (c) 2006, Ivan Sagalaev.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

### Bundled syntax-highlighting themes

- **Files:** `Sources/MarkdownViewer/Resources/highlight-theme-light.css`, `Sources/MarkdownViewer/Resources/highlight-theme-dark.css`
- **Origin:** The `github` and `github-dark` themes from the highlight.js cdn-release distribution.
- **License:** BSD-3-Clause via the parent highlight.js project (above).
- **Color values:** Originally derived from GitHub's open-source `primer/github-syntax-light` and `primer/github-syntax-dark` projects (MIT-licensed) — https://github.com/primer/github-syntax-light. Color values per se are functional and arguably not copyrightable under 17 U.S.C. §102(b), but credit is given here in good faith.

The theme-metadata header comments inside the CSS files (crediting `github.com` as the original color source and `@Hirse` as maintainer) have been preserved unchanged.

---

## Endorsement disclaimer (BSD-3-Clause clause 3)

Per BSD-3-Clause: the names of highlight.js and its contributors are used in this product **descriptively only** (e.g., "syntax highlighting via highlight.js"). No endorsement by or affiliation with highlight.js or its contributors is implied.

---

*Last updated: 2026-05-18. If you bump the version of `markdown-it` or `highlight.js`, re-verify the upstream `LICENSE` file at the new release tag and update the copyright lines + license text above if the upstream text has changed.*
