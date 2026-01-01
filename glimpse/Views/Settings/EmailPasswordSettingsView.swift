import SwiftUI

struct EmailPasswordSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var currentEmail: String = ""
    @State private var newEmail: String = ""
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    @State private var isLoading = false
    @State private var isSavingEmail = false
    @State private var isSavingPassword = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var successMessage: String?
    @State private var showSuccess = false

    @State private var showEmailSection = false
    @State private var showPasswordSection = false

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

                    Text("Email & Password")
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

                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(colorScheme == .dark ?
                                  Color(red: 0.35, green: 0.58, blue: 1.0) :
                                    Color(red: 0.83, green: 0.58, blue: 0.49))
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 32) {
                            // Current Email Display
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Current Email")
                                    .font(.system(size: 15))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                    .padding(.horizontal, 24)

                                Text(currentEmail)
                                    .font(.system(size: 17))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                                    .padding(.horizontal, 24)
                            }
                            .padding(.top, 16)

                            // Update Email Section
                            VStack(spacing: 16) {
                                Button(action: {
                                    showEmailSection.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .font(.system(size: 20))

                                        Text("Update Email")
                                            .font(.system(size: 17, weight: .semibold))

                                        Spacer()

                                        Image(systemName: showEmailSection ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 14))
                                    }
                                    .foregroundColor(colorScheme == .dark ?
                                                     Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                        Color(red: 0.83, green: 0.58, blue: 0.49))
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
                                .padding(.horizontal, 24)

                                if showEmailSection {
                                    VStack(spacing: 16) {
                                        // New Email
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("New Email")
                                                .font(.system(size: 15))
                                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                                .padding(.horizontal, 24)

                                            TextField("Enter new email", text: $newEmail)
                                                .font(.system(size: 17))
                                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                                .textInputAutocapitalization(.never)
                                                .keyboardType(.emailAddress)
                                                .autocorrectionDisabled()
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
                                                .padding(.horizontal, 24)
                                        }

                                        // Current Password (for verification)
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Current Password")
                                                .font(.system(size: 15))
                                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                                .padding(.horizontal, 24)

                                            SecureField("Enter current password", text: $currentPassword)
                                                .font(.system(size: 17))
                                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled()
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
                                                .padding(.horizontal, 24)
                                        }

                                        // Update Email Button
                                        Button(action: {
                                            Task {
                                                await updateEmail()
                                            }
                                        }) {
                                            Group {
                                                if isSavingEmail {
                                                    ProgressView()
                                                        .tint(.white)
                                                } else {
                                                    Text("Update Email")
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
                                        .disabled(isSavingEmail || newEmail.isEmpty || currentPassword.isEmpty || !isValidEmail(newEmail))
                                        .opacity((isSavingEmail || newEmail.isEmpty || currentPassword.isEmpty || !isValidEmail(newEmail)) ? 0.5 : 1.0)
                                        .padding(.horizontal, 24)
                                    }
                                }
                            }

                            // Update Password Section
                            VStack(spacing: 16) {
                                Button(action: {
                                    showPasswordSection.toggle()
                                }) {
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 20))

                                        Text("Update Password")
                                            .font(.system(size: 17, weight: .semibold))

                                        Spacer()

                                        Image(systemName: showPasswordSection ? "chevron.up" : "chevron.down")
                                            .font(.system(size: 14))
                                    }
                                    .foregroundColor(colorScheme == .dark ?
                                                     Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                        Color(red: 0.83, green: 0.58, blue: 0.49))
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
                                .padding(.horizontal, 24)

                                if showPasswordSection {
                                    VStack(spacing: 16) {
                                        // Current Password
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Current Password")
                                                .font(.system(size: 15))
                                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                                .padding(.horizontal, 24)

                                            SecureField("Enter current password", text: $currentPassword)
                                                .font(.system(size: 17))
                                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled()
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
                                                .padding(.horizontal, 24)
                                        }

                                        // New Password
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("New Password")
                                                .font(.system(size: 15))
                                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                                .padding(.horizontal, 24)

                                            SecureField("Enter new password", text: $newPassword)
                                                .font(.system(size: 17))
                                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled()
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
                                                .padding(.horizontal, 24)

                                            Text("Must be at least 6 characters")
                                                .font(.system(size: 13))
                                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.5))
                                                .padding(.horizontal, 24)
                                        }

                                        // Confirm Password
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Confirm New Password")
                                                .font(.system(size: 15))
                                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                                .padding(.horizontal, 24)

                                            SecureField("Confirm new password", text: $confirmPassword)
                                                .font(.system(size: 17))
                                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                                .textInputAutocapitalization(.never)
                                                .autocorrectionDisabled()
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
                                                .padding(.horizontal, 24)

                                            if !confirmPassword.isEmpty && newPassword != confirmPassword {
                                                Text("Passwords do not match")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.red)
                                                    .padding(.horizontal, 24)
                                            }
                                        }

                                        // Update Password Button
                                        Button(action: {
                                            Task {
                                                await updatePassword()
                                            }
                                        }) {
                                            Group {
                                                if isSavingPassword {
                                                    ProgressView()
                                                        .tint(.white)
                                                } else {
                                                    Text("Update Password")
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
                                        .disabled(isSavingPassword || currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword || newPassword.count < 6)
                                        .opacity((isSavingPassword || currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty || newPassword != confirmPassword || newPassword.count < 6) ? 0.5 : 1.0)
                                        .padding(.horizontal, 24)
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadCurrentEmail()
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                // Clear fields on success
                newEmail = ""
                currentPassword = ""
                newPassword = ""
                confirmPassword = ""
                showEmailSection = false
                showPasswordSection = false
            }
        } message: {
            Text(successMessage ?? "Settings updated successfully")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }

    // MARK: - Functions

    private func loadCurrentEmail() async {
        await MainActor.run { isLoading = true }

        do {
            let user = try await SupabaseManager.shared.client.auth.session.user

            await MainActor.run {
                currentEmail = user.email ?? ""
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func updateEmail() async {
        guard !newEmail.isEmpty && !currentPassword.isEmpty && isValidEmail(newEmail) else { return }

        await MainActor.run { isSavingEmail = true }

        do {
            // Re-authenticate with current password first
            try await SupabaseManager.shared.client.auth.signIn(
                email: currentEmail,
                password: currentPassword
            )

            // Update email
            try await SupabaseManager.shared.client.auth.update(
                user: .init(email: newEmail)
            )

            await MainActor.run {
                currentEmail = newEmail
                isSavingEmail = false
                successMessage = "Email updated successfully. Please check your new email to confirm the change."
                showSuccess = true
            }
        } catch {
            await MainActor.run {
                isSavingEmail = false
                errorMessage = "Failed to update email: \(error.localizedDescription)"
                showError = true
            }
        }
    }

    private func updatePassword() async {
        guard !currentPassword.isEmpty && !newPassword.isEmpty && newPassword == confirmPassword && newPassword.count >= 6 else { return }

        await MainActor.run { isSavingPassword = true }

        do {
            // Re-authenticate with current password first
            try await SupabaseManager.shared.client.auth.signIn(
                email: currentEmail,
                password: currentPassword
            )

            // Update password
            try await SupabaseManager.shared.client.auth.update(
                user: .init(password: newPassword)
            )

            await MainActor.run {
                isSavingPassword = false
                successMessage = "Password updated successfully"
                showSuccess = true
            }
        } catch {
            await MainActor.run {
                isSavingPassword = false
                errorMessage = "Failed to update password: \(error.localizedDescription)"
                showError = true
            }
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

#Preview {
    NavigationStack {
        EmailPasswordSettingsView()
    }
}
