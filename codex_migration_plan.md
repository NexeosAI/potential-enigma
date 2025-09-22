# Codex Migration Plan

## Phase 1 – Vendor MAID
* [ ] Add MAID as a submodule under `/vendor/maid`.
* [ ] Confirm `llama_sdk` and dependencies compile inside `apps/mobile_flutter/pubspec.yaml`.
* [ ] Add documentation in `docs/MAID_INTEGRATION.md` describing what MAID provides and what we override.
**Deliverable:** PR #1 → Repo contains `/vendor/maid` with MAID source, Flutter still builds.

## Phase 2 – Extract MAID Core
* [ ] Create `/apps/mobile_flutter/lib/maid_core/`.
* [ ] Copy MAID's chat, model manager, and theme logic into `maid_core`.
* [ ] Wire `main.dart` to boot from `maid_core` chat UI.
**Deliverable:** PR #2 → Mobile app boots with vanilla MAID UI via `maid_core`.

## Phase 3 – Brand Theming
* [ ] Replace MAID theme with `AppBrand` + `BrandConfig` (studentlyai, studentsaiUk, studentsaiUs).
* [ ] Add currency + spelling variants (UK/US differences).
* [ ] Ensure tab bar, buttons, and chip themes use brand colours.
**Deliverable:** PR #3 → App switches theme based on brand flag.

## Phase 4 – Licensing Integration
* [ ] Add `/lib/modules/licensing/` with `licence_service.dart`.
* [ ] Build Licensing tab UI integrated into Settings.
* [ ] Backend: Scaffold `/services/licence_server/` with Express routes:
   * `POST /create-checkout-session`
   * `POST /webhook`
* [ ] Connect Postgres schema (`db/licensing.sql`) with Supabase.
**Deliverable:** PR #4 → Licensing flow (UI + backend) functional with Stripe test mode.

## Phase 5 – Workspace & RAG
* [ ] Add `/lib/modules/workspace/` for folder + file ingestion.
* [ ] Add `/lib/modules/rag/` with embedding pipeline + FAISS/LanceDB.
* [ ] Implement `CitationService` (APA/Harvard).
* [ ] Connect RAG answers into chat output.
**Deliverable:** PR #5 → Upload a PDF, query it via chat, citations returned.

## Phase 6 – Marketplace
* [ ] Add `/lib/modules/marketplace/` with UI cards.
* [ ] Extend DB schema (`db/marketplace.sql`).
* [ ] Fetch SKUs from backend.
* [ ] Disable purchase until backend is ready.
**Deliverable:** PR #6 → Marketplace UI visible, SKU list loads.

## Phase 7 – Sync
* [ ] Add `/lib/modules/sync/`:
   * Phase 1: P2P QR/WebRTC.
   * Phase 2: Cloud adapters (Google Drive, iCloud).
* [ ] Add Sync tab in Settings.
**Deliverable:** PR #7 → P2P device sync working.

## Phase 8 – CI/CD
* [ ] Add GitHub Actions for Flutter builds → Android APK + iOS archive.
* [ ] Add GitHub Actions for Licence Server tests.
* [ ] Deployment docs (`docs/DEPLOY_DO.md`) for DigitalOcean/Postgres.
**Deliverable:** PR #8 → CI/CD pipeline builds artefacts and runs backend tests.

## Phase 9 – Polish & Docs
* [ ] Clean up redundant MAID code not used by McCaigs.
* [ ] Add `docs/BRANDS.md` (how to add a new brand).
* [ ] Add `docs/MARKETPLACE.md` (how to add a new add-on).
* [ ] Update `README.md` with installation + licensing instructions.
**Deliverable:** PR #9 → Documentation complete, repo developer-ready.
