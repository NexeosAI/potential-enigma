# McCaigs Education AI Suite Scaffold

This repository contains the initial monorepo scaffold for the McCaigs Education
AI Suite, covering mobile, desktop, licensing, and marketplace components across
StudentlyAI, StudentsAI UK, and StudentsAI US brands.

## Structure

- `apps/mobile_flutter` — Flutter project scaffold with module placeholders and
  brand-aware theming.
- `apps/desktop_electron` — placeholder for the future Electron/React desktop app.
- `apps/licence_page` — Tailwind-powered landing page for licence purchases.
- `services/licence_server` — Node/Express backend handling Stripe/PayPal flows.
- `db` — PostgreSQL schemas and seeds for licensing and marketplace domains.
- `docs` — deployment and operational documentation.

## Next Steps

1. Fill in the Flutter modules with production features and connect Supabase.
2. Scaffold the Electron application mirroring mobile navigation.
3. Implement Stripe/PayPal logic in the licence server and secure webhook flows.
4. Expand CI/CD in `.github/workflows` for automated builds and deployments.
