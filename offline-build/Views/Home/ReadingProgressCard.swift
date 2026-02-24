import SwiftUI

struct ReadingProgressCard: View {
    @StateObject private var store = QuranStore.shared
    @Environment(\.colorScheme) var cs
    @State private var animateRing = false

    private var lastSurahName: String {
        guard let lr = store.lastRead,
              let s = QuranData.allSurahs.first(where: { $0.id == lr.surahId }) else { return "Al-Fatihah" }
        return s.nameEnglish
    }
    private var progressFraction: Double { Double(OfflineCacheService.shared.cachedSurahCount()) / 114.0 }
    private var cachedCount: Int { OfflineCacheService.shared.cachedSurahCount() }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Progress", systemImage: "book.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            ZStack {
                Circle()
                    .stroke(Color.alehaGreen.opacity(0.12), lineWidth: 6)
                Circle()
                    .trim(from: 0, to: animateRing ? progressFraction : 0)
                    .stroke(Color.alehaGreen, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animateRing)
                VStack(spacing: 1) {
                    Text("\(cachedCount)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.alehaGreen)
                    Text("/114")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 72, height: 72)
            .frame(maxWidth: .infinity)
            Text(lastSurahName)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(cs == .dark ? Color.white.opacity(0.07) : Color.white.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous).stroke(cs == .dark ? Color.white.opacity(0.08) : Color.white.opacity(0.6), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.05), radius: 14, y: 5)
        .onAppear { animateRing = true }
    }
}
