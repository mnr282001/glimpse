//
//  PremiumComingSoonView.swift
//  glimpse
//
//  Created by Nayab Rehmat on 1/8/26.
//
import SwiftUI

struct PremiumComingSoonView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private var accentColor: Color {
        colorScheme == .dark
        ? Color(red: 0.35, green: 0.58, blue: 1.0)
        : Color(red: 0.83, green: 0.58, blue: 0.49)
    }
    
    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17)
    }
    
    private var secondaryTextColor: Color {
        primaryTextColor.opacity(0.6)
    }
    
    var body: some View {
        ZStack {
            (colorScheme == .dark ?
             Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(secondaryTextColor)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // Crown icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 50))
                        .foregroundColor(accentColor)
                }
                
                VStack(spacing: 16) {
                    Text("Premium Coming Soon")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(primaryTextColor)
                    
                    Text("We're working on exciting premium features")
                        .font(.system(size: 17))
                        .foregroundColor(secondaryTextColor)
                        .multilineTextAlignment(.center)
                }
                
                // Features list
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "target", text: "Up to 10 goals", accentColor: accentColor)
                    FeatureRow(icon: "forward.fill", text: "Skip goals for specific days", accentColor: accentColor)
                    FeatureRow(icon: "folder.fill", text: "Customize goal categories", accentColor: accentColor)
                    FeatureRow(icon: "bell.fill", text: "Advanced reminder customization", accentColor: accentColor)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Got it button
                Button(action: { dismiss() }) {
                    Text("Got It")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(accentColor)
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accentColor)
                .frame(width: 28)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(Color.primary.opacity(0.8))
        }
    }
}
