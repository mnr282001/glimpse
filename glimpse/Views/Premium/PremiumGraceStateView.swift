//
//  PremiumGraceStateView.swift
//  glimpse
//
//  Created by Nayab Rehmat on 12/31/25.
//


import SwiftUI

struct PremiumGraceStateView: View {
    @Environment(\.colorScheme) private var colorScheme
    let graceEndDate: Date

    private var primaryText: Color {
        colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 36))
                .foregroundColor(.orange)

            VStack(spacing: 8) {
                Text("Premium access ending soon")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(primaryText)

                Text("Your subscription couldn’t be renewed. You’ll keep Premium features until \(formattedDate).")
                    .font(.system(size: 15))
                    .foregroundColor(primaryText.opacity(0.6))
                    .multilineTextAlignment(.center)
            }

            Button("Manage Subscription") {
                // Open App Store subscription page
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(28)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: graceEndDate)
    }
}
