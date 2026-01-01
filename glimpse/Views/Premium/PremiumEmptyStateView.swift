//
//  PremiumEmptyStateView.swift
//  glimpse
//
//  Created by Nayab Rehmat on 12/31/25.
//


import SwiftUI

struct PremiumEmptyStateView: View {
    @Environment(\.colorScheme) private var colorScheme

    private var primaryText: Color {
        colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)
    }

    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 88, height: 88)

                Image(systemName: "crown.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            VStack(spacing: 10) {
                Text("You’re all set.")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(primaryText)

                Text("As a Premium member, you can create up to 10 goals and explore deeper insights over time.")
                    .font(.system(size: 16))
                    .foregroundColor(primaryText.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            Button {
                // Open AddGoalView
            } label: {
                Text("Create your first goal")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
    }
}
