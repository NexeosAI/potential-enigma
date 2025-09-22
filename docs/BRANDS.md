# Adding a New Brand

The McCaigs Education AI Suite supports multiple brands using shared
infrastructure with per-brand theming and pricing. Follow these steps to add a
new brand such as PupilsAI or TeachersAI.

## 1. Database Setup

1. Insert the brand record:
   ```sql
   INSERT INTO brands (id, display_name, default_currency, primary_colour, accent_colour)
   VALUES ('pupilsai', 'PupilsAI', 'GBP', '#0F172A', '#FACC15');
   ```
2. Insert the pricing tiers using the launch ladder:
   ```sql
   INSERT INTO pricing_tiers (brand_id, sequence, price, cap)
   VALUES
     ('pupilsai', 1, 29, 10000),
     ('pupilsai', 2, 49, 20000),
     ('pupilsai', 3, 99, 70000),
     ('pupilsai', 4, 149, NULL);
   ```

## 2. Mobile App

1. Update `apps/mobile_flutter/lib/branding/branding_config.dart` with the brand
   enum entry and colour palette.
2. Provide brand-specific copy in the translations folder if localisation is
   required.
3. Ensure any brand-specific assets (icons, logos) are stored under
   `apps/mobile_flutter/assets`.

## 3. Desktop App

1. Add the brand configuration to the Electron shell once scaffolded.
2. Provide window theming and iconography to match the brand guidelines.

## 4. Landing Page

1. Update `apps/licence_page/index.html` brand configuration map.
2. Add marketing copy, testimonials, and hero imagery per brand if required.

## 5. QA Checklist

- Confirm pricing tiers match the marketing plan.
- Verify the landing page resolves correctly with `?brand=pupilsai`.
- Ensure licence issuance and validation work across mobile and desktop.
