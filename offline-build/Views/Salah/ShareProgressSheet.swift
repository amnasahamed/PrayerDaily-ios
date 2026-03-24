import SwiftUI

// MARK: - Share Progress Sheet
struct ShareProgressSheet: View {
    @ObservedObject var store: SalahStore
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    @State private var showSystemShare = false
    @State private var shareImage: UIImage? = nil
    @State private var cardRendered = false

    private var todayCount: Int { store.todayLog.completedCount }
    private var streak: Int { store.currentStreak }
    private var pct: Int { store.weeklyConsistency }

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground()
                VStack(spacing: 24) {
                    Spacer().frame(height: 4)
                    previewCard
                        .scaleEffect(cardRendered ? 1.0 : 0.9)
                        .opacity(cardRendered ? 1.0 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1), value: cardRendered)
                    messageText
                    shareButton
                    Spacer()
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 30)
            }
            .navigationTitle(localization.t(.shareProgressTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localization.t(.commonDone)) { dismiss() }
                }
            }
            .onAppear {
                // Pre-render the share card image on appear
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    shareImage = renderShareCard()
                    withAnimation { cardRendered = true }
                }
            }
            .sheet(isPresented: $showSystemShare) {
                if let img = shareImage {
                    SystemShareSheet(items: [img])
                } else {
                    SystemShareSheet(items: [buildShareText()])
                }
            }
        }
    }

    // MARK: - Preview Card (same as exported)
    private var previewCard: some View {
        ProgressShareCard(
            completedCount: todayCount,
            streak: streak,
            weeklyPct: pct,
            dateString: formattedDate
        )
        .environmentObject(localization)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.alehaActiveGreen.opacity(0.25), radius: 24, y: 10)
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "d MMMM"
        return f.string(from: Date())
    }

    private var messageText: some View {
        VStack(spacing: 6) {
            Text(localization.t(.shareReadyToInspire))
                .font(.subheadline.weight(.semibold))
            Text(localization.t(.shareInspireDescription))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var shareButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            showSystemShare = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                Text(localization.t(.shareCard))
            }
        }
        .buttonStyle(PrimaryCTAStyle(color: Color.alehaActiveGreen))
        .disabled(shareImage == nil)
    }

    private func buildShareText() -> String {
        return """
Aleha · \(formattedDate)

\(todayCount)/5 Prayers Completed
\(streak) Day Streak
\(pct)% Weekly Consistency

Alhamdulillah
"""
    }

    // MARK: - Pre-rendered Card for Sharing
    private func renderShareCard() -> UIImage {
        let cardWidth: CGFloat = 360
        let cardHeight: CGFloat = 480
        let renderer = ImageRenderer(
            content: ProgressShareCard(
                completedCount: todayCount,
                streak: streak,
                weeklyPct: pct,
                dateString: formattedDate
            )
            .environmentObject(localization)
            .frame(width: cardWidth, height: cardHeight)
        )
        renderer.scale = 3.0
        return renderer.uiImage ?? UIImage()
    }
}

// MARK: - The Share Card (Used for both Preview and Export)
struct ProgressShareCard: View {
    @EnvironmentObject var localization: LocalizationManager
    let completedCount: Int
    let streak: Int
    let weeklyPct: Int
    let dateString: String

    private var allDone: Bool { completedCount == 5 }

    var body: some View {
        ZStack {
            // Rich brand green gradient - same for preview and export
            LinearGradient(
                colors: [
                    Color(red: 0.03, green: 0.18, blue: 0.12),
                    Color(red: 0.05, green: 0.25, blue: 0.15),
                    Color(red: 0.08, green: 0.32, blue: 0.20)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtle geometric pattern
            IslamicPatternOverlay(opacity: 0.06)

            VStack(spacing: 0) {
                cardTop
                    .padding(.top, 24)
                Spacer()
                statsBlock
                Spacer()
                cardFooter
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
        .frame(width: 360, height: 480)
    }

    private var cardTop: some View {
        HStack(alignment: .top) {
            Image("AppLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)

            VStack(alignment: .leading, spacing: 2) {
                Text("Aleha")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(dateString)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.alehaActiveGreen.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: allDone ? "star.fill" : "moon.stars.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(allDone ? Color.alehaAmber : Color.alehaActiveGreen)
            }
        }
    }

    private var statsBlock: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("\(completedCount) of 5")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                Text(allDone ? localization.t(.sharePrayersCompleted) : localization.t(.sharePrayersLoggedToday))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }

            prayerDots

            HStack(spacing: 0) {
                miniStat(value: "\(streak)", label: localization.t(.shareDayStreak), icon: "flame.fill", color: .orange)
                Rectangle().fill(.white.opacity(0.1)).frame(width: 1, height: 36)
                miniStat(value: "\(weeklyPct)%", label: localization.t(.salahThisWeek), icon: "chart.bar.fill", color: Color.alehaActiveGreen)
                Rectangle().fill(.white.opacity(0.1)).frame(width: 1, height: 36)
                miniStat(
                    value: allDone ? localization.t(.shareAll) : "\(completedCount)",
                    label: localization.t(.shareAllToday),
                    icon: allDone ? "checkmark.circle.fill" : "moon.stars.fill",
                    color: allDone ? Color.alehaAmber : Color.alehaActiveGreen
                )
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.white.opacity(0.08))
            )
        }
    }

    private var prayerDots: some View {
        let names = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
        return HStack(spacing: 14) {
            ForEach(Array(names.enumerated()), id: \.offset) { idx, name in
                VStack(spacing: 5) {
                    ZStack {
                        Circle()
                            .fill(idx < completedCount ? Color.alehaActiveGreen : .white.opacity(0.15))
                            .frame(width: 12, height: 12)
                        if idx < completedCount {
                            Circle()
                                .stroke(Color.alehaActiveGreen.opacity(0.4), lineWidth: 2)
                                .frame(width: 16, height: 16)
                        }
                    }
                    Text(String(name.prefix(3)))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
        }
    }

    private func miniStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Image(systemName: icon).font(.system(size: 14)).foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    private var cardFooter: some View {
        Text("Alhamdulillah")
            .font(.system(size: 16, weight: .medium, design: .serif))
            .foregroundStyle(.white.opacity(0.5))
    }
}

// MARK: - UIKit Share Sheet
struct SystemShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
