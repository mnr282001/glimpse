import SwiftUI

struct PrivacyPolicyView: View {
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
                    
                    Text("Privacy Policy")
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
                            Text("Introduction")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("At Glimpse, we respect your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our gratitude journaling app.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Information We Collect
                        VStack(alignment: .leading, spacing: 12) {
                            Text("1. Information We Collect")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("We collect the following information:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                BulletPoint(text: "Account Information: Your name, email address, and date of birth")
                                BulletPoint(text: "Journal Content: Text entries, photos, and videos you upload as part of your gratitude journal")
                                BulletPoint(text: "Usage Data: Information about how you interact with the App, including timestamps of entries")
                                BulletPoint(text: "Device Information: Device type, operating system, and app version")
                            }
                        }
                        
                        // How We Use Information
                        VStack(alignment: .leading, spacing: 12) {
                            Text("2. How We Use Your Information")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("We use your information to:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                BulletPoint(text: "Provide and maintain the App's functionality")
                                BulletPoint(text: "Store and display your journal entries, photos, and videos")
                                BulletPoint(text: "Send you daily reminders if you've enabled notifications")
                                BulletPoint(text: "Personalize your experience")
                                BulletPoint(text: "Improve and optimize the App")
                                BulletPoint(text: "Communicate with you about updates and support")
                            }
                        }
                        
                        // Data Storage
                        VStack(alignment: .leading, spacing: 12) {
                            Text("3. Data Storage and Security")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("Your data is stored securely using industry-standard encryption. We use Supabase as our backend service provider, which complies with SOC 2 Type II standards. Your journal entries, photos, and videos are stored in encrypted databases and are only accessible to you through your authenticated account.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Data Sharing
                        VStack(alignment: .leading, spacing: 12) {
                            Text("4. Data Sharing")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("We do not sell, trade, or share your personal information with third parties. Your journal content is private and will never be shared without your explicit consent. We may share data only in the following circumstances:")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                BulletPoint(text: "With service providers who help us operate the App (under strict confidentiality agreements)")
                                BulletPoint(text: "When required by law or to protect our legal rights")
                                BulletPoint(text: "In the event of a merger or acquisition (you will be notified)")
                            }
                        }
                        
                        // User Rights
                        VStack(alignment: .leading, spacing: 12) {
                            Text("5. Your Rights and Choices")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("You have the right to:")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                BulletPoint(text: "Access your personal data at any time through the App")
                                BulletPoint(text: "Edit or delete your journal entries")
                                BulletPoint(text: "Export your data")
                                BulletPoint(text: "Delete your account and all associated data")
                                BulletPoint(text: "Opt out of daily reminder notifications")
                                BulletPoint(text: "Request a copy of all your data")
                            }
                        }
                        
                        // Media Content
                        VStack(alignment: .leading, spacing: 12) {
                            Text("6. Photos and Videos")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("Photos and videos you upload are stored securely and are only accessible through your account. We do not scan, analyze, or use your media content for any purpose other than displaying it to you in your journal. You retain all ownership rights to your media content.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Children's Privacy
                        VStack(alignment: .leading, spacing: 12) {
                            Text("7. Children's Privacy")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("Glimpse is intended for users aged 13 and older. We do not knowingly collect personal information from children under 13. If we discover that we have collected information from a child under 13, we will delete it immediately.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Data Retention
                        VStack(alignment: .leading, spacing: 12) {
                            Text("8. Data Retention")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("We retain your data for as long as your account is active. When you delete your account, we will delete all your personal information and journal content within 30 days, except where we are required to retain it for legal purposes.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Changes to Policy
                        VStack(alignment: .leading, spacing: 12) {
                            Text("9. Changes to This Policy")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("We may update this Privacy Policy from time to time. We will notify you of any significant changes through the App or via email. Your continued use of the App after changes are made constitutes acceptance of the updated policy.")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                        }
                        
                        // Contact
                        VStack(alignment: .leading, spacing: 12) {
                            Text("10. Contact Us")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                            
                            Text("If you have any questions or concerns about this Privacy Policy or how we handle your data, please contact us at:")
                                .font(.system(size: 16))
                                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                                .lineSpacing(4)
                            
                            Text("privacy@glimpseapp.com")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(colorScheme == .dark ?
                                                 Color(red: 0.35, green: 0.58, blue: 1.0) :
                                                    Color(red: 0.83, green: 0.58, blue: 0.49))
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

// Helper view for bullet points
struct BulletPoint: View {
    @Environment(\.colorScheme) var colorScheme
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 16))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17))
                .lineSpacing(4)
        }
    }
}

#Preview("Light Mode") {
    PrivacyPolicyView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    PrivacyPolicyView()
        .preferredColorScheme(.dark)
}
