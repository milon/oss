#!/usr/bin/env bash
# Assemble publish/ from sibling checkouts (../barcode, ../papyrus, …).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CODE="$(cd "$ROOT/.." && pwd)"
PUBLISH="$ROOT/publish"
PAPYRUS_BIN="${PAPYRUS_BIN:-}"

run_papyrus() {
  # shellcheck disable=SC2086
  eval "$PAPYRUS_BIN" "$@"
}

if [[ -z "$PAPYRUS_BIN" ]]; then
  if [[ -x "$ROOT/papyrus.phar" ]]; then
    PAPYRUS_BIN="php $ROOT/papyrus.phar"
  elif [[ -x "$CODE/barcode/papyrus.phar" ]]; then
    PAPYRUS_BIN="php $CODE/barcode/papyrus.phar"
  elif [[ -x "$CODE/papyrus/bin/papyrus" ]]; then
    PAPYRUS_BIN="$CODE/papyrus/bin/papyrus"
  else
    echo "Set PAPYRUS_BIN or place papyrus.phar next to this repo." >&2
    exit 1
  fi
fi

nest() {
  local src="$1"
  local dest="$2"
  mkdir -p "$PUBLISH/$dest"
  rsync -a --exclude CNAME "$src"/ "$PUBLISH/$dest/"
  echo "  + /$dest/ ← $src"
}

echo "Building projects…"

(cd "$CODE/barcode" && PAPYRUS_BIN="$PAPYRUS_BIN" docs-src/bin/build-site)
(cd "$CODE/papyrus" && composer install --no-interaction --prefer-dist >/dev/null && ./bin/papyrus build:site -d examples/the-papyrus-handbook -e docs)
(cd "$CODE/bohurupee" && PAPYRUS_BIN="$PAPYRUS_BIN" docs/bin/build-site)
(cd "$CODE/fuse" && PAPYRUS_BIN="$PAPYRUS_BIN" docs-src/bin/build-site)

rm -rf "$PUBLISH"
mkdir -p "$PUBLISH"
nest "$CODE/barcode/docs/milon-barcode-site" barcode
nest "$CODE/papyrus/docs/the-papyrus-handbook-site" papyrus
nest "$CODE/bohurupee/docs/export/bohurupee-site" bohurupee
nest "$CODE/fuse/docs/milon-fuse-site" fuse

echo "oss.milon.im" > "$PUBLISH/CNAME"
touch "$PUBLISH/.nojekyll"
cat > "$PUBLISH/robots.txt" <<EOF
User-agent: *
Allow: /

Sitemap: https://oss.milon.im/barcode/sitemap.xml
Sitemap: https://oss.milon.im/papyrus/sitemap.xml
Sitemap: https://oss.milon.im/bohurupee/sitemap.xml
Sitemap: https://oss.milon.im/fuse/sitemap.xml
EOF

echo "Done → $PUBLISH"
echo "Preview: cd publish && php -S 127.0.0.1:8080"
