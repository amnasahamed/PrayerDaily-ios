import SwiftUI

// MARK: - Dua List View
struct DuaListView: View {
    let category: DuaCategory
    @State private var favorites: Set<UUID> = []
    @State private var appeared = false
    @State private var selectedDua: DuaEntry? = nil
    @Environment(\.colorScheme) var cs
    @Environment(\.localization) var l10n
    private var isMl: Bool { l10n.currentLanguage == .malayalam }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                headerBanner
                duaList
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.bottom, 100)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CalmingBackground())
        .navigationTitle(category.localizedTitle(isMalayalam: isMl))
        .modifier(AlehaNavStyle())
        .sheet(item: $selectedDua) { dua in
            DuaDetailSheet(dua: dua, color: category.color, isFavorite: favorites.contains(dua.id)) {
                toggleFavorite(dua.id)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.05)) {
                appeared = true
            }
        }
    }

    // MARK: - Header Banner
    private var headerBanner: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(category.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(category.localizedTitle(isMalayalam: isMl))
                    .font(.title3.weight(.bold))
                Text(isMl ? "\(category.duas.count) ദുആകൾ • ദൈനംദിന ദിക്ർ" : "\(category.duas.count) duas • Recite daily for barakah")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [category.color.opacity(cs == .dark ? 0.20 : 0.10),
                         category.color.opacity(cs == .dark ? 0.08 : 0.04)],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(category.color.opacity(cs == .dark ? 0.25 : 0.15), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    // MARK: - Dua List
    private var duaList: some View {
        VStack(spacing: 12) {
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
                .offset(y: appeared ? 0 : 16)
                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(i) * 0.06), value: appeared)
            }
        }
    }

    private func toggleFavorite(_ id: UUID) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
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
    @State private var pressed = false

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
            .background(cs == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5)
            )
            .scaleEffect(pressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }

    private var topRow: some View {
        HStack {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Text("\(dua.number)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(color)
                }
                Text(dua.localizedTitle(isMalayalam: isMl))
                    .font(.subheadline.weight(.semibold))
            }
            Spacer()
            Button(action: onFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .font(.subheadline)
                    .foregroundStyle(isFavorite ? Color.red : Color.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private var arabicText: some View {
        Text(dua.arabic)
            .font(.system(size: 20, weight: .regular, design: .default))
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundStyle(.primary)
            .lineSpacing(6)
    }

    private var translationText: some View {
        Text(dua.localizedTranslation(isMalayalam: isMl))
            .font(.footnote)
            .foregroundStyle(.secondary)
            .lineSpacing(3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var bottomRow: some View {
        HStack {
            Label(dua.reference, systemImage: "book.closed.fill")
                .font(.caption2.weight(.medium))
                .foregroundStyle(color.opacity(0.75))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.tertiary)
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
                VStack(spacing: 24) {
                    arabicCard
                    transliterationCard
                    translationCard
                    referenceCard
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.vertical, 24)
            }
            .background(CalmingBackground())
            .navigationTitle(dua.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(color)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { copied = true; UIPasteboard.general.string = dua.arabic }) {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                .font(.subheadline)
                                .foregroundStyle(color)
                        }
                        Button(action: onFavorite) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.subheadline)
                                .foregroundStyle(isFavorite ? Color.red : color)
                        }
                    }
                }
            }
        }
    }

    private var arabicCard: some View {
        VStack(spacing: 12) {
            Text(dua.arabic)
                .font(.system(size: 26, weight: .regular))
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [color.opacity(cs == .dark ? 0.18 : 0.10),
                         color.opacity(cs == .dark ? 0.08 : 0.04)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }

    @Environment(\.localization) var l10nDS
    private var isMlDS: Bool { l10nDS.currentLanguage == .malayalam }

    private var transliterationCard: some View {
        detailCard(label: isMlDS ? "ലിപ്യന്തരണം" : "Transliteration",
                   icon: "textformat.abc", content: dua.transliteration)
    }

    private var translationCard: some View {
        detailCard(label: isMlDS ? "അർത്ഥം" : "Translation",
                   icon: "globe", content: dua.localizedTranslation(isMalayalam: isMlDS))
    }

    private var referenceCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.closed.fill")
                .font(.subheadline)
                .foregroundStyle(color)
            Text("Source: \(dua.reference)")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(14)
        .background(cs == .dark ? Color.white.opacity(0.05) : Color.white.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.smallRadius, style: .continuous))
    }

    private func detailCard(label: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption).foregroundStyle(color)
                Text(label).font(.caption.weight(.semibold)).foregroundStyle(color)
            }
            Text(content)
                .font(.body)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(cs == .dark ? Color.white.opacity(0.06) : Color.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5)
        )
    }
}
