import SwiftUI

// MARK: - Category Model
private struct GuideCategory: Identifiable {
    let id: String
    let title: String
    let guides: [EmergencyGuide]
}

// MARK: - Category assignment
private let categoryMap: [String: String] = [
    "Wudu (Ablution)":                "Purification",
    "Ghusl (Ritual Bath)":            "Purification",
    "Tayammum (Dry Ablution)":        "Purification",
    "Salah (Prayer)":                 "Prayer",
    "Janazah Prayer":                 "Prayer",
    "Travel Prayer (Qasr)":           "Prayer",
    "Ruqyah (Healing Recitation)":    "Supplications",
    "Essential Duas":                 "Supplications",
    "Fasting (Sawm)":                 "Worship",
    "Zakat Calculation":              "Finance & Fiqh",
    "Islamic Inheritance (Mirath)":   "Finance & Fiqh",
]

private let categoryOrder: [String] = ["Purification", "Prayer", "Worship", "Finance & Fiqh", "Supplications"]

private let categoryIcons: [String: String] = [
    "Purification":    "drop.fill",
    "Prayer":          "figure.stand",
    "Worship":         "moon.stars.fill",
    "Finance & Fiqh":  "banknote.fill",
    "Supplications":   "hands.sparkles.fill",
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

// MARK: - Horizontal shelf per category
private struct CategoryShelf: View {
    let category: GuideCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: categoryIcons[category.title] ?? "book.fill")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(category.title.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .kerning(0.8)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, AppTheme.screenPadding)

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
                .padding(.vertical, 4)
            }
            .padding(.horizontal, -AppTheme.screenPadding)
        }
    }
}

// MARK: - Individual guide card
private struct GuideShelfCard: View {
    let guide: EmergencyGuide
    @Environment(\.colorScheme) var cs

    private var accent: Color { guideIconAccentMap[guide.title]?.accent ?? .green }
    private var icon: String   { guideIconAccentMap[guide.title]?.icon ?? guide.icon }
    private var stepCount: Int { guide.sections.flatMap(\.steps).count }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.13))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(accent)
            }
            .padding(.bottom, 10)

            // Title
            Text(guide.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 10)

            // Footer
            HStack(spacing: 4) {
                Image(systemName: "list.number")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(accent)
                Text("\(stepCount) steps")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(accent)
            }
            .padding(.top, 2)
        }
        .padding(14)
        .frame(width: 132, height: 145)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(cs == .dark ? Color(.secondarySystemGroupedBackground) : .white)
                .shadow(color: accent.opacity(cs == .dark ? 0 : 0.10), radius: 8, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(accent.opacity(0.10), lineWidth: 1)
        )
    }
}
