import SwiftUI

struct QadaTrackerView: View {
    @EnvironmentObject var store: SalahStore
    @Environment(\.localization) var l10n

    private var totalQada: Int {
        store.qadaEntries.reduce(0) { $0 + $1.count }
    }

    private func localized(_ key: LocalizedKey) -> String {
        l10n.t(key)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                summaryCard
                autoSuggestCard
                prayerQadaList
                educationCard
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 12)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Summary
    private var summaryCard: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(totalQada == 0 ? Color.alehaGreen.opacity(0.12) : Color.alehaSaffron.opacity(0.12))
                    .frame(width: 72, height: 72)
                Image(systemName: totalQada == 0 ? "checkmark.circle.fill" : "arrow.uturn.backward.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(totalQada == 0 ? Color.alehaGreen : Color.alehaSaffron)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(totalQada)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(totalQada == 0 ? Color.alehaGreen : Color.alehaSaffron)
                    .contentTransition(.numericText())
                Text(totalQada == 0 ? localized(.qadaAllCaughtUp) : localized(.qadaTotalToMakeUp))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .noorCard()
    }

    // MARK: - Auto-Suggest
    private var autoSuggestCard: some View {
        let estimated = store.estimatedMissedPrayers
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.alehaAmber)
                Text(localized(.qadaSmartEstimate))
                    .font(.subheadline.weight(.semibold))
            }
            if estimated > 0 {
                Text("Based on your logs from the last 30 days, you have an estimated **\(estimated) missed prayer\(estimated > 1 ? "s" : "")** to make up.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    applyEstimate(estimated)
                } label: {
                    Label(localized(.qadaApplyEstimate), systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.alehaSaffron)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                Text(localized(.qadaNoMissed30Days))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .noorCard()
    }

    private func applyEstimate(_ count: Int) {
        // Distribute missed prayers evenly across prayer types
        let perPrayer = count / 5
        let remainder = count % 5
        for (i, prayer) in Prayer.allCases.enumerated() {
            let extra = i < remainder ? 1 : 0
            for _ in 0..<(perPrayer + extra) {
                store.incrementQada(for: prayer)
            }
        }
    }

    // MARK: - Qada List
    private var prayerQadaList: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(localized(.qadaMissedPrayersToMakeUp))
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
                .foregroundStyle(Color.alehaSaffron)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.prayer.localizedName(isMalayalam: l10n.currentLanguage == .malayalam)).font(.body.weight(.medium))
                Text("\(entry.count) \(localized(.qadaRemaining))").font(.caption).foregroundStyle(.secondary)
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
                    .foregroundStyle(entry.count > 0 ? Color.alehaSaffron : Color(.systemGray4))
            }
            .disabled(entry.count == 0)
            Text("\(entry.count)")
                .font(.title3.weight(.bold).monospacedDigit())
                .frame(minWidth: 30)
                .contentTransition(.numericText())
            Button {
                withAnimation { store.incrementQada(for: entry.prayer) }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.alehaGreen)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Education
    private var educationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "book.closed.fill")
                    .foregroundStyle(Color.alehaGreen)
                Text("What is Qada?")
                    .font(.subheadline.weight(.semibold))
            }
            Text("Qada (قضاء) is making up a prayer that was missed or delayed beyond its time — it is an obligation to pray it as soon as possible.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider()
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Color.alehaGreen.opacity(0.7))
                Text("How to use this tracker")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text("Add the number of missed prayers above. Each time you complete a Qada prayer, tap the minus (−) to reduce the count.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .noorCard()
    }
}
