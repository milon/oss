# milon/oss

Aggregated documentation sites for **[oss.milon.im](https://oss.milon.im/)**.

| Path | Project | Source |
| --- | --- | --- |
| [`/`](https://oss.milon.im/) | Index | Cloudflare 301 → [milon.im/open-source](https://milon.im/open-source) |
| [`/barcode/`](https://oss.milon.im/barcode/) | milon/barcode | [milon/barcode](https://github.com/milon/barcode) |
| [`/papyrus/`](https://oss.milon.im/papyrus/) | Papyrus handbook | [milon/papyrus](https://github.com/milon/papyrus) |
| [`/bohurupee/`](https://oss.milon.im/bohurupee/) | Bohurupee | [milon/bohurupee](https://github.com/milon/bohurupee) |
| [`/fuse/`](https://oss.milon.im/fuse/) | milon/fuse | [milon/fuse](https://github.com/milon/fuse) |

This repo owns the GitHub Pages custom domain `oss.milon.im`. Individual project repos only **build** docs in CI; they do not deploy Pages.

## Deploy

GitHub Actions (`.github/workflows/pages.yml`) clones each project, builds with Papyrus, nests outputs under `publish/{project}/`, and deploys.

Triggers: push to this repo, `workflow_dispatch`, weekly schedule, or `repository_dispatch` type `rebuild-docs`.

## Local assemble (siblings)

With checkouts next to this repo (`../barcode`, `../papyrus`, …) and `papyrus.phar` / sibling papyrus CLI available:

```bash
./scripts/build-local.sh
# → publish/{barcode,papyrus,bohurupee,fuse}/
```

## GitHub Pages setup

1. Settings → Pages → Source: **GitHub Actions**
2. Custom domain: **oss.milon.im**
3. Cloudflare DNS: `CNAME oss → milon.im` (proxied); root `/` redirect to `milon.im/open-source`
