Awesome — here’s a single, drop-in Agents.md that briefs GPT-5 Codex on everything we planned in this thread and what to build next. It’s written so you can paste it at the root of your repo and let Codex scaffold the whole system end-to-end.


---

Agents.md

Project Name

McCaigs Education AI Suite — multi-brand, local-first AI apps:

StudentlyAI (studentlyai.com)

StudentsAI UK (studentsai.co.uk)

StudentsAI US (studentsai.us)
(Next brands: PupilsAI, TeachersAI, GraduatesAI, CareersAI, …)



---

Vision & Model

Buy once, own forever: lifetime licence per user (covers desktop + tablet + mobile).

Tiered launch pricing per brand:

1. 10k @ £/$29 → 2) 20k @ £/$49 → 3) 70k @ £/$99 → 4) full £/$149.



Marketplace for optional add-ons (one-off purchases) to create recurring revenue without subscriptions.

Local vs Cloud AI toggle in Settings: on-device SLMs (GGUF) or Cloud APIs (OpenRouter, OpenAI, Anthropic, Groq, etc.).



---

Tech Stack (high level)

Mobile: Flutter (MAID-style base), iOS & Android, on-device models via llama.cpp/MLC LLM; cloud via LiteLLM or Vercel AI SDK.

Desktop/Laptop: Electron/React (ClaraVerse-like shell). Integrations: MCP servers, n8n, ActivePieces. Optional agentic coding assistant (Void), career/job agent (Pluely).

Backend (licensing + marketplace): Node/Express (or simple edge functions later).

Database: PostgreSQL (start with Supabase schema or DigitalOcean Managed PG).

Payments: Stripe + PayPal.

Hosting recommendation: start on DigitalOcean (London + NYC), scale with read replicas and more regions; front with Cloudflare; keep option to migrate to Fly.io/AWS later.



---

Repos / Apps to Scaffold

1) Mobile App (Flutter)

Goal: Student-ready Beta built on MAID principles.

Key packages & modules

/app
  main.dart
  /branding
    branding_config.dart        # theming + currency + routes per brand
  /modules
    chat/                       # chat UI + context manager
    files/                      # PDF/EPUB/DOCX ingestion
    workspace/                  # course folders, notes, tagging
    rag/                        # embeddings + SQLite/FAISS or LanceDB
    models/                     # GGUF model manager (+ MLC/Ollama fallback)
    sync/                       # P2P QR + optional Google Drive/iCloud
    tools/                      # calculator, citation, timetable, LaTeX
    auth/                       # licence validation (Supabase/DO PG)
  /services
    licence_service.dart        # create/activate/validate licences
    marketplace_service.dart    # list/buy/install add-ons

Brand theming

StudentlyAI = orange-500 (#F97316) primary, white/black accents.

StudentsAI UK = dark academic blue.

StudentsAI US = sky blue.


Provide branding_config.dart with AppBrand enum and per-brand BrandConfig (app name, tagline, currency, prices, colours). Build flags: --dart-define=APP_BRAND=studentlyai|studentsai_uk|studentsai_us.

Settings Panel (UI)

Tabs: Models, Add-ons, Sync, Account.

Models: segmented toggle Local AI ↔ Cloud AI.

Local: list installed GGUFs (Qwen3-0.6B, Gemma3-1B); “+ Add Model”.

Cloud: Provider dropdown (OpenRouter/OpenAI/Anthropic/Groq), API key, preferred model.


Add-ons: marketplace cards, price, buy/install buttons.

Sync: P2P via QR, optional Google Drive/iCloud/Dropbox.

Account: licence code, tier, devices (3 max), deactivate device.


RAG

Ingest (split, metadata) → embed (e5-small/BGE-small GGUF) → store (SQLite/FAISS/LanceDB) → retrieve → generate.

Auto tag folders by subject; per-brand defaults (UK spelling for StudentsAI UK).



---

2) Desktop/Laptop App (Electron/React)

Goal: ClaraVerse-style shell.

Modules

Chat/Workspace mirroring mobile.

MCP plugin layer.

Bundled n8n and ActivePieces (launchable services + UI hooks).

Agentic assistants:

Void (coding) in GraduatesAI & CareersAI editions.

Pluely for job/career Q&A (CareersAI).


Marketplace client (same backend).



---

3) Licensing & Pricing System

Schema (Postgres / Supabase compatible)
Tables: brands, pricing_tiers, licences.
Functions: get_current_tier(brand_id) (returns active tier), trigger increment_tier_sold after licence insert.

Tier seeds per brand

order: 1 price 29 cap 10000

order: 2 price 49 cap 20000

order: 3 price 99 cap 70000

order: 4 price 149 cap 9999999


API (Node/Express minimal)

POST /create-checkout-session (Stripe) with { brandId, price }.

Stripe webhook /webhook → on checkout.session.completed insert licence (brand, tier, code, price_paid, email).

For PayPal: client‐side SDK “onApprove” → insert licence.


Landing page licence.mccaigs.ai

Single HTML (Tailwind + Supabase client + Stripe/PayPal buttons).

?brand=studentlyai|studentsai_uk|studentsai_us → theme + currency + tier loaded dynamically via RPC get_current_tier.

Progress bar “X of Y sold” + “Buy Now” (Stripe/PayPal).



---

4) Marketplace Backend

Schema (Postgres / Supabase)

addons (id, brand_id nullable for global, name, description, price, currency, category, slug, icon_url).

addon_versions (addon_id, version, release_notes, download_url).

addon_purchases (licence_id, addon_id, price_paid, currency, purchased_at).

