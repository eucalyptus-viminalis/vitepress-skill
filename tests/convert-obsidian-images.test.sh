#!/usr/bin/env bash
# Regression tests for scripts/convert-obsidian-images.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONVERTER="$ROOT/scripts/convert-obsidian-images.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

[ -x "$CONVERTER" ] || fail "converter is missing or not executable: $CONVERTER"

mkdir -p \
  "$TMP/docs/sub" \
  "$TMP/docs/with space" \
  "$TMP/docs/.vitepress" \
  "$TMP/docs/node_modules/pkg"

cat > "$TMP/docs/test.md" <<'EOF'
![[image.png]]
![[image.png|alt text]]
![[subdir/image.png]]
![[image.png|300]]
![[note#heading]]
![normal](image.png)
See ![[Photo.JPG]] inline.
EOF

cat > "$TMP/expected.md" <<'EOF'
![image.png](./image.png)
![alt text](./image.png)
![image.png](./subdir/image.png)
![image.png](./image.png)
![[note#heading]]
![normal](image.png)
See ![Photo.JPG](./Photo.JPG) inline.
EOF

cp "$TMP/docs/test.md" "$TMP/docs/with space/note.md"
printf '![[skipped.png]]\n' > "$TMP/docs/.vitepress/skipped.md"
printf '![[skipped.png]]\n' > "$TMP/docs/node_modules/pkg/skipped.md"
printf '![[not-markdown.png]]\n' > "$TMP/docs/notes.txt"

output="$("$CONVERTER" "$TMP/docs")"
grep -q '2 file(s) converted' <<< "$output" || fail "unexpected conversion count: $output"

diff -u "$TMP/expected.md" "$TMP/docs/test.md" \
  || fail "documented embed forms did not convert"

diff -u "$TMP/expected.md" "$TMP/docs/with space/note.md" \
  || fail "path containing spaces did not convert"

grep -Fq '![[skipped.png]]' "$TMP/docs/.vitepress/skipped.md" \
  || fail ".vitepress directory was not skipped"

grep -Fq '![[skipped.png]]' "$TMP/docs/node_modules/pkg/skipped.md" \
  || fail "node_modules directory was not skipped"

grep -Fq '![[not-markdown.png]]' "$TMP/docs/notes.txt" \
  || fail "non-markdown file was modified"

cp "$TMP/docs/test.md" "$TMP/after-first-run.md"
"$CONVERTER" "$TMP/docs" >/dev/null
diff -u "$TMP/after-first-run.md" "$TMP/docs/test.md" \
  || fail "second run was not idempotent"

if "$CONVERTER" "$TMP/missing" >/dev/null 2>&1; then
  fail "missing directory should be rejected"
fi

echo "ok: converter tests passed"
