import SwiftUI

// MARK: - Quick Tools Horizontal Scroll Row
struct QuickToolsRow: View {
    @ObservedObject var service: PrayerTimesService

    private let tools: [QuickTool] = [
        QuickTool(id: "qibla",  icon: "location.north.fill",  label: "Qibla",  color: Color.alehaGreen),
        QuickTool(id: "dhikr",  icon: "hand.raised.fill",     label: "Dhikr",  color: Color.alehaAmber),
        QuickTool(id: "quran",  icon: "book.fill",            label: "Quran",  color: Color(red: 0.2, green: 0.6, blue: 0.45)),
        QuickTool(id: "hijri",  icon: "calendar",             label: "Hijri",  color: Color(red: 0.4, green: 0.3, blue: 0.8)),
        QuickTool(id: "duas",   icon: "hands.sparkles.fill",  label: "Duas",   color: Color(red: 0.8, green: 0.4, blue: 0.2)),
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tools) { tool in
                    ToolPill(tool: tool, service: service)
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.vertical, 6)
        }
        .padding(.horizontal, -AppTheme.screenPadding)
    }
}

// MARK: - Tool Model
struct QuickTool: Identifiable {
    let id: String
    let icon: String
    let label: String
    let color: Color
}

// MARK: - Tool Pill Button
private struct ToolPill: View {
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
        Button { handleTap() } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [tool.color.opacity(pressed ? 0.38 : 0.22), tool.color.opacity(pressed ? 0.20 : 0.10)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .shadow(color: tool.color.opacity(pressed ? 0.35 : 0.15), radius: pressed ? 8 : 5, y: 3)
                    Image(systemName: tool.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(tool.color)
                        .scaleEffect(pressed ? 1.15 : 1.0)
                }
                Text(tool.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(width: 70)
            .padding(.vertical, 4)
            .scaleEffect(pressed ? 0.93 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.22, dampingFraction: 0.60), value: pressed)
        .sheet(isPresented: $showQibla) { QiblaCompassView() }
        .sheet(isPresented: $showDhikr) { DhikrSheetWrapper() }
        .sheet(isPresented: $showHijri) { HijriDateSheet(hijriDate: service.hijriDate) }
        .sheet(isPresented: $showDuas)  { DuasSheet() }
        .sheet(isPresented: $showQuran) { QuranQuickSheet() }
    }

    private var subtitle: String? {
        switch tool.id {
        case "hijri": return service.hijriDate.components(separatedBy: "—").first?.trimmingCharacters(in: .whitespaces)
        default: return nil
        }
    }

    private func handleTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.22, dampingFraction: 0.5)) { pressed = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) { pressed = false }
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

// MARK: - Dhikr Sheet Wrapper
private struct DhikrSheetWrapper: View {
    @StateObject private var store = SalahStore()
    var body: some View {
        NavigationStack { DhikrCounterView().environmentObject(store) }
    }
}

// MARK: - Quran Quick Sheet (opens Surah list)
private struct QuranQuickSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var store = QuranStore.shared
    private let featured = Array(QuranData.allSurahs.prefix(10))

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
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
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
                    .font(.title3)
                    .foregroundStyle(Color.alehaGreen)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text(gregorianDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Islamic Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }}
        }
    }

    private var gregorianDate: String {
        let f = DateFormatter(); f.dateStyle = .full
        return f.string(from: Date())
    }
}

// MARK: - Duas Sheet
private struct DuasSheet: View {
    @Environment(\.dismiss) var dismiss
    private let duas = SampleData.duas

    var body: some View {
        NavigationStack {
            List(duas) { dua in
                VStack(alignment: .leading, spacing: 8) {
                    Text(dua.title)
                        .font(.subheadline.weight(.semibold))
                    Text(dua.arabic)
                        .font(.system(size: 18, design: .serif))
                        .foregroundStyle(Color.alehaGreen)
                    Text(dua.translation)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Duas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }}
        }
    }
}
