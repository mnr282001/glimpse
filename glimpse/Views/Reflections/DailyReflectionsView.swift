import SwiftUI

struct DailyReflectionsView: View {
    @StateObject private var reflectionManager = ReflectionManager.shared
    @StateObject private var goalStorage = GoalStorageManager.shared
    
    @State private var currentGoalIndex = 0
    @State private var progressText = ""
    @State private var setbackText = ""
    @State private var isSaving = false
    @State private var showSuccessMessage = false
    @State private var showError = false
    @State private var progressFocused = false
    @State private var setbackFocused = false
    @State private var slideOffset: CGFloat = 0
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focusedField: Field?
    
    enum Field {
        case progress, setback
    }
    
    // Current goal being reflected on
    private var currentGoal: Goal? {
        guard currentGoalIndex < goalStorage.goals.count else { return nil }
        return goalStorage.goals[currentGoalIndex]
    }
    
    // Check if all goals are complete
    private var allGoalsComplete: Bool {
        reflectionManager.allGoalsCompleted(for: goalStorage.goals)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    colors: colorScheme == .dark ? [
                        Color(red: 0.08, green: 0.09, blue: 0.12),
                        Color(red: 0.11, green: 0.12, blue: 0.15)
                    ] : [
                        Color(red: 0.98, green: 0.96, blue: 0.94),
                        Color(red: 1.0, green: 0.97, blue: 0.94)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if reflectionManager.isLoading {
                    loadingView
                } else if let currentGoal = currentGoal {
                    mainContentView(for: currentGoal)
                } else {
                    emptyStateView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(reflectionManager.errorMessage ?? "An error occurred")
            }
            .overlay(successOverlay)
            .task {
                await loadReflections()
            }
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private func mainContentView(for goal: Goal) -> some View {
        ScrollViewReader { scrollViewProxy in  // Wrap ScrollView with ScrollViewReader
            ScrollView {
                VStack(spacing: 0) {
                    // Elegant header with progress
                    headerView(for: goal)
                        .padding(.top, 8)
                        .padding(.bottom, 32)

                    // Beautiful reflection cards
                    VStack(spacing: 20) {
                        progressCard
                        setbackCard
                    }
                    .padding(.horizontal, 20)
                    .offset(x: slideOffset)
                    .animation(.spring(response: 0.05, dampingFraction: 0.6), value: slideOffset)  // Instant animation

                    // Action buttons
                    actionButtons
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
                .id("top")  // Adding an id to make sure we can scroll to it
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: currentGoalIndex) { _ in  // iOS 17+ change: handle changes with the new closure syntax
                // Delay scrolling to the top until the goal change completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        scrollViewProxy.scrollTo("top", anchor: .top)  // Scroll to the top using the "top" id
                    }
                }
            }
        }
    }


    
    // MARK: - Header
    
    @ViewBuilder
    private func headerView(for goal: Goal) -> some View {
        VStack(spacing: 20) {
            // Refined progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.15))
                        .frame(height: 4)
                    
                    // Progress fill
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [accentColor, accentColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * CGFloat(currentGoalIndex + 1) / CGFloat(max(goalStorage.goals.count, 1)),
                            height: 4
                        )
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentGoalIndex)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 40)
            
            // Goal indicator with beautiful icon
            VStack(spacing: 16) {
                // Large, gorgeous icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    goal.category.color(for: colorScheme),
                                    goal.category.color(for: colorScheme).opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 72, height: 72)
                        .shadow(
                            color: goal.category.color(for: colorScheme).opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    
                    Image(systemName: goal.category.icon)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Goal title and metadata
                VStack(spacing: 6) {
                    Text(goal.title)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(primaryTextColor)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    HStack(spacing: 6) {
                        Text(goal.category.rawValue.capitalized)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(secondaryTextColor)
                        
                        Text("•")
                            .foregroundColor(secondaryTextColor.opacity(0.5))
                        
                        Text("\(currentGoalIndex + 1) of \(goalStorage.goals.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(secondaryTextColor)
                    }
                }
                .padding(.horizontal, 32)
            }
        }
    }
    
