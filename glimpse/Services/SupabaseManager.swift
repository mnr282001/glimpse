//
//  SupabaseManager.swift
//  glimpse
//
//  Created by Claude Code on 12/31/25.
//

import Foundation
import Supabase

/// Singleton manager for Supabase client and authentication
class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        guard let supabaseURL = URL(string: SupabaseConfig.url) else {
            fatalError("Invalid Supabase URL")
        }

        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: SupabaseConfig.publishableKey
        )
    }

    // MARK: - Authentication Helpers

    /// Sign out the current user
    func signOut() async throws {
        try await client.auth.signOut()
        // Clear local onboarding flag
        UserDefaults.standard.set(false, forKey: "glimpse.onboarding.complete")
    }

    /// Get the current user's ID
    func getCurrentUserId() async throws -> UUID {
        let session = try await client.auth.session
        return session.user.id
    }

    /// Check if user has an active session
    func hasActiveSession() async -> Bool {
        do {
            _ = try await client.auth.session
            return true
        } catch {
            return false
        }
    }
}
