# milon/oss

Cloudflare Worker that fronts open-source docs:

| URL | Backend |
| --- | --- |
| `https://oss.milon.im/` | 301 → `https://milon.im/open-source` |
| `https://oss.milon.im/{project}/…` | `https://milon.github.io/{project}/…` |

Each project **builds and deploys its own GitHub Pages** site on push. This Worker is a stable proxy — deploy it once (or when you change Worker code), not on every docs update.

## Deploy the Worker

First time (or new machine):

```bash
npm install
npm run login    # opens Cloudflare OAuth once
npm run deploy
```

Later (Worker code changes only):

```bash
npm run deploy
```

`npm run deploy` installs deps if needed, checks you’re logged in, then runs Wrangler. Routes for `oss.milon.im` are in `wrangler.toml`.

| Script | What it does |
| --- | --- |
| `npm run login` | Cloudflare auth (`wrangler login`) |
| `npm run whoami` | Show the logged-in account |
| `npm run dev` | Local Worker (`wrangler dev`) |
| `npm run deploy` | Deploy Worker + attach `oss.milon.im` routes |

After the first deploy, remove any leftover DNS **CNAME** `oss → milon.im` and the Cloudflare **Redirect Rule** for `/` if you still have them — the Worker owns the hostname and redirects `/`.

## New project checklist (minimal)

Repo name = URL slug (e.g. `barcode` → `oss.milon.im/barcode/`). **No Worker change.**

1. Papyrus site config:
   ```yaml
   site:
     cname: oss.milon.im   # sitemap absolutes only
     base_path: /barcode   # must match repo name
   ```
2. Docs workflow: `build:site` → **delete `CNAME`** → `upload-pages-artifact` → `deploy-pages`
3. GitHub → Settings → Pages → Source: **GitHub Actions**  
   **No custom domain** on the project (this Worker owns `oss.milon.im`).
4. Push. Live at `https://oss.milon.im/{repo}/`.

## Why a Worker?

GitHub allows only one repo to claim `oss.milon.im`. Path URLs on one host need a proxy so each project can still deploy its own Pages site independently.
