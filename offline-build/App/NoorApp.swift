import SwiftUI
import UserNotifications

@main
struct NoorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        AppReviewManager.incrementSession()
        configureNavigationBarAppearance()
        configureTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.alehaGreen)
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = UIColor(Color.alehaGreen)
    }
}

// MARK: - App Root View
struct AppRootView: View {
    @State private var selectedTab: AppTab = .home
    @StateObject private var salahStore = SalahStore()
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared

    @AppStorage("appearanceMode")          private var appearanceMode: String  = "system"
    @AppStorage("arabicFontSize")          private var arabicFontSize: Double  = 28
    @AppStorage("translationEnabled")      private var translationEnabled: Bool = true
    @AppStorage("transliterationEnabled")  private var transliterationEnabled: Bool = true
    @AppStorage("hasCompletedOnboarding")  private var hasCompletedOnboarding: Bool = false
    @AppStorage("notificationsEnabled")    private var notificationsEnabled: Bool = false

    private var preferredColorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }

    var body: some View {
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
        .onReceive(NotificationCenter.default.publisher(for: .didTapPrayerNotification)) { note in
            if let id = note.object as? String, id.hasPrefix("prayer_") {
                selectedTab = .salah
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .didTapQuickAccess)) { note in
            if let tab = note.object as? AppTab {
                selectedTab = tab
            }
        }
    }

    private var mainApp: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(localization.t(.tabHome), systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)

            SurahListView()
                .tabItem {
                    Label(localization.t(.tabQuran), systemImage: AppTab.quran.icon)
                }
                .tag(AppTab.quran)

            SalahDashboard()
                .tabItem {
                    Label(localization.t(.tabSalah), systemImage: AppTab.salah.icon)
                }
                .tag(AppTab.salah)

            LibraryView()
                .tabItem {
                    Label(localization.t(.tabLibrary), systemImage: AppTab.library.icon)
                }
                .tag(AppTab.library)

            MoreView()
                .tabItem {
                    Label(localization.t(.tabMore), systemImage: AppTab.more.icon)
                }
                .tag(AppTab.more)
        }
        .id(salahStore.resetTrigger)
        .ignoresSafeArea(.keyboard)
        .environmentObject(salahStore)
        .environmentObject(localization)
        .environment(\.arabicFontSize, arabicFontSize)
        .environment(\.translationEnabled, translationEnabled)
        .environment(\.transliterationEnabled, transliterationEnabled)
        .environment(\.localization, localization)
        .environmentObject(networkMonitor)
        .onAppear {
            AppReviewManager.requestReviewIfAppropriate()
        }
    }
}

// MARK: - App Delegate (Notification handling)
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        // Re-schedule notifications if permission was previously granted and not already scheduled today
        NotificationService.shared.checkStatus { status in
            guard status == .authorized else { return }
            let today = Calendar.current.startOfDay(for: Date())
            let lastScheduled = UserDefaults.standard.object(forKey: "lastNotifScheduleDate") as? Date
            guard lastScheduled.map({ Calendar.current.startOfDay(for: $0) }) != today else { return }
            NotificationService.shared.scheduleDailyPrayerReminders()
            NotificationService.shared.scheduleDailyVerseNotification()
            UserDefaults.standard.set(Date(), forKey: "lastNotifScheduleDate")
        }
        return true
    }

    // Show notification as banner even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }

    // Handle tap on notification — navigate to Salah tab
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 didReceive response: UNNotificationResponse,
                                 withCompletionHandler completionHandler: @escaping () -> Void) {
        let id = response.notification.request.identifier
        NSLog("[Notifications] Tapped notification: \(id)")
        NotificationCenter.default.post(name: .didTapPrayerNotification, object: id)
        completionHandler()
    }
}

extension Notification.Name {
    static let didTapPrayerNotification = Notification.Name("didTapPrayerNotification")
    static let didTapQuickAccess = Notification.Name("didTapQuickAccess")
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
