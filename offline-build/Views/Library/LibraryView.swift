import SwiftUI

struct LibraryView: View {
    @State private var searchText = ""
    @State private var selectedCategory = 0
    private let categories = ["All", "Hadith", "Duas", "Tools"]

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
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
            .background(Color("NoorSurface").ignoresSafeArea())
            .navigationTitle("Library")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .searchable(text: $searchText, prompt: "Search hadith, duas...")
        }
    }

    // MARK: - Category Picker
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

    // MARK: - Hadith Collections
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

    // MARK: - Duas Section
    private var duaSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Dua Collection", icon: "hands.sparkles.fill")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                DuaCategoryTile(title: "Morning", icon: "sunrise.fill", count: 12, color: Color("NoorGold"))
                DuaCategoryTile(title: "Evening", icon: "sunset.fill", count: 12, color: Color("NoorAccent"))
                DuaCategoryTile(title: "Travel", icon: "airplane", count: 8, color: Color("NoorPrimary"))
                DuaCategoryTile(title: "Protection", icon: "shield.fill", count: 10, color: Color("NoorSecondary"))
            }
        }
    }

    // MARK: - Tools Section
    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: "Islamic Tools", icon: "wrench.and.screwdriver.fill")
            NavigationLink(destination: QiblaCompassView()) {
                ToolRow(icon: "location.north.fill", title: "Qibla Compass", subtitle: "Find prayer direction", color: Color("NoorPrimary"))
            }
            .buttonStyle(.plain)
            ToolRow(icon: "rosette", title: "Dhikr Counter", subtitle: "Digital tasbeeh", color: Color("NoorGold"))
            ToolRow(icon: "calendar.badge.clock", title: "Hijri Calendar", subtitle: "Islamic date converter", color: Color("NoorAccent"))
        }
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(Color("NoorPrimary"))
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

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color("NoorPrimary") : Color(.systemGray5))
                .clipShape(Capsule())
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
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2).foregroundStyle(color)
            Text(title).font(.subheadline.weight(.semibold))
            Text("\(count) duas").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(cs == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(color: .black.opacity(cs == .dark ? 0.3 : 0.05), radius: 4, y: 2)
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
            Image(systemName: icon).font(.title3).foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(cs == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(color: .black.opacity(cs == .dark ? 0.3 : 0.05), radius: 6, y: 3)
    }
}
