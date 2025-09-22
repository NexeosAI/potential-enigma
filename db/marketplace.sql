-- Marketplace schema scaffold.
CREATE TABLE IF NOT EXISTS addons (
    id TEXT PRIMARY KEY,
    brand_scope TEXT[] DEFAULT ARRAY[]::TEXT[],
    display_name TEXT NOT NULL,
    description TEXT NOT NULL,
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
RETURNS SETOF addons AS $$
BEGIN
    RETURN QUERY
    SELECT *
      FROM addons
     WHERE brand_scope IS NULL
        OR array_length(brand_scope, 1) = 0
        OR p_brand_id = ANY(brand_scope);
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

-- Seed starter add-ons
INSERT INTO addons (id, brand_scope, display_name, description)
VALUES
    ('research_pack', ARRAY['studentlyai','studentsai_uk','studentsai_us'], 'Research Pack', 'Deep research, citations, and academic tone assistance.'),
    ('study_skills_pack', ARRAY['studentlyai','studentsai_uk'], 'Study Skills Pack', 'Timetable automation, revision prompts, and flashcards.'),
    ('career_pack', ARRAY['studentsai_us'], 'Career Pack', 'CV builder, interview prep, and job tracking.'),
    ('classroom_pack', ARRAY['studentlyai'], 'Classroom Pack', 'Group collaboration tools and peer feedback workflows.')
ON CONFLICT (id) DO NOTHING;

INSERT INTO addon_versions (addon_id, version, download_url, release_notes)
VALUES
    ('research_pack', '1.0.0', 'https://downloads.mccaigs.ai/research_pack/v1.zip', 'Initial launch version.'),
    ('study_skills_pack', '1.0.0', 'https://downloads.mccaigs.ai/study_skills_pack/v1.zip', 'Initial launch version.'),
    ('career_pack', '1.0.0', 'https://downloads.mccaigs.ai/career_pack/v1.zip', 'Initial launch version.'),
    ('classroom_pack', '1.0.0', 'https://downloads.mccaigs.ai/classroom_pack/v1.zip', 'Initial launch version.')
ON CONFLICT DO NOTHING;
