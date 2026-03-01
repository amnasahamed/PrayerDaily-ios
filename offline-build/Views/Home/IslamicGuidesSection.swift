import SwiftUI

// MARK: - Category Model
private struct GuideCategory: Identifiable {
    let id: String
    let title: String
    let guides: [EmergencyGuide]
}

// MARK: - Category assignment
private let categoryMap: [String: String] = [
    "Wudu (Ablution)":            "Purification",
    "Ghusl (Ritual Bath)":        "Purification",
    "Tayammum (Dry Ablution)":    "Purification",
    "Salah (Prayer)":             "Prayer",
    "Janazah Prayer":             "Prayer",
    "Zakat Calculation":          "Finance & Fiqh",
    "Islamic Inheritance (Mirath)": "Finance & Fiqh",
    "Essential Duas":             "Supplications",
]

private let categoryOrder: [String] = ["Purification", "Prayer", "Finance & Fiqh", "Supplications"]

// MARK: - Per-guide icon + accent (all valid SF Symbols)
private let guideIconMap: [String: (icon: String, accent: Color)] = [
    "Wudu (Ablution)":              ("hand.raised.fill",       Color.alehaGreen),
    "Ghusl (Ritual Bath)":          ("drop.fill",              Color(red: 0.20, green: 0.55, blue: 0.85)),
    "Tayammum (Dry Ablution)":      ("sun.dust.fill",          Color.alehaAmber),
    "Salah (Prayer)":               ("figure.stand",           Color(red: 0.42, green: 0.28, blue: 0.82)),
    "Janazah Prayer":               ("heart.fill",             Color(red: 0.68, green: 0.28, blue: 0.50)),
    "Zakat Calculation":            ("banknote.fill",          Color(red: 0.18, green: 0.55, blue: 0.42)),
    "Islamic Inheritance (Mirath)": ("scroll.fill",            Color(red: 0.75, green: 0.42, blue: 0.18)),
    "Essential Duas":               ("hands.sparkles.fill",    Color(red: 0.80, green: 0.36, blue: 0.20)),
]

// MARK: - Main Section
struct IslamicGuidesSection: View {
    private var categories: [GuideCategory] {
        var buckets: [String: [EmergencyGuide]] = [:]
        for guide in EmergencyGuideData.allGuides {
            let cat = categoryMap[guide.title] ?? "Other"
            buckets[cat, default: []].append(guide)
        }
        return categoryOrder.compactMap { name in
            guard let guides = buckets[name], !guides.isEmpty else { return nil }
            return GuideCategory(id: name, title: name, guides: guides)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(categories) { category in
                CategoryShelf(category: category)
            }
        }
    }
}

// MARK: - One horizontal shelf per category
private struct CategoryShelf: View {
    let category: GuideCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Category header
            HStack {
                Text(category.title.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .kerning(1.0)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("See all →")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.alehaGreen)
            }

            // Horizontal scroll — breaks out of parent horizontal padding
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(category.guides) { guide in
                        NavigationLink(destination: GuideDetailView(guide: guide)) {
                            GuideShelfCard(guide: guide)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.vertical, 3)
            }
            .padding(.horizontal, -AppTheme.screenPadding)
        }
    }
}

// MARK: - Individual guide card (uniform size)
private struct GuideShelfCard: View {
    let guide: EmergencyGuide
    @Environment(\.colorScheme) var cs

    private var accent: Color {
        guideIconMap[guide.title]?.accent ?? Color.alehaGreen
    }
    private var icon: String {
        guideIconMap[guide.title]?.icon ?? guide.icon
    }
    private var stepCount: Int {
        guide.sections.flatMap(\.steps).count
    }
    private var readTime: String {
        let mins = max(1, stepCount / 3)
        return "\(mins) min"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Icon area
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(accent)
            }
            .padding(.bottom, 12)

            // Title
            Text(guide.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 8)

            // Footer: steps + read time
            HStack(spacing: 4) {
                Text("\(stepCount) steps")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(accent)
                Text("·")
                    .font(.system(size: 11))
                    .foregroundStyle(.quaternary)
                Text(readTime)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .frame(width: 130, height: 140)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cs == .dark ? Color(.systemGray6) : .white)
                .shadow(color: accent.opacity(cs == .dark ? 0.0 : 0.10), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.12), lineWidth: 1)
        )
    }
}


