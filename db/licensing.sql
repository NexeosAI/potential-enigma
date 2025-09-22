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
    devices JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
     LIMIT 1;
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE brands IS 'Supported brands (StudentlyAI, StudentsAI UK, StudentsAI US, etc.)';
COMMENT ON TABLE pricing_tiers IS 'Tiered launch pricing for each brand.';
COMMENT ON TABLE licences IS 'Issued licences including device activation metadata.';

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
