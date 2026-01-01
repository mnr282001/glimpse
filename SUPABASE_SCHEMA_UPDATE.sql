-- Add profile_image_url column to profiles table
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS profile_image_url TEXT;

-- Create index for faster lookups (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_profiles_profile_image_url
ON profiles(profile_image_url);

-- Note: You also need to create a storage bucket called "profile-images"
-- This must be done through the Supabase Dashboard:
-- 1. Go to Storage in your Supabase Dashboard
-- 2. Click "New Bucket"
-- 3. Name it: profile-images
-- 4. Make it public (so profile images are accessible via URL)
-- 5. Set up RLS policies for the bucket:

-- Storage RLS Policy: Allow authenticated users to upload their own profile image
-- This is done in the Supabase Dashboard under Storage > profile-images > Policies
-- Policy Name: Users can upload their own profile image
-- Allowed operation: INSERT
-- Policy definition:
-- (bucket_id = 'profile-images' AND (storage.foldername(name))[1] = auth.uid()::text)

-- Policy Name: Users can update their own profile image
-- Allowed operation: UPDATE
-- Policy definition:
-- (bucket_id = 'profile-images' AND (storage.foldername(name))[1] = auth.uid()::text)

-- Policy Name: Users can delete their own profile image
-- Allowed operation: DELETE
-- Policy definition:
-- (bucket_id = 'profile-images' AND (storage.foldername(name))[1] = auth.uid()::text)

-- Policy Name: Anyone can view profile images
-- Allowed operation: SELECT
-- Policy definition:
-- bucket_id = 'profile-images'
