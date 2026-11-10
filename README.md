# VitePress Docs Skill

Serve your `docs` folder on your local network.

## Install

### Claude Code

```bash
git clone https://github.com/eucalyptus-viminalis/vitepress-skill ~/.claude/skills/vitepress-skill
```

Then restart Claude Code.

### Codex

> prereq: a macOS/Linux machine with Codex installed

```bash
python3 "${CODEX_HOME:-$HOME/.codex}/skills/.system/skill-installer/scripts/install-skill-from-github.py" \
  --repo "eucalyptus-viminalis/vitepress-skill" \
  --path . \
  --name vitepress \
  --method git
```

Then restart Codex.

## What it helps with

- creates a sensible `docs/` + `.vitepress/` scaffold
- configures `nav` and `sidebar` patterns
- prefers `pnpm` and namespaced docs scripts
- handles common VitePress gotchas like ESM config and `esbuild` issues
- includes an Obsidian image conversion helper at `scripts/convert-obsidian-images.sh`
- encourages `--host 0.0.0.0` for checking docs from another device on the same Wi-Fi network
- documents copy-to-clipboard buttons, including the VitePress 1.x vs 2.0 config difference, in [references/Copy-to-Clipboard Buttons.md](<references/Copy-to-Clipboard Buttons.md>)

## Example prompts

### Claude Code

```text
/vitepress set up a new docs site for this repo
```

```text
/vitepress add a sidebar and top nav for the docs section
```

```text
/vitepress convert this Obsidian docs folder into VitePress-friendly markdown
```

```text
/vitepress fix why pnpm docs:build is failing
```

### Codex

```text
Use $vitepress to set up a new docs site for this repo.
```

```text
Use $vitepress to add a sidebar and top nav for the docs section.
```

```text
Use $vitepress to convert this Obsidian docs folder into VitePress-friendly markdown.
```

```text
Use $vitepress to fix why pnpm docs:build is failing.
```

## Development

Run the shell syntax checks and the Obsidian converter regression tests:

```bash
make test
```

Regenerate the social preview image (requires Chrome; Playwright is invoked through `npx`):

```bash
make social-preview
```

The reference guide lives at [references/Copy-to-Clipboard Buttons.md](<references/Copy-to-Clipboard Buttons.md>).

## License

MIT. See [LICENSE](LICENSE).
