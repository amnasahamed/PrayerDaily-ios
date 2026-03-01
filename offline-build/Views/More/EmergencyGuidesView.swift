import SwiftUI

// MARK: - Shared icon/accent lookup (mirrors IslamicGuidesSection)
let guideIconAccentMap: [String: (icon: String, accent: Color)] = [
    "Wudu (Ablution)":              ("hand.raised.fill",    Color.alehaGreen),
    "Ghusl (Ritual Bath)":          ("drop.fill",           Color(red: 0.20, green: 0.55, blue: 0.85)),
    "Tayammum (Dry Ablution)":      ("sun.dust.fill",       Color.alehaAmber),
    "Salah (Prayer)":               ("figure.stand",        Color(red: 0.42, green: 0.28, blue: 0.82)),
    "Janazah Prayer":               ("heart.fill",          Color(red: 0.68, green: 0.28, blue: 0.50)),
    "Zakat Calculation":            ("banknote.fill",       Color(red: 0.18, green: 0.55, blue: 0.42)),
    "Islamic Inheritance (Mirath)": ("scroll.fill",         Color(red: 0.75, green: 0.42, blue: 0.18)),
    "Essential Duas":               ("hands.sparkles.fill", Color(red: 0.80, green: 0.36, blue: 0.20)),
]

// MARK: - Guide List
struct EmergencyGuidesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(EmergencyGuideData.allGuides) { guide in
                    NavigationLink(destination: GuideDetailView(guide: guide)) {
                        GuideCard(guide: guide)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppTheme.screenPadding)
            .padding(.bottom, 20)
        }
        .background(Color("NoorSurface").ignoresSafeArea())
        .navigationTitle("Islamic Guides")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GuideCard: View {
    let guide: EmergencyGuide
    @Environment(\.colorScheme) var cs

    private var icon: String { guideIconAccentMap[guide.title]?.icon ?? guide.icon }
    private var accent: Color { guideIconAccentMap[guide.title]?.accent ?? Color.alehaGreen }
    private var stepCount: Int { guide.sections.flatMap(\.steps).count }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(accent)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(guide.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(guide.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(stepCount)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(accent)
                Text("steps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .padding(.leading, 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cs == .dark ? Color(.systemGray6) : .white)
                .shadow(color: accent.opacity(cs == .dark ? 0 : 0.08), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(accent.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Guide Detail
struct GuideDetailView: View {
    let guide: EmergencyGuide
    @State private var isMalayalam = false

    private var icon: String { guideIconAccentMap[guide.title]?.icon ?? guide.icon }
    private var accent: Color { guideIconAccentMap[guide.title]?.accent ?? Color.alehaGreen }
    private var totalSteps: Int { guide.sections.flatMap(\.steps).count }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerBanner
                ForEach(guide.sections) { section in
                    SectionBlock(section: section, accent: accent, isMalayalam: isMalayalam)
                }
            }
            .padding(AppTheme.screenPadding)
            .padding(.bottom, 40)
        }
        .background(Color("NoorSurface").ignoresSafeArea())
        .navigationTitle(isMalayalam ? guide.titleMl : guide.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                BilingualToggle(isMalayalam: $isMalayalam)
            }
        }
    }

    private var headerBanner: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(accent.opacity(0.12))
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(accent)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(isMalayalam ? guide.titleMl : guide.title)
                    .font(.title3.weight(.bold))
                Text(isMalayalam ? guide.subtitleMl : guide.subtitle)
                    .font(.subheadline).foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "list.number")
                        .font(.caption2)
                        .foregroundStyle(accent)
                    Text("\(totalSteps) steps · \(guide.sections.count) sections")
                        .font(.caption)
                        .foregroundStyle(accent)
                }
                .padding(.top, 2)
            }
            Spacer()
        }
        .padding(16)
        .background(accent.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(accent.opacity(0.12), lineWidth: 1))
        .animation(.easeInOut(duration: 0.2), value: isMalayalam)
    }
}

// MARK: - Bilingual Toggle
struct BilingualToggle: View {
    @Binding var isMalayalam: Bool

    var body: some View {
        HStack(spacing: 0) {
            langButton(label: "EN", active: !isMalayalam) { isMalayalam = false }
            langButton(label: "മ", active: isMalayalam) { isMalayalam = true }
        }
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func langButton(label: String, active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.2)) { action() } }) {
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

struct SectionBlock: View {
    let section: GuideSection
    let accent: Color
    let isMalayalam: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(accent)
                    .frame(width: 3, height: 16)
                Text(isMalayalam ? section.headingMl : section.heading)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(accent)
            }
            ForEach(section.steps) { step in
                StepRow(step: step, accent: accent, isMalayalam: isMalayalam)
            }
        }
    }
}

struct StepRow: View {
    let step: GuideStep
    let accent: Color
    let isMalayalam: Bool
    @Environment(\.colorScheme) var cs

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Text("\(step.number)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(accent)
                    .clipShape(Circle())
                    .padding(.top, 1)
                VStack(alignment: .leading, spacing: 4) {
                    Text(isMalayalam ? step.titleMl : step.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(isMalayalam ? step.detailMl : step.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if let arabic = step.arabic {
                Text(arabic)
                    .font(.system(size: 18))
                    .foregroundStyle(accent)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(12)
                    .background(accent.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(14)
        .background(cs == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(accent.opacity(0.08), lineWidth: 1))
        .animation(.easeInOut(duration: 0.2), value: isMalayalam)
    }
}
