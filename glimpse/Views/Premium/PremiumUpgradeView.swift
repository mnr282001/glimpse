import SwiftUI

struct PremiumUpgradeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var storageManager = GoalStorageManager.shared

    @State private var isPurchasing = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background color
            (colorScheme == .dark ?
             Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            .frame(width: 32, height: 32)
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 32) {
                        // Premium badge
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            colorScheme == .dark ?
                                                Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                Color(red: 0.83, green: 0.58, blue: 0.49),
                                            colorScheme == .dark ?
                                                Color(red: 0.45, green: 0.65, blue: 1.0) :
                                                Color(red: 0.73, green: 0.48, blue: 0.39)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Image(systemName: "crown.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 16)

                        // Title
                        VStack(spacing: 12) {
                            Text("Upgrade to Premium")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .multilineTextAlignment(.center)

                            Text("Unlock your full potential")
                                .font(.system(size: 17))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 32)

                        // Features list
                        VStack(spacing: 20) {
                            FeatureRow(
                                icon: "target",
                                title: "10 Goals",
                                description: "Track up to 10 goals instead of 3",
                                colorScheme: colorScheme
                            )

                            FeatureRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Advanced Analytics",
                                description: "Deep insights into your progress",
                                colorScheme: colorScheme
                            )

                            FeatureRow(
                                icon: "bell.badge.fill",
                                title: "Custom Reminders",
                                description: "Set multiple reminders per goal",
                                colorScheme: colorScheme
                            )

                            FeatureRow(
                                icon: "paintbrush.fill",
                                title: "Custom Themes",
                                description: "Personalize your experience",
                                colorScheme: colorScheme
                            )

                            FeatureRow(
                                icon: "icloud.fill",
                                title: "Priority Support",
                                description: "Get help when you need it",
                                colorScheme: colorScheme
                            )
                        }
                        .padding(.horizontal, 24)

                        // Pricing
                        VStack(spacing: 16) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("$4.99")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                Text("/month")
                                    .font(.system(size: 17))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                            }

                            Text("Cancel anytime")
                                .font(.system(size: 15))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.5))
                        }
                        .padding(.top, 8)

                        // Upgrade button
                        Button(action: {
                            upgradeToPremium()
                        }) {
                            Group {
                                if isPurchasing {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    HStack(spacing: 8) {
                                        Image(systemName: "crown.fill")
                                            .font(.system(size: 20))

                                        Text("Upgrade to Premium")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [
                                        colorScheme == .dark ?
                                            Color(red: 0.35, green: 0.58, blue: 1.0) :
                                            Color(red: 0.83, green: 0.58, blue: 0.49),
                                        colorScheme == .dark ?
                                            Color(red: 0.45, green: 0.65, blue: 1.0) :
                                            Color(red: 0.73, green: 0.48, blue: 0.39)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                        }
                        .disabled(isPurchasing)
                        .opacity(isPurchasing ? 0.7 : 1.0)
                        .padding(.horizontal, 24)

                        // Terms
                        Text("Terms and conditions apply")
                            .font(.system(size: 13))
                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.4))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Welcome to Premium! You can now add up to 10 goals.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }

    private func upgradeToPremium() {
        isPurchasing = true

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        Task {
            do {
                // Get current user
                let userId = try await SupabaseManager.shared.client.auth.session.user.id

                // Update tier in Supabase
                try await SupabaseManager.shared.client
                    .database
                    .from("profiles")
                    .update(["tier": "premium"])
                    .eq("id", value: userId.uuidString)
                    .execute()

                // Reload tier
                await storageManager.loadUserTier()

                await MainActor.run {
                    isPurchasing = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = "Failed to upgrade: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

// Feature row component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let colorScheme: ColorScheme

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(colorScheme == .dark ?
                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                            Color.white.opacity(0.5))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(colorScheme == .dark ?
                                     Color(red: 0.35, green: 0.58, blue: 1.0) :
                                        Color(red: 0.83, green: 0.58, blue: 0.49))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview("Light Mode") {
    PremiumUpgradeView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    PremiumUpgradeView()
        .preferredColorScheme(.dark)
}
