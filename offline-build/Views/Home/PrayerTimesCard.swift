import SwiftUI

struct PrayerTimesCard: View {
    @StateObject private var service = PrayerTimesService.shared
    @Environment(\.colorScheme) var cs

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow
            contentBody
            hijriLabel
        }
        .alehaCard()
        .onAppear { service.requestLocation() }
    }

    @ViewBuilder
    private var contentBody: some View {
        if service.isLoading {
            HStack { Spacer(); ProgressView(); Spacer() }.padding(.vertical, 8)
        } else if !service.prayerTimes.isEmpty {
            timesGrid
        } else {
            emptyState
        }
    }

    private var headerRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Label("Prayer Times", systemImage: "clock.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("NoorPrimary"))
                Text(service.locationName)
                    .font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Button { service.toggleNotifications() } label: {
                Image(systemName: service.notificationsEnabled ? "bell.fill" : "bell.slash")
                    .font(.subheadline)
                    .foregroundStyle(service.notificationsEnabled ? Color("NoorGold") : .secondary)
            }
        }
    }

    private var timesGrid: some View {
        HStack(spacing: 0) {
            ForEach(service.prayerTimes) { pt in
                let isNext = service.nextPrayer?.prayer == pt.prayer
                VStack(spacing: 6) {
                    Image(systemName: pt.prayer.icon)
                        .font(.caption)
                        .foregroundStyle(isNext ? Color("NoorGold") : (pt.isPast ? .secondary : Color("NoorPrimary")))
                    Text(pt.prayer.rawValue)
                        .font(.system(size: 9).weight(.semibold))
                        .foregroundStyle(isNext ? Color("NoorGold") : .primary)
                    Text(pt.timeString)
                        .font(.caption2.weight(isNext ? .bold : .regular))
                        .foregroundStyle(isNext ? Color("NoorGold") : .secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isNext ? Color("NoorGold").opacity(0.1) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }

    private var emptyState: some View {
        Button { service.requestLocation() } label: {
            Label("Enable Location for Prayer Times", systemImage: "location.fill")
                .font(.caption.weight(.medium))
                .foregroundStyle(Color("NoorPrimary"))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 8)
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
