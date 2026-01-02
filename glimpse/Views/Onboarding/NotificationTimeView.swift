import SwiftUI
import UserNotifications

struct NotificationTimeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var selectedTime: Date = Date()
    @State private var enableReminders: Bool = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var navigateToGoals = false
    @StateObject private var notificationManager = NotificationManager.shared
    
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
                HStack {
                    // Back button
                    Button(action: {
                        // Back action
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
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(colorScheme == .dark ? Color(red: 0.35, green: 0.58, blue: 1.0) : Color(red: 0.83, green: 0.58, blue: 0.49))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                .padding(.bottom, 40)
                
                // Title and subtitle
                VStack(spacing: 12) {
                    Text("When should we remind you?")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Text("We'll send a gentle reminder each day.")
                        .font(.system(size: 17))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 40)
                
                // Time Picker
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
                
                
                Spacer()
                
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
                .padding(.bottom, 40)

                // Hidden NavigationLink for navigation
                NavigationLink(destination: GoalsSetupView(), isActive: $navigateToGoals) {
                    EmptyView()
                }
                .hidden()

                // Continue button
                Button(action: {
                    Task {
                        await handleContinue()
                    }
                }) {
                    Group {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue")
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
                .disabled(isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .navigationBarHidden(true)
    }

    // MARK: - Supabase Functions

    private struct NotificationSettings: Encodable {
        let user_id: String
        let reminder_time: String
        let enabled: Bool
    }

    private func handleContinue() async {
        await MainActor.run {
            isLoading = true
        }

        // Request notification permission if reminders are enabled
        if enableReminders {
            let granted = await requestNotificationPermission()

            if !granted {
                await MainActor.run {
                    errorMessage = "Notification permission was denied. You can enable it later in Settings if you'd like to receive daily reminders."
                    showError = true
                }
                // Still continue even if permission denied - user can enable later
            }
        }

        // Save settings to Supabase
        await saveNotificationSettings()

        // Navigate to goals setup (loading state cleared by saveNotificationSettings)
        await MainActor.run {
            navigateToGoals = true
        }
    }

    private func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }

    private func saveNotificationSettings() async {
        do {
            // Request notification permission if not already granted
            if enableReminders && !notificationManager.isAuthorized {
                let granted = await notificationManager.requestAuthorization()
                if !granted {
                    await MainActor.run {
                        errorMessage = "Please enable notifications in Settings to receive daily reminders."
                        showError = true
                        isLoading = false
                    }
                    return
                }
            }

            let userId = try await SupabaseManager.shared.client.auth.session.user.id

            // Extract time components
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: selectedTime)
            let minute = calendar.component(.minute, from: selectedTime)
            let timeString = String(format: "%02d:%02d:00", hour, minute)

            let settings = NotificationSettings(
                user_id: userId.uuidString,
                reminder_time: timeString,
                enabled: enableReminders
            )

            // Upsert (insert or update if exists) - specify user_id as conflict resolution column
            try await SupabaseManager.shared.client
                .database
                .from("notification_settings")
                .upsert(settings, onConflict: "user_id")
                .execute()

            // Schedule the actual notification
            if enableReminders {
                await notificationManager.scheduleDailyNotification(at: selectedTime, enabled: true)
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
}

#Preview("Light Mode") {
    NotificationTimeView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NotificationTimeView()
        .preferredColorScheme(.dark)
}
