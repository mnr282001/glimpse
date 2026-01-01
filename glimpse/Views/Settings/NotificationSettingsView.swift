import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var selectedTime: Date = Date()
    @State private var enableReminders: Bool = true
    @State private var isLoading = false
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var successMessage: String?
    @State private var showSuccess = false

    // Generate array of dates representing each hour of the day
    private var hourOptions: [Date] {
        let calendar = Calendar.current
        return (0..<24).compactMap { hour in
            calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())
        }
    }

    // Format date to hour string
    private func formatHour(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:00 a"
        return formatter.string(from: date)
    }

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

                    Text("Notifications")
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
                            // Title and description
                            VStack(spacing: 12) {
                                Text("Daily Reminder")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                Text("Get reminded each day to reflect on your goals")
                                    .font(.system(size: 15))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.top, 16)

                            // Time Picker
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Reminder Time")
                                    .font(.system(size: 15))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                                    .padding(.horizontal, 24)

                                HStack {
                                    Picker("Select Hour", selection: $selectedTime) {
                                        ForEach(hourOptions, id: \.self) { date in
                                            Text(formatHour(date))
                                                .tag(date)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 180)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(colorScheme == .dark ?
                                                  Color(red: 0.2, green: 0.25, blue: 0.35) :
                                                    Color.white.opacity(0.5))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.1), lineWidth: 1)
                                    )
                                    .padding(.horizontal, 24)
                                }
                            }

                            // Enable reminders toggle
                            HStack {
                                Text("Enable daily reminders")
                                    .font(.system(size: 17))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))

                                Spacer()

                                Toggle("", isOn: $enableReminders)
                                    .labelsHidden()
                                    .tint(colorScheme == .dark ?
                                          Color(red: 0.35, green: 0.58, blue: 1.0) :
                                            Color(red: 0.83, green: 0.58, blue: 0.49))
                            }
                            .padding(.horizontal, 24)

                            // Save Button
                            Button(action: {
                                Task {
                                    await saveSettings()
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
                            .disabled(isSaving)
                            .opacity(isSaving ? 0.5 : 1.0)
                            .padding(.horizontal, 24)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadSettings()
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(successMessage ?? "Settings saved successfully")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An error occurred")
        }
    }

    // MARK: - Functions

    private func loadSettings() async {
        await MainActor.run { isLoading = true }

        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            struct NotificationResponse: Decodable {
                let reminder_time: String
                let enabled: Bool
            }

            let response: [NotificationResponse] = try await SupabaseManager.shared.client
                .database
                .from("notification_settings")
                .select("reminder_time, enabled")
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value

            await MainActor.run {
                if let settings = response.first {
                    enableReminders = settings.enabled

                    // Parse time string (format: "HH:MM:SS")
                    let components = settings.reminder_time.split(separator: ":")
                    if let hour = Int(components[0]) {
                        let calendar = Calendar.current
                        if let date = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) {
                            selectedTime = date
                        }
                    }
                }
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

    private func saveSettings() async {
        await MainActor.run { isSaving = true }

        do {
            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            // Extract time components
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: selectedTime)
            let minute = calendar.component(.minute, from: selectedTime)
            let timeString = String(format: "%02d:%02d:00", hour, minute)

            struct NotificationSettingsUpdate: Encodable {
                let user_id: String
                let reminder_time: String
                let enabled: Bool
            }

            let settings = NotificationSettingsUpdate(
                user_id: userId.uuidString,
                reminder_time: timeString,
                enabled: enableReminders
            )

            // Upsert settings
            try await SupabaseManager.shared.client
                .database
                .from("notification_settings")
                .upsert(settings, onConflict: "user_id")
                .execute()

            await MainActor.run {
                isSaving = false
                successMessage = "Notification settings updated"
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
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}

