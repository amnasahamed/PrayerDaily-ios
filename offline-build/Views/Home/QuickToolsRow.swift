import SwiftUI

// MARK: - Quick Tools 2×2 Grid
struct QuickToolsRow: View {
    @ObservedObject var service: PrayerTimesService

    var body: some View {
        let tools = makeTools()
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            ForEach(tools) { tool in
                ToolGridCard(tool: tool, service: service)
            }
        }
    }

    private func makeTools() -> [QuickTool] {[
        QuickTool(id: "qibla",  icon: "location.north.fill",  label: "Qibla",
                  accent: Color.alehaGreen,    subtitle: nil),
        QuickTool(id: "hijri",  icon: "moon.stars.fill",      label: "Hijri Calendar",
                  accent: Color(red: 0.42, green: 0.28, blue: 0.82), subtitle: service.hijriDateShort),
        QuickTool(id: "dhikr",  icon: "hand.raised.fill",     label: "Dhikr Counter",
                  accent: Color.alehaAmber,    subtitle: nil),
        QuickTool(id: "quran",  icon: "book.fill",            label: "Quran",
                  accent: Color(red: 0.18, green: 0.55, blue: 0.42), subtitle: nil),
        QuickTool(id: "duas",   icon: "hands.sparkles.fill",  label: "Duas",
                  accent: Color(red: 0.82, green: 0.38, blue: 0.20), subtitle: nil),
    ]}
}

// MARK: - Tool Model
struct QuickTool: Identifiable {
    let id: String
    let icon: String
    let label: String
    let accent: Color
    let subtitle: String?
}

// MARK: - Grid Card
private struct ToolGridCard: View {
    let tool: QuickTool
    @ObservedObject var service: PrayerTimesService
    @Environment(\.colorScheme) var cs

    @State private var showQibla  = false
    @State private var showDhikr  = false
    @State private var showHijri  = false
    @State private var showDuas   = false
    @State private var showQuran  = false
    @State private var pressed    = false

    var body: some View {
        Button { handleTap() } label: { cardLabel }
            .buttonStyle(.plain)
            .scaleEffect(pressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.62), value: pressed)
            .sheet(isPresented: $showQibla) { NavigationStack { QiblaCompassView() } }
            .sheet(isPresented: $showDhikr) { DhikrSheetWrapper() }
            .sheet(isPresented: $showHijri) { NavigationStack { LibraryHijriView() } }
            .sheet(isPresented: $showDuas)  { DuasCategorySheet() }
            .sheet(isPresented: $showQuran) { QuranQuickSheet() }
    }

    private var cardLabel: some View {
        HStack(spacing: 12) {
            // Icon badge
            ZStack {
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .fill(tool.accent.opacity(0.15))
                    .frame(width: 42, height: 42)
                Image(systemName: tool.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tool.accent)
            }

            // Labels
            VStack(alignment: .leading, spacing: 2) {
                Text(tool.label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if let sub = tool.subtitle {
                    Text(sub)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(tool.accent)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cs == .dark ? Color(.systemGray6) : .white)
                .shadow(color: tool.accent.opacity(cs == .dark ? 0.0 : 0.08), radius: 6, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(tool.accent.opacity(0.10), lineWidth: 1)
        )
    }

    private func handleTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation { pressed = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
            withAnimation { pressed = false }
            switch tool.id {
            case "qibla": showQibla = true
            case "dhikr": showDhikr = true
            case "hijri": showHijri = true
            case "duas":  showDuas  = true
            case "quran": showQuran = true
            default: break
            }
        }
    }
}

// MARK: - Dhikr Wrapper
private struct DhikrSheetWrapper: View {
    @StateObject private var store = SalahStore()
    var body: some View {
        NavigationStack {
            DhikrCounterView()
                .environmentObject(store)
                .navigationTitle("Dhikr")
                .navigationBarTitleDisplayMode(.inline)
                .sheetDismissButton()
                .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Quran Quick Sheet
private struct QuranQuickSheet: View {
    @Environment(\.dismiss) var dismiss
    private let featured = QuranData.allSurahs

    var body: some View {
        NavigationStack {
            List(featured) { surah in
                NavigationLink(destination: SurahReaderView(surah: surah)) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.alehaGreen.opacity(0.12))
                                .frame(width: 36, height: 36)
                            Text("\(surah.id)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.alehaGreen)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(surah.nameTransliteration)
                                .font(.subheadline.weight(.semibold))
                            Text("\(surah.verses) verses · \(surah.type)")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(surah.nameArabic)
                            .font(.system(size: 17, design: .serif))
                            .foregroundStyle(Color.alehaGreen)
                    }
                }
            }
            .navigationTitle("Quran")
            .navigationBarTitleDisplayMode(.inline)
            .sheetDismissButton()
        }
    }
}

// MARK: - Hijri Date Sheet
private struct HijriDateSheet: View {
    let hijriDate: String
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 56, weight: .semibold))
                    .foregroundStyle(Color.alehaAmber)
                Text("Hijri Date")
                    .font(.title2.weight(.bold))
                Text(hijriDate.isEmpty ? "Loading…" : hijriDate)
                    .font(.title3).foregroundStyle(Color.alehaGreen)
                    .multilineTextAlignment(.center).padding(.horizontal)
                Text(gregorianDate)
                    .font(.subheadline).foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Islamic Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .sheetDismissButton()
        }
    }

    private var gregorianDate: String {
        let f = DateFormatter(); f.dateStyle = .full; return f.string(from: Date())
    }
}

// MARK: - Duas Category Sheet
struct DuasCategorySheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var cs
    @State private var selectedCategory: DuaCategory? = nil
    private let categories = DuaDatabase.all

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(categories) { cat in
                        Button { selectedCategory = cat } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(cat.color.opacity(0.12))
                                        .frame(width: 46, height: 46)
                                    Image(systemName: cat.icon)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(cat.color)
                                }
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(cat.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.primary)
                                    Text("\(cat.duas.count) duas")
                                        .font(.caption)
                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(Color(UIColor.tertiaryLabel))
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.black.opacity(cs == .dark ? 0 : 0.05),
                                    radius: 6, x: 0, y: 2)
                        }
                        .buttonStyle(SpringPressStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Duas")
            .navigationBarTitleDisplayMode(.inline)
            .modifier(AlehaNavStyle())
            .sheetDismissButton()
            .navigationDestination(item: $selectedCategory) { cat in
                DuaListView(category: cat)
            }
        }
    }
}
