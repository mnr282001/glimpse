-- =============================================================================
-- GLIMPSE APP - REFLECTIONS DATABASE SCHEMA
-- =============================================================================
-- This script creates the reflections table and related database objects
-- Run this in Supabase SQL Editor
-- =============================================================================

-- Reflections table
CREATE TABLE IF NOT EXISTS public.reflections (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  goal_id UUID REFERENCES public.goals ON DELETE CASCADE NOT NULL,
  reflection_date DATE NOT NULL,
  progress_text TEXT NOT NULL,
  setback_text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,

  -- Ensure one reflection per goal per day
  UNIQUE(user_id, goal_id, reflection_date)
);

-- =============================================================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================================================

-- Enable Row Level Security
ALTER TABLE public.reflections ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own reflections
CREATE POLICY "Users can view own reflections"
  ON public.reflections FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own reflections
CREATE POLICY "Users can insert own reflections"
  ON public.reflections FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own reflections
CREATE POLICY "Users can update own reflections"
  ON public.reflections FOR UPDATE
  USING (auth.uid() = user_id);

-- Policy: Users can delete their own reflections
CREATE POLICY "Users can delete own reflections"
  ON public.reflections FOR DELETE
  USING (auth.uid() = user_id);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Index for faster queries by user and date
CREATE INDEX IF NOT EXISTS reflections_user_date_idx
  ON public.reflections(user_id, reflection_date DESC);

-- Index for faster queries by goal and date
CREATE INDEX IF NOT EXISTS reflections_goal_date_idx
  ON public.reflections(goal_id, reflection_date DESC);

-- =============================================================================
-- TRIGGERS
-- =============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at on row update
DROP TRIGGER IF EXISTS update_reflections_updated_at ON public.reflections;
CREATE TRIGGER update_reflections_updated_at
  BEFORE UPDATE ON public.reflections
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- VERIFICATION QUERIES (Run these to verify the setup)
-- =============================================================================

-- Check that the table was created successfully
-- SELECT table_name, column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'reflections'
-- ORDER BY ordinal_position;

-- Check RLS policies
-- SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
-- FROM pg_policies
-- WHERE tablename = 'reflections';

-- Check indexes
-- SELECT indexname, indexdef
-- FROM pg_indexes
-- WHERE tablename = 'reflections';

-- =============================================================================
-- SAMPLE QUERIES (For testing - DO NOT RUN IN PRODUCTION)
-- =============================================================================

-- Insert a sample reflection (replace UUIDs with actual values)
-- INSERT INTO public.reflections (user_id, goal_id, reflection_date, progress_text, setback_text)
-- VALUES (
--   'your-user-id-here',
--   'your-goal-id-here',
--   CURRENT_DATE,
--   'I completed my morning workout and felt great!',
--   'I skipped my evening meditation due to a late meeting.'
-- );

-- Query today's reflections for a user
-- SELECT * FROM public.reflections
-- WHERE user_id = 'your-user-id-here'
-- AND reflection_date = CURRENT_DATE;

-- Query reflection history for a specific goal
-- SELECT reflection_date, progress_text, setback_text, created_at
-- FROM public.reflections
-- WHERE goal_id = 'your-goal-id-here'
-- ORDER BY reflection_date DESC
-- LIMIT 30;

-- =============================================================================
-- NOTES
-- =============================================================================
-- 1. This table has a UNIQUE constraint on (user_id, goal_id, reflection_date)
--    which ensures a user can only have ONE reflection per goal per day.
--
-- 2. The app uses UPSERT operations with ON CONFLICT to handle updates to
--    existing reflections for the same day.
--
-- 3. RLS policies ensure users can only access their own reflections.
--
-- 4. Indexes are optimized for common query patterns:
--    - Loading all reflections for a user on a specific date (today's reflections)
--    - Loading reflection history for a specific goal (analytics/history view)
--
-- 5. The updated_at timestamp is automatically updated via trigger whenever
--    a reflection is modified.
-- =============================================================================
