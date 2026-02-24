import SwiftUI

struct PrayerTimesCard: View {
    @StateObject private var service = PrayerTimesService.shared
    @Environment(\.colorScheme) var cs
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow
            contentBody
            hijriLabel
        }
        .alehaCard()
        .onAppear {
            service.requestLocation()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appeared = true
            }
        }
    }

    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Label("Prayer Times", systemImage: "clock.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.alehaGreen)
                Text(service.locationName)
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                let gen = UIImpactFeedbackGenerator(style: .light)
                gen.impactOccurred()
                service.toggleNotifications()
            } label: {
                Image(systemName: service.notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                    .font(.subheadline)
                    .foregroundStyle(service.notificationsEnabled ? Color.alehaAmber : .secondary)
                    .padding(8)
                    .background(service.notificationsEnabled ? Color.alehaAmber.opacity(0.12) : Color(.systemGray5).opacity(0.4))
                    .clipShape(Circle())
            }
            .buttonStyle(BouncePressStyle())
        }
    }

    @ViewBuilder
    private var contentBody: some View {
        if service.isLoading {
            shimmerRow
        } else if !service.prayerTimes.isEmpty {
            timesGrid
        } else {
            emptyState
        }
    }

    private var shimmerRow: some View {
        HStack(spacing: 8) {
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .shimmer()
            }
        }
    }

    private var timesGrid: some View {
        HStack(spacing: 6) {
            ForEach(service.prayerTimes.indices, id: \.self) { i in
                let pt = service.prayerTimes[i]
                let isNext = service.nextPrayer?.prayer == pt.prayer
                PrayerTimeCell(
                    prayer: pt.prayer,
                    timeString: pt.timeString,
                    isPast: pt.isPast,
                    isNext: isNext,
                    index: i
                )
            }
        }
    }

    private var emptyState: some View {
        Button { service.requestLocation() } label: {
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(Color.alehaGreen)
                Text("Enable Location")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.alehaGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.alehaGreen.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(SpringPressStyle())
    }

    @ViewBuilder
    private var hijriLabel: some View {
        if !service.hijriDate.isEmpty {
            Text(service.hijriDate)
                .font(.caption2).foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

private struct PrayerTimeCell: View {
    let prayer: Prayer
    let timeString: String
    let isPast: Bool
    let isNext: Bool
    let index: Int
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: prayer.icon)
                .font(.system(size: 12))
                .foregroundStyle(isNext ? Color.alehaAmber : (isPast ? .secondary : Color.alehaGreen))
            Text(prayer.rawValue)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(isNext ? Color.alehaAmber : .primary)
            Text(timeString)
                .font(.system(size: 10, weight: isNext ? .bold : .regular))
                .foregroundStyle(isNext ? Color.alehaAmber : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isNext
                      ? Color.alehaAmber.opacity(0.12)
                      : (isPast ? Color(.systemGray5).opacity(0.3) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isNext ? Color.alehaAmber.opacity(0.35) : Color.clear, lineWidth: 1)
        )
        .scaleEffect(appeared ? 1.0 : 0.85)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(Double(index) * 0.07)) {
                appeared = true
            }
        }
    }
}
