# Deploying the McCaigs Education AI Suite to DigitalOcean

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
