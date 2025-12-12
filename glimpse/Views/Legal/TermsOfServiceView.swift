import SwiftUI

struct TermsOfServiceView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
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
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    }
                    
                    Spacer()
                    
                    Text("Terms of Service")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                    
                    Spacer()
                    
                    // Invisible placeholder
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .opacity(0)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                
                // Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Last Updated: November 17, 2025")
                            .font(.system(size: 14))
                            .foregroundColor((colorScheme == .dark ? Color.white : Color(red: 0.17, green: 0.17, blue: 0.17)).opacity(0.6))
                        
                        // Introduction
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. Acceptance of Terms")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("By accessing and using Glimpse (\"the App\"), you accept and agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Service Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("2. Service Description")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("Glimpse is a gratitude journaling application that allows users to record daily moments of gratitude, including text entries, photos, and videos. The App provides daily prompts and reminders to help users maintain a consistent gratitude practice.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // User Account
                        VStack(alignment: .leading, spacing: 12) {
                            Text("3. User Account")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You must provide accurate and complete information when creating your account, including your name and date of birth.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // User Content
                        VStack(alignment: .leading, spacing: 12) {
                            Text("4. User Content")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("You retain all rights to the content you create and upload to Glimpse, including journal entries, photos, and videos. By using the App, you grant us a limited license to store and display your content solely for the purpose of providing the service to you.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Acceptable Use
                        VStack(alignment: .leading, spacing: 12) {
                            Text("5. Acceptable Use")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("You agree not to use the App for any unlawful purpose or in any way that could damage, disable, or impair the service. You will not upload content that is harmful, offensive, or violates the rights of others.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Data Storage
                        VStack(alignment: .leading, spacing: 12) {
                            Text("6. Data Storage and Backup")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("We strive to keep your data safe and secure. However, you are responsible for maintaining your own backups of your content. We are not liable for any loss of data or content.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Termination
                        VStack(alignment: .leading, spacing: 12) {
                            Text("7. Termination")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("We reserve the right to terminate or suspend your account at any time for violations of these Terms. You may delete your account at any time through the App settings.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Disclaimer
                        VStack(alignment: .leading, spacing: 12) {
                            Text("8. Disclaimer of Warranties")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("The App is provided \"as is\" without warranties of any kind. We do not guarantee that the service will be uninterrupted or error-free.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Changes to Terms
                        VStack(alignment: .leading, spacing: 12) {
                            Text("9. Changes to Terms")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("We reserve the right to modify these Terms at any time. We will notify users of any material changes through the App or via email. Continued use of the App after changes constitutes acceptance of the new Terms.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Contact
                        VStack(alignment: .leading, spacing: 12) {
                            Text("10. Contact Us")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("If you have any questions about these Terms, please contact us at support@glimpseapp.com")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview("Light Mode") {
    TermsOfServiceView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    TermsOfServiceView()
        .preferredColorScheme(.dark)
}
