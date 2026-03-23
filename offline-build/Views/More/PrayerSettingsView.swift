import SwiftUI

struct PrayerSettingsView: View {
    @EnvironmentObject var localization: LocalizationManager
    @ObservedObject private var service = PrayerTimesService.shared
    @AppStorage("profileMadhab") private var profileMadhab: String = "Hanafi"
    @State private var appeared = false
    @State private var showSaved = false

    var body: some View {
        ZStack {
            CalmingBackground().ignoresSafeArea()
            ScrollView {
                VStack(spacing: 18) {
                    infoCard.slideUp(appeared, delay: 0.05)
                    methodSection.slideUp(appeared, delay: 0.10)
                    asrSection.slideUp(appeared, delay: 0.16)
                    activeTimesCard.slideUp(appeared, delay: 0.22)
                    if showSaved { savedBanner.slideUp(appeared, delay: 0) }
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle(localization.t(.prayerSettingsTitle))
        .navigationBarTitleDisplayMode(.large)
        .modifier(AlehaNavStyle())
        .onAppear {
            withAnimation { appeared = true }
        }
    }

    // MARK: - Info Card
    private var infoCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle().fill(Color.alehaGreen.opacity(0.12)).frame(width: 42, height: 42)
                Image(systemName: "globe.desk.fill")
                    .font(.title3).foregroundStyle(Color.alehaGreen)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(localization.t(.prayerWhyMatter))
                    .font(.subheadline.weight(.semibold))
                Text(localization.t(.prayerSettingsWhyMatterDescription))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if !service.activeMethodName.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2).foregroundStyle(Color.alehaGreen)
                        Text("\(localization.t(.prayerActiveMethod)) \(service.activeMethodName)")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(Color.alehaGreen)
                    }
                    .padding(.top, 2)
                }
            }
        }
        .noorCard()
    }

    // MARK: - Calculation Method
    private var methodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(localization.t(.prayerSettingsMethod), systemImage: "doc.text.magnifyingglass")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.alehaGreen)
                Spacer()
                Text(localization.t(.prayerFajrIsha))
                    .font(.caption2).foregroundStyle(.secondary)
            }

            VStack(spacing: 0) {
                ForEach(Array(PrayerCalculationMethod.allCases.enumerated()), id: \.element.rawValue) { idx, method in
                    methodRow(method: method, isLast: idx == PrayerCalculationMethod.allCases.count - 1)
                }
            }
            .background(Color(.systemBackground).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.alehaGreen.opacity(0.12), lineWidth: 1)
            )
        }
        .noorCard()
    }

    private func methodRow(method: PrayerCalculationMethod, isLast: Bool) -> some View {
        let isSelected = service.calculationMethod == method
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                service.calculationMethod = method
            }
            triggerSaved()
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.alehaGreen : Color(.systemGray4), lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(Color.alehaGreen)
                            .frame(width: 11, height: 11)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.displayName)
                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? Color.alehaGreen : .primary)
                    Text(method.shortName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.alehaGreen)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if !isLast { Divider().padding(.leading, 46) }
        }
    }

    // MARK: - Asr Section
    private var asrSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(localization.t(.prayerSettingsAsr), systemImage: "sun.haze.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.alehaAmber)

            Text(localization.t(.prayerSettingsAsrDescription))
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                asrChip(method: .shafii, title: localization.t(.prayerSettingsAsrStandard), subtitle: localization.t(.prayerSettingsAsrShafiiSubtitle))
                asrChip(method: .hanafi, title: localization.t(.prayerSettingsAsrHanafi), subtitle: localization.t(.prayerSettingsAsrHanafiSubtitle))
            }
        }
        .noorCard()
    }

    private func asrChip(method: AsrJuristicMethod, title: String, subtitle: String) -> some View {
        let isSelected = service.asrMethod == method
        return Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                service.asrMethod = method
            }
            triggerSaved()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.caption).foregroundStyle(isSelected ? Color.alehaAmber : .secondary)
                    Text(title).font(.subheadline.weight(isSelected ? .semibold : .medium))
                        .foregroundStyle(isSelected ? Color.alehaAmber : .primary)
                }
                Text(subtitle).font(.caption2).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.alehaAmber.opacity(0.08) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.alehaAmber : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(SpringPressStyle())
    }

    // MARK: - Active Times Preview
    private var activeTimesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(localization.t(.prayerTodaysTimes), systemImage: "clock.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.alehaGreen)
                Spacer()
                if service.isLoading {
                    ProgressView().scaleEffect(0.7)
                }
            }
            if service.prayerTimes.isEmpty {
                Text(localization.t(.prayerEnableLocation))
                    .font(.caption).foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(service.prayerTimes) { pt in
                        HStack {
                            Image(systemName: pt.prayer.icon)
                                .font(.caption).foregroundStyle(Color.alehaGreen)
                                .frame(width: 20)
                            Text(pt.prayer.rawValue).font(.subheadline)
                            Spacer()
                            Text(pt.timeString)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(service.nextPrayer?.prayer == pt.prayer ? Color.alehaAmber : .primary)
                            if service.nextPrayer?.prayer == pt.prayer {
                                Text(localization.t(.headerNextPrayer))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.alehaAmber)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            if !service.locationName.isEmpty && service.locationName != "Locating..." {
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption2).foregroundStyle(.secondary)
                    Text(service.locationName)
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .noorCard()
    }

    // MARK: - Saved Banner
    private var savedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.alehaGreen)
            Text(localization.t(.prayerSettingsApplied)).font(.subheadline)
        }
        .padding(14)
        .background(Color.alehaGreen.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func triggerSaved() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showSaved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation { showSaved = false }
        }
    }
}


