import SwiftUI

struct AuthView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    @State private var showEmailAuth = false
    @State private var navigateToPersonalization = false
    
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
                .padding(.bottom, 50)
                
                //                    // Welcome illustration
                //                    ZStack {
                //                        // Card background
                //                        RoundedRectangle(cornerRadius: 40)
                //                            .fill(colorScheme == .dark ?
                //                                  Color(red: 0.15, green: 0.18, blue: 0.24) :
                //                                    Color.white.opacity(0.5))
                //                            .frame(width: 280, height: 280)
                //                        
                //                        // Decorative circles
                //                        Circle()
                //                            .fill(colorScheme == .dark ?
                //                                  Color(red: 0.2, green: 0.25, blue: 0.35) :
                //                                    Color(red: 0.83, green: 0.58, blue: 0.49).opacity(0.35))
                //                            .frame(width: 60, height: 60)
                //                            .offset(x: -130, y: -100)
                //                        
                //                        Circle()
                //                            .fill(colorScheme == .dark ?
                //                                  Color(red: 0.2, green: 0.25, blue: 0.35) :
                //                                    Color(red: 0.83, green: 0.58, blue: 0.49).opacity(0.35))
                //                            .frame(width: 40, height: 40)
                //                            .offset(x: 120, y: 80)
                //                        
                //                        Circle()
                //                            .fill(colorScheme == .dark ?
                //                                  Color(red: 0.2, green: 0.25, blue: 0.35) :
                //                                    Color(red: 0.83, green: 0.58, blue: 0.49).opacity(0.35))
                //                            .frame(width: 50, height: 50)
                //                            .offset(x: 110, y: -80)
                //                        
                //                        // Person icon
                //                        Image(systemName: "person.circle.fill")
                //                            .font(.system(size: 100))
                //                            .foregroundColor(colorScheme == .dark ?
                //                                             Color(red: 0.35, green: 0.58, blue: 1.0) :
                //                                                Color(red: 0.83, green: 0.58, blue: 0.49))
                //                    }
                //                    .padding(.bottom, 60)
                
                // Text content
                VStack(spacing: 16) {
                    Text("Welcome to Glimpse")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Text("Sign in to start journaling your gratitude and build lasting memories.")
                        .font(.system(size: 17))
                        .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.7))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                
                // Email/Password fields (conditional)
                if showEmailAuth {
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
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Auth buttons
                VStack(spacing: 16) {
                    // Email/Password button
                    if showEmailAuth {
                        Button(action: {
                            signInWithEmail()
                        }) {
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
                        .disabled(email.isEmpty || password.isEmpty)
                        .opacity((email.isEmpty || password.isEmpty) ? 0.5 : 1.0)
                    } else {
                        Button(action: {
                            withAnimation(.spring(response: 0.4)) {
                                showEmailAuth = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("Continue with Email")
                                    .font(.system(size: 17, weight: .semibold))
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
                    }
                    
                    if !showEmailAuth {
                        // Divider
                        HStack(spacing: 16) {
                            Rectangle()
                                .fill((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.2))
                                .frame(height: 1)
                            
                            Text("or")
                                .font(.system(size: 15))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.5))
                            
                            Rectangle()
                                .fill((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.2))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        // Sign in with Apple
                        Button(action: {
                            signInWithApple()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "apple.logo")
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("Continue with Apple")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color.black)
                            )
                        }
                        
                        // Sign in with Google
                        Button(action: {
                            signInWithGoogle()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "g.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                
                                Text("Continue with Google")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(colorScheme == .dark ?
                                          Color(red: 0.15, green: 0.18, blue: 0.24) :
                                            Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28)
                                            .stroke((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                    } else {
                        // Back to options button
                        Button(action: {
                            withAnimation(.spring(response: 0.4)) {
                                showEmailAuth = false
                                email = ""
                                password = ""
                            }
                        }) {
                            Text("Back to sign in options")
                                .font(.system(size: 15))
                                .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
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
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToPersonalization) {
            PersonalizationView()
        }
    }
    
    // MARK: - Auth Functions
    
    func signInWithEmail() {
        isLoading = true
        print("Sign in with email: \(email)")
        
        // TODO: Implement Supabase Email Sign In
        // supabase.auth.signIn(email: email, password: password)
        
        navigateToPersonalization = true
        isLoading = false
    }

    func signInWithApple() {
        isLoading = true
        print("Sign in with Apple tapped")
        
        // TODO: Implement Supabase Apple Sign In
        
        navigateToPersonalization = true
        isLoading = false
    }

    func signInWithGoogle() {
        isLoading = true
        print("Sign in with Google tapped")
        
        // TODO: Implement Supabase Google Sign In
        
        navigateToPersonalization = true
        isLoading = false
    }
}

#Preview("Light Mode") {
    AuthView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    AuthView()
        .preferredColorScheme(.dark)
}
