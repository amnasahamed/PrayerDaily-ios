import SwiftUI

struct MoreView: View {
    @EnvironmentObject var store: SalahStore
    @Environment(\.colorScheme) var cs
    @State private var showStreakHistory = false
    @State private var showDataExport = false
    @State private var showShareApp = false
    @State private var showInvite = false

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                ScrollView {
                    VStack(spacing: 18) {
                        streakSnapshot
                        mainSection
                        communitySection
                        footerSection
                    }
                    .padding(.horizontal, AppTheme.screenPadding)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("More")
            .modifier(AlehaNavStyle())
            .sheet(isPresented: $showStreakHistory) { StreakHistorySheet(store: store) }
            .sheet(isPresented: $showDataExport) { DataExportSheet(store: store) }
            .sheet(isPresented: $showShareApp) { ShareAppSheet() }
        }
    }

    // MARK: - Streak Snapshot
    private var streakSnapshot: some View {
        HStack(spacing: 0) {
            snapBlock(value: "\(store.currentStreak)", label: "Day Streak", icon: "flame.fill", color: .orange)
            Divider().frame(height: 44)
            snapBlock(value: "\(store.weeklyConsistency)%", label: "This Week", icon: "chart.bar.fill", color: Color.alehaGreen)
            Divider().frame(height: 44)
            snapBlock(value: "\(totalLogged)", label: "Total Logged", icon: "checkmark.seal.fill", color: Color.alehaAmber)
        }
        .noorCard()
    }

    private var totalLogged: Int {
        store.logs.values.reduce(0) { $0 + $1.completedCount }
    }

    private func snapBlock(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption).foregroundStyle(color)
                Text(value).font(.title3.weight(.bold))
            }
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Main Section
    private var mainSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: EmergencyGuidesView()) {
                MoreMenuRow(icon: "cross.case.fill", title: "Emergency Guides",
                            subtitle: "Janazah, Ruqyah, Nikah & Travel",
                            color: Color.alehaAmber, showDivider: true)
            }
            .buttonStyle(.plain)

            Button { showStreakHistory = true } label: {
                MoreMenuRow(icon: "flame.fill", title: "Streak History",
                            subtitle: "View your prayer consistency over time",
                            color: .orange, showDivider: true)
            }
            .buttonStyle(.plain)

            MoreMenuRow(icon: "person.crop.circle.fill", title: "Profile",
                        subtitle: "Your settings & preferences",
                        color: Color.alehaGreen, showDivider: true)

            MoreMenuRow(icon: "moon.stars.fill", title: "Appearance",
                        subtitle: "Theme & display options",
                        color: Color.alehaDarkGreen, showDivider: true)

            let cacheCount = OfflineCacheService.shared.cachedSurahCount()
            let cacheSize = OfflineCacheService.shared.cacheSizeString()
            MoreMenuRow(icon: "arrow.down.circle.fill", title: "Offline Content",
                        subtitle: "\(cacheCount) surahs saved (\(cacheSize))",
                        color: Color.alehaAmber, showDivider: true)

            Button { showDataExport = true } label: {
                MoreMenuRow(icon: "square.and.arrow.up.fill", title: "Export My Data",
                            subtitle: "Download your prayer logs & notes",
                            color: Color(red: 0.45, green: 0.25, blue: 0.75), showDivider: false)
            }
            .buttonStyle(.plain)
        }
        .groupedCard()
    }

    // MARK: - Community Section
    private var communitySection: some View {
        VStack(spacing: 0) {
            sectionLabel("Community")
            Button { showShareApp = true } label: {
                MoreMenuRow(icon: "square.and.arrow.up", title: "Share Aleha",
                            subtitle: "Help others discover the app",
                            color: Color.alehaGreen, showDivider: true)
            }
            .buttonStyle(.plain)

            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                showShareApp = true
            } label: {
                MoreMenuRow(icon: "person.badge.plus", title: "Invite Friends",
                            subtitle: "Grow your circle of practice",
                            color: Color.alehaAmber, showDivider: false)
            }
            .buttonStyle(.plain)
        }
        .groupedCard()
    }

    // MARK: - Footer
    private var footerSection: some View {
        VStack(spacing: 0) {
            MoreMenuRow(icon: "info.circle.fill", title: "About Aleha",
                        subtitle: "Version 1.0 • Built with ♥",
                        color: Color.alehaGreen, showDivider: false)
        }
        .groupedCard()
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 4)
    }
}

// MARK: - Grouped Card Modifier
private extension View {
    func groupedCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
            )
    }
}

