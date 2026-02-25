import SwiftUI

struct DhikrCounterView: View {
    @EnvironmentObject var store: SalahStore
    @State private var activeDhikrID: UUID?

    var body: some View {
        if let activeID = activeDhikrID,
           let idx = store.dhikrPresets.firstIndex(where: { $0.id == activeID }) {
            DhikrFullScreen(
                preset: store.dhikrPresets[idx],
                lifetimeCount: store.dhikrLifetimeCounts[store.dhikrPresets[idx].id, default: 0],
                onTap: { store.incrementDhikr(activeID) },
                onReset: { store.resetDhikr(activeID) },
                onDismiss: { withAnimation { activeDhikrID = nil } }
            )
        } else {
            dhikrList
        }
    }

    // MARK: - List View
    private var dhikrList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: AppTheme.sectionSpacing) {
                statsHeader
                ForEach(store.dhikrPresets) { preset in
                    dhikrCard(preset)
                }
                streakCard
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 4)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Stats Header
    private var statsHeader: some View {
        VStack(spacing: 14) {
            HStack(spacing: 0) {
                statBlock(value: "\(store.dhikrTodayTotal)", label: "Today's Dhikr", color: Color("NoorGold"))
                Divider().frame(height: 44)
                statBlock(value: "\(store.dhikrWeeklyTotal)", label: "This Week", color: Color("NoorPrimary"))
                Divider().frame(height: 44)
                statBlock(value: formatLifetime(store.dhikrLifetimeTotal), label: "Lifetime", color: Color("NoorAccent"))
            }
            if store.dhikrTodayTotal > 0 {
                Text("\"Remember Allah and He will remember you.\" — Quran 2:152")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .italic()
            }
        }
        .noorCard()
    }

    private func statBlock(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatLifetime(_ n: Int) -> String {
        n >= 1000 ? "\(n / 1000)k" : "\(n)"
    }

    // MARK: - Dhikr Card
    private func dhikrCard(_ preset: DhikrPreset) -> some View {
        let progress = preset.target > 0 ? Double(preset.currentCount) / Double(preset.target) : 0
        let accentColor = Color(preset.color)
        let isComplete = preset.currentCount >= preset.target

        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.4)) { activeDhikrID = preset.id }
        } label: {
            HStack(spacing: 16) {
                circularProgress(progress, color: accentColor, count: preset.currentCount, complete: isComplete)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(preset.name).font(.body.weight(.semibold)).foregroundStyle(.primary)
                        if isComplete {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color("NoorGold"))
                                .font(.caption)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    Text(preset.arabic)
                        .font(.title3)
                        .foregroundStyle(.primary.opacity(0.7))
                    progressMiniBar(progress, color: accentColor)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(preset.currentCount)/\(preset.target)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(isComplete ? Color("NoorGold") : accentColor)
                        .contentTransition(.numericText())
                    Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
                }
            }
            .noorCard()
        }
        .buttonStyle(SpringPressStyle())
    }

    private func progressMiniBar(_ value: Double, color: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2).fill(Color(.systemGray5)).frame(height: 3)
                RoundedRectangle(cornerRadius: 2).fill(color)
                    .frame(width: geo.size.width * min(value, 1.0), height: 3)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: value)
            }
        }
        .frame(height: 3)
        .frame(maxWidth: 120)
    }

    private func circularProgress(_ value: Double, color: Color, count: Int, complete: Bool) -> some View {
        ZStack {
            Circle().stroke(Color(.systemGray5), lineWidth: 5)
            Circle()
                .trim(from: 0, to: min(value, 1.0))
                .stroke(complete ? Color("NoorGold") : color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: value)
            Text("\(count)")
                .font(.caption.weight(.bold).monospacedDigit())
                .contentTransition(.numericText())
        }
        .frame(width: 50, height: 50)
        .pulseGlow(color, active: value > 0 && !complete)
    }

    // MARK: - Streak Card
    private var streakCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(Color.alehaAmber)
            VStack(alignment: .leading, spacing: 3) {
                Text("Daily Dhikr Streak")
                    .font(.subheadline.weight(.semibold))
                Text("Complete all Dhikr targets each day to build your streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            let allComplete = store.dhikrPresets.allSatisfy { $0.currentCount >= $0.target }
            HStack(spacing: 4) {
                if allComplete {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.alehaGreen)
                } else {
                    Text("\(store.currentStreak)d")
                }
            }
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(allComplete ? Color.alehaGreen : Color.alehaAmber)
        }
        .noorCard()
    }
}

