import SwiftUI

struct PersonalizationView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var showDatePicker: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background color
            (colorScheme == .dark ?
             Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top section with back button and progress
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
                        .fill(colorScheme == .dark ? Color(red: 0.35, green: 0.58, blue: 1.0) : Color(red: 0.83, green: 0.58, blue: 0.49))
                        .frame(width: 8, height: 8)

                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)


                }
                .padding(.bottom, 40)
                
                // Title and subtitle
                VStack(spacing: 12) {
                    Text("Let's Get to Know You")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                        .multilineTextAlignment(.center)
                    
                    Text("This helps us personalize your experience.")
                        .font(.system(size: 17))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                
                // Form fields
                VStack(alignment: .leading, spacing: 24) {
                    // First Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("First Name")
                            .font(.system(size: 15))
                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                        
                        TextField("e.g., Taylor", text: $firstName)
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
                    
                    // Last Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Name")
                            .font(.system(size: 15))
                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                        
                        TextField("e.g., Smith", text: $lastName)
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
                    
                    // Date of Birth
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date of Birth")
                            .font(.system(size: 15))
                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                        
                        Button(action: {
                            showDatePicker.toggle()
                        }) {
                            HStack {
                                Text(dateOfBirth, style: .date)                                    .font(.system(size: 17))
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.4))
                                
                                Spacer()
                                
                                Image(systemName: "calendar")
                                    .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.4))
                            }
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
                        .popover(isPresented: $showDatePicker, arrowEdge: .bottom) {
                            VStack(spacing: 20) {
                                // Title
                                Text("Select Date")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                    .padding(.top, 20)
                                
                                // Date Picker
                                DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                    .padding(.horizontal)
                                
                                // Done Button
                                Button(action: {
                                    showDatePicker = false
                                }) {
                                    Text("Done")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 52)
                                        .background(
                                            RoundedRectangle(cornerRadius: 26)
                                                .fill(colorScheme == .dark ?
                                                      Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                        Color(red: 0.83, green: 0.58, blue: 0.49))
                                        )
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                            .frame(width: 340)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color(red: 1.0, green: 0.97, blue: 0.94))
                            )
                            .presentationCompactAdaptation(.popover)
                        }
//                        .popover(isPresented: $showDatePicker, arrowEdge: .bottom) {
//                            VStack(spacing: 0) {
//                                DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
//                                    .datePickerStyle(.wheel)
//                                    .labelsHidden()
//                                    .padding()
//                                
//                                Button(action: {
//                                    showDatePicker = false
//                                }) {
//                                    Text("Done")
//                                        .font(.system(size: 16, weight: .semibold))
//                                        .foregroundColor(.white)
//                                        .frame(maxWidth: .infinity)
//                                        .frame(height: 44)
//                                        .background(
//                                            RoundedRectangle(cornerRadius: 12)
//                                                .fill(colorScheme == .dark ?
//                                                      Color(red: 0.35, green: 0.58, blue: 1.0) :
//                                                        Color(red: 0.83, green: 0.58, blue: 0.49))
//                                        )
//                                }
//                                .padding(.horizontal)
//                                .padding(.bottom)
//                            }
//                            .frame(width: 320)
//                            .background(colorScheme == .dark ?
//                                        Color(red: 0.15, green: 0.18, blue: 0.24) :
//                                            Color(red: 1.0, green: 0.97, blue: 0.94))
//                            .presentationCompactAdaptation(.popover)
//                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Continue button
                NavigationLink(destination: NotificationTimeView()) {
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
    PersonalizationView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    PersonalizationView()
        .preferredColorScheme(.dark)
}
