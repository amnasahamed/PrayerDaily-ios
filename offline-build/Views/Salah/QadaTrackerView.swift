import SwiftUI

struct QadaTrackerView: View {
    @EnvironmentObject var store: SalahStore

    private var totalQada: Int {
        store.qadaEntries.reduce(0) { $0 + $1.count }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                summaryCard
                prayerQadaList
                infoCard
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.bottom, 30)
        }
    }

    // MARK: - Summary
    private var summaryCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color("NoorAccent"))
            Text("Total Qada Prayers")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(totalQada)")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(totalQada == 0 ? Color("NoorPrimary") : Color("NoorAccent"))
            if totalQada == 0 {
                Text("All caught up! Alhamdulillah ✨")
                    .font(.caption)
                    .foregroundStyle(Color("NoorPrimary"))
            }
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    // MARK: - Qada List
    private var prayerQadaList: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Missed Prayers to Make Up")
                .font(.subheadline.weight(.semibold))
            ForEach(store.qadaEntries) { entry in
                qadaRow(entry)
            }
        }
        .noorCard()
    }

    private func qadaRow(_ entry: QadaEntry) -> some View {
        HStack(spacing: 14) {
            Image(systemName: entry.prayer.icon)
                .font(.title3)
                .foregroundStyle(Color("NoorAccent"))
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.prayer.rawValue)
                    .font(.body.weight(.medium))
                Text("\(entry.count) remaining")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            counterButtons(entry)
        }
        .padding(.vertical, 4)
    }

    private func counterButtons(_ entry: QadaEntry) -> some View {
        HStack(spacing: 12) {
            Button {
                withAnimation { store.decrementQada(for: entry.prayer) }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(entry.count > 0 ? Color("NoorAccent") : Color(.systemGray4))
            }
            .disabled(entry.count == 0)

            Text("\(entry.count)")
                .font(.title3.weight(.bold).monospacedDigit())
                .frame(minWidth: 30)

            Button {
                withAnimation { store.incrementQada(for: entry.prayer) }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color("NoorPrimary"))
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Info
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("How to use", systemImage: "info.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("NoorPrimary"))
            Text("Add the number of missed prayers you need to make up. When you pray a Qada prayer, tap the minus button to track your progress.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .noorCard()
    }
}
