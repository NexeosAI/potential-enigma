import 'dotenv/config';
import express from 'express';
import cors from 'cors';
codex/create-working-plan-from-agents.md-0qnebh

codex/create-working-plan-from-agents.md-gyf1jn
main
import Stripe from 'stripe';
import paypal from '@paypal/checkout-server-sdk';
import { createClient } from '@supabase/supabase-js';

const app = express();
app.use(cors());

const jsonMiddleware = express.json();
app.use((req, res, next) => {
  if (req.originalUrl === '/webhook') {
    next();
    return;
  }
  jsonMiddleware(req, res, next);
});

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey =
  process.env.SUPABASE_SERVICE_ROLE_KEY ??
  process.env.SUPABASE_SERVICE_KEY ??
  process.env.SUPABASE_ANON_KEY;

const supabase =
  supabaseUrl && supabaseKey
    ? createClient(supabaseUrl, supabaseKey, { auth: { persistSession: false } })
    : null;

const stripeSecret = process.env.STRIPE_SECRET_KEY;
const stripe = stripeSecret ? new Stripe(stripeSecret, { apiVersion: '2024-04-10' }) : null;

const paypalClientId = process.env.PAYPAL_CLIENT_ID;
const paypalClientSecret = process.env.PAYPAL_CLIENT_SECRET;
const paypalEnvironment = (process.env.PAYPAL_ENVIRONMENT ?? 'sandbox').toLowerCase();

const paypalEnv =
  paypalClientId && paypalClientSecret
    ? paypalEnvironment === 'live'
      ? new paypal.core.LiveEnvironment(paypalClientId, paypalClientSecret)
      : new paypal.core.SandboxEnvironment(paypalClientId, paypalClientSecret)
    : null;

const paypalClient = paypalEnv ? new paypal.core.PayPalHttpClient(paypalEnv) : null;

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

const defaultSuccessUrl = process.env.CHECKOUT_SUCCESS_URL ?? 'https://mccaigs.ai/licence-success';
const defaultCancelUrl = process.env.CHECKOUT_CANCEL_URL ?? 'https://mccaigs.ai/licence-cancelled';
const deviceLimit = Number(process.env.LICENCE_DEVICE_LIMIT ?? 3);

async function fetchTier(brandId) {
  if (!supabase) {
    throw new Error('Supabase client is not configured');
  }

  const { data, error } = await supabase.rpc('get_current_tier', {
    p_brand_id: brandId,
  });

  if (error) {
    throw error;
  }

  const tier = Array.isArray(data) ? data[0] : data;
  if (!tier) {
    throw new Error(`No active tier for brand ${brandId}`);
  }

  const { data: brand, error: brandError } = await supabase
    .from('brands')
    .select('default_currency')
    .eq('id', brandId)
    .single();

  if (brandError) {
    throw brandError;
  }

  return {
    price: tier.price,
    currency: brand.default_currency ?? 'GBP',
    sequence: tier.sequence,
    cap: tier.cap,
    sold: tier.sold,
  };
}

app.post('/create-checkout-session', async (req, res) => {
  const { brandId, email, provider = 'stripe', successUrl, cancelUrl } = req.body ?? {};

codex/create-working-plan-from-agents.md-0qnebh



const app = express();
app.use(cors());
app.use(express.json());

// TODO: Replace with real Stripe integration keys.
const stripeSecret = process.env.STRIPE_SECRET_KEY ?? 'sk_test_placeholder';

app.post('/create-checkout-session', async (req, res) => {
  const { brandId, email } = req.body ?? {};
main
main
  if (!brandId || !email) {
    return res.status(400).json({ error: 'brandId and email are required' });
  }

codex/create-working-plan-from-agents.md-0qnebh

codex/create-working-plan-from-agents.md-gyf1jn
main
  try {
    const tier = await fetchTier(brandId);
    const amountCents = Math.round(Number(tier.price) * 100);

    if (provider === 'paypal') {
      if (!paypalClient) {
        return res.status(503).json({ error: 'PayPal client not configured' });
      }

      const request = new paypal.orders.OrdersCreateRequest();
      request.requestBody({
        intent: 'CAPTURE',
        purchase_units: [
          {
            amount: {
              currency_code: tier.currency,
              value: (amountCents / 100).toFixed(2),
            },
            custom_id: JSON.stringify({ brandId, email }),
          },
        ],
        application_context: {
          brand_name: 'McCaigs Education AI Suite',
          landing_page: 'LOGIN',
          user_action: 'PAY_NOW',
          return_url: successUrl ?? defaultSuccessUrl,
          cancel_url: cancelUrl ?? defaultCancelUrl,
        },
      });

      const response = await paypalClient.execute(request);
      const approvalUrl = response.result.links?.find((link) => link.rel === 'approve')?.href;

      return res.json({
        provider: 'paypal',
        orderId: response.result.id,
        approvalUrl,
        brandId,
        email,
      });
    }

    if (!stripe) {
      return res.status(503).json({ error: 'Stripe client not configured' });
    }

    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      customer_email: email,
      metadata: {
        brandId,
        email,
        tierSequence: String(tier.sequence),
      },
      line_items: [
        {
          price_data: {
            currency: tier.currency.toLowerCase(),
            unit_amount: amountCents,
            product_data: {
              name: `McCaigs Education AI Suite – ${brandId} licence`,
            },
          },
          quantity: 1,
        },
      ],
      success_url: successUrl ?? defaultSuccessUrl,
      cancel_url: cancelUrl ?? defaultCancelUrl,
    });

    return res.json({
      provider: 'stripe',
      sessionId: session.id,
      checkoutUrl: session.url,
    });
  } catch (error) {
    console.error('[checkout-session] Failed to create session', error);
    return res.status(500).json({ error: 'Failed to create checkout session' });
  }
});

app.post(
  '/webhook',
  express.raw({ type: 'application/json' }),
  async (req, res) => {
    if (!stripe || !webhookSecret) {
      res.status(503).json({ error: 'Stripe webhook is not configured' });
      return;
    }

    const signature = req.headers['stripe-signature'];

    let event;
    try {
      event = stripe.webhooks.constructEvent(req.body, signature, webhookSecret);
    } catch (err) {
      console.error('[webhook] Invalid signature', err.message);
      res.status(400).send(`Webhook Error: ${err.message}`);
      return;
    }

    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const brandId = session.metadata?.brandId;
      const email = session.metadata?.email ?? session.customer_details?.email;

      if (brandId && email && supabase) {
        try {
          await supabase.rpc('create_licence', {
            p_brand_id: brandId,
            p_email: email,
          });
        } catch (err) {
          console.error('[webhook] Failed to create licence', err);
        }
      }
    }

    res.json({ received: true });
  },
);

app.get('/healthz', (_, res) => {
  res.json({ status: 'ok', deviceLimit });
codex/create-working-plan-from-agents.md-0qnebh


  // TODO: Create a Stripe Checkout session here.
  return res.json({
    checkoutUrl: 'https://example.com/checkout',
    brandId,
    email,
    stripeSecretUsed: stripeSecret.startsWith('sk_'),
  });
});

app.post('/webhook', express.raw({ type: 'application/json' }), (req, res) => {
  // TODO: Verify webhook signature and persist licence records.
  res.json({ received: true });
});

app.get('/healthz', (_, res) => {
  res.json({ status: 'ok' });
main
main
});

const port = process.env.PORT ?? 4000;
app.listen(port, () => {
  console.log(`Licence server listening on port ${port}`);
});
