# Licence Server Scaffold

This directory contains a lightweight Express server that will handle Stripe and
PayPal checkout flows for the McCaigs Education AI Suite. The implementation is
a stub that exposes the expected routes so front-end clients can integrate
incrementally.

## Available Scripts

- `npm install` — install dependencies.
- `npm run dev` — run the server with nodemon.
- `npm start` — run the server with Node.js.

## Endpoints

- `POST /create-checkout-session` — create a checkout session (Stripe stub).
- `POST /webhook` — handle Stripe webhook callbacks.
- `GET /healthz` — simple health check for uptime monitoring.

Environment variables expected:

- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `PAYPAL_CLIENT_ID`
- `DATABASE_URL`
