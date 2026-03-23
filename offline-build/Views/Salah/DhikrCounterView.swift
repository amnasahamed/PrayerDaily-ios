import SwiftUI

// MARK: - Dhikr Counter View (tap-focused single-dhikr mode)
struct DhikrCounterView: View {
    @EnvironmentObject var store: SalahStore
    @State private var currentIndex: Int = 0
    @State private var showOverview = false
    @State private var tapScale: CGFloat = 1.0
    @State private var ringPulse = false

    private var preset: DhikrPreset { store.dhikrPresets[currentIndex] }
    private var progress: Double {
        preset.target > 0 ? Double(preset.currentCount) / Double(preset.target) : 0
    }
    private var isComplete: Bool { preset.currentCount >= preset.target }
    private var accentColor: Color { Color(preset.color) }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                statsHeader
                Spacer()
                arabicDisplay
                Spacer().frame(height: 32)
                tapCircle
                Spacer().frame(height: 16)
                tapHintLabel
                Spacer()
                swipeNavigation
                bottomActions
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 12)
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showOverview) {
            DhikrOverviewSheet(store: store, currentIndex: $currentIndex)
        }
    }

    // MARK: - Stats Header
    private var statsHeader: some View {
        HStack(spacing: 0) {
            statBlock(value: "\(store.dhikrTodayTotal)", label: "Today", color: Color.alehaAmber)
            Divider().frame(height: 36)
            statBlock(value: "\(store.dhikrSessionTotal)", label: "Session", color: Color.alehaGreen)
            Divider().frame(height: 36)
            statBlock(value: formatLifetime(store.dhikrLifetimeTotal), label: "Lifetime", color: Color.alehaSaffron)
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.5))
        )
        .padding(.top, 8)
    }

    private func statBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Arabic Display (primary, large)
    private var arabicDisplay: some View {
        VStack(spacing: 12) {
            Text(preset.arabic)
                .font(.system(size: 44, weight: .regular, design: .serif))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .lineSpacing(10)
                .padding(.horizontal, 8)
            Text(preset.name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Tap Circle with Arc
    private var tapCircle: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 14)
            // Progress arc
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    isComplete ? Color.alehaAmber : accentColor,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.25, dampingFraction: 0.65), value: preset.currentCount)
            // Pulse ring when active
            if !isComplete && preset.currentCount > 0 {
                Circle()
                    .stroke(accentColor.opacity(ringPulse ? 0 : 0.25), lineWidth: 2)
                    .scaleEffect(ringPulse ? 1.18 : 1.0)
                    .animation(.easeOut(duration: 1.1).repeatForever(autoreverses: false), value: ringPulse)
                    .onAppear { ringPulse = true }
            }
            // Center count
            VStack(spacing: 4) {
                Text("\(preset.currentCount)")
                    .font(.system(size: 62, weight: .bold, design: .rounded))
                    .foregroundStyle(isComplete ? Color.alehaAmber : .primary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.2), value: preset.currentCount)
                Text("of \(preset.target)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if isComplete {
                    Text(preset.completionText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.alehaAmber)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: 220, height: 220)
        .scaleEffect(tapScale)
        .onTapGesture { handleTap() }
    }

    private var tapHintLabel: some View {
        Text(isComplete ? "Target reached! Tap to continue" : "Tap circle to count")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }

    // MARK: - Swipe Navigation dots
    private var swipeNavigation: some View {
        HStack(spacing: 20) {
            Button {
                guard currentIndex > 0 else { return }
                withAnimation(.spring(response: 0.3)) { currentIndex -= 1 }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(currentIndex == 0 ? Color(.systemGray4) : Color.alehaGreen)
            }
            HStack(spacing: 7) {
                ForEach(store.dhikrPresets.indices, id: \.self) { i in
                    let done = store.dhikrPresets[i].currentCount >= store.dhikrPresets[i].target
                    Circle()
                        .fill(i == currentIndex ? accentColor : (done ? Color.alehaAmber : Color(.systemGray4)))
                        .frame(width: i == currentIndex ? 9 : 7, height: i == currentIndex ? 9 : 7)
                        .animation(.spring(response: 0.3), value: currentIndex)
                }
            }
            Button {
                guard currentIndex < store.dhikrPresets.count - 1 else { return }
                withAnimation(.spring(response: 0.3)) { currentIndex += 1 }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(currentIndex == store.dhikrPresets.count - 1 ? Color(.systemGray4) : Color.alehaGreen)
            }
        }
        .padding(.bottom, 16)
    }

    // MARK: - Bottom Actions
    private var bottomActions: some View {
        HStack(spacing: 12) {
            Button {
                store.resetDhikr(preset.id)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.systemGray5).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showOverview = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                    Text("All Dhikr")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.bottom, 20)
    }

    // MARK: - Helpers
    private func handleTap() {
        store.incrementDhikr(preset.id)
        let style: UIImpactFeedbackGenerator.FeedbackStyle = isComplete ? .heavy : (preset.currentCount % 10 == 9 ? .medium : .light)
        UIImpactFeedbackGenerator(style: style).impactOccurred()
        withAnimation(.spring(response: 0.10, dampingFraction: 0.38)) { tapScale = 1.07 }
        withAnimation(.spring(response: 0.22).delay(0.08)) { tapScale = 1.0 }
    }

    private func formatLifetime(_ n: Int) -> String {
        n >= 1000 ? "\(n / 1000)k" : "\(n)"
    }
}

// MARK: - Overview Sheet
struct DhikrOverviewSheet: View {
    @ObservedObject var store: SalahStore
    @Binding var currentIndex: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(Array(store.dhikrPresets.enumerated()), id: \.element.id) { i, preset in
                        let progress = preset.target > 0 ? Double(preset.currentCount) / Double(preset.target) : 0
                        let isComplete = preset.currentCount >= preset.target
                        let accent = Color(preset.color)
                        Button {
                            currentIndex = i
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle().stroke(Color(.systemGray5), lineWidth: 4)
                                    Circle()
                                        .trim(from: 0, to: min(progress, 1.0))
                                        .stroke(isComplete ? Color.alehaAmber : accent,
                                                style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                    Text("\(preset.currentCount)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(isComplete ? Color.alehaAmber : accent)
                                }
                                .frame(width: 44, height: 44)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(preset.arabic)
                                        .font(.system(size: 22, design: .serif))
                                        .foregroundStyle(.primary)
                                    Text(preset.name)
                                        .font(.caption.weight(.medium))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(preset.currentCount)/\(preset.target)")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(isComplete ? Color.alehaAmber : accent)
                                    if isComplete {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(Color.alehaAmber)
                                    }
                                }
                            }
                            .padding(14)
                            .background(Color(.systemGray6).opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
            .navigationTitle("Session Overview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.alehaGreen)
                }
            }
        }
    }
}
