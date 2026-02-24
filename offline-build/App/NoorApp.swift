import SwiftUI

@main
struct NoorApp: App {
    @State private var selectedTab: AppTab = .home

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label(AppTab.home.rawValue, systemImage: AppTab.home.icon) }
                    .tag(AppTab.home)
                QuranPlaceholderView()
                    .tabItem { Label(AppTab.quran.rawValue, systemImage: AppTab.quran.icon) }
                    .tag(AppTab.quran)
                SalahPlaceholderView()
                    .tabItem { Label(AppTab.salah.rawValue, systemImage: AppTab.salah.icon) }
                    .tag(AppTab.salah)
                LibraryPlaceholderView()
                    .tabItem { Label(AppTab.library.rawValue, systemImage: AppTab.library.icon) }
                    .tag(AppTab.library)
                MorePlaceholderView()
                    .tabItem { Label(AppTab.more.rawValue, systemImage: AppTab.more.icon) }
                    .tag(AppTab.more)
            }
            .tint(Color("NoorPrimary"))
        }
    }
}
