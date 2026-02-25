import SwiftUI

// MARK: - Quick Tools Horizontal Scroll Row
struct QuickToolsRow: View {
    @ObservedObject var service: PrayerTimesService

    private let tools: [QuickTool] = [
        QuickTool(id: "qibla", icon: "location.north.fill", label: "Qibla", color: Color.alehaGreen),
        QuickTool(id: "dhikr", icon: "hand.raised.fill", label: "Dhikr", color: Color.alehaAmber),
        QuickTool(id: "quran", icon: "book.fill", label: "Quran", color: Color(red: 0.2, green: 0.6, blue: 0.45)),
        QuickTool(id: "hijri", icon: "calendar", label: "Hijri", color: Color(red: 0.4, green: 0.3, blue: 0.8)),
        QuickTool(id: "duas", icon: "hands.sparkles.fill", label: "Duas", color: Color(red: 0.8, green: 0.4, blue: 0.2)),
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(tools) { tool in
                    ToolPill(tool: tool, service: service)
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.vertical, 2)
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

    @State private var showQibla = false
    @State private var showDhikr = false
    @State private var showHijri = false
    @State private var showDuas = false

    var body: some View {
        Button { handleTap() } label: {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(tool.color.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: tool.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(tool.color)
                }
                Text(tool.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                // Contextual subtitle
                if let sub = subtitle {
                    Text(sub)
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.88)
            )
            .clipShape(Capsule())
            .overlay(Capsule().stroke(cs == .dark ? Color.white.opacity(0.10) : Color.white.opacity(0.6), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        }
        .buttonStyle(SpringPressStyle())
        .sheet(isPresented: $showQibla) { QiblaCompassView() }
        .sheet(isPresented: $showDhikr) { DhikrSheetWrapper() }
        .sheet(isPresented: $showHijri) { HijriDateSheet(hijriDate: service.hijriDate) }
        .sheet(isPresented: $showDuas)  { DuasSheet() }
    }

    private var subtitle: String? {
        switch tool.id {
        case "hijri": return service.hijriDate.components(separatedBy: "—").first?.trimmingCharacters(in: .whitespaces)
        default: return nil
        }
    }

    private func handleTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        switch tool.id {
        case "qibla": showQibla = true
        case "dhikr": showDhikr = true
        case "hijri": showHijri = true
        case "duas":  showDuas = true
        default: break
        }
    }
}

// MARK: - Dhikr Sheet Wrapper
private struct DhikrSheetWrapper: View {
    @StateObject private var store = SalahStore()
    var body: some View {
        DhikrCounterView().environmentObject(store)
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
