import SwiftUI

struct SalahDashboard: View {
    @StateObject private var store = SalahStore()
    @State private var selectedSection: SalahSection = .today

    enum SalahSection: String, CaseIterable {
        case today = "Today"
        case calendar = "Calendar"
        case qada = "Qada"
        case dhikr = "Dhikr"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sectionPicker
                tabContent
            }
            .background(CalmingBackground())
            .navigationTitle("Salah Tracker")
            .modifier(AlehaNavStyle())
        }
        .environmentObject(store)
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SalahSection.allCases, id: \.self) { section in
                    sectionChip(section)
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.vertical, 12)
        }
    }

    private func sectionChip(_ section: SalahSection) -> some View {
        let isSelected = selectedSection == section
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedSection = section }
        } label: {
            Text(section.rawValue)
                .font(.subheadline.weight(isSelected ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(isSelected ? Color.alehaGreen : Color(.systemGray5).opacity(0.6))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedSection {
        case .today: TodayPrayerView()
        case .calendar: CalendarPrayerView()
        case .qada: QadaTrackerView()
        case .dhikr: DhikrCounterView()
        }
    }
}