// MARK: - Streak History Sheet
struct StreakHistorySheet: View {
    @ObservedObject var store: SalahStore
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var cs

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        summaryCard
                        weeklyBars
                        calendarGrid
                    }
                    .padding(AppTheme.screenPadding)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Streak History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var summaryCard: some View {
        HStack(spacing: 0) {
            snapStat(value: "\(store.currentStreak)", label: "Current\nStreak", color: .orange)
            Divider().frame(height: 44)
            snapStat(value: "\(bestStreak)", label: "Best\nStreak", color: Color.alehaGreen)
            Divider().frame(height: 44)
            snapStat(value: "\(store.weeklyConsistency)%", label: "This\nWeek", color: Color.alehaAmber)
        }
        .noorCard()
    }

    private var bestStreak: Int {
        var best = 0; var cur = 0
        let cal = Calendar.current
        let today = Date()
        for i in (0..<90).reversed() {
            guard let d = cal.date(byAdding: .day, value: -i, to: today) else { continue }
            if store.log(for: d).completedCount == 5 { cur += 1; best = max(best, cur) }
            else { cur = 0 }
        }
        return best
    }

    private func snapStat(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.title2.weight(.bold)).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var weeklyBars: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 7 Days").font(.headline.weight(.bold))
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(lastSevenDays, id: \.0) { dayLabel, count in
                    VStack(spacing: 4) {
                        let h = max(4, CGFloat(count) / 5.0 * 64)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(barColor(count: count))
                            .frame(height: h)
                        Text(dayLabel).font(.caption2).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80, alignment: .bottom)
        }
        .noorCard()
    }

    private var lastSevenDays: [(String, Int)] {
        let cal = Calendar.current
        let today = Date()
        let fmt = DateFormatter(); fmt.dateFormat = "EEE"
        return (0..<7).reversed().compactMap { offset -> (String, Int)? in
            guard let d = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return (fmt.string(from: d), store.log(for: d).completedCount)
        }
    }

    private func barColor(count: Int) -> Color {
        switch count {
        case 5: return Color.alehaGreen
        case 3..<5: return Color.alehaAmber
        case 1..<3: return .orange
        default: return Color(.systemGray5)
        }
    }

    private var calendarGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 30 Days").font(.headline.weight(.bold))
            let days = last30Days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(days, id: \.0) { _, count in
                    let col = barColor(count: count)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(count >= 0 ? col.opacity(0.85) : Color(.systemGray6))
                        .frame(height: 28)
                }
            }
            HStack(spacing: 14) {
                legendDot(color: Color.alehaGreen, label: "All 5")
                legendDot(color: Color.alehaAmber, label: "3-4")
                legendDot(color: .orange, label: "1-2")
                legendDot(color: Color(.systemGray4), label: "None")
            }
        }
        .noorCard()
    }

    private var last30Days: [(Date, Int)] {
        let cal = Calendar.current; let today = Date()
        return (0..<30).reversed().compactMap { offset -> (Date, Int)? in
            guard let d = cal.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return (d, store.log(for: d).completedCount)
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Data Export Sheet
struct DataExportSheet: View {
    @ObservedObject var store: SalahStore
    @Environment(\.dismiss) var dismiss
    @State private var exported = false

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                VStack(spacing: 28) {
                    Spacer()
                    exportIcon
                    exportInfo
                    if exported { successBadge } else { exportButton }
                    Spacer()
                }
                .padding(AppTheme.screenPadding)
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
        }
    }

    private var exportIcon: some View {
        ZStack {
            Circle().fill(Color.alehaGreen.opacity(0.12)).frame(width: 90, height: 90)
            Image(systemName: "square.and.arrow.up.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.alehaGreen)
        }
    }

    private var exportInfo: some View {
        VStack(spacing: 10) {
            Text("Export Your Data").font(.title3.weight(.bold))
            Text("Your prayer logs, dhikr counts, and notes are ready to export as a summary.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 8) {
                exportRow("Prayer logs", value: "\(store.logs.count) days")
                exportRow("Total prayers logged", value: "\(store.logs.values.reduce(0) { $0 + $1.completedCount })")
                exportRow("Dhikr lifetime", value: "\(store.dhikrLifetimeTotal) counts")
                exportRow("Current streak", value: "\(store.currentStreak) days")
            }
            .noorCard()
        }
    }

    private func exportRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.weight(.semibold))
        }
    }

    private var exportButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            exported = true
        } label: {
            Label("Export Summary", systemImage: "arrow.down.doc.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.alehaGreen)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var successBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.alehaGreen)
            Text("Export ready — check your share sheet").font(.subheadline)
        }
        .padding(14)
        .background(Color.alehaGreen.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Share App Sheet
struct ShareAppSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var showShareSheet = false

    private let shareText = "I've been using Aleha for prayer tracking & Quran reading 🕌 — it's beautiful and super helpful. Try it out!"

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                VStack(spacing: 28) {
                    Spacer()
                    appIcon
                    shareContent
                    shareButton
                    inviteOptions
                    Spacer()
                }
                .padding(AppTheme.screenPadding)
            }
            .navigationTitle("Share Aleha")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [shareText])
            }
        }
    }

    private var appIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(LinearGradient(colors: [Color.alehaGreen, Color.alehaDarkGreen],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 90, height: 90)
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white)
        }
    }

    private var shareContent: some View {
        VStack(spacing: 8) {
            Text("Share with Friends").font(.title3.weight(.bold))
            Text("Help your friends build better habits with Aleha.")
                .font(.subheadline).foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var shareButton: some View {
        Button { showShareSheet = true } label: {
            Label("Share Aleha", systemImage: "square.and.arrow.up")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.alehaGreen)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var inviteOptions: some View {
        HStack(spacing: 16) {
            inviteChip(icon: "message.fill", label: "Message", color: Color.alehaGreen)
            inviteChip(icon: "envelope.fill", label: "Email", color: Color.alehaAmber)
            inviteChip(icon: "link", label: "Copy Link", color: Color.alehaDarkGreen)
        }
    }

    private func inviteChip(icon: String, label: String, color: Color) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            showShareSheet = true
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle().fill(color.opacity(0.12)).frame(width: 48, height: 48)
                    Image(systemName: icon).font(.title3).foregroundStyle(color)
                }
                Text(label).font(.caption.weight(.medium))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(SpringPressStyle())
    }
}

// MARK: - MoreMenuRow (kept compatible)
struct MoreMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    var showDivider: Bool = false
    @Environment(\.colorScheme) var cs

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.medium))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)

            if showDivider {
                Divider().padding(.leading, 68)
            }
        }
    }
}