// MARK: - Full Screen Dhikr Counter
struct DhikrFullScreen: View {
    let preset: DhikrPreset
    let lifetimeCount: Int
    let onTap: () -> Void
    let onReset: () -> Void
    let onDismiss: () -> Void

    @State private var tapScale: CGFloat = 1.0
    @State private var showShare = false

    private var progress: Double {
        preset.target > 0 ? Double(preset.currentCount) / Double(preset.target) : 0
    }
    private var isComplete: Bool { preset.currentCount >= preset.target }
    private let accentColor: Color
    private let lifetimeStr: String

    init(preset: DhikrPreset, lifetimeCount: Int, onTap: @escaping () -> Void, onReset: @escaping () -> Void, onDismiss: @escaping () -> Void) {
        self.preset = preset
        self.lifetimeCount = lifetimeCount
        self.onTap = onTap
        self.onReset = onReset
        self.onDismiss = onDismiss
        self.accentColor = Color(preset.color)
        self.lifetimeStr = lifetimeCount >= 1000 ? "\(lifetimeCount / 1000)k" : "\(lifetimeCount)"
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Spacer()
            arabicText
            Spacer().frame(height: 24)
            counterCircle
            Spacer().frame(height: 12)
            tapHint
            Spacer()
            bottomBar
        }
        .padding(AppTheme.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("NoorSurface").ignoresSafeArea())
        .sheet(isPresented: $showShare) { shareSheet }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button("Done", action: onDismiss)
                .foregroundStyle(Color("NoorPrimary"))
            Spacer()
            VStack(spacing: 2) {
                Text(preset.name).font(.headline)
                Text("Lifetime: \(lifetimeStr)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button { onReset() } label: {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Arabic
    private var arabicText: some View {
        Text(preset.arabic)
            .font(.system(size: 42, design: .serif))
            .multilineTextAlignment(.center)
    }

    // MARK: - Counter
    private var counterCircle: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 12)
            // Fill track
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    isComplete ? Color("NoorGold") : accentColor,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.25, dampingFraction: 0.65), value: preset.currentCount)
                .pulseGlow(accentColor, active: !isComplete && preset.currentCount > 0)
            // Center content
            VStack(spacing: 4) {
                Text("\(preset.currentCount)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.2), value: preset.currentCount)
                Text("of \(preset.target)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if isComplete {
                    Text("ماشاء الله")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color("NoorGold"))
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: 210, height: 210)
        .scaleEffect(tapScale)
        .onTapGesture { handleTap() }
    }

    private var tapHint: some View {
        Text(isComplete ? "Target reached! Tap to continue" : "Tap the circle to count")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .padding(.top, 4)
    }

    private func handleTap() {
        onTap()
        // Graduated haptic: heavier when complete milestone hit
        let style: UIImpactFeedbackGenerator.FeedbackStyle = isComplete ? .heavy : (preset.currentCount % 10 == 9 ? .medium : .light)
        UIImpactFeedbackGenerator(style: style).impactOccurred()
        // Pulse scale
        withAnimation(.spring(response: 0.10, dampingFraction: 0.38)) { tapScale = 1.08 }
        withAnimation(.spring(response: 0.22).delay(0.08)) { tapScale = 1.0 }
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 12) {
            Button { handleTap() } label: {
                HStack {
                    Image(systemName: "hand.tap.fill")
                    Text("Tap to Count")
                        .font(.headline)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isComplete ? Color("NoorGold") : accentColor)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            }
            Button {
                showShare = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Progress")
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(accentColor)
            }
        }
    }

    // MARK: - Share Sheet
    private var shareSheet: some View {
        let shareText = "I completed \(preset.currentCount) \(preset.name) today 🌿\n\(preset.arabic)\n\n— via Noor App"
        return ShareLink(item: shareText) {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .presentationDetents([.height(200)])
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let shareVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let root = scene.windows.first?.rootViewController {
                    root.present(shareVC, animated: true)
                }
                showShare = false
            }
        }
    }
}
