import SwiftUI

struct SalahDashboard: View {
    @EnvironmentObject private var store: SalahStore
    @Environment(\.localization) var l10n
    @State private var selectedSection: SalahSection = .today
    @Namespace private var pillNS

    enum SalahSection: String, CaseIterable {
        case today = "today"
        case calendar = "calendar"
        case qada = "qada"
        case dhikr = "dhikr"

        func label(_ l10n: LocalizationManager) -> String {
            switch self {
            case .today: return l10n.t(.salahToday)
            case .calendar: return l10n.t(.salahCalendar)
            case .qada: return l10n.t(.salahQada)
            case .dhikr: return l10n.t(.salahDhikr)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sectionPicker
                tabContent
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(CalmingBackground())
            .navigationTitle(l10n.t(.salahTitle))
            .navigationBarTitleDisplayMode(.inline)
            .modifier(AlehaNavStyle())
        }
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SalahSection.allCases, id: \.self) { section in
                    sectionChip(section, label: section.label(l10n))
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.vertical, 12)
        }
    }

    private func sectionChip(_ section: SalahSection, label: String) -> some View {
        let isSelected = selectedSection == section
        return Button {
            let gen = UIImpactFeedbackGenerator(style: .soft)
            gen.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedSection = section
            }
        } label: {
            Text(label)
                .font(.subheadline.weight(isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(chipBackground(isSelected))
                .clipShape(Capsule())
        }
        .buttonStyle(SpringPressStyle())
    }

    @ViewBuilder
    private func chipBackground(_ isSelected: Bool) -> some View {
        if isSelected {
            Capsule()
                .fill(Color.alehaGreen)
                .matchedGeometryEffect(id: "salahPill", in: pillNS)
        } else {
            Capsule()
                .fill(Color(.systemGray5).opacity(0.5))
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedSection {
        case .today:    TodayPrayerView()
        case .calendar: CalendarPrayerView()
        case .qada:     QadaTrackerView()
        case .dhikr:    DhikrCounterView()
        }
    }
}
