#!/bin/bash
# Converts Obsidian image embeds to standard markdown for VitePress compatibility.
#
#   ![[image.png]]           → ![image.png](./image.png)
#   ![[image.png|alt text]]  → ![alt text](./image.png)
#   ![[subdir/image.png]]    → ![image.png](./subdir/image.png)
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

find "$TARGET_DIR" -name '*.md' \
  -not -path '*/.vitepress/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' | while read -r file; do
  if grep -q '!\[\[.*\]\]' "$file"; then
    # ![[path/image.png|alt text]] → ![alt text](./path/image.png)
    # ![[path/image.png]]          → ![image.png](./path/image.png)
    sed -E '
      s/!\[\[([^]|]+)\|([^]]+)\]\]/![\2](.\/\1)/g
      s/!\[\[([^]]+)\]\]/![\1](.\/\1)/g
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    echo "converted: $file"
    count=$((count + 1))
  fi
done

echo "done"
