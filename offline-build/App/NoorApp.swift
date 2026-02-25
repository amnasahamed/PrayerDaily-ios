import SwiftUI

@main
struct NoorApp: App {
    @State private var selectedTab: AppTab = .home
    @StateObject private var salahStore = SalahStore()
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 28
    @AppStorage("translationEnabled") private var translationEnabled: Bool = true
    @AppStorage("transliterationEnabled") private var transliterationEnabled: Bool = true

    private var preferredColorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    init() {
        UITabBar.appearance().isHidden = true
    }

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
                    MoreView()
                        .tag(AppTab.more)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.38, dampingFraction: 0.85), value: selectedTab)

                FloatingTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
            .environmentObject(salahStore)
            .preferredColorScheme(preferredColorScheme)
            .environment(\.arabicFontSize, arabicFontSize)
            .environment(\.translationEnabled, translationEnabled)
            .environment(\.transliterationEnabled, transliterationEnabled)
        }
    }
}

// MARK: - Environment Keys for global settings
private struct ArabicFontSizeKey: EnvironmentKey { static let defaultValue: Double = 28 }
private struct TranslationEnabledKey: EnvironmentKey { static let defaultValue: Bool = true }
private struct TransliterationEnabledKey: EnvironmentKey { static let defaultValue: Bool = true }

extension EnvironmentValues {
    var arabicFontSize: Double {
        get { self[ArabicFontSizeKey.self] }
        set { self[ArabicFontSizeKey.self] = newValue }
    }
    var translationEnabled: Bool {
        get { self[TranslationEnabledKey.self] }
        set { self[TranslationEnabledKey.self] = newValue }
    }
    var transliterationEnabled: Bool {
        get { self[TransliterationEnabledKey.self] }
        set { self[TransliterationEnabledKey.self] = newValue }
    }
}