addon_installs (addon_id, licence_id, device_id, status).


RPC helpers

get_available_addons(brand_id) → global + brand-specific.

get_purchased_addons(licence_id) → with latest version + installed status.


Starter catalogue (SKUs)

Research Pack (£19/$25): MemGPT, SentenceTransformers, Zotero/Notion connectors, citation helper.

Study Skills Pack (£15/$20): spaCy reading level, fastText classifier, flashcard generator.

Lesson Builder Pack (£25/$30): Haystack Q&A, lesson plan → slides/doc.

Classroom Automation Pack (£29/$35): quick grading helpers, parent comms.

Career Pack (£29/$39): Pluely agent, CV builder, interview sim.

Graduate Coding Pack (£39/$49): TabbyML, Void assistant, deploy workflow.

Law Pack (£49/$59): Haystack over case law, citation finder.

Medical Pack (£49/$59): PubMed embeddings, case summariser.

Workflow Automation Pack (£25/$30): 10 n8n + ActivePieces templates.

Productivity Pack (£19/$25): meetings → notes, calendar optimiser, study tracker.



---

5) Model Options

Local (default)

GGUF models: Qwen3-0.6B, Gemma3-270M / 1B; run via llama.cpp (desktop) & MLC LLM (mobile).

Embeddings: e5-small/bge-small in GGUF.


Cloud (optional)

LiteLLM or Vercel AI SDK as the single client to route to:

OpenRouter.ai (multi-provider)

OpenAI / Anthropic / Groq / etc.


Per-brand defaults: UK spelling for StudentsAI UK, US for StudentsAI US.



---

DigitalOcean Deployment Plan

Initial (UK+US)

Managed Postgres: London primary; optional NYC read replica.

App Platform: Node licence server in London + NYC, static landing page in London.

DNS: licence.mccaigs.ai behind Cloudflare; geo-route to nearest server.

Cost after credits (ballpark): ~$50–70/m start; scale with dyno sizes + DB replicas.


Scale-out

Add regions (EU/Asia/LatAm) with additional App Platform services + DB read replicas.

Optionally migrate app tier to Fly.io for multi-region VMs if needed.

Keep the database on DO or move to AWS RDS when enterprise/contracts require.



---

Security & Limits

3 devices per licence (store hashed device IDs).

Offline validation grace period (e.g., 30 days).

Webhook handlers idempotent (Stripe replay protection).

RLS/Policies: public read for brands/tiers; inserts allowed for licences (or route via server only).

Secrets: Stripe, PayPal, DB keys in environment variables.



---

CI/CD

GitHub → DO App Platform (auto deploy main).

Flutter CI: build Android/iOS pipelines, store artefacts.

Electron CI: build Windows/macOS/Linux binaries.



---

Tasks for Codex (DO THESE IN ORDER)

1. Create monorepo structure

apps/mobile_flutter/

apps/desktop_electron/

apps/licence_page/

services/licence_server/

db/ (SQL)

docs/ (this file + readmes)



2. Scaffold Flutter app with modules & theming; include Settings panel UI with Local/Cloud toggle and stubs for marketplace/sync/account.


3. Implement licence_service.dart (Supabase client) with:

getCurrentTier(brandId)

createLicence(brandId, userEmail) (after payment confirmation)

activateLicence(code, deviceId)

validateLicence(code, deviceId)



4. Add dynamic LicenceScreen that shows current tier price, progress bar, and purchase button.


5. Create landing page apps/licence_page/index.html with brand query param, Tailwind, Supabase client, Stripe & PayPal buttons.


6. Build Node/Express server services/licence_server/server.js:

/create-checkout-session for Stripe

/webhook for Stripe events → insert licence row.



7. Database

Put SQL (brands, pricing_tiers, licences + functions/triggers) in db/licensing.sql.

Put marketplace SQL (addons, versions, purchases, installs + RPCs) in db/marketplace.sql.



8. Desktop app initial scaffold (Electron/React) with nav + Settings panel + links to bundled n8n and ActivePieces (start as external services; we’ll dock them later).


9. Integrate model runners

Mobile: MLC LLM with example GGUF loading & chat.

Desktop: llama.cpp (binary + bindings) or Ollama bridge; add LiteLLM/Vercel AI SDK for cloud route.



10. Seed Marketplace



Insert starter SKUs; render Add-ons tab listing via get_available_addons(brand_id).


11. Docs



docs/DEPLOY_DO.md with DO App Platform + Managed PG + DNS steps.

docs/BRANDS.md for adding new brands (DB inserts + theming).

docs/MARKETPLACE.md for adding new add-ons + versions.



---

Environment Variables (examples)

SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_KEY (or DO PG connection string).

STRIPE_PUBLISHABLE_KEY, STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET.

PAYPAL_CLIENT_ID.

FRONTEND_URL=https://licence.mccaigs.ai.



---

QA Checklist

Tier rollover at exact caps (10k, 20k, 70k).

Licence insert increments sold.

Device activations capped at 3.

Offline validation grace period works.

Landing page shows correct price/cap per brand.

Settings panel toggles local/cloud successfully; cloud API key masked & tested.

Marketplace purchase → purchase row created → install works → updates visible.



---

Stretch Goals

Geo-replicated read endpoints; sticky sessions by region.

Caching layer for read-only counters (Cloudflare KV/Workers or Redis).

Institutional licensing adapter (bulk codes for universities).

In-app telemetry (opt-in) to improve onboarding and performance.



---

Owner note: Default all copy to British English for UK brands; switch to US spelling for StudentsAI US.


---

End of Agents.md

