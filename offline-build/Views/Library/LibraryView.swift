import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory = 0
    private let categories = ["All", "Hadith", "Duas", "Tools"]

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {
                        categoryPicker
                        if selectedCategory == 0 || selectedCategory == 1 {
                            hadithCollectionsSection
                        }
                        if selectedCategory == 0 || selectedCategory == 2 {
                            duaSection
                        }
                        if selectedCategory == 0 || selectedCategory == 3 {
                            toolsSection
                        }
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Library")
            .modifier(AlehaNavStyle())
            .searchable(text: $searchText, prompt: "Search hadith, duas...")
        }
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<categories.count, id: \.self) { idx in
                    CategoryChip(title: categories[idx], isSelected: selectedCategory == idx) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = idx }
                    }
                }
            }
        }
    }

    private var hadithCollectionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Hadith Collections", icon: "book.closed.fill")
            ForEach(filteredCollections) { collection in
                NavigationLink(destination: HadithCollectionDetailView(collection: collection)) {
                    HadithCollectionCard(collection: collection)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var filteredCollections: [HadithCollection] {
        if searchText.isEmpty { return HadithLibrary.collections }
        return HadithLibrary.collections.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.author.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var duaSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Dua Collection", icon: "hands.sparkles.fill")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                DuaCategoryTile(title: "Morning", icon: "sunrise.fill", count: 12, color: Color.alehaAmber)
                DuaCategoryTile(title: "Evening", icon: "sunset.fill", count: 12, color: Color.alehaDarkGreen)
                DuaCategoryTile(title: "Travel", icon: "airplane", count: 8, color: Color.alehaGreen)
                DuaCategoryTile(title: "Protection", icon: "shield.fill", count: 10, color: Color.noorGold)
            }
        }
    }

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Islamic Tools", icon: "wrench.and.screwdriver.fill")
            NavigationLink(destination: QiblaCompassView()) {
                ToolRow(icon: "location.north.fill", title: "Qibla Compass", subtitle: "Find prayer direction", color: Color.alehaGreen)
            }
            .buttonStyle(.plain)
            ToolRow(icon: "rosette", title: "Dhikr Counter", subtitle: "Digital tasbeeh", color: Color.alehaAmber)
            ToolRow(icon: "calendar.badge.clock", title: "Hijri Calendar", subtitle: "Islamic date converter", color: Color.alehaDarkGreen)
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.alehaGreen)
                .font(.subheadline)
            Text(title).font(.headline.weight(.bold))
            Spacer()
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @Environment(\.colorScheme) var cs

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(isSelected ? Color.alehaGreen : (cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.7)))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? Color.clear : (cs == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.05)), lineWidth: 0.5)
                )
        }
    }
}

// MARK: - Dua Category Tile
struct DuaCategoryTile: View {
    let title: String
    let icon: String
    let count: Int
    let color: Color
    @Environment(\.colorScheme) var cs

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            Text(title).font(.subheadline.weight(.semibold))
            Text("\(count) duas").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(cs == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(cs == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.5), lineWidth: 0.5)
        )
    }
}

// MARK: - Tool Row
struct ToolRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    @Environment(\.colorScheme) var cs

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 46, height: 46)
                Image(systemName: icon).font(.title3).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(cs == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(cs == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.5), lineWidth: 0.5)
        )
    }
}
