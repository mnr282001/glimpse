-- Add tier column to profiles table
-- This column tracks whether a user is on the free or premium plan

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS tier TEXT DEFAULT 'free';

-- Add check constraint to ensure only valid tier values
ALTER TABLE profiles
ADD CONSTRAINT valid_tier_values CHECK (tier IN ('free', 'premium'));

-- Create index for faster tier lookups (optional but recommended)
CREATE INDEX IF NOT EXISTS idx_profiles_tier
ON profiles(tier);

-- Update existing users to free tier (if they don't have a tier set)
UPDATE profiles
SET tier = 'free'
WHERE tier IS NULL;

-- Tier limits:
-- free: 3 goals max
-- premium: 10 goals max
