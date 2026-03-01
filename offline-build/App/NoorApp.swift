import SwiftUI

@main
struct NoorApp: App {
    @State private var selectedTab: AppTab = .home
    @StateObject private var salahStore = SalahStore()
    @StateObject private var localization = LocalizationManager.shared
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 28
    @AppStorage("translationEnabled") private var translationEnabled: Bool = true
    @AppStorage("transliterationEnabled") private var transliterationEnabled: Bool = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    private var preferredColorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    init() {
        UITabBar.appearance().isHidden = true
        AppReviewManager.incrementSession()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    mainApp
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: hasCompletedOnboarding)
            .preferredColorScheme(preferredColorScheme)
        }
    }

    private var mainApp: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack { HomeView() }
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
            .id(salahStore.resetTrigger)

            FloatingTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
        .environmentObject(salahStore)
        .environmentObject(localization)
        .environment(\.arabicFontSize, arabicFontSize)
        .environment(\.translationEnabled, translationEnabled)
        .environment(\.transliterationEnabled, transliterationEnabled)
        .environment(\.localization, localization)
        .onAppear {
            AppReviewManager.requestReviewIfAppropriate()
        }
        .onChange(of: salahStore.resetTrigger) { _, _ in
            // Also reset onboarding flag so re-onboarding is possible after full reset
            // (user can choose to re-onboard; we keep it completed after reset for UX)
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
