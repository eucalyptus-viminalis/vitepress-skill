---
name: vitepress
description: Set up and configure VitePress documentation sites. Use when creating a docs site, configuring VitePress sidebar/nav, converting Obsidian markdown, or troubleshooting VitePress issues. Triggers on phrases like "set up docs", "vitepress", "documentation site", "add sidebar", "add nav".
---

# Vitepress Skill

VitePress is used for serving docs.

## Scaffold

When setting up a new VitePress project, create the following structure:

```
docs/
├── .vitepress/
│   └── config.ts
├── public/           # static assets (favicons, etc.)
├── guide/            # content pages
│   └── getting-started.md
└── index.md          # home page
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

## Install

prefer `pnpm`

```bash
pnpm add -D vitepress
```

## Scripts

- do not use a directory that contains spaces.
  - this causes issues with shell quoting in npm/pnpm scripts and VitePress path resolution.
  - ask the user to rename the folder to serve or use symlinking as a last resort

```json
  ...
  "scripts": {
    "docs:dev": "vitepress dev docs --host 0.0.0.0",
    "docs:build": "bash scripts/convert-obsidian-images.sh docs && vitepress build docs",
    "docs:preview": "vitepress preview docs --host 0.0.0.0"
  }
  ...
```

Opens on `http://localhost:5173` and `http://0.0.0.0:5173` (network accessible).

The `docs:build` script runs the Obsidian image converter before building so image syntax is always normalized. Standard markdown images render fine in Obsidian, so this is safe even if the docs directory is an Obsidian vault.

## Sidebar & Nav Configuration

All navigation is configured in `docs/.vitepress/config.ts` under `themeConfig`.

### Top nav bar

```ts
themeConfig: {
  nav: [
    { text: 'Home', link: '/' },
    { text: 'Guide', link: '/guide/getting-started' },
    // dropdown
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

### Sidebar

Simple flat sidebar:

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

Per-route sidebars (different sidebar for different sections):

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

Collapsible sections:

```ts
{
  text: 'Advanced',
  collapsed: true,  // starts collapsed
  items: [ ... ]
}
```

Key rules:
- sidebar links must match the file path relative to `docs/` (e.g. `docs/guide/foo.md` → `/guide/foo`)
- sidebar does NOT render on `layout: home` pages — only on `layout: doc` (the default)
- keep sidebar config in sync with actual files; broken links silently render as empty items

## Gotchas

### 1. `pnpm docs` opens npmjs.com

`pnpm docs` is a built-in pnpm command that opens the package's npm page. It does not run the `docs` script in `package.json`. Use namespacing; prefix it with `docs:` e.g. `docs:dev`.

### 2. ESM compatibility error

VitePress is ESM-only. Without `"type": "module"` in `package.json`, vite's esbuild fails with:

```
"vitepress" resolved to an ESM file. ESM file cannot be loaded by `require`.
```

Fix: add `"type": "module"` to `package.json`.

### 3. esbuild build scripts blocked by pnpm

pnpm requires explicit approval to run postinstall scripts for dependencies. esbuild needs its postinstall to install the platform-specific binary. Without it, VitePress fails silently or with missing binary errors.

Fix: add to `package.json`:

```json
"pnpm": {
  "onlyBuiltDependencies": ["esbuild"]
}
```

### 4. Obsidian image syntax not supported

Obsidian uses `![[image.png]]` for image embeds. VitePress only supports standard markdown:

```md
![alt text](./image.png)
```

The `scripts/convert-obsidian-images.sh` script handles this conversion automatically. It runs as part of `docs:build` (see Scripts section). It also handles:
- `![[image.png|alt text]]` → `![alt text](./image.png)`
- `![[subdir/image.png]]` → `![image.png](./subdir/image.png)`
- `![[image.png|300]]` (Obsidian resize syntax) → stripped, outputs `![image.png](./image.png)`
- `![[note#heading]]` (Obsidian embeds) → skipped, these are not images

### 5. Gitignore `.vitepress/cache` and `.vitepress/dist`

`.vitepress/cache` and `.vitepress/dist` should be added to `.gitignore`. The config file (`config.ts`) must remain tracked.

### 6. Home page has no sidebar

VitePress's `layout: home` does not render the sidebar. The sidebar only appears on `layout: doc` pages (see Sidebar & Nav Configuration section). Use hero action buttons and the top nav bar for home page navigation.
