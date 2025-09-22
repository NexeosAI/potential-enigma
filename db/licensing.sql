-- Licensing schema scaffold for McCaigs Education AI Suite.
CREATE TABLE IF NOT EXISTS brands (
    id TEXT PRIMARY KEY,
    display_name TEXT NOT NULL,
    default_currency TEXT NOT NULL,
    primary_colour TEXT NOT NULL,
    accent_colour TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS pricing_tiers (
    id SERIAL PRIMARY KEY,
    brand_id TEXT NOT NULL REFERENCES brands(id),
    sequence SMALLINT NOT NULL,
    price INTEGER NOT NULL,
    cap INTEGER,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS licences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    brand_id TEXT NOT NULL REFERENCES brands(id),
    code TEXT UNIQUE NOT NULL,
    purchaser_email TEXT NOT NULL,
    tier_sequence SMALLINT NOT NULL,
codex/create-working-plan-from-agents.md-0qnebh
=======
codex/create-working-plan-from-agents.md-gyf1jn
main
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS licence_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    licence_id UUID NOT NULL REFERENCES licences(id) ON DELETE CASCADE,
    device_id TEXT NOT NULL,
    activated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_validated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'active',
    UNIQUE (licence_id, device_id)
);

codex/create-working-plan-from-agents.md-0qnebh


    devices JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

main
main
CREATE OR REPLACE FUNCTION get_current_tier(p_brand_id TEXT)
RETURNS TABLE (
    brand_id TEXT,
    sequence SMALLINT,
    price INTEGER,
    cap INTEGER,
    sold BIGINT
) AS $$
BEGIN
    RETURN QUERY
codex/create-working-plan-from-agents.md-0qnebh

codex/create-working-plan-from-agents.md-gyf1jn
main
    WITH tier_counts AS (
        SELECT pt.brand_id,
               pt.sequence,
               pt.price,
               pt.cap,
               COUNT(l.*) AS sold
          FROM pricing_tiers pt
          LEFT JOIN licences l
            ON l.brand_id = pt.brand_id
           AND l.tier_sequence = pt.sequence
         WHERE pt.brand_id = p_brand_id
         GROUP BY pt.brand_id, pt.sequence, pt.price, pt.cap
         ORDER BY pt.sequence
    )
    SELECT tc.brand_id,
           tc.sequence,
           tc.price,
           tc.cap,
           tc.sold
      FROM tier_counts tc
     WHERE tc.cap IS NULL OR tc.sold < tc.cap
     ORDER BY tc.sequence
codex/create-working-plan-from-agents.md-0qnebh


    SELECT pt.brand_id,
           pt.sequence,
           pt.price,
           pt.cap,
           COUNT(l.*) AS sold
      FROM pricing_tiers pt
      LEFT JOIN licences l
        ON l.brand_id = pt.brand_id
       AND l.tier_sequence = pt.sequence
     WHERE pt.brand_id = p_brand_id
     GROUP BY pt.brand_id, pt.sequence, pt.price, pt.cap
     ORDER BY pt.sequence
main
main
     LIMIT 1;
END;
$$ LANGUAGE plpgsql;

codex/create-working-plan-from-agents.md-0qnebh

codex/create-working-plan-from-agents.md-gyf1jn
main
CREATE OR REPLACE FUNCTION create_licence(p_brand_id TEXT, p_email TEXT)
RETURNS TABLE (
    licence_id UUID,
    code TEXT,
    tier_sequence SMALLINT,
    price INTEGER
) AS $$
DECLARE
    target_tier RECORD;
    new_code TEXT;
BEGIN
    SELECT *
      INTO target_tier
      FROM get_current_tier(p_brand_id)
     LIMIT 1;

    IF target_tier IS NULL THEN
        RAISE EXCEPTION 'No pricing tier available for brand %', p_brand_id;
    END IF;

    new_code := CONCAT(UPPER(p_brand_id), '-', SUBSTRING(REPLACE(gen_random_uuid()::TEXT, '-', ''), 1, 8));

    INSERT INTO licences (brand_id, code, purchaser_email, tier_sequence)
    VALUES (p_brand_id, new_code, p_email, target_tier.sequence)
    RETURNING id, code, tier_sequence
      INTO licence_id, code, tier_sequence;

    price := target_tier.price;

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION activate_licence(p_licence_code TEXT, p_device_id TEXT)
RETURNS TABLE (
    licence_id UUID,
    device_id TEXT,
    status TEXT,
    device_count INTEGER
) AS $$
DECLARE
    target_licence licences%ROWTYPE;
    existing_device licence_devices%ROWTYPE;
    active_devices INTEGER;
BEGIN
    SELECT * INTO target_licence FROM licences WHERE code = p_licence_code;

    IF target_licence IS NULL THEN
        RAISE EXCEPTION 'Licence % not found', p_licence_code USING ERRCODE = 'P0002';
    END IF;

    SELECT *
      INTO existing_device
      FROM licence_devices
     WHERE licence_id = target_licence.id
       AND device_id = p_device_id;

    IF existing_device IS NULL THEN
        SELECT COUNT(*)
          INTO active_devices
          FROM licence_devices
         WHERE licence_id = target_licence.id
           AND status = 'active';

        IF active_devices >= 3 THEN
            RAISE EXCEPTION 'Device limit reached for licence %', p_licence_code USING ERRCODE = 'P0001';
        END IF;

        INSERT INTO licence_devices (licence_id, device_id)
        VALUES (target_licence.id, p_device_id);
    ELSE
        UPDATE licence_devices
           SET status = 'active',
               last_validated_at = NOW()
         WHERE id = existing_device.id;
    END IF;

    SELECT COUNT(*)
      INTO device_count
      FROM licence_devices
     WHERE licence_id = target_licence.id
       AND status = 'active';

    licence_id := target_licence.id;
    device_id := p_device_id;
    status := 'active';

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION validate_licence(p_licence_code TEXT, p_device_id TEXT)
RETURNS TABLE (
    licence_id UUID,
    device_id TEXT,
    status TEXT,
    last_validated_at TIMESTAMP WITH TIME ZONE,
    grace_expires_at TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    target_licence licences%ROWTYPE;
    target_device licence_devices%ROWTYPE;
    grace_interval INTERVAL := INTERVAL '72 hours';
BEGIN
    SELECT * INTO target_licence FROM licences WHERE code = p_licence_code;

    IF target_licence IS NULL THEN
        RAISE EXCEPTION 'Licence % not found', p_licence_code USING ERRCODE = 'P0002';
    END IF;

    SELECT *
      INTO target_device
      FROM licence_devices
     WHERE licence_id = target_licence.id
       AND device_id = p_device_id;

    IF target_device IS NULL THEN
        status := 'unregistered';
        licence_id := target_licence.id;
        device_id := p_device_id;
        last_validated_at := NULL;
        grace_expires_at := NULL;
        RETURN NEXT;
    END IF;

    IF target_device.status <> 'active' THEN
        status := target_device.status;
        licence_id := target_licence.id;
        device_id := p_device_id;
        last_validated_at := target_device.last_validated_at;
        grace_expires_at := target_device.last_validated_at + grace_interval;
        RETURN NEXT;
    END IF;

    licence_id := target_licence.id;
    device_id := p_device_id;

    IF NOW() > target_device.last_validated_at + grace_interval THEN
        status := 'grace_expired';
        last_validated_at := target_device.last_validated_at;
        grace_expires_at := target_device.last_validated_at + grace_interval;
        RETURN NEXT;
    END IF;

    UPDATE licence_devices
       SET last_validated_at = NOW()
     WHERE id = target_device.id
     RETURNING last_validated_at INTO last_validated_at;

    grace_expires_at := last_validated_at + grace_interval;
    status := 'active';

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE brands IS 'Supported brands (StudentlyAI, StudentsAI UK, StudentsAI US, etc.)';
COMMENT ON TABLE pricing_tiers IS 'Tiered launch pricing for each brand.';
COMMENT ON TABLE licences IS 'Issued licences including device activation metadata.';
COMMENT ON TABLE licence_devices IS 'Tracks per-device activation and validation timestamps.';
codex/create-working-plan-from-agents.md-0qnebh

COMMENT ON TABLE brands IS 'Supported brands (StudentlyAI, StudentsAI UK, StudentsAI US, etc.)';
COMMENT ON TABLE pricing_tiers IS 'Tiered launch pricing for each brand.';
COMMENT ON TABLE licences IS 'Issued licences including device activation metadata.';
main
main

-- Seed brands
INSERT INTO brands (id, display_name, default_currency, primary_colour, accent_colour)
VALUES
    ('studentlyai', 'StudentlyAI', 'GBP', '#F97316', '#FFFFFF'),
    ('studentsai_uk', 'StudentsAI UK', 'GBP', '#1E3A8A', '#0EA5E9'),
    ('studentsai_us', 'StudentsAI US', 'USD', '#0369A1', '#38BDF8')
ON CONFLICT (id) DO NOTHING;

-- Seed tier ladder (10k @ £/$29 → 20k @ £/$49 → 70k @ £/$99 → final @ £/$149)
INSERT INTO pricing_tiers (brand_id, sequence, price, cap)
VALUES
    ('studentlyai', 1, 29, 10000),
    ('studentlyai', 2, 49, 20000),
    ('studentlyai', 3, 99, 70000),
    ('studentlyai', 4, 149, NULL),
    ('studentsai_uk', 1, 29, 10000),
    ('studentsai_uk', 2, 49, 20000),
    ('studentsai_uk', 3, 99, 70000),
    ('studentsai_uk', 4, 149, NULL),
    ('studentsai_us', 1, 29, 10000),
    ('studentsai_us', 2, 49, 20000),
    ('studentsai_us', 3, 99, 70000),
    ('studentsai_us', 4, 149, NULL)
ON CONFLICT DO NOTHING;
