---
name: vitepress
description: Set up, configure, migrate, and troubleshoot VitePress documentation sites. Use when creating a docs site, wiring docs/.vitepress/config.ts, configuring sidebar/nav, converting Obsidian markdown, or fixing VitePress dev/build issues. Triggers on phrases like "vitepress", "docs site", "documentation site", "add sidebar", "add nav", or "obsidian docs".
---

# VitePress Skill

Use this skill when the user wants a VitePress documentation site created, configured, migrated from markdown or Obsidian, or repaired.

## Typical requests

- set up a VitePress docs site
- add nav or sidebar items in VitePress
- convert an Obsidian vault into VitePress-friendly docs
- fix a VitePress dev server or build failure

## Default workflow

1. Keep docs in `docs/` and config in `docs/.vitepress/config.ts`.
2. Prefer `pnpm` for install and scripts.
3. Ensure `package.json` includes `"type": "module"` and `docs:dev`, `docs:build`, and `docs:preview` scripts.
4. If the source markdown comes from Obsidian, copy the bundled script to `scripts/convert-obsidian-images.sh`, make it executable, then run it before building or wire it into `docs:build`.
5. Keep `themeConfig.nav` and `themeConfig.sidebar` aligned with real files under `docs/`.
6. Verify with `pnpm docs:build`; use `pnpm docs:dev` for local inspection.

## Scaffold

When bootstrapping a new site, create:

```text
docs/
├── .vitepress/
│   └── config.ts
├── public/
├── guide/
│   └── getting-started.md
└── index.md
```

Minimal `docs/.vitepress/config.ts`:

```ts
import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'Project Name',
  description: 'Project description',
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Guide', link: '/guide/getting-started' }
    ],
    sidebar: [
      {
        text: 'Guide',
        items: [
          { text: 'Getting Started', link: '/guide/getting-started' }
        ]
      }
    ]
  }
})
```

Minimal `docs/index.md`:

```md
---
layout: home
hero:
  name: Project Name
  tagline: A short description
  actions:
    - theme: brand
      text: Get Started
      link: /guide/getting-started
---
```

## Install and scripts

Prefer:

```bash
pnpm add -D vitepress
```

Use namespaced scripts:

```json
{
  "type": "module",
  "scripts": {
    "docs:dev": "vitepress dev docs --host 0.0.0.0",
    "docs:build": "bash scripts/convert-obsidian-images.sh docs && vitepress build docs",
    "docs:preview": "vitepress preview docs --host 0.0.0.0"
  },
  "pnpm": {
    "onlyBuiltDependencies": ["esbuild"]
  }
}
```

Notes:

- do not use a directory path that contains spaces; it causes quoting and path-resolution issues in scripts and VitePress
- `docs:dev` usually opens on `http://localhost:5173`
- using `--host 0.0.0.0` lets the docs dev server be reached from other devices on the same local network, which is useful for reviewing docs on a phone or tablet away from the desk while connected over Wi-Fi
- if `docs:build` references `scripts/convert-obsidian-images.sh`, ensure that file has been copied into the project first
- `docs:build` can safely run the Obsidian image converter even when the docs already use standard markdown images

## Nav and sidebar patterns

All navigation lives in `docs/.vitepress/config.ts` under `themeConfig`.

Top nav example:

```ts
themeConfig: {
  nav: [
    { text: 'Home', link: '/' },
    { text: 'Guide', link: '/guide/getting-started' },
    {
      text: 'Resources',
      items: [
        { text: 'API Reference', link: '/api/' },
        { text: 'Changelog', link: '/changelog' }
      ]
    }
  ]
}
```

Simple sidebar example:

```ts
themeConfig: {
  sidebar: [
    {
      text: 'Guide',
      items: [
        { text: 'Getting Started', link: '/guide/getting-started' },
        { text: 'Configuration', link: '/guide/configuration' }
      ]
    }
  ]
}
```

Per-route sidebar example:

```ts
themeConfig: {
  sidebar: {
    '/guide/': [
      {
        text: 'Guide',
        items: [
          { text: 'Getting Started', link: '/guide/getting-started' },
          { text: 'Configuration', link: '/guide/configuration' }
        ]
      }
    ],
    '/api/': [
      {
        text: 'API Reference',
        items: [
          { text: 'Overview', link: '/api/' },
          { text: 'Endpoints', link: '/api/endpoints' }
        ]
      }
    ]
  }
}
```

Key rules:

- sidebar links must match file paths relative to `docs/` without the `.md` suffix
- `layout: home` pages do not render the sidebar; `layout: doc` pages do
- keep config and file structure in sync; broken links often show up as empty items rather than loud failures

## Obsidian migration

VitePress does not support Obsidian image embeds like:

```md
![[image.png]]
```

Use `scripts/convert-obsidian-images.sh` to normalize image syntax before building. It handles:

- `![[image.png]]` -> `![image.png](./image.png)`
- `![[image.png|alt text]]` -> `![alt text](./image.png)`
- `![[subdir/image.png]]` -> `![image.png](./subdir/image.png)`
- `![[image.png|300]]` -> `![image.png](./image.png)`
- non-image embeds like `![[note#heading]]` are skipped

When the project needs this workflow, copy the bundled script from this skill into the target repo as `scripts/convert-obsidian-images.sh`.

## Common gotchas

### `pnpm docs` opens npmjs.com

`pnpm docs` is a built-in pnpm command. Use `docs:dev`, `docs:build`, or `docs:preview` instead.

### ESM error loading VitePress

If VitePress fails because an ESM file cannot be loaded by `require`, add `"type": "module"` to `package.json`.

### esbuild binary missing under pnpm

If VitePress fails because `esbuild` did not install correctly, add:

```json
"pnpm": {
  "onlyBuiltDependencies": ["esbuild"]
}
```

### `.vitepress/cache` and `.vitepress/dist` tracked in git

Add `.vitepress/cache` and `.vitepress/dist` to `.gitignore`. Keep `docs/.vitepress/config.ts` tracked.

### Home page has no sidebar

That is expected for `layout: home`. Use the top nav and hero actions to guide people into doc pages.
