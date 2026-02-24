import SwiftUI

// MARK: - Quran
struct QuranPlaceholderView: View {
    var body: some View {
        NavigationStack {
            PlaceholderContent(
                icon: "book.fill",
                title: "Quran Companion",
                subtitle: "Complete Quran with Arabic text, translations, word-by-word meanings, tafsir, and audio recitation — all offline.",
                features: ["114 Surahs with Arabic + English", "Word-by-word meaning", "Offline tafsir database", "Audio recitation (download once)", "Bookmarks & reflection notes", "Keyword search"]
            )
            .navigationTitle("Quran")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Salah
struct SalahPlaceholderView: View {
    var body: some View {
        NavigationStack {
            PlaceholderContent(
                icon: "clock.fill",
                title: "Salah & Deen Tracker",
                subtitle: "Your daily self-discipline companion. Track prayers, build streaks, and level up your consistency.",
                features: ["Fajr–Isha daily logging", "Qada & Tahajjud tracker", "Dhikr counter", "Habit streaks & challenges", "Ramadan 30-Day Mode", "Weekly self-evaluation"]
            )
            .navigationTitle("Salah")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Library
struct LibraryPlaceholderView: View {
    var body: some View {
        NavigationStack {
            PlaceholderContent(
                icon: "books.vertical.fill",
                title: "Islamic Knowledge Vault",
                subtitle: "Your pocket Islamic library. Hadith collections, Seerah, Prophet stories, duas, and more — all searchable offline.",
                features: ["40 Hadith collection", "Sahih Hadith selections", "Seerah timeline", "Stories of 25 Prophets", "Dua by situation", "Islamic quotes database"]
            )
            .navigationTitle("Library")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - More
struct MorePlaceholderView: View {
    var body: some View {
        NavigationStack {
            PlaceholderContent(
                icon: "ellipsis.circle.fill",
                title: "More Features",
                subtitle: "Kids learning, emergency guides, settings, and personalization — everything you need in one place.",
                features: ["Islamic Kids App", "Emergency Guides", "Janazah & Nikah procedures", "Ruqyah guide", "Settings & preferences", "Focus / distraction-free mode"]
            )
            .navigationTitle("More")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("NoorPrimary"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

// MARK: - Shared Placeholder
struct PlaceholderContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let features: [String]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                iconHeader
                descriptionSection
                featureList
                comingSoonBadge
            }
            .padding(AppTheme.screenPadding)
        }
        .background(Color("NoorSurface").ignoresSafeArea())
    }

    private var iconHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(Color("NoorPrimary"))
                .padding(24)
                .background(Color("NoorPrimary").opacity(0.1))
                .clipShape(Circle())
            Text(title)
                .font(.title2.weight(.bold))
        }
        .padding(.top, 20)
    }

    private var descriptionSection: some View {
        Text(subtitle)
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Planned Features")
                .font(.subheadline.weight(.semibold))
            ForEach(features, id: \.self) { feature in
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color("NoorPrimary"))
                        .font(.body)
                    Text(feature)
                        .font(.subheadline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .noorCard()
    }

    private var comingSoonBadge: some View {
        Text("Coming Soon")
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color("NoorGold"))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color("NoorGold").opacity(0.12))
            .clipShape(Capsule())
    }
}