    // MARK: - Progress Card
    
    @ViewBuilder
    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header with icon
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(colorScheme == .dark ? 0.2 : 0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Progress")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(primaryTextColor)
                    
                    Text("What went well today?")
                        .font(.system(size: 14))
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
            }
            
            // Beautiful text editor
            ZStack(alignment: .topLeading) {
                // Background with subtle pattern
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(textEditorBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                focusedField == .progress
                                ? accentColor.opacity(0.5)
                                : Color.clear,
                                lineWidth: 2
                            )
                            .animation(.spring(response: 0.3), value: focusedField)
                    )
                
                // Placeholder
                if progressText.isEmpty {
                    Text("I made progress by...")
                        .font(.system(size: 17))
                        .foregroundColor(secondaryTextColor.opacity(0.5))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
                
                // Text editor
                TextEditor(text: $progressText)
                    .font(.system(size: 17, design: .default))
                    .foregroundColor(primaryTextColor)
                    .focused($focusedField, equals: .progress)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 140)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .frame(minHeight: 140)
            
            // Character count with beautiful styling
            if !progressText.isEmpty {
                HStack {
                    Spacer()
                    Text("\(progressText.count)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(secondaryTextColor.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.1))
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                    radius: 20,
                    x: 0,
                    y: 10
                )
        )
        .scaleEffect(focusedField == .progress ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: focusedField)
    }
    
    // MARK: - Setback Card
    
    @ViewBuilder
    private var setbackCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Card header with icon
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(colorScheme == .dark ? 0.2 : 0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.orange)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Setback")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(primaryTextColor)
                    
