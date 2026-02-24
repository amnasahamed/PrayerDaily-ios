import SwiftUI

struct PrayerTrackerCard: View {
    @Binding var prayers: [SalahLogEntry]

    private var completedCount: Int {
        prayers.filter(\.completed).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow
            prayerRow
            progressBar
        }
        .noorCard()
    }

    private var headerRow: some View {
        HStack {
            Label("Today's Salah", systemImage: "clock.fill")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Text("\(completedCount)/5")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color("NoorPrimary"))
        }
    }

    private var prayerRow: some View {
        HStack(spacing: 0) {
            ForEach(prayers.indices, id: \.self) { index in
                prayerItem(for: index)
                if index < prayers.count - 1 { Spacer() }
            }
        }
    }

    private func prayerItem(for index: Int) -> some View {
        let entry = prayers[index]
        return Button {
            withAnimation(.spring(response: 0.3)) {
                prayers[index].completed.toggle()
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(entry.completed ? Color("NoorPrimary") : Color(.systemGray5))
                        .frame(width: 44, height: 44)
                    Image(systemName: entry.prayer.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(entry.completed ? .white : .secondary)
                }
                Text(entry.prayer.rawValue)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(entry.completed ? Color("NoorPrimary") : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var progressBar: some View {
        let progress = Double(completedCount) / 5.0
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(.systemGray5))
                Capsule().fill(Color("NoorPrimary"))
                    .frame(width: geo.size.width * progress)
            }
        }
        .frame(height: 6)
    }
}
