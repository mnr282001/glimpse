//
//  SupabaseManager+Tier.swift
//  glimpse
//
//  Created by Nayab Rehmat on 12/31/25.
//

import Foundation

// MARK: - User Tier Management

extension SupabaseManager {

    /// Fetch the current user's tier from Supabase
    func fetchUserTier() async throws -> UserTier {
        let userId = try await getCurrentUserId()

        let response: ProfileTierResponse = try await client
            .database
            .from("profiles")
            .select("tier")
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value

        return UserTier(rawValue: response.tier) ?? .free
    }

    /// Update the current user's tier in Supabase
    func setTier(_ tier: UserTier) async throws {
        let userId = try await getCurrentUserId()

        try await client
            .database
            .from("profiles")
            .update(["tier": tier.rawValue])
            .eq("id", value: userId.uuidString)
            .execute()
    }
}
