#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -d node_modules/wrangler ]]; then
  echo "Installing dependencies…"
  npm install
fi

if ! npx wrangler whoami &>/dev/null; then
  echo "Not logged in to Cloudflare. Run: npm run login"
  exit 1
fi

echo "Deploying Worker oss-milon-im → oss.milon.im …"
npx wrangler deploy
echo "Done. https://oss.milon.im/"
