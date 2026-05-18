// Glue: receive markdown text from Swift via window.renderMarkdown(text).
(function () {
  'use strict';

  const md = window.markdownit({
    html: false,           // do not allow raw HTML — safer
    linkify: true,
    typographer: true,
    breaks: false,
    highlight: function (str, lang) {
      if (lang && window.hljs && window.hljs.getLanguage(lang)) {
        try {
          return '<pre class="hljs"><code>' +
                 window.hljs.highlight(str, { language: lang, ignoreIllegals: true }).value +
                 '</code></pre>';
        } catch (e) { /* fall through */ }
      }
      // No language hint — try auto-detect.
      if (window.hljs) {
        try {
          return '<pre class="hljs"><code>' +
                 window.hljs.highlightAuto(str).value +
                 '</code></pre>';
        } catch (e) { /* fall through */ }
      }
      return '<pre class="hljs"><code>' + md.utils.escapeHtml(str) + '</code></pre>';
    }
  });

  // Task-list rendering (GFM `- [ ]` / `- [x]`).
  // markdown-it doesn't ship task lists by default; do a light post-process.
  md.core.ruler.after('inline', 'gfm-task-lists', function (state) {
    const tokens = state.tokens;
    for (let i = 0; i < tokens.length; i++) {
      if (tokens[i].type !== 'inline') continue;
      const parent = tokens[i - 1];
      if (!parent || parent.type !== 'paragraph_open') continue;
      const li = tokens[i - 2];
      if (!li || li.type !== 'list_item_open') continue;
      const m = /^\[([ xX])\]\s+/.exec(tokens[i].content);
      if (!m) continue;
      // Mutate the inline content.
      const checked = m[1].toLowerCase() === 'x';
      tokens[i].content = tokens[i].content.slice(m[0].length);
      // Strip the same prefix from the first child text token.
      if (tokens[i].children && tokens[i].children.length) {
        for (const child of tokens[i].children) {
          if (child.type === 'text') {
            const cm = /^\[([ xX])\]\s+/.exec(child.content);
            if (cm) { child.content = child.content.slice(cm[0].length); }
            break;
          }
        }
      }
      // Tag the li/parent classes so CSS can style them.
      li.attrJoin('class', 'task-list-item');
      // Find the enclosing ul and tag it.
      for (let j = i - 3; j >= 0; j--) {
        if (tokens[j].type === 'bullet_list_open') {
          tokens[j].attrJoin('class', 'contains-task-list');
          break;
        }
        if (tokens[j].type === 'bullet_list_close') break;
      }
      // Inject a checkbox at the start of the inline.
      const cb = new state.Token('html_inline', '', 0);
      cb.content = '<input type="checkbox" disabled' + (checked ? ' checked' : '') + '> ';
      tokens[i].children.unshift(cb);
    }
  });

  window.renderMarkdown = function (text) {
    try {
      const html = md.render(String(text || ''));
      document.getElementById('content').innerHTML = html;
      // Re-highlight any code blocks that markdown-it's highlight didn't catch.
      if (window.hljs) {
        document.querySelectorAll('pre code:not(.hljs)').forEach(function (el) {
          try { window.hljs.highlightElement(el); } catch (e) {}
        });
      }
      window.scrollTo(0, 0);
    } catch (e) {
      document.getElementById('content').textContent = 'Render error: ' + e.message;
    }
  };
})();
