import SwiftUI

struct PrayerTimesCard: View {
    @StateObject private var service = PrayerTimesService.shared
    @Environment(\.colorScheme) var cs
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerRow
            contentBody
            hijriLabel
        }
        .alehaCard()
        .onAppear { service.requestLocation() }
    }

    private var headerRow: some View {
        HStack {
            Label(localization.t(.prayerTimesTitle), systemImage: "clock.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.alehaGreen)
            Spacer()
            bellButton
        }
    }

    private var bellButton: some View {
        Button {
            let gen = UIImpactFeedbackGenerator(style: .light)
            gen.impactOccurred()
            service.toggleNotifications()
        } label: {
            Image(systemName: service.notificationsEnabled ? "bell.fill" : "bell.slash.fill")
                .font(.system(size: 14))
                .foregroundStyle(service.notificationsEnabled ? Color.alehaAmber : .secondary)
                .padding(7)
                .background(service.notificationsEnabled ? Color.alehaAmber.opacity(0.12) : Color(.systemGray5).opacity(0.4))
                .clipShape(Circle())
        }
        .buttonStyle(BouncePressStyle())
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
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .shimmer()
            }
        }
    }

    private var timesGrid: some View {
        HStack(spacing: 5) {
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
                Image(systemName: "location.fill").foregroundStyle(Color.alehaGreen)
                Text(localization.t(.prayerTimesEnableLocation)).font(.subheadline.weight(.medium)).foregroundStyle(Color.alehaGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
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
    @Environment(\.colorScheme) var cs

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: prayer.icon)
                .font(.system(size: 13, weight: isNext ? .semibold : .regular))
                .foregroundStyle(cellColor)
            Text(prayer.rawValue)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(isNext ? Color.alehaSaffron : .primary)
            Text(timeString)
                .font(.system(size: 10, weight: isNext ? .bold : .regular))
                .foregroundStyle(isNext ? Color.alehaSaffron : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(cellBackground)
        .overlay(leftAccent)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .scaleEffect(appeared ? 1.0 : 0.88)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75).delay(Double(index) * 0.06)) {
                appeared = true
            }
        }
    }

    private var cellColor: Color {
        isNext ? Color.alehaSaffron : (isPast ? .secondary : Color.alehaGreen)
    }

    private var cellBackground: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(isNext
                  ? Color.alehaSaffron.opacity(0.10)
                  : (isPast ? Color(.systemGray5).opacity(0.25) : Color.clear))
    }

    private var leftAccent: some View {
        HStack {
            if isNext {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.alehaSaffron)
                    .frame(width: 3)
                    .padding(.vertical, 6)
            }
            Spacer()
        }
    }
}
