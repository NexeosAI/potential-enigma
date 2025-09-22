codex/create-working-plan-from-agents.md-0qnebh
# Codex Task Board

This file tracks incremental tasks for continuing the McCaigs Education AI Suite
build. Mark items as you complete them and append new tasks as requirements
arrive.

## ✅ Recently Completed
- [x] Scaffold the Electron desktop shell with brand-aware navigation and module
  placeholders that mirror the mobile app.

## 🔜 Up Next
- [ ] Replace the vanilla renderer with a framework-driven UI (React or Svelte)
  to unlock component reuse and state management.
- [ ] Add IPC channels and local storage for workspace data, model downloads,
  and marketplace metadata.
- [ ] Wire the desktop shell to the existing licensing and marketplace services
  to reuse Supabase + checkout flows.

## 📌 Backlog
- [ ] Package the Electron app for macOS, Windows, and Linux via Electron Forge
  or Vite Electron Builder.
- [ ] Integrate MCP plugins plus n8n/ActivePieces launchers for automation
  workflows.
- [ ] Add telemetry toggles, offline indicators, and QA coverage mirroring the
  mobile roadmap.

# Codex Next Tasks

## Phase 1 – Stabilise & Test
- Scaffold Jest + widget tests for Flutter and Node licence server.
- Implement Express licence server with `/create-checkout-session` and `/webhook`.
- Add GitHub Actions workflows to run Flutter build + Node/Postgres tests.

## Phase 2 – Core Features
- Expand Workspace, Models, and RAG modules as per Agents.md.
- Implement file ingestion (PDF/DOCX/TXT), vector indexing with FAISS, and retrieval pipeline.

## Phase 3 – Monetisation
- Finish licence page (Stripe/PayPal checkout integration).
- Seed marketplace (Research Pack, Career Pack).
- Flutter Settings UI → show marketplace cards.

## Phase 4 – Sync
- Implement P2P sync with QR/WebRTC.
- Add cloud sync (Google Drive/iCloud) adapter.
main
