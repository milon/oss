# milon/oss

Cloudflare Worker that fronts open-source docs:

| URL | Backend |
| --- | --- |
| `https://oss.milon.im/` | 301 → `https://milon.im/open-source` |
| `https://oss.milon.im/{project}/…` | `https://milon.github.io/{project}/…` |

Each project **builds and deploys its own GitHub Pages** site on push. This repo does **not** aggregate builds.

## New project checklist (minimal)

In the project repo (name = URL slug, e.g. `barcode`):

1. Papyrus site config:
   ```yaml
   site:
     cname: oss.milon.im   # sitemap absolutes only
     base_path: /barcode   # must match repo name
   ```
2. Docs workflow: `build:site` → **delete `CNAME`** → `upload-pages-artifact` → `deploy-pages`
3. GitHub → Settings → Pages → Source: **GitHub Actions**  
   **No custom domain** on the project (Worker owns `oss.milon.im`).
4. Push. Live at `https://oss.milon.im/{repo}/` with **zero changes** to this Worker.

## Deploy this Worker

```bash
npm install
npx wrangler login
npm run deploy
```

Then in Cloudflare: attach custom domain **`oss.milon.im`** to the Worker  
(or set a route `oss.milon.im/*` on the `milon.im` zone).

Remove the old **DNS CNAME** `oss → milon.im` if the Worker domain binding creates its own record. Keep the zone on Cloudflare.

You can delete the Cloudflare **Redirect Rule** for `/` — the Worker handles that redirect.

## Why not one Pages site for everything?

GitHub allows only one repo to claim `oss.milon.im`. Path URLs on one host need either an aggregator (rebuilds everything) or this proxy (each repo deploys independently). This matches “deploy on every push” with minimal new-project setup.
