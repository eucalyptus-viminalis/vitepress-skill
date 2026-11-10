---
title: Copy-to-Clipboard Buttons
description: Customize code block copy buttons or add copy buttons for other content in VitePress.
---

# Copy-to-Clipboard Buttons

The default VitePress theme already puts a copy button on every fenced code block, so there is nothing to install for the common case. The work is usually one of:

- change the tooltip or the "copied" label
- add a copy button to content that is not a code block
- add a "copy page as Markdown" button

Checked against VitePress 1.6.4 and 2.0.0-alpha.21. The configuration key differs between the two.

## Built-in code block buttons

Every fenced code block gets a `<button class="copy">` automatically. No config is required.

### Tooltip text

VitePress 1.x uses `markdown.codeCopyButtonTitle`:

```ts
import { defineConfig } from 'vitepress'

export default defineConfig({
  markdown: {
    codeCopyButtonTitle: 'Copy code'
  }
})
```

In 1.x this sets only the button's `title` attribute (the hover tooltip). The default is `Copy Code`.

VitePress 2.0 alpha renamed the option and added a separate success label:

```ts
import { defineConfig } from 'vitepress'

export default defineConfig({
  markdown: {
    codeCopyButton: {
      tooltipText: 'Copy code',
      copiedText: 'Copied'
    }
  }
})
```

### "Copied" label

VitePress 1.x renders the success label with a CSS variable:

```css
:root {
  --vp-code-copy-copied-text-content: 'Copied';
}
```

This changes the success feedback only, not the hover tooltip. VitePress 1.x has no config option for this text.

VitePress 2.0 alpha no longer uses that variable. The label comes from `markdown.codeCopyButton.copiedText` (shown in the previous snippet) and is emitted as a `data-copied` attribute on the button.

### LAN preview caveat

`navigator.clipboard` is only available in a secure context. When you preview with `--host 0.0.0.0` and open `http://192.168.x.x:5173`, the API is unavailable; VitePress falls back to a hidden textarea plus `document.execCommand('copy')`. A custom component should do the same, otherwise its button will silently fail off `localhost`. Test clipboard behavior over `localhost` or HTTPS.

## A custom copy button

Use a small Vue component when you need a button for prose, a command, or a blockquote. This works with any VitePress version that supports theme extension.

`docs/.vitepress/theme/components/CopyButton.vue`:

```vue
<script setup>
import { ref } from 'vue'

const props = defineProps({
  text: { type: String, required: true },
  label: { type: String, default: 'Copy' }
})

const copied = ref(false)

async function writeToClipboard(value) {
  if (navigator.clipboard?.writeText) {
    await navigator.clipboard.writeText(value)
    return
  }

  // Fallback for insecure contexts such as http://192.168.x.x
  const el = document.createElement('textarea')
  el.value = value
  el.setAttribute('readonly', '')
  el.style.position = 'absolute'
  el.style.left = '-9999px'
  document.body.appendChild(el)
  el.select()
  document.execCommand('copy')
  document.body.removeChild(el)
}

async function copy() {
  try {
    await writeToClipboard(props.text)
    copied.value = true
    setTimeout(() => {
      copied.value = false
    }, 2000)
  } catch (err) {
    console.error('Failed to copy:', err)
  }
}
</script>

<template>
  <button type="button" class="copy-button" :class="{ copied }" @click="copy">
    {{ copied ? 'Copied' : label }}
  </button>
</template>

<style scoped>
.copy-button {
  padding: 4px 12px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 6px;
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  cursor: pointer;
}

.copy-button:hover {
  border-color: var(--vp-c-brand-1);
}

.copy-button.copied {
  border-color: var(--vp-c-green-1);
  color: var(--vp-c-green-1);
}
</style>
```

Register it in `docs/.vitepress/theme/index.ts`:

```ts
import DefaultTheme from 'vitepress/theme'
import CopyButton from './components/CopyButton.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('CopyButton', CopyButton)
  }
}
```

If the project already has a theme entry, add `extends` and the `app.component(...)` line to it instead of replacing the file.

Use it from Markdown:

```md
<CopyButton text="pnpm docs:dev" label="Copy command" />
```

Do not paste `<` or `>` into the `text` prop; use HTML entities (`&lt;`, `&gt;`) if the copied string contains them.

## Community options

Both packages are third-party. Pin the version you install and re-check compatibility when you upgrade VitePress.

### vitepress-copy-helper

Attaches copy buttons to inline code and code blocks, and supports standalone buttons. Last release is 0.0.3 (December 2023), so verify it still works with your VitePress version.

```bash
pnpm add -D vitepress-copy-helper
```

`.vitepress/theme/index.ts`:

```ts
import DefaultTheme from 'vitepress/theme'
import CopyButton from 'vitepress-copy-helper'
import 'vitepress-copy-helper/style.css'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('C', CopyButton)
  }
}
```

`C` is the tag you write in Markdown. With no props it attaches to the nearest previous `code` element; a standalone button needs the `content` prop:

```md
<C content="pnpm docs:dev" label="Copy command" />
```

Defaults can be changed through `defaultSettings` (`position`, `message`, `label`, `classes`, `target`, `preferSibling`). See the [repository readme](https://github.com/Mtillmann/vitepress-copy-helper) for the full API.

### vitepress-plugin-llms

Generates `llms.txt` and adds a page-level "Copy page" / "Download as Markdown" control. Setup needs both a theme component and a Markdown plugin; the Markdown plugin inserts the buttons, so you do not add a tag per page.

```bash
pnpm add -D vitepress-plugin-llms
```

Theme entry:

```ts
import DefaultTheme from 'vitepress/theme'
import type { Theme } from 'vitepress'
import CopyOrDownloadAsMarkdownButtons from 'vitepress-plugin-llms/vitepress-components/CopyOrDownloadAsMarkdownButtons.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('CopyOrDownloadAsMarkdownButtons', CopyOrDownloadAsMarkdownButtons)
  }
} satisfies Theme
```

Config:

```ts
import { defineConfig } from 'vitepress'
import { copyOrDownloadAsMarkdownButtons } from 'vitepress-plugin-llms'

export default defineConfig({
  markdown: {
    config(md) {
      md.use(copyOrDownloadAsMarkdownButtons)
    }
  }
})
```

Labels are configurable through `themeConfig.llms` (`copyText`, `copiedText`, `viewMarkdownText`, `openInAIText`). See the [repository readme](https://github.com/okineadev/vitepress-plugin-llms) for the plugin options and generated files.

## Which one to use

| Method | Scope | Setup | Notes |
| --- | --- | --- | --- |
| Built-in | Code blocks | None | Already present; only text is configurable |
| Custom component | Any content | Low | Full control, no dependency, needs the clipboard fallback |
| vitepress-copy-helper | Inline code, code blocks, standalone | Low | Third-party, small API, last release 2023 |
| vitepress-plugin-llms | Whole page as Markdown | Medium | Also emits `llms.txt`; not a per-block button |

## Sources

- [VitePress site config: markdown](https://vitepress.dev/reference/site-config#markdown)
- [VitePress 1.x markdown options](https://github.com/vuejs/vitepress/blob/v1/src/node/markdown/markdown.ts)
- [VitePress default theme styles](https://github.com/vuejs/vitepress/blob/v1/src/client/theme-default/styles/components/vp-doc.css)
- [vitepress-copy-helper](https://github.com/Mtillmann/vitepress-copy-helper)
- [vitepress-plugin-llms](https://github.com/okineadev/vitepress-plugin-llms)
