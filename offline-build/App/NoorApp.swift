import SwiftUI

@main
struct NoorApp: App {
    @State private var selectedTab: AppTab = .home

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(AppTab.home)
                    SurahListView()
                        .tag(AppTab.quran)
                    SalahDashboard()
                        .tag(AppTab.salah)
                    LibraryView()
                        .tag(AppTab.library)
                    MorePlaceholderView()
                        .tag(AppTab.more)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.38, dampingFraction: 0.85), value: selectedTab)

                FloatingTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}
