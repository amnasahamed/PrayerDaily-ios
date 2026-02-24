import SwiftUI

struct DhikrCounterView: View {
    @EnvironmentObject var store: SalahStore
    @State private var activeDhikrID: UUID?

    var body: some View {
        if let activeID = activeDhikrID,
           let idx = store.dhikrPresets.firstIndex(where: { $0.id == activeID }) {
            DhikrFullScreen(preset: store.dhikrPresets[idx]) {
                store.incrementDhikr(activeID)
            } onReset: {
                store.resetDhikr(activeID)
            } onDismiss: {
                withAnimation { activeDhikrID = nil }
            }
        } else {
            dhikrList
        }
    }

    private var dhikrList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                headerCard
                ForEach(store.dhikrPresets) { preset in
                    dhikrCard(preset)
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.bottom, 30)
        }
    }

    private var headerCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "hands.sparkles.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color("NoorGold"))
            Text("Dhikr & Tasbih")
                .font(.headline)
            Text("Tap a dhikr to begin counting")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    private func dhikrCard(_ preset: DhikrPreset) -> some View {
        let progress = preset.target > 0 ? Double(preset.currentCount) / Double(preset.target) : 0
        let accentColor = Color(preset.color)

        return Button {
            withAnimation(.spring(response: 0.4)) { activeDhikrID = preset.id }
        } label: {
            HStack(spacing: 16) {
                circularProgress(progress, color: accentColor, count: preset.currentCount)
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(preset.arabic)
                        .font(.title3)
                        .foregroundStyle(.primary.opacity(0.7))
                    Text("Target: \(preset.target)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .noorCard()
        }
        .buttonStyle(.plain)
    }

    private func circularProgress(_ value: Double, color: Color, count: Int) -> some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 5)
            Circle()
                .trim(from: 0, to: min(value, 1.0))
                .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(count)")
                .font(.caption.weight(.bold).monospacedDigit())
        }
        .frame(width: 50, height: 50)
    }
}

// MARK: - Full Screen Dhikr
struct DhikrFullScreen: View {
    let preset: DhikrPreset
    let onTap: () -> Void
    let onReset: () -> Void
    let onDismiss: () -> Void

    @State private var tapScale: CGFloat = 1.0

    private var progress: Double {
        preset.target > 0 ? Double(preset.currentCount) / Double(preset.target) : 0
    }
    private var isComplete: Bool { preset.currentCount >= preset.target }

    var body: some View {
        VStack(spacing: 30) {
            topBar
            Spacer()
            arabicText
            counterSection
            Spacer()
            bottomControls
        }
        .padding(AppTheme.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("NoorSurface").ignoresSafeArea())
    }

    private var topBar: some View {
        HStack {
            Button("Done", action: onDismiss)
                .foregroundStyle(Color("NoorPrimary"))
            Spacer()
            Text(preset.name)
                .font(.headline)
            Spacer()
            Button { onReset() } label: {
                Image(systemName: "arrow.counterclockwise")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var arabicText: some View {
        Text(preset.arabic)
            .font(.system(size: 40, design: .serif))
            .multilineTextAlignment(.center)
    }

    private var counterSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        isComplete ? Color("NoorGold") : Color(preset.color),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.3), value: preset.currentCount)

                VStack(spacing: 4) {
                    Text("\(preset.currentCount)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                    Text("of \(preset.target)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 180, height: 180)
            .scaleEffect(tapScale)
            .onTapGesture {
                onTap()
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                    tapScale = 1.08
                }
                withAnimation(.spring(response: 0.15).delay(0.1)) {
                    tapScale = 1.0
                }
            }

            Text("Tap the circle to count")
                .font(.caption)
                .foregroundStyle(.tertiary)

            if isComplete {
                Label("Target reached! ماشاء الله", systemImage: "checkmark.seal.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color("NoorGold"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    private var bottomControls: some View {
        Button {
            onTap()
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                tapScale = 1.05
            }
            withAnimation(.spring(response: 0.15).delay(0.1)) {
                tapScale = 1.0
            }
        } label: {
            Text("Tap to Count")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(preset.color))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
    }
}
