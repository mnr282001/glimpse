import SwiftUI
import PhotosUI

struct AccountSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var firstName: String = ""
    @State private var profileImageURL: String?
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var successMessage: String?
    @State private var showSuccess = false
    @State private var showDeleteConfirmation = false
    @State private var showFinalDeleteWarning = false
    @State private var deleteConfirmationText = ""
    @State private var isDeleting = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImage: UIImage?

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

                    Text("Profile")
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
                            // Profile Picture Section
                            VStack(spacing: 16) {
                                ZStack {
                                    if let image = profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(colorScheme == .dark ?
                                                  Color(red: 0.15, green: 0.18, blue: 0.24) :
                                                    Color.white.opacity(0.5))
                                            .frame(width: 100, height: 100)

                                        Image(systemName: "person.circle.fill")
                                            .font(.system(size: 80))
                                            .foregroundColor(colorScheme == .dark ?
                                                             Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                                Color(red: 0.83, green: 0.58, blue: 0.49))
                                    }
                                }

                                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                    Text(profileImage == nil ? "Add Photo" : "Change Photo")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(colorScheme == .dark ?
                                                         Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                            Color(red: 0.83, green: 0.58, blue: 0.49))
                                }
                                .onChange(of: selectedPhoto) { _, newValue in
                                    Task {
                                        await loadPhoto(from: newValue)
                                    }
                                }
                            }
                            .padding(.top, 8)

                            // Name Section
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Name")
                                    .font(.system(size: 15))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                    .padding(.horizontal, 24)

                                TextField("Your name", text: $firstName)
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
                                    .padding(.horizontal, 24)
                            }

                            // Save Button
                            Button(action: {
                                Task {
                                    await saveProfile()
                                }
                            }) {
                                Group {
                                    if isSaving {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Save Changes")
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
                            .disabled(isSaving || firstName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .opacity((isSaving || firstName.trimmingCharacters(in: .whitespaces).isEmpty) ? 0.5 : 1.0)
                            .padding(.horizontal, 24)

                            // Delete Account Section
                            VStack(spacing: 16) {
                                Divider()
                                    .padding(.vertical, 16)

                                Button(action: {
                                    showDeleteConfirmation = true
                                }) {
                                    HStack {
                                        Image(systemName: "trash.fill")
                                            .font(.system(size: 20))

                                        Text("Delete Account")
                                            .font(.system(size: 17, weight: .semibold))
                                    }
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        RoundedRectangle(cornerRadius: 26)
                                            .fill(colorScheme == .dark ?
                                                  Color(red: 0.15, green: 0.18, blue: 0.24) :
                                                    Color.white.opacity(0.5))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 26)
                                                    .stroke(Color.red.opacity(0.5), lineWidth: 2)
                                            )
                                    )
                                }
                                .padding(.horizontal, 24)

                                Text("This action cannot be undone. All your data will be permanently deleted.")
                                    .font(.system(size: 13))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.5))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadProfile()
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage ?? "Changes saved successfully")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showFinalDeleteWarning = true
            }
        } message: {
            Text("Are you sure you want to delete your account? This will permanently delete all your data including goals and journal entries.")
        }
        .alert("Final Warning", isPresented: $showFinalDeleteWarning) {
            TextField("Type DELETE to confirm", text: $deleteConfirmationText)
            Button("Cancel", role: .cancel) {
                deleteConfirmationText = ""
            }
            Button("Delete Forever", role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }
            .disabled(deleteConfirmationText != "DELETE")
        } message: {
            Text("Type DELETE in all caps to confirm permanent account deletion. This cannot be undone.")
        }
    }

    // MARK: - Functions

    private func loadProfile() async {
        await MainActor.run { isLoading = true }

        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            struct ProfileResponse: Decodable {
                let first_name: String?
                let profile_image_url: String?
            }

            let response: [ProfileResponse] = try await SupabaseManager.shared.client
                .database
                .from("profiles")
                .select("first_name, profile_image_url")
                .eq("id", value: userId.uuidString)
                .execute()
                .value

            if let profile = response.first {
                await MainActor.run {
                    firstName = profile.first_name ?? ""
                    profileImageURL = profile.profile_image_url
                }

                // Load image from URL if available - wait for it to complete
                if let urlString = profile.profile_image_url,
                   let url = URL(string: urlString) {
                    await loadImageFromURL(url)
                }
            }

            await MainActor.run {
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

    private func loadImageFromURL(_ url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run {
                profileImage = UIImage(data: data)
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    profileImage = image
                }
                await uploadProfileImage(image)
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to load image"
                showError = true
            }
        }
    }

    private func uploadProfileImage(_ image: UIImage) async {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }

        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id
            let fileName = "\(userId.uuidString).jpg"

            // Upload to Supabase Storage
            _ = try await SupabaseManager.shared.client
                .storage
                .from("profile-images")
                .upload(
                    path: fileName,
                    file: imageData,
                    options: .init(upsert: true)
                )

            // Get public URL
            let publicURL = try SupabaseManager.shared.client
                .storage
                .from("profile-images")
                .getPublicURL(path: fileName)

            // Update profile with image URL
            try await SupabaseManager.shared.client
                .database
                .from("profiles")
                .update(["profile_image_url": publicURL.absoluteString])
                .eq("id", value: userId.uuidString)
                .execute()

            await MainActor.run {
                profileImageURL = publicURL.absoluteString
                successMessage = "Profile picture updated"
                showSuccess = true
            }
        } catch {
            await MainActor.run {
                errorMessage = "Failed to upload image: \(error.localizedDescription)"
                showError = true
            }
        }
    }

    private func saveProfile() async {
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        await MainActor.run { isSaving = true }

        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            try await SupabaseManager.shared.client
                .database
                .from("profiles")
                .update(["first_name": firstName.trimmingCharacters(in: .whitespaces)])
                .eq("id", value: userId.uuidString)
                .execute()

            await MainActor.run {
                isSaving = false
                successMessage = "Profile updated successfully"
                showSuccess = true
            }
        } catch {
            await MainActor.run {
                isSaving = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func deleteAccount() async {
        guard deleteConfirmationText == "DELETE" else { return }

        await MainActor.run {
            isDeleting = true
            deleteConfirmationText = ""
        }

        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            // Delete user's data from all tables
            // Delete goals
            try await SupabaseManager.shared.client
                .database
                .from("goals")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .execute()

            // Delete notification settings
            try await SupabaseManager.shared.client
                .database
                .from("notification_settings")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .execute()

            // Delete profile
            try await SupabaseManager.shared.client
                .database
                .from("profiles")
                .delete()
                .eq("id", value: userId.uuidString)
                .execute()

            // Delete profile image from storage if exists
            if let imageURL = profileImageURL {
                let fileName = "\(userId.uuidString).jpg"
                try? await SupabaseManager.shared.client
                    .storage
                    .from("profile-images")
                    .remove(paths: [fileName])
            }

            // Sign out
            try await SupabaseManager.shared.signOut()

            await MainActor.run {
                // Clear local data
                GoalStorageManager.shared.goals = []
                UserDefaults.standard.set(false, forKey: "glimpse.onboarding.complete")

                isDeleting = false

                // Dismiss all the way back to welcome screen
                dismiss()
            }
        } catch {
            await MainActor.run {
                isDeleting = false
                errorMessage = "Failed to delete account: \(error.localizedDescription)"
                showError = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountSettingsView()
    }
}
