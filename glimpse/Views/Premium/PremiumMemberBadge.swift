//
//  PremiumMemberBadge.swift
//  glimpse
//
//  Created by Nayab Rehmat on 12/31/25.
//
import SwiftUI

struct PremiumMemberBadge: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: colorScheme == .dark
                        ? [.white, .white.opacity(0.8)]
                        : [.yellow, .orange],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text("Premium Member")
                .font(.system(size: 13, weight: .semibold))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}
