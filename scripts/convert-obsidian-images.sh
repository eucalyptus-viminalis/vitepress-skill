#!/bin/bash
# Converts Obsidian image embeds to standard markdown for VitePress compatibility.
#
#   ![[image.png]]           → ![image.png](./image.png)
#   ![[image.png|alt text]]  → ![alt text](./image.png)
#   ![[image.png|300]]       → ![image.png](./image.png)  (resize syntax stripped)
#   ![[subdir/image.png]]    → ![image.png](./subdir/image.png)
#   ![[note#heading]]        → skipped (not an image embed)
#
# Usage:
#   ./convert-obsidian-images.sh [directory]
#
# If no directory is given, defaults to the current directory.
# Skips .vitepress, node_modules, and .git directories.

TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "error: '$TARGET_DIR' is not a directory" >&2
  exit 1
fi

count=0

while IFS= read -r file; do
  if grep -q '!\[\[.*\]\]' "$file"; then
    sed -E '
      # Skip non-image embeds like ![[note#heading]] — only process lines with image extensions
      /!\[\[[^]]*\.(png|jpg|jpeg|gif|svg|webp|bmp|ico)/I {

        # ![[path/image.ext|digits]] → strip resize syntax (Obsidian width specifier)
        s/!\[\[([^]|]+\.(png|jpg|jpeg|gif|svg|webp|bmp|ico))\|[0-9]+\]\]/![[\1]]/gI

        # ![[path/image.ext|alt text]] → ![alt text](./path/image.ext)
        s/!\[\[([^]|]+\.(png|jpg|jpeg|gif|svg|webp|bmp|ico))\|([^]]+)\]\]/![\3](.\/\1)/gI

        # ![[subdir/image.ext]] → ![image.ext](./subdir/image.ext)
        s/!\[\[([^]|]+\/)*([^]|]+\.(png|jpg|jpeg|gif|svg|webp|bmp|ico))\]\]/![\2](.\/\1\2)/gI
      }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "converted: $file"
    count=$((count + 1))
  fi
done < <(find "$TARGET_DIR" -name '*.md' \
  -not -path '*/.vitepress/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*')

echo "done. $count file(s) converted."
