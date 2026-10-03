/**
 * Route oss.milon.im/{project}/… → milon.github.io/{project}/…
 *
 * Each project deploys its own GitHub Pages site. This Worker only proxies.
 * New project: deploy Pages at milon.github.io/{repo} with base_path /{repo} — no Worker change.
 */

const ORIGIN = "https://milon.github.io";
const INDEX_REDIRECT = "https://milon.im/open-source";

export default {
  async fetch(request, _env, _ctx) {
    const url = new URL(request.url);

    if (url.pathname === "/" || url.pathname === "") {
      return Response.redirect(INDEX_REDIRECT, 301);
    }

    // /barcode, /barcode/, /barcode/index.html → milon.github.io/barcode/...
    const target = new URL(ORIGIN + url.pathname);
    if (url.pathname.endsWith("/")) {
      // GitHub Pages serves directory indexes; keep trailing slash
    } else if (!url.pathname.split("/").pop().includes(".")) {
      // /barcode → /barcode/ for cleaner project roots
      const parts = url.pathname.split("/").filter(Boolean);
      if (parts.length === 1) {
        return Response.redirect(`${url.origin}/${parts[0]}/`, 301);
      }
    }

    target.search = url.search;

    const incoming = new Request(target, request);
    const response = await fetch(incoming);

    // Pass through; avoid leaking github.io redirects to custom domains we removed.
    const headers = new Headers(response.headers);
    headers.delete("content-security-policy");

    return new Response(response.body, {
      status: response.status,
      statusText: response.statusText,
      headers,
    });
  },
};
