import SwiftUI

struct NotificationSplashView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotationAngle: Double = -180
    @State private var showRipple1 = false
    @State private var showRipple2 = false
    @State private var showRipple3 = false

    let onComplete: () -> Void

    var body: some View {
        ZStack {
            // Background
            (colorScheme == .dark ?
                Color(red: 0.11, green: 0.12, blue: 0.15) :
                Color(red: 1.0, green: 0.97, blue: 0.94))
                .ignoresSafeArea()

            // Ripple effects
            ForEach(0..<3) { index in
                Circle()
                    .stroke(accentColor.opacity(0.3), lineWidth: 2)
                    .frame(width: 100, height: 100)
                    .scaleEffect(rippleScale(for: index))
                    .opacity(rippleOpacity(for: index))
            }

            // Main icon container
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                accentColor.opacity(0.3),
                                accentColor.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(scale)
                    .opacity(opacity)

                // Icon circle
                Circle()
                    .fill(accentColor)
                    .frame(width: 100, height: 100)
                    .shadow(color: accentColor.opacity(0.5), radius: 20, x: 0, y: 10)

                // Bell icon
                Image(systemName: "bell.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(rotationAngle))
            }
            .scaleEffect(scale)
            .opacity(opacity)

            // Text
            VStack(spacing: 8) {
                Spacer()
                    .frame(height: 200)

                Text("Time to Reflect")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(primaryTextColor)
                    .opacity(opacity)

                Text("Opening your reflections...")
                    .font(.system(size: 16))
                    .foregroundColor(secondaryTextColor)
                    .opacity(opacity * 0.8)
            }
        }
        .onAppear {
            print("🎬 NotificationSplashView: View appeared - starting animation")
            startAnimation()
        }
    }

    // MARK: - Computed Properties

    private var accentColor: Color {
        colorScheme == .dark ?
            Color(red: 0.35, green: 0.58, blue: 1.0) :
            Color(red: 0.83, green: 0.58, blue: 0.49)
    }

    private var primaryTextColor: Color {
        colorScheme == .dark ? .white : Color(red: 0.17, green: 0.17, blue: 0.17)
    }

    private var secondaryTextColor: Color {
        primaryTextColor.opacity(0.6)
    }

    // MARK: - Ripple Helpers

    private func rippleScale(for index: Int) -> CGFloat {
        switch index {
        case 0: return showRipple1 ? 3.0 : 1.0
        case 1: return showRipple2 ? 3.5 : 1.0
        case 2: return showRipple3 ? 4.0 : 1.0
        default: return 1.0
        }
    }

    private func rippleOpacity(for index: Int) -> Double {
        switch index {
        case 0: return showRipple1 ? 0.0 : 0.6
        case 1: return showRipple2 ? 0.0 : 0.6
        case 2: return showRipple3 ? 0.0 : 0.6
        default: return 0.0
        }
    }

    // MARK: - Animation

    private func startAnimation() {
        // Phase 1: Icon appears with bounce (0.0s - 0.5s)
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0)) {
            scale = 1.0
            opacity = 1.0
            rotationAngle = 0
        }

        // Phase 2: First ripple (0.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeOut(duration: 0.8)) {
                showRipple1 = true
            }
        }

        // Phase 3: Second ripple (0.4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.8)) {
                showRipple2 = true
            }
        }

        // Phase 4: Third ripple (0.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.8)) {
                showRipple3 = true
            }
        }

        // Phase 5: Bell wiggle (0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.interpolatingSpring(stiffness: 300, damping: 10)) {
                rotationAngle = 15
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 10)) {
                    rotationAngle = -15
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 10)) {
                        rotationAngle = 0
                    }
                }
            }
        }

        // Phase 6: Fade out and complete (1.4s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0
                scale = 1.2
            }

            // Call completion after fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                print("✅ NotificationSplashView: Animation complete - calling onComplete()")
                onComplete()
            }
        }
    }
}

#Preview("Light Mode") {
    NotificationSplashView {
        print("Animation completed")
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NotificationSplashView {
        print("Animation completed")
    }
    .preferredColorScheme(.dark)
}
