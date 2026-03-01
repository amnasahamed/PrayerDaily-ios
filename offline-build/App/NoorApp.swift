import SwiftUI
import UserNotifications

@main
struct NoorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var selectedTab: AppTab = .home
    @StateObject private var salahStore = SalahStore()
    @StateObject private var localization = LocalizationManager.shared
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 28
    @AppStorage("translationEnabled") private var translationEnabled: Bool = true
    @AppStorage("transliterationEnabled") private var transliterationEnabled: Bool = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false

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
        configureNavigationBarAppearance()
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
        .onReceive(NotificationCenter.default.publisher(for: .didTapPrayerNotification)) { note in
            if let id = note.object as? String, id.hasPrefix("prayer_") {
                selectedTab = .salah
            }
        }
    }
}

// MARK: - App Delegate (Notification handling)
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        // Re-schedule notifications if permission was previously granted
        NotificationService.shared.checkStatus { status in
            if status == .authorized {
                NotificationService.shared.scheduleDailyPrayerReminders()
                NotificationService.shared.scheduleDailyVerseNotification()
            }
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
        // Post a notification so the app can navigate if needed
        NotificationCenter.default.post(name: .didTapPrayerNotification, object: id)
        completionHandler()
    }
}

extension Notification.Name {
    static let didTapPrayerNotification = Notification.Name("didTapPrayerNotification")
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
