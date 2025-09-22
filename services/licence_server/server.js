import 'dotenv/config';
import express from 'express';
import cors from 'cors';

const app = express();
app.use(cors());
app.use(express.json());

// TODO: Replace with real Stripe integration keys.
const stripeSecret = process.env.STRIPE_SECRET_KEY ?? 'sk_test_placeholder';

app.post('/create-checkout-session', async (req, res) => {
  const { brandId, email } = req.body ?? {};
  if (!brandId || !email) {
    return res.status(400).json({ error: 'brandId and email are required' });
  }

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
});

const port = process.env.PORT ?? 4000;
app.listen(port, () => {
  console.log(`Licence server listening on port ${port}`);
});
