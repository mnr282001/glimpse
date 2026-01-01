import SwiftUI

struct PremiumUpgradeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storageManager = GoalStorageManager.shared

    @State private var isPurchasing = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage: String?
    @State private var animateHero = false


    private var primaryText: Color {
        colorScheme == .dark ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)
    }

    private var accentGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
            ? [Color(red: 0.38, green: 0.62, blue: 1.0),
               Color(red: 0.25, green: 0.45, blue: 0.9)]
            : [Color(red: 0.88, green: 0.65, blue: 0.55),
               Color(red: 0.78, green: 0.55, blue: 0.45)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 40) {
                        hero
                        titleSection
                        features
                        pricing
                        upgradeButton
                        footnote
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Welcome to Premium", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text("You can now create up to 10 goals.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "Something went wrong.")
        }
    }

    // MARK: - Sections

    private var background: some View {
        (colorScheme == .dark
         ? Color(red: 0.10, green: 0.11, blue: 0.14)
         : Color(red: 0.98, green: 0.96, blue: 0.94))
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(primaryText)
                    .frame(width: 32, height: 32)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    private var hero: some View {
        ZStack {
            Circle()
                .fill(accentGradient)
                .frame(width: 88, height: 88)
                .scaleEffect(animateHero ? 1.0 : 0.94)
                .opacity(animateHero ? 1 : 0.85)

            Image(systemName: "crown.fill")
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.85)
            ) {
                animateHero = true
            }
        }
    }

    private var titleSection: some View {
        VStack(spacing: 14) {
            Text("Upgrade to Premium")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(primaryText)
                .multilineTextAlignment(.center)

            Text("More clarity. More progress.")
                .font(.system(size: 17))
                .foregroundColor(primaryText.opacity(0.55))
                .multilineTextAlignment(.center)
        }
    }

    private var features: some View {
        VStack(spacing: 22) {
            PremiumFeatureRow(
                icon: "target",
                title: "Up to 10 goals",
                description: "More room for what matters most."
            )

            PremiumFeatureRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Advanced insights",
                description: "Understand your progress at a deeper level."
            )

            PremiumFeatureRow(
                icon: "bell.badge.fill",
                title: "Custom reminders",
                description: "Stay on track with flexible notifications."
            )

            PremiumFeatureRow(
                icon: "paintbrush.fill",
                title: "Personalized themes",
                description: "Make Glimpse feel like yours."
            )

            PremiumFeatureRow(
                icon: "icloud.fill",
                title: "Priority support",
                description: "Help when you need it."
            )
        }
    }

    private var pricing: some View {
        VStack(spacing: 6) {
            Text("$4.99")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(primaryText)

            Text("per month")
                .font(.system(size: 15))
                .foregroundColor(primaryText.opacity(0.5))
        }
        .padding(.top, 8)
    }

    private var upgradeButton: some View {
        Button(action: upgradeToPremium) {
            Group {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Go Premium")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(
                color: Color.black.opacity(colorScheme == .dark ? 0.4 : 0.15),
                radius: 12,
                y: 6
            )
        }
        .disabled(isPurchasing)
        .opacity(isPurchasing ? 0.7 : 1.0)
        .padding(.top, 12)
    }

    private var footnote: some View {
        Text("Cancel anytime.")
            .font(.system(size: 13))
            .foregroundColor(primaryText.opacity(0.45))
    }

    // MARK: - Upgrade Logic

    private func upgradeToPremium() {
        isPurchasing = true
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        Task {
            do {
                let userId = try await SupabaseManager.shared.client.auth.session.user.id

                try await SupabaseManager.shared.client
                    .database
                    .from("profiles")
                    .update(["tier": "premium"])
                    .eq("id", value: userId.uuidString)
                    .execute()

                await storageManager.loadUserTier()

                await MainActor.run {
                    isPurchasing = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        showSuccess = true
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}
