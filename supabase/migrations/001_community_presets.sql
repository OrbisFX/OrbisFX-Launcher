-- OrbisFX Community Presets Schema
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- User profiles (linked to Discord OAuth)
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  discord_id VARCHAR(255) UNIQUE NOT NULL,
  discord_username VARCHAR(255) NOT NULL,
  discord_discriminator VARCHAR(10),
  discord_avatar_hash VARCHAR(255),
  
  -- Reputation & status
  reputation_score INTEGER DEFAULT 0,
  is_trusted BOOLEAN DEFAULT FALSE,
  is_banned BOOLEAN DEFAULT FALSE,
  is_moderator BOOLEAN DEFAULT FALSE,
  
  -- Stats
  total_submissions INTEGER DEFAULT 0,
  approved_submissions INTEGER DEFAULT 0,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Community preset submissions
CREATE TABLE community_presets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug VARCHAR(255) UNIQUE NOT NULL,
  author_id UUID REFERENCES user_profiles(id) NOT NULL,
  
  -- Basic metadata
  name VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  long_description TEXT,
  category VARCHAR(100) NOT NULL,
  version VARCHAR(50) DEFAULT '1.0.0',
  
  -- Attribution
  based_on_preset_id VARCHAR(255),
  based_on_preset_name VARCHAR(255),
  
  -- Files (Supabase Storage paths)
  preset_file_path TEXT NOT NULL,
  preset_file_hash VARCHAR(64),
  thumbnail_path TEXT,
  
  -- Status workflow
  status VARCHAR(50) DEFAULT 'pending',
  rejection_reason TEXT,
  report_count INTEGER DEFAULT 0,
  
  -- Stats
  download_count INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  published_at TIMESTAMPTZ,
  
  -- Search optimization
  search_vector TSVECTOR
);

-- Preset images (before/after comparisons, showcase)
CREATE TABLE community_preset_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  preset_id UUID REFERENCES community_presets(id) ON DELETE CASCADE,
  
  image_type VARCHAR(50) NOT NULL,
  pair_index INTEGER,
  
  full_image_path TEXT NOT NULL,
  thumbnail_path TEXT,
  
  original_filename VARCHAR(255),
  file_size_bytes INTEGER,
  width INTEGER,
  height INTEGER,
  
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Preset features/tags
CREATE TABLE community_preset_features (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  preset_id UUID REFERENCES community_presets(id) ON DELETE CASCADE,
  feature TEXT NOT NULL
);

-- Community reports
CREATE TABLE community_preset_reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  preset_id UUID REFERENCES community_presets(id) ON DELETE CASCADE,
  reporter_id UUID REFERENCES user_profiles(id),
  
  reason VARCHAR(100) NOT NULL,
  details TEXT,
  
  status VARCHAR(50) DEFAULT 'pending',
  reviewed_by UUID REFERENCES user_profiles(id),
  reviewed_at TIMESTAMPTZ,
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  UNIQUE(preset_id, reporter_id)
);

-- Indexes
CREATE INDEX idx_community_presets_status ON community_presets(status);
CREATE INDEX idx_community_presets_author ON community_presets(author_id);
CREATE INDEX idx_community_presets_category ON community_presets(category);
CREATE INDEX idx_community_presets_search ON community_presets USING GIN(search_vector);
CREATE INDEX idx_preset_images_preset ON community_preset_images(preset_id);
CREATE INDEX idx_user_profiles_discord ON user_profiles(discord_id);

-- Full-text search trigger
CREATE OR REPLACE FUNCTION update_preset_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector := 
    setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.category, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER preset_search_update
BEFORE INSERT OR UPDATE ON community_presets
FOR EACH ROW EXECUTE FUNCTION update_preset_search_vector();

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_profiles_updated_at
BEFORE UPDATE ON user_profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER community_presets_updated_at
BEFORE UPDATE ON community_presets
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Row Level Security policies
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_presets ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_preset_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_preset_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_preset_reports ENABLE ROW LEVEL SECURITY;

-- Public read for approved presets
CREATE POLICY "Public can view approved presets" ON community_presets
  FOR SELECT USING (status = 'approved');

-- Authors can view their own presets
CREATE POLICY "Authors can view own presets" ON community_presets
  FOR SELECT USING (author_id IN (
    SELECT id FROM user_profiles WHERE discord_id = current_setting('app.discord_id', true)
  ));

-- Public can view preset images for approved presets
CREATE POLICY "Public can view approved preset images" ON community_preset_images
  FOR SELECT USING (preset_id IN (
    SELECT id FROM community_presets WHERE status = 'approved'
  ));

-- ============== Storage Buckets ==============
-- NOTE: Storage buckets must be created via Supabase Dashboard or API
-- Go to Storage in Supabase Dashboard and create these buckets:

-- 1. community-presets (for .ini preset files)
--    - Public bucket: YES
--    - Allowed MIME types: text/plain, application/octet-stream
--    - Max file size: 1MB

-- 2. community-images (for screenshots)
--    - Public bucket: YES
--    - Allowed MIME types: image/png, image/jpeg, image/webp
--    - Max file size: 10MB

-- After creating buckets, run these policies in SQL Editor:

-- Storage policies for community-presets bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'community-presets',
  'community-presets',
  true,
  1048576, -- 1MB
  ARRAY['text/plain', 'application/octet-stream']
) ON CONFLICT (id) DO NOTHING;

-- Storage policies for community-images bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'community-images',
  'community-images',
  true,
  10485760, -- 10MB
  ARRAY['image/png', 'image/jpeg', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Allow authenticated uploads to community-presets
CREATE POLICY "Allow authenticated preset uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'community-presets');

-- Allow public read from community-presets
CREATE POLICY "Allow public preset downloads"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'community-presets');

-- Allow authenticated uploads to community-images
CREATE POLICY "Allow authenticated image uploads"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'community-images');

-- Allow public read from community-images
CREATE POLICY "Allow public image downloads"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'community-images');

-- Allow anon uploads (for users without Discord auth yet)
CREATE POLICY "Allow anon preset uploads"
ON storage.objects FOR INSERT
TO anon
WITH CHECK (bucket_id = 'community-presets');

CREATE POLICY "Allow anon image uploads"
ON storage.objects FOR INSERT
TO anon
WITH CHECK (bucket_id = 'community-images');

