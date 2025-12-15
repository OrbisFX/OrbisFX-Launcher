-- ============================================================
-- OrbisFX Launcher - Preset Rating System Database Schema
-- ============================================================
-- Run this SQL in your Supabase SQL Editor to set up the tables
-- Project: https://xvnfgmgfthniadpwrxjw.supabase.co
-- ============================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- Table: preset_ratings
-- Stores individual user ratings for presets
-- ============================================================
CREATE TABLE IF NOT EXISTS preset_ratings (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  preset_id VARCHAR(255) NOT NULL,           -- Matches preset.id from GitHub
  user_id VARCHAR(255) NOT NULL,             -- Device-based anonymous user ID
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),  -- 1-5 stars
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Ensure one rating per user per preset
  UNIQUE(preset_id, user_id)
);

-- Index for fast queries by preset
CREATE INDEX IF NOT EXISTS idx_ratings_preset_id ON preset_ratings(preset_id);

-- Index for fast queries by user
CREATE INDEX IF NOT EXISTS idx_ratings_user_id ON preset_ratings(user_id);

-- ============================================================
-- Table: preset_rating_summaries
-- Cached aggregated ratings (auto-updated via trigger)
-- ============================================================
CREATE TABLE IF NOT EXISTS preset_rating_summaries (
  preset_id VARCHAR(255) PRIMARY KEY,
  average_rating DECIMAL(3,2) NOT NULL DEFAULT 0,
  total_ratings INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================
-- Function: update_rating_summary
-- Automatically updates summary when ratings change
-- ============================================================
CREATE OR REPLACE FUNCTION update_rating_summary()
RETURNS TRIGGER AS $$
DECLARE
  target_preset_id VARCHAR(255);
  new_avg DECIMAL(3,2);
  new_count INTEGER;
BEGIN
  -- Determine which preset_id to update
  IF TG_OP = 'DELETE' THEN
    target_preset_id := OLD.preset_id;
  ELSE
    target_preset_id := NEW.preset_id;
  END IF;
  
  -- Calculate new averages
  SELECT 
    COALESCE(AVG(rating)::DECIMAL(3,2), 0),
    COUNT(*)::INTEGER
  INTO new_avg, new_count
  FROM preset_ratings
  WHERE preset_id = target_preset_id;
  
  -- Upsert the summary
  INSERT INTO preset_rating_summaries (preset_id, average_rating, total_ratings, updated_at)
  VALUES (target_preset_id, new_avg, new_count, NOW())
  ON CONFLICT (preset_id) 
  DO UPDATE SET 
    average_rating = EXCLUDED.average_rating,
    total_ratings = EXCLUDED.total_ratings,
    updated_at = NOW();
  
  -- Clean up if no ratings left
  IF new_count = 0 THEN
    DELETE FROM preset_rating_summaries WHERE preset_id = target_preset_id;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Trigger: rating_changed
-- Fires the summary update function on rating changes
-- ============================================================
DROP TRIGGER IF EXISTS rating_changed ON preset_ratings;
CREATE TRIGGER rating_changed
AFTER INSERT OR UPDATE OR DELETE ON preset_ratings
FOR EACH ROW EXECUTE FUNCTION update_rating_summary();

-- ============================================================
-- Row Level Security (RLS) Policies
-- ============================================================

-- Enable RLS on tables
ALTER TABLE preset_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE preset_rating_summaries ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can read rating summaries (public data)
DROP POLICY IF EXISTS "Public read access for summaries" ON preset_rating_summaries;
CREATE POLICY "Public read access for summaries" ON preset_rating_summaries
  FOR SELECT USING (true);

-- Policy: Anyone can read all ratings (for transparency)
DROP POLICY IF EXISTS "Public read access for ratings" ON preset_ratings;
CREATE POLICY "Public read access for ratings" ON preset_ratings
  FOR SELECT USING (true);

-- Policy: Anyone can insert ratings (using device ID as user_id)
DROP POLICY IF EXISTS "Anyone can rate" ON preset_ratings;
CREATE POLICY "Anyone can rate" ON preset_ratings
  FOR INSERT WITH CHECK (true);

-- Policy: Users can update their own ratings
DROP POLICY IF EXISTS "Users can update own ratings" ON preset_ratings;
CREATE POLICY "Users can update own ratings" ON preset_ratings
  FOR UPDATE USING (true);

-- Policy: Users can delete their own ratings (if needed)
DROP POLICY IF EXISTS "Users can delete own ratings" ON preset_ratings;
CREATE POLICY "Users can delete own ratings" ON preset_ratings
  FOR DELETE USING (true);

-- ============================================================
-- Grant permissions for anonymous access
-- ============================================================
GRANT SELECT ON preset_rating_summaries TO anon;
GRANT SELECT, INSERT, UPDATE ON preset_ratings TO anon;
GRANT SELECT ON preset_rating_summaries TO authenticated;
GRANT SELECT, INSERT, UPDATE ON preset_ratings TO authenticated;

-- ============================================================
-- Test data (optional - uncomment to add sample ratings)
-- ============================================================
-- INSERT INTO preset_ratings (preset_id, user_id, rating) VALUES
--   ('cinematic-nights', 'test-user-1', 5),
--   ('cinematic-nights', 'test-user-2', 4),
--   ('vibrant-colors', 'test-user-1', 4);

-- ============================================================
-- Verification queries (run after setup to verify)
-- ============================================================
-- SELECT * FROM preset_ratings;
-- SELECT * FROM preset_rating_summaries;

