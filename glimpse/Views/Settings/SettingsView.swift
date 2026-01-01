import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var storageManager = GoalStorageManager.shared
    @State private var showLogoutConfirmation = false
    @State private var isLoggingOut = false
    @State private var showWelcomeScreen = false

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
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    }

                    Spacer()

                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                    Spacer()

                    // Invisible placeholder to balance layout
                    Image(systemName: "arrow.left")
                        .font(.system(size: 24))
                        .opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 32)

                ScrollView {
                    VStack(spacing: 24) {
                        // Account Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Account")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                NavigationLink(destination: AccountSettingsView()) {
                                    SettingsRowView(
                                        icon: "person.circle.fill",
                                        title: "Profile",
                                        showChevron: true
                                    )
                                }

                                Divider()
                                    .background((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1))
                                    .padding(.leading, 68)

                                NavigationLink(destination: EmailPasswordSettingsView()) {
                                    SettingsRowView(
                                        icon: "envelope.fill",
                                        title: "Email & Password",
                                        showChevron: true
                                    )
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                        }

                        // Notifications Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notifications")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                .textCase(.uppercase)
                                .padding(.horizontal, 24)

                            VStack(spacing: 0) {
                                NavigationLink(destination: NotificationSettingsView()) {
                                    SettingsRowView(
                                        icon: "bell.fill",
                                        title: "Notification Settings",
                                        showChevron: true
                                    )
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal, 24)
                        }

                        // Logout Button
                        Button(action: {
                            showLogoutConfirmation = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 20))
                                    .foregroundColor(.red)
                                    .frame(width: 44, height: 44)

                                Text("Log Out")
                                    .font(.system(size: 17))
                                    .foregroundColor(.red)

                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Log Out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                logout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .fullScreenCover(isPresented: $showWelcomeScreen) {
            ContentView()
        }
    }

    // MARK: - Logout Function

    private func logout() {
        isLoggingOut = true

        Task {
            do {
                try await SupabaseManager.shared.signOut()

                await MainActor.run {
                    // Clear local data
                    storageManager.goals = []
                    storageManager.isLoadingGoals = false
                    UserDefaults.standard.set(false, forKey: "glimpse.onboarding.complete")

                    isLoggingOut = false

                    // Show welcome screen (ContentView)
                    showWelcomeScreen = true
                }
            } catch {
                await MainActor.run {
                    isLoggingOut = false
                    print("Error logging out: \(error)")
                }
            }
        }
    }
}

// MARK: - Settings Row Component

struct SettingsRowView: View {
    @Environment(\.colorScheme) var colorScheme
    let icon: String
    let title: String
    let showChevron: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(colorScheme == .dark ?
                                 Color(red: 0.35, green: 0.58, blue: 1.0) :
                                    Color(red: 0.83, green: 0.58, blue: 0.49))
                .frame(width: 44, height: 44)

            Text(title)
                .font(.system(size: 17))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.4))
            }
        }
        .padding(.horizontal, 24)
        .frame(height: 56)
        .contentShape(Rectangle())
    }
}

#Preview("Light Mode") {
    NavigationStack {
        SettingsView()
            .preferredColorScheme(.light)
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
