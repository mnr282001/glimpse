//
//  PremiumFeatureRow.swift
//  glimpse
//
//  Created by Nayab Rehmat on 12/31/25.
//
import SwiftUI

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    @Environment(\.colorScheme) private var colorScheme

    private var primaryText: Color {
        colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)
    }

    private var accentColor: Color {
        colorScheme == .dark
        ? Color(red: 0.45, green: 0.65, blue: 1.0)
        : Color(red: 0.78, green: 0.55, blue: 0.45)
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(primaryText)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(primaryText.opacity(0.55))
            }

            Spacer()
        }
    }
}
