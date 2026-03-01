import SwiftUI

// Priority order — drives hero card selection and grid ordering
private let priorityOrder: [String] = [
    "Wudu (Ablution)",
    "Salah (Prayer)",
    "Ghusl (Ritual Bath)",
    "Essential Duas",
    "Tayammum (Dry Ablution)",
    "Janazah Prayer",
    "Zakat Calculation",
    "Islamic Inheritance (Mirath)"
]

struct IslamicGuidesSection: View {
    private var sortedGuides: [EmergencyGuide] {
        EmergencyGuideData.allGuides.sorted { a, b in
            let ai = priorityOrder.firstIndex(of: a.title) ?? 99
            let bi = priorityOrder.firstIndex(of: b.title) ?? 99
            return ai < bi
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            heroRow
            gridRows
        }
    }

    // MARK: - Top 2 hero cards
    private var heroRow: some View {
        HStack(spacing: 12) {
            ForEach(sortedGuides.prefix(2)) { guide in
                NavigationLink(destination: GuideDetailView(guide: guide)) {
                    FeaturedGuideCard(guide: guide)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - All remaining guides in 2-col grid
    private var gridRows: some View {
        let remaining = Array(sortedGuides.dropFirst(2))
        return LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 10
        ) {
            ForEach(remaining) { guide in
                NavigationLink(destination: GuideDetailView(guide: guide)) {
                    CompactGuideCell(guide: guide)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Featured Card (tall hero-style)
struct FeaturedGuideCard: View {
    let guide: EmergencyGuide
    @Environment(\.colorScheme) var cs

    var body: some View {
        let stepCount = guide.sections.flatMap(\.steps).count
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(guide.color).opacity(0.18))
                    .frame(width: 48, height: 48)
                Image(systemName: guide.icon)
                    .font(.title2)
                    .foregroundStyle(Color(guide.color))
            }
            Spacer()
            Text(guide.title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.primary)
                .lineLimit(2)
            Text(guide.subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            HStack {
                Text("\(stepCount) steps")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color(guide.color))
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Color(guide.color).opacity(0.7))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 130)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .fill(cs == .dark ? Color(.systemGray6) : .white)
                .shadow(color: Color(guide.color).opacity(0.12), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(Color(guide.color).opacity(0.18), lineWidth: 1)
        )
    }
}

// MARK: - Compact Cell (small grid card)
struct CompactGuideCell: View {
    let guide: EmergencyGuide
    @Environment(\.colorScheme) var cs

    var body: some View {
        let stepCount = guide.sections.flatMap(\.steps).count
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(guide.color).opacity(0.14))
                    .frame(width: 38, height: 38)
                Image(systemName: guide.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(guide.color))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(guide.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text("\(stepCount) steps")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(cs == .dark ? Color(.systemGray6) : .white)
                .shadow(color: .black.opacity(cs == .dark ? 0.25 : 0.05), radius: 5, y: 2)
        )
    }
}
