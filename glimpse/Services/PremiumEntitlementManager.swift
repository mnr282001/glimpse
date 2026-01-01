//
//  PremiumEntitlementManager.swift
//  glimpse
//
//  Created by Nayab Rehmat on 12/31/25.
//
import SwiftUI

@MainActor
final class PremiumEntitlementManager: ObservableObject {
    static let shared = PremiumEntitlementManager()

    @Published private(set) var tier: UserTier = .free
    @Published private(set) var isLoading = false

    private init() {}

    func loadTier() async {
        do {
            tier = try await SupabaseManager.shared.fetchUserTier()
        } catch {
            tier = .free
        }
    }

    func upgradeToPremium() async throws {
        isLoading = true
        defer { isLoading = false }

        try await SupabaseManager.shared.setTier(.premium)
        tier = .premium
    }

    func downgradeToFree() async throws {
        isLoading = true
        defer { isLoading = false }

        try await SupabaseManager.shared.setTier(.free)
        tier = .free
    }
}
