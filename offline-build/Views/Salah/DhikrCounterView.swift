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
            VStack(spacing: 16) {
                statsHeader
                ForEach(store.dhikrPresets) { preset in
                    dhikrCard(preset)
                }
                streakCard
            }
            .padding(.horizontal, AppTheme.screenPadding)
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
                        }
                    }
                    Text(preset.arabic)
                        .font(.title3)
                        .foregroundStyle(.primary.opacity(0.7))
                    Text("Target: \(preset.target)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
            .noorCard()
        }
        .buttonStyle(.plain)
    }

    private func circularProgress(_ value: Double, color: Color, count: Int, complete: Bool) -> some View {
        ZStack {
            Circle().stroke(Color(.systemGray5), lineWidth: 5)
            Circle()
                .trim(from: 0, to: min(value, 1.0))
                .stroke(complete ? Color("NoorGold") : color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(count)")
                .font(.caption.weight(.bold).monospacedDigit())
        }
        .frame(width: 50, height: 50)
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
            Text(allComplete ? "✅ Done!" : "\(store.currentStreak)d")
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
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 10)
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    isComplete ? Color("NoorGold") : accentColor,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.3), value: preset.currentCount)

            VStack(spacing: 4) {
                Text("\(preset.currentCount)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("of \(preset.target)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if isComplete {
                    Text("ماشاء الله ✨")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color("NoorGold"))
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(width: 200, height: 200)
        .scaleEffect(tapScale)
        .onTapGesture { handleTap() }
    }

    private var tapHint: some View {
        Text(isComplete ? "Target reached! Tap to continue" : "Tap the circle to count")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }

    private func handleTap() {
        onTap()
        let style: UIImpactFeedbackGenerator.FeedbackStyle = isComplete ? .heavy : .medium
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
        withAnimation(.spring(response: 0.12, dampingFraction: 0.4)) { tapScale = 1.1 }
        withAnimation(.spring(response: 0.2).delay(0.1)) { tapScale = 1.0 }
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
