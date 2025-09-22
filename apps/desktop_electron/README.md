# Desktop Electron Scaffold

codex/create-working-plan-from-agents.md-0qnebh
This directory now contains the starter Electron shell for the McCaigs
Education AI Suite. The scaffold focuses on brand-aware navigation with module
placeholders that mirror the mobile experience. React is not yet wired in; the
renderer uses lightweight vanilla JavaScript so we can iterate quickly before
introducing a framework or bundler.

## Structure

- `package.json` — minimal Electron app metadata and scripts.
- `src/main.js` — Electron main process that loads the renderer and applies
  the `APP_BRAND` environment variable (`studentlyai`, `studentsai_uk`,
  `studentsai_us`).
- `src/preload.js` — exposes the resolved brand into the renderer context.
- `src/renderer/` — vanilla HTML/CSS/JS for the navigation shell and module
  cards.

## Getting Started

```bash
cd apps/desktop_electron
npm install
npm run dev # or npm start for production-like execution
```

Set the brand at launch with `APP_BRAND=studentsai_uk npm run dev` to preview UK
styling. Without an override the shell defaults to StudentlyAI.

Future work should:

1. Swap the vanilla renderer for a Vite-powered React (or Svelte) front end.
2. Add IPC bridges for workspace storage, local model management, and MCP
   plugin control.
3. Integrate n8n and ActivePieces launchers alongside marketplace-driven
   extensions.

This directory reserves space for the Electron/React desktop experience. Future
iterations should:

1. Initialise an Electron + Vite/React project.
2. Mirror navigation with the mobile app (chat, workspace, settings).
3. Integrate MCP plugins and external automation services (n8n, ActivePieces).
4. Provide brand-aware theming matching `branding_config.dart` in the Flutter app.
main
