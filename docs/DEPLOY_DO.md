# Deploying the McCaigs Education AI Suite to DigitalOcean

codex/create-working-plan-from-agents.md-gyf1jn
This playbook turns the repository into a working beta on DigitalOcean using App Platform, Managed PostgreSQL, and Cloudflare DNS.

## 1. Provision core infrastructure

1. Create a **DigitalOcean Project** (e.g. `mccaigs-education-ai`).
2. Provision a **Managed PostgreSQL** cluster (Small / 2 vCPU / 4 GB RAM) in the London region and enable the `pgcrypto` extension (for UUID generation) plus `pgvector` if you plan to host embeddings on the same cluster.
3. Create a **Spaces bucket** (optional) to host add-on bundles and media assets (`downloads.mccaigs.ai`).
4. Spin up a **DigitalOcean App Platform** app with two components:
   - A static site for `apps/licence_page`.
   - A Node.js service for `services/licence_server`.

## 2. Prepare the database

1. Create a connection string for administrative access (`psql "postgres://..."`).
2. Run the schema bootstrap scripts in order:
   ```bash
   \i db/licensing.sql
   \i db/marketplace.sql
   ```
3. Verify seed data with quick sanity checks:
   ```sql
   SELECT id, display_name FROM brands;
   SELECT addon_id, version FROM addon_versions;
   ```
4. Create roles for the different actors:
   - **service_role** – full access used by the Node.js checkout service.
   - **anon_role** – read-only access for the landing page and Flutter client.
5. If you plan to use Supabase for authentication, supply the database connection string when creating the Supabase project so the RPC functions (`get_current_tier`, `create_licence`, `record_addon_purchase`, etc.) remain accessible.

## 3. Configure App Platform components

### Licence server (Node.js)

| Setting | Value |
| --- | --- |
| Source | `services/licence_server` |
| Runtime | Node.js 20 |
| Build command | `npm install` |
| Run command | `npm start` |
| HTTP port | `4000` (default from the app) |

Environment variables:

- `PORT=4000`
- `SUPABASE_URL` and `SUPABASE_SERVICE_KEY` (or `SUPABASE_SERVICE_ROLE_KEY`)
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `PAYPAL_CLIENT_ID`
- `PAYPAL_CLIENT_SECRET`
- `CHECKOUT_SUCCESS_URL` / `CHECKOUT_CANCEL_URL`
- `LICENCE_DEVICE_LIMIT` (defaults to 3)

### Landing page (static site)

Build the static site by pointing App Platform to `apps/licence_page` and select the “Static Site” component type. Publish-time environment variables are expressed through data attributes on the `<body>` element. Update them in `apps/licence_page/index.html` during build or by using App Platform’s replace-at-build feature.

Required values:

- `data-supabase-url`
- `data-supabase-anon-key`
- `data-licence-server-url` (the deployed Node.js URL)
- `data-stripe-publishable-key`
- `data-paypal-client-id`

## 4. Stripe & PayPal configuration

1. Create products/prices in Stripe to match tier pricing (£/$29 → £/$149) if you intend to manage them in Stripe. The current implementation uses ad-hoc `price_data`, so catalogue entries are optional.
2. Configure the Stripe webhook endpoint to point at `https://<licence-server-domain>/webhook` and add the generated signing secret to `STRIPE_WEBHOOK_SECRET`.
3. For PayPal, create a REST application (Sandbox and Live). Supply the client ID/secret to the Node service. The landing page will automatically render PayPal buttons when `data-paypal-client-id` is present.

## 5. DNS and routing

1. Point `licence.mccaigs.ai` (and brand domains such as `studentsai.co.uk`) at Cloudflare.
2. In Cloudflare, create CNAME records targeting the App Platform generated hosts.
3. Enable “Full (strict)” SSL mode and automatic HTTPS rewrites.
4. Optionally create workers / transform rules to route `/api/*` to the Node.js component while keeping the static page on the root path.

## 6. Secrets & environment management

- Use App Platform’s **Environment Variables** UI to store secrets; mark Stripe and PayPal keys as encrypted.
- Mirror the same variables in GitHub Actions secrets for CI deployments (`SUPABASE_SERVICE_KEY`, `STRIPE_SECRET_KEY`, `PAYPAL_CLIENT_SECRET`, etc.).
- For local development, create an `.env` file in `services/licence_server/` with matching keys.

## 7. Continuous integration

1. Configure GitHub Actions to build and deploy on `main` or tagged releases. Suggested workflow:
   - Flutter `flutter analyze` + `flutter test` (once Flutter SDK is wired up in CI).
   - `npm test` or lint scripts for the Node service.
   - DigitalOcean App Platform deploy using `doctl apps update` with a spec file.
2. Publish build artefacts for QA (APK/TestFlight build, Electron package) from the same pipeline when ready.

## 8. Observability & maintenance

- Enable **DigitalOcean Insights** for each component and set alerts on CPU/memory.
- Forward App Platform logs to Logtail or another managed log sink.
- Schedule automated backups for the Managed PostgreSQL cluster.
- Review Stripe and PayPal dashboards after each deploy to confirm webhook success and captured payments.

This guide outlines the initial deployment approach for the multi-brand suite
using DigitalOcean App Platform, Managed PostgreSQL, and Cloudflare DNS.

## 1. Provision Infrastructure

1. Create a **DigitalOcean Project** for McCaigs Education AI Suite.
2. Provision a **Managed PostgreSQL** cluster (Small/2 vCPU/4GB RAM, London region).
3. Enable **pgvector** and **pgcrypto** extensions on the cluster.
4. Create a **Spaces bucket** (optional) for add-on downloads and media assets.

## 2. Configure App Platform Services

1. Create an **App Platform** app for the Flutter web build or landing page.
2. Add a **Node.js service** pointing at `services/licence_server`.
3. Define environment variables:
   - `STRIPE_SECRET_KEY`
   - `STRIPE_WEBHOOK_SECRET`
   - `PAYPAL_CLIENT_ID`
   - `PAYPAL_CLIENT_SECRET`
   - `SUPABASE_SERVICE_KEY` or `DATABASE_URL`
4. Mount the `docs` directory as build artifacts if needed for reference.

## 3. Database Bootstrapping

1. Connect via `psql` and run `db/licensing.sql` followed by `db/marketplace.sql`.
2. Verify seed data with `SELECT * FROM brands;`.
3. Create read-only roles for Supabase or direct application access.

## 4. DNS and Routing

1. Point `licence.mccaigs.ai` and brand domains to Cloudflare.
2. Configure Cloudflare to proxy traffic to DigitalOcean App Platform endpoints.
3. Set up SSL/TLS with automatic certificate management.

## 5. CI/CD

1. Add GitHub secrets for the environment variables above.
2. Configure workflows (see `.github` plan) to build Flutter/Electron artifacts and
   deploy to App Platform on tagged releases.

## 6. Observability & Maintenance

- Enable DigitalOcean Insights for resource monitoring.
- Forward logs to Logtail or your preferred sink.
- Schedule backups for the PostgreSQL cluster.
main
