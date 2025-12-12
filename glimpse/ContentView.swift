import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color - changes based on color scheme
                (colorScheme == .dark ?
                 Color(red: 0.11, green: 0.12, blue: 0.15) :
                    Color(red: 1.0, green: 0.97, blue: 0.94))
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // App name with logo
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
                    .padding(.top, 20)

                    // Progress dots
                    HStack(spacing: 12) {
                        Circle()
                            .fill(colorScheme == .dark ? Color.blue : Color(red: 0.83, green: 0.58, blue: 0.49))
                            .frame(width: 8, height: 8)

                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)

                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)

                    }
                    .padding(.bottom, 40)
                    
                    // Book icon with card background
                    ZStack {
                        // Card background
                        RoundedRectangle(cornerRadius: 40)
                            .fill(colorScheme == .dark ?
                                  Color(red: 0.15, green: 0.18, blue: 0.24) :
                                    Color.white.opacity(0.5))
                            .frame(width: 280, height: 280)
                        
                        // Decorative circles (optional - for the floating effect)
                        Circle()
                            .fill(colorScheme == .dark ?
                                  Color(red: 0.2, green: 0.25, blue: 0.35) :
                                    Color(red: 0.83, green: 0.58, blue: 0.49).opacity(0.35))
                            .frame(width: 60, height: 60)
                            .offset(x: -130, y: -100)
                        
                        Circle()
                            .fill(colorScheme == .dark ?
                                  Color(red: 0.2, green: 0.25, blue: 0.35) :
                                    Color(red: 0.83, green: 0.58, blue: 0.49).opacity(0.35))
                            .frame(width: 40, height: 40)
                            .offset(x: 120, y: 80)
                        
                        Circle()
                            .fill(colorScheme == .dark ?
                                  Color(red: 0.2, green: 0.25, blue: 0.35) :
                                    Color(red: 0.83, green: 0.58, blue: 0.49).opacity(0.35))
                            .frame(width: 50, height: 50)
                            .offset(x: 110, y: -80)
                        
                        // Book icon
                        Image(systemName: "book.fill")
                            .font(.system(size: 100))
                            .foregroundColor(colorScheme == .dark ?
                                             Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                Color(red: 0.83, green: 0.58, blue: 0.49))
                    }
                    .padding(.bottom, 60)
                    
                    Spacer()
                    
                    // Text content
                    VStack(spacing: 16) {
                        Text("Capture what matters")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)

                        Text("Answer one question each day. Build a journal of your best moments.")
                            .font(.system(size: 17))
                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.7))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                    
                    // Get Started button
                    NavigationLink(destination: AuthView()) {
                        Text("Get Started")
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
}

#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
