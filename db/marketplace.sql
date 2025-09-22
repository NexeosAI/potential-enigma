-- Marketplace schema scaffold.
CREATE TABLE IF NOT EXISTS addons (
    id TEXT PRIMARY KEY,
    brand_scope TEXT[] DEFAULT ARRAY[]::TEXT[],
    display_name TEXT NOT NULL,
    description TEXT NOT NULL,
    codex/create-working-plan-from-agents.md-0qnebh
    price_cents INTEGER NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'GBP',

codex/create-working-plan-from-agents.md-gyf1jn
    price_cents INTEGER NOT NULL DEFAULT 0,
    currency TEXT NOT NULL DEFAULT 'GBP',

main
main
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS addon_versions (
    id SERIAL PRIMARY KEY,
    addon_id TEXT NOT NULL REFERENCES addons(id),
    version TEXT NOT NULL,
    download_url TEXT NOT NULL,
    release_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS addon_purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    addon_id TEXT NOT NULL REFERENCES addons(id),
    brand_id TEXT NOT NULL REFERENCES brands(id),
    purchaser_email TEXT NOT NULL,
    price_paid INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS addon_installs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    purchase_id UUID NOT NULL REFERENCES addon_purchases(id),
    device_id TEXT NOT NULL,
    installed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE OR REPLACE FUNCTION get_available_addons(p_brand_id TEXT)
codex/create-working-plan-from-agents.md-0qnebh

codex/create-working-plan-from-agents.md-gyf1jn
main
RETURNS TABLE (
    id TEXT,
    display_name TEXT,
    description TEXT,
    price_cents INTEGER,
    currency TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id,
           a.display_name,
           a.description,
           a.price_cents,
           a.currency
      FROM addons a
     WHERE a.brand_scope IS NULL
        OR array_length(a.brand_scope, 1) = 0
        OR p_brand_id = ANY(a.brand_scope)
     ORDER BY a.display_name;
codex/create-working-plan-from-agents.md-0qnebh


RETURNS SETOF addons AS $$
BEGIN
    RETURN QUERY
    SELECT *
      FROM addons
     WHERE brand_scope IS NULL
        OR array_length(brand_scope, 1) = 0
        OR p_brand_id = ANY(brand_scope);
main
main
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_purchased_addons(p_brand_id TEXT, p_email TEXT)
RETURNS TABLE (
    addon_id TEXT,
    version TEXT,
    download_url TEXT,
    purchased_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT av.addon_id,
           av.version,
           av.download_url,
           ap.created_at
      FROM addon_purchases ap
      JOIN addon_versions av ON av.addon_id = ap.addon_id
     WHERE ap.brand_id = p_brand_id
       AND ap.purchaser_email = p_email
  ORDER BY ap.created_at DESC;
END;
$$ LANGUAGE plpgsql;

codex/create-working-plan-from-agents.md-0qnebh

codex/create-working-plan-from-agents.md-gyf1jn
main
CREATE OR REPLACE FUNCTION record_addon_purchase(
    p_addon_id TEXT,
    p_brand_id TEXT,
    p_email TEXT,
    p_price_cents INTEGER
)
RETURNS TABLE (
    purchase_id UUID,
    addon_id TEXT,
    price_paid INTEGER,
    purchased_at TIMESTAMP WITH TIME ZONE
) AS $$
DECLARE
    target_addon addons%ROWTYPE;
BEGIN
    SELECT * INTO target_addon FROM addons WHERE id = p_addon_id;

    IF target_addon IS NULL THEN
        RAISE EXCEPTION 'Addon % not found', p_addon_id USING ERRCODE = 'P0002';
    END IF;

    IF target_addon.brand_scope IS NOT NULL
       AND array_length(target_addon.brand_scope, 1) > 0
       AND NOT (p_brand_id = ANY(target_addon.brand_scope)) THEN
        RAISE EXCEPTION 'Addon % is not available for brand %', p_addon_id, p_brand_id USING ERRCODE = 'P0001';
    END IF;

    INSERT INTO addon_purchases (addon_id, brand_id, purchaser_email, price_paid)
    VALUES (p_addon_id, p_brand_id, p_email, COALESCE(p_price_cents, target_addon.price_cents))
    RETURNING id, addon_id, price_paid, created_at
      INTO purchase_id, addon_id, price_paid, purchased_at;

    RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

-- Seed starter add-ons
INSERT INTO addons (id, brand_scope, display_name, description, price_cents, currency)
VALUES
    ('research_pack', ARRAY['studentlyai','studentsai_uk','studentsai_us'], 'Research Pack', 'Deep research, citations, and academic tone assistance.', 1900, 'GBP'),
    ('study_skills_pack', ARRAY['studentlyai','studentsai_uk'], 'Study Skills Pack', 'Timetable automation, revision prompts, and flashcards.', 1500, 'GBP'),
    ('career_pack', ARRAY['studentsai_us'], 'Career Pack', 'CV builder, interview prep, and job tracking.', 1500, 'USD'),
    ('classroom_pack', ARRAY['studentlyai'], 'Classroom Pack', 'Group collaboration tools and peer feedback workflows.', 1200, 'GBP')
codex/create-working-plan-from-agents.md-0qnebh


-- Seed starter add-ons
INSERT INTO addons (id, brand_scope, display_name, description)
VALUES
    ('research_pack', ARRAY['studentlyai','studentsai_uk','studentsai_us'], 'Research Pack', 'Deep research, citations, and academic tone assistance.'),
    ('study_skills_pack', ARRAY['studentlyai','studentsai_uk'], 'Study Skills Pack', 'Timetable automation, revision prompts, and flashcards.'),
    ('career_pack', ARRAY['studentsai_us'], 'Career Pack', 'CV builder, interview prep, and job tracking.'),
    ('classroom_pack', ARRAY['studentlyai'], 'Classroom Pack', 'Group collaboration tools and peer feedback workflows.')
main
main
ON CONFLICT (id) DO NOTHING;

INSERT INTO addon_versions (addon_id, version, download_url, release_notes)
VALUES
    ('research_pack', '1.0.0', 'https://downloads.mccaigs.ai/research_pack/v1.zip', 'Initial launch version.'),
    ('study_skills_pack', '1.0.0', 'https://downloads.mccaigs.ai/study_skills_pack/v1.zip', 'Initial launch version.'),
    ('career_pack', '1.0.0', 'https://downloads.mccaigs.ai/career_pack/v1.zip', 'Initial launch version.'),
    ('classroom_pack', '1.0.0', 'https://downloads.mccaigs.ai/classroom_pack/v1.zip', 'Initial launch version.')
ON CONFLICT DO NOTHING;
