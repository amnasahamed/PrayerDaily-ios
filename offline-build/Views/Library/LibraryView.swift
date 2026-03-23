import SwiftUI

struct LibraryView: View {
    @AppStorage("lastHadithCollectionId") private var lastHadithCollectionId: String = "nawawi40"
    @Environment(\.localization) var l10n
    @State private var searchText = ""
    @State private var selectedCategory = 0
    @State private var appeared = false
    @State private var selectedCollectionId: String? = nil
    @State private var selectedDuaCategory: DuaCategory? = nil
    private var categories: [String] { [l10n.t(.libraryKnowledge), l10n.t(.libraryDuas), l10n.t(.libraryTools), l10n.t(.libraryGuides)] }

    private var lastCollection: HadithCollection? {
        HadithLibrary.collections.first(where: { $0.id == lastHadithCollectionId }) ?? HadithLibrary.collections.first
    }

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 22) {
                    continueReadingBanner
                    categoryPicker
                    contentForCategory
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 120)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CalmingBackground())
            .navigationTitle(l10n.t(.libraryTitle))
            .navigationBarTitleDisplayMode(.inline)
            .modifier(AlehaNavStyle())
            .searchable(text: $searchText, prompt: l10n.t(.quranSearchPrompt))
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) { appeared = true }
            }
            .navigationDestination(item: $selectedCollectionId) { id in
                if let collection = HadithLibrary.collections.first(where: { $0.id == id }) {
                    HadithCollectionDetailView(collection: collection)
                }
            }
            .navigationDestination(item: $selectedDuaCategory) { cat in
                DuaListView(category: cat)
            }
        }
    }

    @ViewBuilder
    private var contentForCategory: some View {
        switch selectedCategory {
        case 1: duaSection
        case 2: toolsSection
        case 3: guidesSection
        default: knowledgeSection
        }
    }

    // MARK: - Continue Reading Banner
    private var continueReadingBanner: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            selectedCollectionId = lastHadithCollectionId
        } label: {
            ContinueReadingCard(
                collection: lastCollection,
                hadithNumber: 1
            )
        }
        .buttonStyle(.plain)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05), value: appeared)
    }

    // MARK: - Category Picker
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<categories.count, id: \.self) { idx in
                    CategoryChip(title: categories[idx], isSelected: selectedCategory == idx) {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        withAnimation(.easeInOut(duration: 0.25)) { selectedCategory = idx }
                    }
                }
            }
        }
    }

    // MARK: - Knowledge Section
    @ViewBuilder
    private var knowledgeSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: l10n.t(.libraryHadithCollections), icon: "book.closed.fill")
            ForEach(Array(filteredCollections.enumerated()), id: \.element.id) { i, collection in
                Button {
                    lastHadithCollectionId = collection.id
                    selectedCollectionId = collection.id
                } label: {
                    HadithCollectionCard(collection: collection)
                }
                .buttonStyle(SpringPressStyle())
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(i) * 0.08), value: appeared)
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
            sectionHeader(title: l10n.t(.libraryDuaCollection), icon: "hands.sparkles.fill")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(DuaDatabase.all) { category in
                    Button {
                        selectedDuaCategory = category
                    } label: {
                        DuaCategoryTile(
                            title: category.title,
                            icon: category.icon,
                            count: category.duas.count,
                            color: category.color
                        )
                    }
                    .buttonStyle(SpringPressStyle())
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: appeared)
    }

    // MARK: - Tools Section
    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: l10n.t(.libraryIslamicTools), icon: "wrench.and.screwdriver.fill")
            NavigationLink(destination: QiblaCompassView()) {
                ToolRow(icon: "location.north.fill", title: l10n.t(.libraryQiblaDesc),
                        subtitle: l10n.t(.libraryQibla), color: Color.alehaGreen)
            }
            .buttonStyle(SpringPressStyle())
            NavigationLink(destination: LibraryDhikrView()) {
                ToolRow(icon: "rosette", title: l10n.t(.dhikrTitle),
                        subtitle: l10n.t(.libraryDhikrDesc), color: Color.alehaAmber)
            }
            .buttonStyle(SpringPressStyle())
            NavigationLink(destination: LibraryHijriView()) {
                ToolRow(icon: "calendar.badge.clock", title: l10n.t(.libraryIslamicCalendar),
                        subtitle: l10n.t(.libraryHijriDesc), color: Color.alehaDarkGreen)
            }
            .buttonStyle(SpringPressStyle())
            NavigationLink(destination: LibraryPrayerTrackerView()) {
                ToolRow(icon: "moon.stars.fill", title: l10n.t(.trackerPrayerTracker),
                        subtitle: l10n.t(.libraryPrayerTrackerDesc), color: Color(red: 0.45, green: 0.25, blue: 0.75))
            }
            .buttonStyle(SpringPressStyle())
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35), value: appeared)
    }

    // MARK: - Guides Section
    private var guidesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: l10n.t(.libraryIslamicGuides), icon: "map.fill")
            NavigationLink(destination: EmergencyGuidesView()) {
                LibraryGuideRow(icon: "cross.case.fill", title: l10n.t(.moreEmergency),
                                subtitle: l10n.t(.libraryEmergencyGuidesDesc),
                                color: Color(red: 0.8, green: 0.2, blue: 0.25))
            }
            .buttonStyle(SpringPressStyle())
            NavigationLink(destination: EmergencyGuidesView()) {
                LibraryGuideRow(icon: "person.fill.questionmark", title: l10n.t(.libraryNewMuslimGuide),
                                subtitle: l10n.t(.libraryNewMuslimGuideDesc),
                                color: Color.alehaGreen)
            }
            .buttonStyle(SpringPressStyle())
            NavigationLink(destination: EmergencyGuidesView()) {
                LibraryGuideRow(icon: "book.pages.fill", title: l10n.t(.libraryFiqhBasics),
                                subtitle: l10n.t(.libraryFiqhBasicsDesc),
                                color: Color.alehaDarkGreen)
            }
            .buttonStyle(SpringPressStyle())
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35), value: appeared)
    }

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2).fill(Color.alehaGreen).frame(width: 4, height: 18)
            Image(systemName: icon).foregroundStyle(Color.alehaGreen).font(.subheadline)
            Text(title).font(.headline.weight(.bold))
            Spacer()
        }
    }
}

