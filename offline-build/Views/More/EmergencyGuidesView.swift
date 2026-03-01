import SwiftUI

// MARK: - Shared icon/accent lookup
let guideIconAccentMap: [String: (icon: String, accent: Color)] = [
    "Wudu (Ablution)":              ("hand.raised.fill",       Color(red: 0.14, green: 0.65, blue: 0.45)),
    "Ghusl (Ritual Bath)":          ("drop.fill",              Color(red: 0.20, green: 0.50, blue: 0.88)),
    "Tayammum (Dry Ablution)":      ("sun.dust.fill",          Color(red: 0.82, green: 0.60, blue: 0.18)),
    "Salah (Prayer)":               ("figure.stand",           Color(red: 0.45, green: 0.30, blue: 0.85)),
    "Janazah Prayer":               ("heart.fill",             Color(red: 0.70, green: 0.28, blue: 0.52)),
    "Zakat Calculation":            ("banknote.fill",          Color(red: 0.16, green: 0.58, blue: 0.40)),
    "Islamic Inheritance (Mirath)": ("scroll.fill",            Color(red: 0.72, green: 0.40, blue: 0.16)),
    "Essential Duas":               ("hands.sparkles.fill",    Color(red: 0.78, green: 0.34, blue: 0.22)),
    "Ruqyah (Healing Recitation)":  ("waveform.path.ecg",      Color(red: 0.20, green: 0.50, blue: 0.88)),
    "Travel Prayer (Qasr)":         ("airplane",               Color(red: 0.14, green: 0.65, blue: 0.45)),
    "Fasting (Sawm)":               ("moon.stars.fill",        Color(red: 0.52, green: 0.22, blue: 0.78)),
]

// MARK: - Guide List
struct EmergencyGuidesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(EmergencyGuideData.allGuides) { guide in
                    NavigationLink(destination: GuideDetailView(guide: guide)) {
                        GuideCard(guide: guide)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Islamic Guides")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Guide Card
struct GuideCard: View {
    let guide: EmergencyGuide
    @Environment(\.colorScheme) var cs

    private var icon: String { guideIconAccentMap[guide.title]?.icon ?? guide.icon }
    private var accent: Color { guideIconAccentMap[guide.title]?.accent ?? .green }
    private var stepCount: Int { guide.sections.flatMap(\.steps).count }
    private var sectionCount: Int { guide.sections.count }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(accent.opacity(0.13))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(accent)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(guide.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(guide.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Label("\(stepCount) steps", systemImage: "list.number")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(accent)
                    Text("·")
                        .font(.caption2)
                        .foregroundStyle(.quaternary)
                    Label("\(sectionCount) sections", systemImage: "rectangle.grid.1x2")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cs == .dark ? Color(.secondarySystemGroupedBackground) : .white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(accent.opacity(0.10), lineWidth: 1)
        )
    }
}

// MARK: - Guide Detail
struct GuideDetailView: View {
    let guide: EmergencyGuide
    @State private var isMalayalam = false
    @Environment(\.colorScheme) var cs

    private var icon: String { guideIconAccentMap[guide.title]?.icon ?? guide.icon }
    private var accent: Color { guideIconAccentMap[guide.title]?.accent ?? .green }
    private var totalSteps: Int { guide.sections.flatMap(\.steps).count }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                heroHeader
                    .padding(.bottom, 24)
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(Array(guide.sections.enumerated()), id: \.element.id) { idx, section in
                        SectionBlock(
                            section: section,
                            sectionIndex: idx,
                            accent: accent,
                            isMalayalam: isMalayalam
                        )
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 48)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(isMalayalam ? guide.titleMl : guide.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                BilingualToggle(isMalayalam: $isMalayalam)
            }
        }
    }

    private var heroHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.08))
                    .frame(width: 90, height: 90)
                Circle()
                    .fill(accent.opacity(0.15))
                    .frame(width: 72, height: 72)
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(accent)
            }
            VStack(spacing: 4) {
                Text(isMalayalam ? guide.titleMl : guide.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                Text(isMalayalam ? guide.subtitleMl : guide.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            HStack(spacing: 16) {
                statPill(icon: "list.number", value: "\(totalSteps)", label: "Steps")
                statPill(icon: "rectangle.grid.1x2", value: "\(guide.sections.count)", label: "Sections")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, AppTheme.screenPadding)
        .background(
            LinearGradient(
                colors: [accent.opacity(0.16), accent.opacity(0.04)],
                startPoint: .top, endPoint: .bottom
            )
        )
        .animation(.easeInOut(duration: 0.2), value: isMalayalam)
    }

    @ViewBuilder
    private func statPill(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(accent)
            Text("\(value) \(label)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(accent.opacity(0.10))
        .clipShape(Capsule())
    }
}

// MARK: - Bilingual Toggle
struct BilingualToggle: View {
    @Binding var isMalayalam: Bool

    var body: some View {
        HStack(spacing: 0) {
            langBtn("EN", active: !isMalayalam) { isMalayalam = false }
            langBtn("മ", active: isMalayalam)  { isMalayalam = true }
        }
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func langBtn(_ label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) { action() }
        } label: {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(active ? .white : .secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(active ? Color.accentColor : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 7))
        }
    }
}

// MARK: - Section Block
struct SectionBlock: View {
    let section: GuideSection
    let sectionIndex: Int
    let accent: Color
    let isMalayalam: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader
            VStack(spacing: 10) {
                ForEach(Array(section.steps.enumerated()), id: \.element.id) { idx, step in
                    StepRow(
                        step: step,
                        globalIndex: idx,
                        accent: accent,
                        isMalayalam: isMalayalam
                    )
                }
            }
        }
    }

    private var sectionHeader: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.15))
                    .frame(width: 28, height: 28)
                Text("\(sectionIndex + 1)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(accent)
            }
            Text(isMalayalam ? section.headingMl : section.heading)
                .font(.headline.weight(.bold))
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Step Row
struct StepRow: View {
    let step: GuideStep
    let globalIndex: Int
    let accent: Color
    let isMalayalam: Bool
    @Environment(\.colorScheme) var cs

    private var cardBg: Color { cs == .dark ? Color(.secondarySystemGroupedBackground) : .white }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            mainContent
            if let arabic = step.arabic {
                arabicPanel(arabic)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accent.opacity(0.12), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.18), value: isMalayalam)
    }

    private var mainContent: some View {
        HStack(alignment: .top, spacing: 12) {
            numberBadge
            VStack(alignment: .leading, spacing: 5) {
                Text(isMalayalam ? step.titleMl : step.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(isMalayalam ? step.detailMl : step.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(14)
    }

    private var numberBadge: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.13))
                .frame(width: 28, height: 28)
            Text("\(step.number)")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accent)
        }
        .frame(width: 28, height: 28)
        .padding(.top, 1)
    }

    @ViewBuilder
    private func arabicPanel(_ text: String) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(accent.opacity(0.12))
                .frame(height: 1)
            Text(text)
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(accent)
                .multilineTextAlignment(.trailing)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(accent.opacity(0.05))
        }
    }
}
