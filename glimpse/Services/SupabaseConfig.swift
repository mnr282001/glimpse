//
//  SupabaseConfig.swift
//  glimpse
//
//  Created by AI Assistant on 01/08/26.
//

import Foundation

/// Centralized configuration for Supabase credentials
/// Replace the placeholder values with your actual project URL and anon key.
struct SupabaseConfig {
    /// Example: "https://your-project-id.supabase.co"
    static let url: String = "https://snrpggjvujrepxncwfkz.supabase.co"

    /// Example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    static let publishableKey: String = "sb_publishable_rm4CmL82Jiem5MXzD4F2nA_gX32YA71"
}

#if DEBUG
// Help catch accidental check-ins of placeholder values at runtime in debug builds
extension SupabaseConfig {
    static func validate() {
        assert(!url.contains("<#") && !publishableKey.contains("<#"), "SupabaseConfig has placeholder values. Set your Supabase URL and anon key.")
    }
}
#endif