// MARK: - Continue Reading Card
struct ContinueReadingCard: View {
    let collection: HadithCollection?
    let hadithNumber: Int
    @Environment(\.colorScheme) var cs
    @Environment(\.localization) var l10n
    @EnvironmentObject var localization: LocalizationManager

    private var isMalayalam: Bool {
        localization.currentLanguage == .malayalam
    }

    private var collectionName: String {
        guard let collection = collection else { return "40 Hadith Nawawi" }
        return collection.localizedName(isMalayalam: isMalayalam)
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.alehaGreen.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: "book.fill")
                    .font(.title3)
                    .foregroundStyle(Color.alehaGreen)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(l10n.t(.libraryContinueReading))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.alehaGreen)
                Text("\(collectionName) #\(hadithNumber)")
                    .font(.subheadline.weight(.bold))
                Text("\"Actions are judged by intentions...\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Image(systemName: "arrow.right.circle.fill")
                .font(.title2)
                .foregroundStyle(Color.alehaGreen.opacity(0.7))
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color.alehaGreen.opacity(cs == .dark ? 0.18 : 0.07),
                         Color.alehaGreen.opacity(cs == .dark ? 0.08 : 0.03)],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(Color.alehaGreen.opacity(cs == .dark ? 0.25 : 0.15), lineWidth: 1)
        )
    }
}

// MARK: - Library Guide Row
struct LibraryGuideRow: View {
    let icon: String; let title: String; let subtitle: String; let color: Color
    @Environment(\.colorScheme) var cs
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(color.opacity(0.12)).frame(width: 48, height: 48)
                Image(systemName: icon).font(.title3).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(cs == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5))
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
                .background(isSelected
                    ? Color.alehaGreen
                    : (cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.75)))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(
                    isSelected ? Color.clear : (cs == .dark ? Color.white.opacity(0.06) : Color.black.opacity(0.06)),
                    lineWidth: 0.5))
        }
        .buttonStyle(SpringPressStyle())
    }
}

// MARK: - Dua Category Tile
struct DuaCategoryTile: View {
    let title: String; let icon: String; let count: Int; let color: Color
    @Environment(\.colorScheme) var cs

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(color.opacity(0.13)).frame(width: 48, height: 48)
                Image(systemName: icon).font(.title3).foregroundStyle(color)
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text("\(count) duas").font(.caption).foregroundStyle(.secondary)
        }
        .foregroundColor(.primary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(cs == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5))
    }
}

// MARK: - Tool Row
struct ToolRow: View {
    let icon: String; let title: String; let subtitle: String; let color: Color
    @Environment(\.colorScheme) var cs

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(color.opacity(0.12)).frame(width: 48, height: 48)
                Image(systemName: icon).font(.title3).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(cs == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
            .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5))
    }
}
