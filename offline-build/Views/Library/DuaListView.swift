import SwiftUI

// MARK: - Dua List View
struct DuaListView: View {
    let category: DuaCategory
    @AppStorage("duaFavorites") private var favoritesData: String = ""
    @State private var appeared = false
    @State private var selectedDua: DuaEntry? = nil
    @Environment(\.colorScheme) var cs
    @Environment(\.localization) var l10n
    private var isMl: Bool { l10n.currentLanguage == .malayalam }

    private var favorites: Set<UUID> {
        guard !favoritesData.isEmpty else { return [] }
        return Set(favoritesData.split(separator: ",").compactMap { UUID(uuidString: String($0)) })
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 12) {
                headerBanner
                ForEach(Array(category.duas.enumerated()), id: \.element.id) { i, dua in
                    DuaRowCard(
                        dua: dua,
                        color: category.color,
                        isMl: isMl,
                        isFavorite: favorites.contains(dua.id)
                    ) {
                        selectedDua = dua
                    } onFavorite: {
                        toggleFavorite(dua.id)
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeIn(duration: 0.2).delay(Double(i) * 0.04), value: appeared)
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 48)
        }
        .scrollBounceBehavior(.basedOnSize)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(category.localizedTitle(isMalayalam: isMl))
        .navigationBarTitleDisplayMode(.inline)
        .modifier(AlehaNavStyle())
        .sheet(item: $selectedDua) { dua in
            DuaDetailSheet(dua: dua, color: category.color, isFavorite: favorites.contains(dua.id)) {
                toggleFavorite(dua.id)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.25)) { appeared = true }
        }
    }

    // MARK: - Header Banner
    private var headerBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(category.color)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(category.localizedTitle(isMalayalam: isMl))
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                Text(isMl
                     ? "\(category.duas.count) ദുആകൾ • ദൈനംദിന ദിക്ർ"
                     : "\(category.duas.count) duas • Recite daily for barakah")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(cs == .dark ? 0 : 0.05), radius: 6, x: 0, y: 2)
    }

    private func toggleFavorite(_ id: UUID) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        var current = favorites
        if current.contains(id) { current.remove(id) } else { current.insert(id) }
        favoritesData = current.map { $0.uuidString }.joined(separator: ",")
    }
}

// MARK: - Dua Row Card
struct DuaRowCard: View {
    let dua: DuaEntry
    let color: Color
    var isMl: Bool = false
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavorite: () -> Void
    @Environment(\.colorScheme) var cs

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                topRow
                arabicText
                translationText
                bottomRow
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(cs == .dark ? 0 : 0.04), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(SpringPressStyle())
        .accessibilityLabel("\(dua.localizedTitle(isMalayalam: isMl))")
        .accessibilityHint("Tap to read full dua")
    }

    private var topRow: some View {
        HStack {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.10))
                        .frame(width: 26, height: 26)
                    Text("\(dua.number)")
                        .font(.caption2.weight(.bold))
                        .foregroundColor(color)
                }
                Text(dua.localizedTitle(isMalayalam: isMl))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            Spacer()
            Button(action: onFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.subheadline)
                    .foregroundStyle(isFavorite ? Color.red : Color(UIColor.tertiaryLabel))
            }
            .buttonStyle(.plain)
        }
    }

    private var arabicText: some View {
        Text(dua.arabic)
            .font(.system(size: 19, weight: .regular))
            .multilineTextAlignment(.trailing)
            .lineSpacing(7)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundColor(.primary)
    }

    private var translationText: some View {
        Text(dua.localizedTranslation(isMalayalam: isMl))
            .font(.footnote)
            .foregroundColor(Color(UIColor.secondaryLabel))
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var bottomRow: some View {
        HStack {
            Label(dua.reference, systemImage: "book.closed.fill")
                .font(.caption2.weight(.medium))
                .foregroundColor(color.opacity(0.7))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
        }
    }
}

// MARK: - Dua Detail Sheet
struct DuaDetailSheet: View {
    let dua: DuaEntry
    let color: Color
    let isFavorite: Bool
    let onFavorite: () -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var cs
    @State private var copied = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    arabicCard
                    transliterationCard
                    translationCard
                    referenceCard
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(dua.title)
            .navigationBarTitleDisplayMode(.inline)
            .modifier(AlehaNavStyle())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 14) {
                        Button(action: { copied = true; UIPasteboard.general.string = dua.arabic }) {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                .font(.subheadline)
                                .foregroundStyle(color)
                                .accessibilityLabel(copied ? "Copied" : "Copy Arabic text")
                        }
                        Button(action: onFavorite) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.subheadline)
                                .foregroundStyle(isFavorite ? Color.red : color)
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SheetCloseButton { dismiss() }
                }
            }
        }
    }

    private var arabicCard: some View {
        Text(dua.arabic)
            .font(.system(size: 24, weight: .regular))
            .multilineTextAlignment(.center)
            .lineSpacing(10)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [color.opacity(cs == .dark ? 0.15 : 0.08),
                             color.opacity(cs == .dark ? 0.06 : 0.03)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(color.opacity(0.15), lineWidth: 1)
            )
    }

    @Environment(\.localization) var l10nDS
    private var isMlDS: Bool { l10nDS.currentLanguage == .malayalam }

    private var transliterationCard: some View {
        detailCard(label: l10nDS.t(.quranTransliteration),
                   icon: "textformat.abc", content: dua.transliteration)
    }

    private var translationCard: some View {
        detailCard(label: l10nDS.t(.quranTranslation),
                   icon: "globe", content: dua.localizedTranslation(isMalayalam: isMlDS))
    }

    private var referenceCard: some View {
        HStack(spacing: 10) {
            Image(systemName: "book.closed.fill")
                .font(.subheadline)
                .foregroundStyle(color)
            Text("\(l10nDS.t(.duaSource)): \(dua.reference)")
                .font(.footnote.weight(.medium))
                .foregroundColor(Color(UIColor.secondaryLabel))
            Spacer()
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func detailCard(label: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption).foregroundStyle(color)
                Text(label).font(.caption.weight(.semibold)).foregroundStyle(color)
            }
            Text(content)
                .font(.body)
                .lineSpacing(5)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