                    Text("What could be better?")
                        .font(.system(size: 14))
                        .foregroundColor(secondaryTextColor)
                }
                
                Spacer()
            }
            
            // Beautiful text editor
            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(textEditorBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                focusedField == .setback
                                ? accentColor.opacity(0.5)
                                : Color.clear,
                                lineWidth: 2
                            )
                            .animation(.spring(response: 0.3), value: focusedField)
                    )
                
                // Placeholder
                if setbackText.isEmpty {
                    Text("I struggled with...")
                        .font(.system(size: 17))
                        .foregroundColor(secondaryTextColor.opacity(0.5))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
                
                // Text editor
                TextEditor(text: $setbackText)
                    .font(.system(size: 17, design: .default))
                    .foregroundColor(primaryTextColor)
                    .focused($focusedField, equals: .setback)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 140)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .frame(minHeight: 140)
            
            // Character count
            if !setbackText.isEmpty {
                HStack {
                    Spacer()
                    Text("\(setbackText.count)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(secondaryTextColor.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.1))
                        )
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)
                .shadow(
                    color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.08),
                    radius: 20,
                    x: 0,
                    y: 10
                )
        )
        .scaleEffect(focusedField == .setback ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: focusedField)
    }
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Primary action button
            Button(action: saveReflection) {
                HStack(spacing: 8) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isLastGoal ? "Complete" : "Continue")
                            .font(.system(size: 17, weight: .semibold))
                        
                        Image(systemName: isLastGoal ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            canSave
                            ? LinearGradient(
                                colors: [accentColor, accentColor.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(
                            color: canSave ? accentColor.opacity(0.3) : Color.clear,
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                )
            }
            .disabled(!canSave || isSaving)
            .scaleEffect(canSave ? 1.0 : 0.98)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: canSave)
            .padding(.horizontal, 20)
            
            // Skip button
            if !isLastGoal {
                Button(action: skipToNextGoal) {
                    Text("Skip for now")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(secondaryTextColor)
                        .frame(height: 44)
                }
            }
        }
    }
    
    // MARK: - Loading View
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(accentColor)
                .scaleEffect(1.2)
            
            Text("Loading reflections...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(secondaryTextColor)
        }
    }
    
    // MARK: - Empty State
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                accentColor.opacity(0.2),
                                accentColor.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "target")
                    .font(.system(size: 56, weight: .medium))
                    .foregroundColor(accentColor)
            }
            
            VStack(spacing: 12) {
                Text("No goals to reflect on")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(primaryTextColor)
                
                Text("Add goals to start your daily reflections")
                    .font(.system(size: 16))
                    .foregroundColor(secondaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { dismiss() }) {
                Text("Go to Dashboard")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 200, height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(accentColor)
                            .shadow(color: accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
                    )
            }
            .padding(.top, 8)
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .semibold))
                    
                }
                .foregroundColor(secondaryTextColor)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.gray.opacity(colorScheme == .dark ? 0.2 : 0.15))
                )
            }
        }
        
        ToolbarItem(placement: .principal) {
            Text(todayFormatted)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(primaryTextColor)
        }
    }
    
    // MARK: - Success Overlay
    
    @ViewBuilder
    private var successOverlay: some View {
        if showSuccessMessage {
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.green)
                    
                    Text(allGoalsComplete ? "All complete! 🎉" : "Saved!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(primaryTextColor)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(cardBackground)
                        .shadow(
                            color: Color.black.opacity(0.15),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                )
                .padding(.bottom, 100)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showSuccessMessage)
        }
    }
    
    // MARK: - Computed Properties
    
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
    
    private var cardBackground: Color {
        colorScheme == .dark
        ? Color(red: 0.15, green: 0.16, blue: 0.20)
        : Color.white
    }
    
    private var textEditorBackground: Color {
        colorScheme == .dark
        ? Color(red: 0.12, green: 0.13, blue: 0.17)
        : Color(red: 0.96, green: 0.96, blue: 0.97)
    }
    
    private var canSave: Bool {
        !progressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !setbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isLastGoal: Bool {
        currentGoalIndex >= goalStorage.goals.count - 1
    }
    
    private var todayFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    // MARK: - Actions
    
    private func loadReflections() async {
        await reflectionManager.loadTodayReflections(for: goalStorage.goals)
        
        if let currentGoal = currentGoal,
           let existingReflection = reflectionManager.reflection(for: currentGoal.id) {
            await MainActor.run {
                progressText = existingReflection.progressText
                setbackText = existingReflection.setbackText
            }
        }
    }
    
    private func saveReflection() {
        guard let currentGoal = currentGoal else { return }

        // Dismiss keyboard
        focusedField = nil
        isSaving = true

        Task {
            do {
                let userId = try await SupabaseManager.shared.client.auth.session.user.id
                var reflection = Reflection(userId: userId, goalId: currentGoal.id)
                reflection.progressText = progressText
                reflection.setbackText = setbackText

                try await reflectionManager.saveReflection(reflection)

                await MainActor.run {
                    isSaving = false

                    // Slide out smoothly after saving (fully slide off the screen)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        slideOffset = -UIScreen.main.bounds.width
                    }

                    // Show success message
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showSuccessMessage = true
                    }

                    // Hide success message and move to next goal or dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showSuccessMessage = false
                        }

                        if !isLastGoal {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                moveToNextGoal()
                            }
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                dismiss()
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    reflectionManager.errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func skipToNextGoal() {
        focusedField = nil
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            slideOffset = -50
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            moveToNextGoal()
        }
    }
    private func moveToNextGoal() {
        // Reset text fields
        progressText = ""
        setbackText = ""

        // Slide out the content off the screen (instant animation)
        withAnimation(.spring(response: 0.05, dampingFraction: 0.6)) {
            slideOffset = -UIScreen.main.bounds.width
        }

        // Wait until the slide-out animation completes before updating goal and sliding back in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {  // Instant transition
            // Move to the next goal
            currentGoalIndex += 1

            // Reset slideOffset to bring the content back in
            withAnimation(.spring(response: 0.05, dampingFraction: 0.6)) {
                slideOffset = UIScreen.main.bounds.width
            }

            // Now that we are at the next goal, load its reflection if available
            if let nextGoal = currentGoal,
               let existingReflection = reflectionManager.reflection(for: nextGoal.id) {
                progressText = existingReflection.progressText
                setbackText = existingReflection.setbackText
            }

            // Slide back to the center of the screen to show the new goal
            withAnimation(.spring(response: 0.05, dampingFraction: 0.6)) {
                slideOffset = 0
            }
        }
    }

}
