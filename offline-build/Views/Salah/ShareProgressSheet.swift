import SwiftUI

// MARK: - Share Progress Sheet
struct ShareProgressSheet: View {
    @ObservedObject var store: SalahStore
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var cs
    @State private var showSystemShare = false
    @State private var shareImage: UIImage? = nil
    @State private var rendered = false

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
                        .scaleEffect(rendered ? 1.0 : 0.9)
                        .opacity(rendered ? 1.0 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.1), value: rendered)
                    messageText
                    shareButton
                    Spacer()
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.bottom, 30)
            }
            .navigationTitle("Share Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { withAnimation { rendered = true } }
            .sheet(isPresented: $showSystemShare) {
                if let img = shareImage {
                    SystemShareSheet(items: [img])
                } else {
                    SystemShareSheet(items: [buildShareText()])
                }
            }
        }
    }

    // MARK: - Preview Card
    private var previewCard: some View {
        ProgressShareCard(
            completedCount: todayCount,
            streak: streak,
            weeklyPct: pct,
            dateString: formattedDate,
            colorScheme: cs
        )
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
            Text("Ready to inspire others?")
                .font(.subheadline.weight(.semibold))
            Text("Share your consistency with family and friends.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var shareButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            shareImage = renderCard()
            showSystemShare = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                Text("Share Card")
            }
        }
        .buttonStyle(PrimaryCTAStyle(color: Color.alehaActiveGreen))
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

    private func renderCard() -> UIImage {
        let cardWidth = min(UIScreen.main.bounds.width - 48, 360)
        let cardHeight = cardWidth * (480.0 / 360.0)
        let renderer = ImageRenderer(
            content: ProgressShareCard(
                completedCount: todayCount,
                streak: streak,
                weeklyPct: pct,
                dateString: formattedDate,
                colorScheme: cs
            )
            .frame(width: cardWidth, height: cardHeight)
        )
        renderer.scale = 3.0
        return renderer.uiImage ?? UIImage()
    }
}

// MARK: - The Exportable Share Card
struct ProgressShareCard: View {
    let completedCount: Int
    let streak: Int
    let weeklyPct: Int
    let dateString: String
    let colorScheme: ColorScheme

    private var allDone: Bool { completedCount == 5 }

    var body: some View {
        ZStack {
            cardBackground
            IslamicPatternOverlay(opacity: 0.04)
            VStack(spacing: 0) {
                cardTop
                Spacer()
                statsBlock
                Spacer()
                cardFooter
            }
            .padding(28)
        }
        .frame(width: 360, height: 480)
    }

    private var cardBackground: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0.04, green: 0.10, blue: 0.07),
                    Color(red: 0.06, green: 0.18, blue: 0.11),
                    Color(red: 0.10, green: 0.28, blue: 0.17)
                ]
                : [
                    Color(red: 0.85, green: 0.95, blue: 0.88),
                    Color(red: 0.75, green: 0.90, blue: 0.80),
                    Color(red: 0.65, green: 0.85, blue: 0.72)
                ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardTop: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    CrescentShape()
                        .fill(Color.alehaAmber)
                        .frame(width: 16, height: 16)
                    Text("aleha")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Text(dateString)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 48, height: 48)
                Image(systemName: allDone ? "star.fill" : "moon.stars.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(allDone ? Color.alehaAmber : Color.alehaGreen)
            }
        }
    }

    private var statsBlock: some View {
        VStack(spacing: 20) {
            // Main prayer count
            VStack(spacing: 8) {
                Text("\(completedCount) of 5")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(allDone ? "Prayers Completed" : "Prayers Logged Today")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }

            // Prayer dots
            prayerDots

            // Stats row
            HStack(spacing: 0) {
                miniStat(value: "\(streak)", label: "Day\nStreak", icon: "flame.fill", color: .orange)
                Rectangle().fill(.white.opacity(0.1)).frame(width: 1, height: 40)
                miniStat(value: "\(weeklyPct)%", label: "This\nWeek", icon: "chart.bar.fill", color: Color.alehaGreen)
                Rectangle().fill(.white.opacity(0.1)).frame(width: 1, height: 40)
                miniStat(value: allDone ? "All" : "\(completedCount)", label: "All\nToday", icon: allDone ? "checkmark.circle.fill" : "moon.stars.fill", color: allDone ? Color.alehaAmber : Color.alehaGreen)
            }
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var prayerDots: some View {
        let names = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
        return HStack(spacing: 12) {
            ForEach(Array(names.enumerated()), id: \.offset) { idx, name in
                VStack(spacing: 4) {
                    Circle()
                        .fill(idx < completedCount ? Color.alehaActiveGreen : Color.white.opacity(0.15))
                        .frame(width: 10, height: 10)
                        .overlay(
                            idx < completedCount ?
                            Circle().stroke(Color.alehaActiveGreen.opacity(0.4), lineWidth: 3) : nil
                        )
                    Text(String(name.prefix(3)))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
        }
    }

    private func miniStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 16)).foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }

    private var cardFooter: some View {
        Text("Alhamdulillah")
            .font(.system(size: 16, weight: .medium, design: .serif))
            .foregroundStyle(.white.opacity(0.55))
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
