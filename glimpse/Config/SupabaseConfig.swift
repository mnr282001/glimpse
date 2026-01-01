//
//  SupabaseConfig.swift
//  glimpse
//
//  Created by Claude Code on 12/31/25.
//

import Foundation
/// Configuration for Supabase credentials
/// IMPORTANT: In production, move these to environment variables or a secure config file
/// Never commit actual credentials to version control
struct SupabaseConfig {
    /// Supabase Project URL
    static let url = "https://snrpggjvujrepxncwfkz.supabase.co"

    /// Supabase Anon/Public Key
    /// This key is safe to use in client-side code when Row Level Security (RLS) is enabled
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNucnBnZ2p2dWpyZXB4bmN3Zmt6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcyMDQ0MTYsImV4cCI6MjA4Mjc4MDQxNn0.8dgcqllc3Mc_Yb29TK9odRYASpMp89COSBIRn2Jcie8"
}
