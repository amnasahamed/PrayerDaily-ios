import SwiftUI

// MARK: - Category Model
private struct GuideCategory: Identifiable {
    let id: String
    let titleKey: LocalizedKey
    let guides: [EmergencyGuide]
}

// MARK: - Category assignment
private let categoryMap: [String: LocalizedKey] = [
    "Wudu (Ablution)":                .guideCategoryPurification,
    "Ghusl (Ritual Bath)":            .guideCategoryPurification,
    "Tayammum (Dry Ablution)":        .guideCategoryPurification,
    "Salah (Prayer)":                  .guideCategoryPrayer,
    "Janazah Prayer":                  .guideCategoryPrayer,
    "Travel Prayer (Qasr)":            .guideCategoryPrayer,
    "Ruqyah (Healing Recitation)":    .guideCategorySupplications,
    "Essential Duas":                  .guideCategorySupplications,
    "Fasting (Sawm)":                  .guideCategoryWorship,
    "Zakat Calculation":               .guideCategoryFinanceFiqh,
    "Islamic Inheritance (Mirath)":    .guideCategoryFinanceFiqh,
]

private let categoryOrder: [LocalizedKey] = [
    .guideCategoryPurification,
    .guideCategoryPrayer,
    .guideCategoryWorship,
    .guideCategoryFinanceFiqh,
    .guideCategorySupplications,
]

private let categoryIcons: [LocalizedKey: String] = [
    .guideCategoryPurification:  "drop.fill",
    .guideCategoryPrayer:        "figure.stand",
    .guideCategoryWorship:       "moon.stars.fill",
    .guideCategoryFinanceFiqh:  "banknote.fill",
    .guideCategorySupplications: "hands.sparkles.fill",
]

// MARK: - Main Section
struct IslamicGuidesSection: View {
    @EnvironmentObject var localization: LocalizationManager

    private var categories: [GuideCategory] {
        var buckets: [LocalizedKey: [EmergencyGuide]] = [:]
        for guide in EmergencyGuideData.allGuides {
            let cat = categoryMap[guide.title] ?? .guideCategorySupplications
            buckets[cat, default: []].append(guide)
        }
        return categoryOrder.compactMap { key in
            guard let guides = buckets[key], !guides.isEmpty else { return nil }
            return GuideCategory(id: String(describing: key), titleKey: key, guides: guides)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(categories) { category in
                CategoryShelf(
                    category: category,
                    categoryTitle: localization.t(category.titleKey),
                    icon: categoryIcons[category.titleKey] ?? "book.fill",
                    isMalayalam: localization.currentLanguage == .malayalam
                )
            }
        }
    }
}

// MARK: - Horizontal shelf per category
private struct CategoryShelf: View {
    let category: GuideCategory
    let categoryTitle: String
    let icon: String
    let isMalayalam: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                    Text(categoryTitle.uppercased())
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
                            GuideShelfCard(guide: guide, isMalayalam: isMalayalam)
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
    let isMalayalam: Bool
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
            Text(guide.localizedTitle(isMalayalam: isMalayalam))
                .font(.subheadline)
                .fontWeight(.semibold)
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
                    .font(.caption)
                    .fontWeight(.semibold)
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
