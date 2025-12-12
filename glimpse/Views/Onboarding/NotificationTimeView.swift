import SwiftUI

struct NotificationTimeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var selectedTime: Date = Date()
    @State private var enableReminders: Bool = true
    
    
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
                    DatePicker(
                        "Select Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
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
                
                // Continue button

                NavigationLink(destination: GoalsSetupView()) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .semibold))
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
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
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
