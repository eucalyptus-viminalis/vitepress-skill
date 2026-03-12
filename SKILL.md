# Vitepress Skill

VitePress is used for serving docs.

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
    "docs:build": "vitepress build docs",
    "docs:preview": "vitepress preview docs --host 0.0.0.0"
  }
  ...
```

Opens on `http://localhost:5173` and `http://0.0.0.0:5173` (network accessible).

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

The `scripts/convert-obsidian-images.sh` script handles this conversion automatically.

### 5. Home page has no sidebar

VitePress's `layout: home` does not render the sidebar. The sidebar only appears on `layout: doc` pages. Add hero action buttons and a top nav bar to provide navigation.
