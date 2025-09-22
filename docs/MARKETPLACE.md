# Marketplace Operations

This guide explains how to add and manage add-ons for the McCaigs Education AI
Suite marketplace.

## 1. Creating an Add-on

1. Insert the base add-on metadata:
   ```sql
   INSERT INTO addons (id, brand_scope, display_name, description)
   VALUES ('career_pack', ARRAY['studentsai_us'], 'Career Pack', 'CV builder and interview prep.');
   ```
2. Upload the add-on bundle to object storage (e.g., DO Spaces) and note the URL.
3. Insert the first version:
   ```sql
   INSERT INTO addon_versions (addon_id, version, download_url, release_notes)
   VALUES ('career_pack', '1.0.1', 'https://downloads.mccaigs.ai/career_pack/v1.0.1.zip', 'Adds internship matching.');
   ```

## 2. Recording Purchases

Purchases should be recorded by the licensing backend after successful payment:
```sql
INSERT INTO addon_purchases (addon_id, brand_id, purchaser_email, price_paid)
VALUES ('career_pack', 'studentsai_us', 'student@example.com', 1900);
```

## 3. Tracking Installs

Client apps call the backend to register installs for each device:
```sql
INSERT INTO addon_installs (purchase_id, device_id)
VALUES ('00000000-0000-0000-0000-000000000000', 'ios-device-123');
```

## 4. RPC Helpers

- `get_available_addons(brand_id)` — returns add-ons available to the brand.
- `get_purchased_addons(brand_id, email)` — returns owned add-ons with download
  URLs for installation.

## 5. QA Checklist

- Confirm add-on scope matches intended brands.
- Test purchase and install flows on mobile and desktop clients.
- Validate version updates trigger refreshes in the UI.
