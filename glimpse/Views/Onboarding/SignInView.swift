//
//  SignInView.swift
//  glimpse
//
//  Created by Claude Code on 12/31/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @StateObject private var storageManager = GoalStorageManager.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var navigateToPersonalization = false
    @State private var navigateToDashboard = false

    var body: some View {
        ZStack {
            // Background color
            (colorScheme == .dark ?
             Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top spacing
                HStack {
                    // Back button
                    Button(action: {
                        dismiss()
                        print("Back tapped")
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 24))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    }

                    Spacer()

                    // App name with logo (centered)
                    HStack(spacing: 12) {
                        // Logo circle
                        ZStack {
                            Circle()
                                .fill(colorScheme == .dark ?
                                      Color(red: 0.35, green: 0.58, blue: 1.0) :
                                        Color(red: 0.83, green: 0.58, blue: 0.49))
                                .frame(width: 44, height: 44)

                            Image(systemName: "book.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                        }

                        Text("Glimpse")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    }

                    Spacer()

                    // Invisible placeholder to balance the layout
                    Image(systemName: "arrow.left")
                        .font(.system(size: 24))
                        .opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                // Progress dots
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(colorScheme == .dark ? Color(red: 0.35, green: 0.58, blue: 1.0) : Color(red: 0.83, green: 0.58, blue: 0.49))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .padding(.bottom, 40)

                // Text content
                VStack(spacing: 16) {
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("Sign in to continue your journey.")
                        .font(.system(size: 17))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)

                // Email/Password fields
                VStack(spacing: 16) {
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 15))
                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))

                        TextField("your@email.com", text: $email)
                            .font(.system(size: 17))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                                    )
                            )
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 15))
                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))

                        SecureField("Enter your password", text: $password)
                            .font(.system(size: 17))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white.opacity(0.5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                // Sign In button
                Button(action: {
                    signIn()
                }) {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(colorScheme == .dark ?
                                  Color(red: 0.35, green: 0.58, blue: 1.0) :
                                    Color(red: 0.83, green: 0.58, blue: 0.49))
                    )
                }
                .disabled(email.isEmpty || password.isEmpty || isLoading)
                .opacity((email.isEmpty || password.isEmpty || isLoading) ? 0.5 : 1.0)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

                Spacer()

                // Terms and Privacy
                VStack(spacing: 8) {
                    Text("By continuing, you agree to our")
                        .font(.system(size: 13))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.5))

                    HStack(spacing: 4) {
                        NavigationLink(destination: TermsOfServiceView()) {
                            Text("Terms of Service")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(colorScheme == .dark ?
                                                 Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                    Color(red: 0.83, green: 0.58, blue: 0.49))
                        }

                        Text("and")
                            .font(.system(size: 13))
                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.5))

                        NavigationLink(destination: PrivacyPolicyView()) {
                            Text("Privacy Policy")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(colorScheme == .dark ?
                                                 Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                    Color(red: 0.83, green: 0.58, blue: 0.49))
                        }
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .navigationDestination(isPresented: $navigateToPersonalization) {
            PersonalizationView()
        }
        .navigationDestination(isPresented: $navigateToDashboard) {
            DashboardView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .navigationBarHidden(true)
    }

    // MARK: - Auth Functions

    func signIn() {
        guard !email.isEmpty, !password.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Only sign in - do NOT sign up
                _ = try await SupabaseManager.shared.client.auth.signIn(
                    email: email,
                    password: password
                )

                // Check Supabase to see if user has completed onboarding
                let hasCompletedOnboarding = await checkOnboardingStatus()

                await MainActor.run {
                    isLoading = false

                    if hasCompletedOnboarding {
                        // Existing user with complete onboarding → Go to Dashboard
                        storageManager.loadGoals() // Load their goals
                        storageManager.completeOnboarding() // Sync local flag
                        navigateToDashboard = true
                    } else {
                        // User signed up but didn't finish onboarding → Continue onboarding
                        navigateToPersonalization = true
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Invalid email or password. Please try again."
                    showError = true
                }
            }
        }
    }

    // MARK: - Onboarding Check

    /// Check if user has completed onboarding by verifying Supabase data
    private func checkOnboardingStatus() async -> Bool {
        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            // Check if user has a profile with first_name
            struct ProfileResponse: Decodable {
                let first_name: String?
            }

            let profileResponse: [ProfileResponse] = try await SupabaseManager.shared.client
                .database
                .from("profiles")
                .select("first_name")
                .eq("id", value: userId.uuidString)
                .execute()
                .value

            guard let profile = profileResponse.first,
                  let firstName = profile.first_name,
                  !firstName.isEmpty else {
                return false
            }

            // Check if user has goals
            struct GoalCountResponse: Decodable {
                let id: String
            }

            let goalsResponse: [GoalCountResponse] = try await SupabaseManager.shared.client
                .database
                .from("goals")
                .select("id")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value

            // User has completed onboarding if they have a profile with first_name AND at least one goal
            return !goalsResponse.isEmpty

        } catch {
            print("Error checking onboarding status: \(error)")
            return false
        }
    }
}

#Preview("Light Mode") {
    SignInView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    SignInView()
        .preferredColorScheme(.dark)
}
