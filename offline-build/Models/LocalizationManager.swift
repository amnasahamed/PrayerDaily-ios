import Foundation
import SwiftUI

// MARK: - Language
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case malayalam = "ml"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .malayalam: return "മലയാളം"
        }
    }

    var flag: String {
        switch self {
        case .english: return "🇬🇧"
        case .malayalam: return "🇮🇳"
        }
    }
}

// MARK: - Localization Manager
class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
        }
    }

    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        currentLanguage = AppLanguage(rawValue: saved) ?? .english
    }

    func t(_ key: LocalizedKey) -> String {
        return key.string(for: currentLanguage)
    }
}

// MARK: - Environment Key
struct LocalizationManagerKey: EnvironmentKey {
    static let defaultValue = LocalizationManager.shared
}

extension EnvironmentValues {
    var localization: LocalizationManager {
        get { self[LocalizationManagerKey.self] }
        set { self[LocalizationManagerKey.self] = newValue }
    }
}

// MARK: - Localized Strings
enum LocalizedKey {
    // Tab Bar
    case tabHome, tabQuran, tabSalah, tabLibrary, tabMore

    // Home
    case homeGreetingMorning, homeGreetingAfternoon, homeGreetingEvening, homeGreetingNight
    case homeSalah, homeHabits, homeQuickTools, homeVerseOfDay
    case homeAssalamu, homeWelcomeBack, homeTodayPrayers

    // Prayer names
    case prayerFajr, prayerDhuhr, prayerAsr, prayerMaghrib, prayerIsha, prayerJumuah

    // Salah Dashboard
    case salahTitle, salahToday, salahCalendar, salahQada, salahDhikr
    case salahCompleted, salahMissed, salahQadaTracker, salahLogPrayer
    case salahStreak, salahThisWeek, salahTotalLogged
    case salahAllPrayers, salahDayStreak, salahWeeklyConsistency
    case salahMarkDone, salahUndone, salahPrayerLog

    // Quran
    case quranTitle, quranSurahList, quranVerse, quranVerses, quranJuz
    case quranMakki, quranMadani, quranContinueReading, quranLastRead
    case quranTranslation, quranTransliteration, quranBookmark, quranShare
    case quranSearch, quranSearchPrompt

    // Library
    case libraryTitle, libraryKnowledge, libraryDuas, libraryTools, libraryGuides
    case libraryContinueReading, libraryHadith, libraryHadithCollection
    case libraryHadithCollections, libraryDuaCollection
    case libraryQibla, libraryTasbih, libraryIslamicCalendar

    // Qibla
    case qiblaTitle, qiblaDirection, qiblaFaceDirection, qiblaCalibrated
    case qiblaNeedsCalibration, qiblaAligned, qiblaPerfectAlignment
    case qiblaDistanceTo, qiblaMakkah, qiblaShareDirection
    case qiblaSpiritual1, qiblaSpiritual2

    // Dhikr / Tasbih
    case dhikrTitle, dhikrCount, dhikrReset, dhikrLifetime, dhikrTarget
    case dhikrSubhanAllah, dhikrAlhamdulillah, dhikrAllahuAkbar
    case dhikrAstaghfirullah, dhikrSalawat

    // Duas
    case duaTitle, duaMorning, duaEvening, duaAfterPrayer, duaForProtection
    case duaForForgiveness, duaForHealth, duaCategory

    // More / Settings
    case moreTitle, moreProfile, moreAppearance, morePrayerCalc, moreOffline
    case moreEmergency, moreStreakHistory, moreExport, moreCommunity
    case moreShare, moreInvite, moreAbout, moreLanguage
    case moreReset, moreResetTitle, moreResetMessage, moreResetConfirm

    // Profile
    case profileTitle, profileName, profileLocation, profileMadhab
    case profileMemberSince, profileEditName, profileSave, profileEdit
    case profileStreak, profilePrayers, profileThisWeek

    // Appearance
    case appearanceTitle, appearanceTheme, appearanceDark, appearanceLight, appearanceSystem
    case appearanceArabicSize, appearanceTranslation, appearanceTransliteration
    case appearanceFontSize

    // Prayer Settings
    case prayerSettingsTitle, prayerSettingsMethod, prayerSettingsAsr
    case prayerSettingsStandard, prayerSettingsHanafi
    case prayerSettingsLocation, prayerSettingsUsing, prayerSettingsAutoDetect

    // Emergency Guides
    case emergencyTitle, emergencyJanazah, emergencyRuqyah, emergencyNikah, emergencyTravel

    // Offline
    case offlineTitle, offlineSaved, offlineDownload, offlineSize

    // Common
    case commonDone, commonCancel, commonSave, commonEdit, commonClose, commonShare
    case commonNext, commonBack, commonSearch, commonLoading, commonError
    case commonNotSet, commonVersion, commonMadeWith

    // Streak / Stats
    case streakCurrent, streakBest, streakHistory, streakLast7, streakLast30
    case streakAll5, streakNone

    // Export
    case exportTitle, exportButton, exportReady, exportPrayerLogs
    case exportTotalPrayers, exportDhikrLifetime, exportDaysTracked

    // Smart Header
    case headerNextPrayer, headerIn, headerKm, headerToMakkah

    // Hadith
    case hadithTitle, hadithNarrated, hadithSource, hadithShare

    // Qada Tracker
    case qadaAllCaughtUp, qadaTotalToMakeUp, qadaSmartEstimate, qadaApplyEstimate
    case qadaNoMissed30Days, qadaMissedPrayersToMakeUp, qadaRemaining

    func string(for lang: AppLanguage) -> String {
        switch lang {
        case .english: return englishValue
        case .malayalam: return malayalamValue
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private var englishValue: String {
        switch self {
        // Tabs
        case .tabHome: return "Home"
        case .tabQuran: return "Quran"
        case .tabSalah: return "Salah"
        case .tabLibrary: return "Library"
        case .tabMore: return "More"

        // Home
        case .homeGreetingMorning: return "Good Morning"
        case .homeGreetingAfternoon: return "Good Afternoon"
        case .homeGreetingEvening: return "Good Evening"
        case .homeGreetingNight: return "Good Night"
        case .homeSalah: return "Salah"
        case .homeHabits: return "Habits"
        case .homeQuickTools: return "Quick Tools"
        case .homeVerseOfDay: return "Verse of the Day"
        case .homeAssalamu: return "Assalamu Alaikum"
        case .homeWelcomeBack: return "Welcome back"
        case .homeTodayPrayers: return "Today's Prayers"

        // Prayer names
        case .prayerFajr: return "Fajr"
        case .prayerDhuhr: return "Dhuhr"
        case .prayerAsr: return "Asr"
        case .prayerMaghrib: return "Maghrib"
        case .prayerIsha: return "Isha"
        case .prayerJumuah: return "Jumuah"

        // Salah
        case .salahTitle: return "Salah"
        case .salahToday: return "Today"
        case .salahCalendar: return "Calendar"
        case .salahQada: return "Qada"
        case .salahDhikr: return "Dhikr"
        case .salahCompleted: return "Completed"
        case .salahMissed: return "Missed"
        case .salahQadaTracker: return "Qada Tracker"
        case .salahLogPrayer: return "Log Prayer"
        case .salahStreak: return "Day Streak"
        case .salahThisWeek: return "This Week"
        case .salahTotalLogged: return "Total Logged"
        case .salahAllPrayers: return "All Prayers"
        case .salahDayStreak: return "Day Streak"
        case .salahWeeklyConsistency: return "Weekly Consistency"
        case .salahMarkDone: return "Mark Done"
        case .salahUndone: return "Undo"
        case .salahPrayerLog: return "Prayer Log"

        // Quran
        case .quranTitle: return "Quran"
        case .quranSurahList: return "Surah List"
        case .quranVerse: return "Verse"
        case .quranVerses: return "verses"
        case .quranJuz: return "Juz"
        case .quranMakki: return "Makki"
        case .quranMadani: return "Madani"
        case .quranContinueReading: return "Continue Reading"
        case .quranLastRead: return "Last Read"
        case .quranTranslation: return "Translation"
        case .quranTransliteration: return "Transliteration"
        case .quranBookmark: return "Bookmark"
        case .quranShare: return "Share"
        case .quranSearch: return "Search"
        case .quranSearchPrompt: return "Search surahs..."

        // Library
        case .libraryTitle: return "Library"
        case .libraryKnowledge: return "Knowledge"
        case .libraryDuas: return "Duas"
        case .libraryTools: return "Tools"
        case .libraryGuides: return "Guides"
        case .libraryContinueReading: return "Continue Reading"
        case .libraryHadith: return "Hadith"
        case .libraryHadithCollection: return "Hadith Collection"
        case .libraryHadithCollections: return "Hadith Collections"
        case .libraryDuaCollection: return "Dua Collection"
        case .libraryQibla: return "Qibla"
        case .libraryTasbih: return "Tasbih"
        case .libraryIslamicCalendar: return "Islamic Calendar"

        // Qibla
        case .qiblaTitle: return "Qibla"
        case .qiblaDirection: return "Qibla Direction"
        case .qiblaFaceDirection: return "Face this direction to pray"
        case .qiblaCalibrated: return "Compass calibrated"
        case .qiblaNeedsCalibration: return "Move device in figure-8"
        case .qiblaAligned: return "Aligned"
        case .qiblaPerfectAlignment: return "Perfect Alignment"
        case .qiblaDistanceTo: return "from Makkah"
        case .qiblaMakkah: return "Makkah"
        case .qiblaShareDirection: return "Share Qibla Direction"
        case .qiblaSpiritual1: return "Align your heart before your direction."
        case .qiblaSpiritual2: return "Stand with intention."

        // Dhikr
        case .dhikrTitle: return "Dhikr"
        case .dhikrCount: return "Count"
        case .dhikrReset: return "Reset"
        case .dhikrLifetime: return "Lifetime"
        case .dhikrTarget: return "Target"
        case .dhikrSubhanAllah: return "Subhan Allah"
        case .dhikrAlhamdulillah: return "Alhamdulillah"
        case .dhikrAllahuAkbar: return "Allahu Akbar"
        case .dhikrAstaghfirullah: return "Astaghfirullah"
        case .dhikrSalawat: return "Salawat"

        // Duas
        case .duaTitle: return "Duas"
        case .duaMorning: return "Morning"
        case .duaEvening: return "Evening"
        case .duaAfterPrayer: return "After Prayer"
        case .duaForProtection: return "Protection"
        case .duaForForgiveness: return "Forgiveness"
        case .duaForHealth: return "Health"
        case .duaCategory: return "Category"

        // More
        case .moreTitle: return "More"
        case .moreProfile: return "Profile"
        case .moreAppearance: return "Appearance"
        case .morePrayerCalc: return "Prayer Calculation"
        case .moreOffline: return "Offline Content"
        case .moreEmergency: return "Emergency Guides"
        case .moreStreakHistory: return "Streak History"
        case .moreExport: return "Export My Data"
        case .moreCommunity: return "Community"
        case .moreShare: return "Share PrayerDaily"
        case .moreInvite: return "Invite Friends"
        case .moreAbout: return "About PrayerDaily"
        case .moreLanguage: return "Language"
        case .moreReset: return "Reset App"
        case .moreResetTitle: return "Reset Everything?"
        case .moreResetMessage: return "This will permanently clear all prayer logs, dhikr counts, qada records, bookmarks, and preferences. This cannot be undone."
        case .moreResetConfirm: return "Reset Everything"

        // Profile
        case .profileTitle: return "Profile"
        case .profileName: return "Your Name"
        case .profileLocation: return "Location"
        case .profileMadhab: return "Madhab"
        case .profileMemberSince: return "Member since"
        case .profileEditName: return "Your name"
        case .profileSave: return "Save"
        case .profileEdit: return "Edit"
        case .profileStreak: return "Streak"
        case .profilePrayers: return "Prayers"
        case .profileThisWeek: return "This Week"

        // Appearance
        case .appearanceTitle: return "Appearance"
        case .appearanceTheme: return "Theme"
        case .appearanceDark: return "Dark"
        case .appearanceLight: return "Light"
        case .appearanceSystem: return "System"
        case .appearanceArabicSize: return "Arabic Font Size"
        case .appearanceTranslation: return "Show Translation"
        case .appearanceTransliteration: return "Show Transliteration"
        case .appearanceFontSize: return "Font Size"

        // Prayer Settings
        case .prayerSettingsTitle: return "Prayer Calculation"
        case .prayerSettingsMethod: return "Calculation Method"
        case .prayerSettingsAsr: return "Asr Juristic Rule"
        case .prayerSettingsStandard: return "Standard (Shafi'i / Maliki / Hanbali)"
        case .prayerSettingsHanafi: return "Hanafi (Later)"
        case .prayerSettingsLocation: return "Location"
        case .prayerSettingsUsing: return "Using"
        case .prayerSettingsAutoDetect: return "Auto-detect"

        // Emergency
        case .emergencyTitle: return "Emergency Guides"
        case .emergencyJanazah: return "Janazah Guide"
        case .emergencyRuqyah: return "Ruqyah"
        case .emergencyNikah: return "Nikah"
        case .emergencyTravel: return "Travel Prayer"

        // Offline
        case .offlineTitle: return "Offline Content"
        case .offlineSaved: return "surahs saved"
        case .offlineDownload: return "Download"
        case .offlineSize: return "Size"

        // Common
        case .commonDone: return "Done"
        case .commonCancel: return "Cancel"
        case .commonSave: return "Save"
        case .commonEdit: return "Edit"
        case .commonClose: return "Close"
        case .commonShare: return "Share"
        case .commonNext: return "Next"
        case .commonBack: return "Back"
        case .commonSearch: return "Search"
        case .commonLoading: return "Loading…"
        case .commonError: return "Something went wrong"
        case .commonNotSet: return "Not set"
        case .commonVersion: return "Version"
        case .commonMadeWith: return "Made with care for the Muslim community"

        // Streak
        case .streakCurrent: return "Current\nStreak"
        case .streakBest: return "Best\nStreak"
        case .streakHistory: return "Streak History"
        case .streakLast7: return "Last 7 Days"
        case .streakLast30: return "Last 30 Days"
        case .streakAll5: return "All 5"
        case .streakNone: return "None"

        // Export
        case .exportTitle: return "Export Data"
        case .exportButton: return "Export Summary"
        case .exportReady: return "Export ready — sharing…"
        case .exportPrayerLogs: return "Prayer logs"
        case .exportTotalPrayers: return "Total prayers logged"
        case .exportDhikrLifetime: return "Dhikr lifetime"
        case .exportDaysTracked: return "Days tracked"

        // Header
        case .headerNextPrayer: return "Next"
        case .headerIn: return "in"
        case .headerKm: return "km"
        case .headerToMakkah: return "to Makkah"

        // Hadith
        case .hadithTitle: return "Hadith"
        case .hadithNarrated: return "Narrated by"
        case .hadithSource: return "Source"
        case .hadithShare: return "Share"

        // Qada Tracker
        case .qadaAllCaughtUp: return "All caught up! Alhamdulillah"
        case .qadaTotalToMakeUp: return "Total Qada to Make Up"
        case .qadaSmartEstimate: return "Smart Estimate"
        case .qadaApplyEstimate: return "Apply Estimate"
        case .qadaNoMissed30Days: return "No missed prayers detected in your last 30 days of logs. Keep it up!"
        case .qadaMissedPrayersToMakeUp: return "Missed Prayers to Make Up"
        case .qadaRemaining: return "remaining"
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private var malayalamValue: String {
        switch self {
        // Tabs
        case .tabHome: return "ഹോം"
        case .tabQuran: return "ഖുർആൻ"
        case .tabSalah: return "നമസ്കാരം"
        case .tabLibrary: return "ലൈബ്രറി"
        case .tabMore: return "കൂടുതൽ"

        // Home
        case .homeGreetingMorning: return "ശുഭ പ്രഭാതം"
        case .homeGreetingAfternoon: return "ശുഭ ഉച്ചയ്ക്ക്"
        case .homeGreetingEvening: return "ശുഭ സന്ധ്യ"
        case .homeGreetingNight: return "ശുഭ രാത്രി"
        case .homeSalah: return "നമസ്കാരം"
        case .homeHabits: return "ശീലങ്ങൾ"
        case .homeQuickTools: return "ദ്രുത ഉപകരണങ്ങൾ"
        case .homeVerseOfDay: return "ഇന്നത്തെ ആയത്ത്"
        case .homeAssalamu: return "അസ്സലാമു അലൈക്കും"
        case .homeWelcomeBack: return "സ്വാഗതം"
        case .homeTodayPrayers: return "ഇന്നത്തെ നമസ്കാരം"

        // Prayer names
        case .prayerFajr: return "ഫജ്ർ"
        case .prayerDhuhr: return "ദുഹ്ർ"
        case .prayerAsr: return "അസ്ർ"
        case .prayerMaghrib: return "മഗ്‌രിബ്"
        case .prayerIsha: return "ഇശാ"
        case .prayerJumuah: return "ജുമുഅ"

        // Salah
        case .salahTitle: return "നമസ്കാരം"
        case .salahToday: return "ഇന്ന്"
        case .salahCalendar: return "കലണ്ടർ"
        case .salahQada: return "ഖദ"
        case .salahDhikr: return "ദിക്ർ"
        case .salahCompleted: return "പൂർത്തിയാക്കി"
        case .salahMissed: return "വിട്ടുപോയി"
        case .salahQadaTracker: return "ഖദ ട്രാക്കർ"
        case .salahLogPrayer: return "നമസ്കാരം രേഖപ്പെടുത്തുക"
        case .salahStreak: return "ദിവസ സ്ട്രീക്ക്"
        case .salahThisWeek: return "ഈ ആഴ്ച"
        case .salahTotalLogged: return "മൊത്തം രേഖ"
        case .salahAllPrayers: return "എല്ലാ നമസ്കാരവും"
        case .salahDayStreak: return "ദിവസ സ്ട്രീക്ക്"
        case .salahWeeklyConsistency: return "ആഴ്ചതോറുമുള്ള കൃത്യത"
        case .salahMarkDone: return "പൂർത്തിയായി"
        case .salahUndone: return "പൂർവ്വസ്ഥിതി"
        case .salahPrayerLog: return "നമസ്കാര ലോഗ്"

        // Quran
        case .quranTitle: return "ഖുർആൻ"
        case .quranSurahList: return "സൂറ പട്ടിക"
        case .quranVerse: return "ആയത്ത്"
        case .quranVerses: return "ആയത്തുകൾ"
        case .quranJuz: return "ജുസ്ഉ"
        case .quranMakki: return "മക്കി"
        case .quranMadani: return "മദനി"
        case .quranContinueReading: return "വായന തുടരുക"
        case .quranLastRead: return "അവസാനം വായിച്ചത്"
        case .quranTranslation: return "പരിഭാഷ"
        case .quranTransliteration: return "ലിപ്യന്തരണം"
        case .quranBookmark: return "ബുക്ക്മാർക്ക്"
        case .quranShare: return "പങ്കിടുക"
        case .quranSearch: return "തിരയൽ"
        case .quranSearchPrompt: return "സൂറകൾ തിരയുക..."

        // Library
        case .libraryTitle: return "ലൈബ്രറി"
        case .libraryKnowledge: return "അറിവ്"
        case .libraryDuas: return "ദുആകൾ"
        case .libraryTools: return "ഉപകരണങ്ങൾ"
        case .libraryGuides: return "മാർഗ്ഗദർശികൾ"
        case .libraryContinueReading: return "വായന തുടരുക"
        case .libraryHadith: return "ഹദീസ്"
        case .libraryHadithCollection: return "ഹദീസ് ശേഖരം"
        case .libraryHadithCollections: return "ഹദീസ് ശേഖരങ്ങൾ"
        case .libraryDuaCollection: return "ദുആ ശേഖരം"
        case .libraryQibla: return "ഖിബ്‌ല"
        case .libraryTasbih: return "തസ്ബീഹ്"
        case .libraryIslamicCalendar: return "ഇസ്‌ലാമിക കലണ്ടർ"

        // Qibla
        case .qiblaTitle: return "ഖിബ്‌ല"
        case .qiblaDirection: return "ഖിബ്‌ലാ ദിശ"
        case .qiblaFaceDirection: return "നമസ്കരിക്കാൻ ഈ ദിശ നോക്കുക"
        case .qiblaCalibrated: return "കോമ്പസ് ശരിയാക്കി"
        case .qiblaNeedsCalibration: return "ഉപകരണം ∞ ആകൃതിയിൽ ചലിപ്പിക്കുക"
        case .qiblaAligned: return "ദിശ ശരി"
        case .qiblaPerfectAlignment: return "കൃത്യമായ ദിശ"
        case .qiblaDistanceTo: return "മക്കയിൽ നിന്ന്"
        case .qiblaMakkah: return "മക്ക"
        case .qiblaShareDirection: return "ഖിബ്‌ലാ ദിശ പങ്കിടുക"
        case .qiblaSpiritual1: return "ദിശ ശരിയാക്കുന്നതിന് മുൻപ് ഹൃദയം ശരിയാക്കൂ."
        case .qiblaSpiritual2: return "നിയ്യത്തോടെ നിൽക്കൂ."

        // Dhikr
        case .dhikrTitle: return "ദിക്ർ"
        case .dhikrCount: return "എണ്ണം"
        case .dhikrReset: return "പുനഃക്രമീകരിക്കുക"
        case .dhikrLifetime: return "ആകെ"
        case .dhikrTarget: return "ലക്ഷ്യം"
        case .dhikrSubhanAllah: return "സുബ്ഹാനള്ളാഹ്"
        case .dhikrAlhamdulillah: return "അൽഹംദുലില്ലാഹ്"
        case .dhikrAllahuAkbar: return "അള്ളാഹു അക്ബർ"
        case .dhikrAstaghfirullah: return "അസ്തഗ്ഫിറുള്ളാഹ്"
        case .dhikrSalawat: return "സ്വലാത്ത്"

        // Duas
        case .duaTitle: return "ദുആകൾ"
        case .duaMorning: return "പ്രഭാത ദുആ"
        case .duaEvening: return "സന്ധ്യ ദുആ"
        case .duaAfterPrayer: return "നമസ്കാരത്തിനു ശേഷം"
        case .duaForProtection: return "സംരക്ഷണം"
        case .duaForForgiveness: return "പൊറുക്കൽ"
        case .duaForHealth: return "ആരോഗ്യം"
        case .duaCategory: return "വിഭാഗം"

        // More
        case .moreTitle: return "കൂടുതൽ"
        case .moreProfile: return "പ്രൊഫൈൽ"
        case .moreAppearance: return "രൂപം"
        case .morePrayerCalc: return "നമസ്കാര കണക്കുകൂട്ടൽ"
        case .moreOffline: return "ഓഫ്‌ലൈൻ ഉള്ളടക്കം"
        case .moreEmergency: return "അടിയന്തര ഗൈഡുകൾ"
        case .moreStreakHistory: return "സ്ട്രീക്ക് ചരിത്രം"
        case .moreExport: return "ഡാറ്റ എക്സ്പോർട്ട്"
        case .moreCommunity: return "കൂട്ടായ്മ"
        case .moreShare: return "ആലിഹ പങ്കിടുക"
        case .moreInvite: return "സുഹൃത്തുക്കളെ ക്ഷണിക്കുക"
        case .moreAbout: return "ആലിഹ നെ കുറിച്ച്"
        case .moreLanguage: return "ഭാഷ"
        case .moreReset: return "ആപ്പ് റീസെറ്റ്"
        case .moreResetTitle: return "എല്ലാം മായ്ക്കണോ?"
        case .moreResetMessage: return "നമസ്കാര ലോഗ്, ദിക്ർ എണ്ണം, ഖദ രേഖ, ബുക്ക്മാർക്ക്, ക്രമീകരണങ്ങൾ എന്നിവ ശാശ്വതമായി നഷ്ടപ്പെടും. ഇത് പഴയപടിയാക്കാൻ കഴിയില്ല."
        case .moreResetConfirm: return "എല്ലാം മായ്ക്കുക"

        // Profile
        case .profileTitle: return "പ്രൊഫൈൽ"
        case .profileName: return "നിങ്ങളുടെ പേര്"
        case .profileLocation: return "സ്ഥലം"
        case .profileMadhab: return "മദ്ഹബ്"
        case .profileMemberSince: return "അംഗം"
        case .profileEditName: return "നിങ്ങളുടെ പേര്"
        case .profileSave: return "സേവ്"
        case .profileEdit: return "എഡിറ്റ്"
        case .profileStreak: return "സ്ട്രീക്ക്"
        case .profilePrayers: return "നമസ്കാരം"
        case .profileThisWeek: return "ഈ ആഴ്ച"

        // Appearance
        case .appearanceTitle: return "രൂപം"
        case .appearanceTheme: return "തീം"
        case .appearanceDark: return "ഇരുൾ"
        case .appearanceLight: return "പ്രകാശം"
        case .appearanceSystem: return "സിസ്റ്റം"
        case .appearanceArabicSize: return "അറബി ഫോണ്ട് വലിപ്പം"
        case .appearanceTranslation: return "പരിഭാഷ കാണിക്കുക"
        case .appearanceTransliteration: return "ലിപ്യന്തരണം കാണിക്കുക"
        case .appearanceFontSize: return "ഫോണ്ട് വലിപ്പം"

        // Prayer Settings
        case .prayerSettingsTitle: return "നമസ്കാര കണക്കുകൂട്ടൽ"
        case .prayerSettingsMethod: return "കണക്കുകൂട്ടൽ രീതി"
        case .prayerSettingsAsr: return "അസ്ർ ഫിഖ്ഹ് നിയമം"
        case .prayerSettingsStandard: return "സ്റ്റാൻഡേർഡ് (ശാഫിഈ / മാലിക്കി / ഹൻബലി)"
        case .prayerSettingsHanafi: return "ഹനഫി (വൈകിയ)"
        case .prayerSettingsLocation: return "സ്ഥലം"
        case .prayerSettingsUsing: return "ഉപയോഗിക്കുന്നത്"
        case .prayerSettingsAutoDetect: return "സ്വയം കണ്ടെത്തുക"

        // Emergency
        case .emergencyTitle: return "അടിയന്തര ഗൈഡുകൾ"
        case .emergencyJanazah: return "ജനാസ ഗൈഡ്"
        case .emergencyRuqyah: return "റുഖ്‌യ"
        case .emergencyNikah: return "നിക്കാഹ്"
        case .emergencyTravel: return "യാത്രാ നമസ്കാരം"

        // Offline
        case .offlineTitle: return "ഓഫ്‌ലൈൻ ഉള്ളടക്കം"
        case .offlineSaved: return "സൂറകൾ സേവ് ചെയ്തു"
        case .offlineDownload: return "ഡൗൺലോഡ്"
        case .offlineSize: return "വലിപ്പം"

        // Common
        case .commonDone: return "പൂർത്തി"
        case .commonCancel: return "റദ്ദാക്കുക"
        case .commonSave: return "സേവ്"
        case .commonEdit: return "എഡിറ്റ്"
        case .commonClose: return "അടയ്ക്കുക"
        case .commonShare: return "പങ്കിടുക"
        case .commonNext: return "അടുത്തത്"
        case .commonBack: return "തിരിച്ച്"
        case .commonSearch: return "തിരയൽ"
        case .commonLoading: return "ലോഡ് ആകുന്നു…"
        case .commonError: return "എന്തോ കുഴപ്പം സംഭവിച്ചു"
        case .commonNotSet: return "സജ്ജമാക്കിയിട്ടില്ല"
        case .commonVersion: return "പതിപ്പ്"
        case .commonMadeWith: return "മുസ്‌ലിം സമൂഹത്തിന് സ്നേഹത്തോടെ നിർമ്മിച്ചത്"

        // Streak
        case .streakCurrent: return "ഇപ്പോഴത്തെ\nസ്ട്രീക്ക്"
        case .streakBest: return "മികച്ച\nസ്ട്രീക്ക്"
        case .streakHistory: return "സ്ട്രീക്ക് ചരിത്രം"
        case .streakLast7: return "കഴിഞ്ഞ 7 ദിവസം"
        case .streakLast30: return "കഴിഞ്ഞ 30 ദിവസം"
        case .streakAll5: return "5-ഉം"
        case .streakNone: return "ഒന്നുമില്ല"

        // Export
        case .exportTitle: return "ഡാറ്റ എക്സ്പോർട്ട്"
        case .exportButton: return "സംഗ്രഹം എക്സ്പോർട്ട്"
        case .exportReady: return "എക്സ്പോർട്ട് തയ്യാർ — പങ്കിടുന്നു…"
        case .exportPrayerLogs: return "നമസ്കാര ലോഗ്"
        case .exportTotalPrayers: return "മൊത്തം നമസ്കാരം"
        case .exportDhikrLifetime: return "ദിക്ർ ആകെ"
        case .exportDaysTracked: return "ട്രാക്ക് ചെയ്ത ദിവസങ്ങൾ"

        // Header
        case .headerNextPrayer: return "അടുത്തത്"
        case .headerIn: return "ൽ"
        case .headerKm: return "കി.മീ"
        case .headerToMakkah: return "മക്കയിലേക്ക്"

        // Hadith
        case .hadithTitle: return "ഹദീസ്"
        case .hadithNarrated: return "റിപ്പോർട്ട് ചെയ്തത്"
        case .hadithSource: return "ഉറവിടം"
        case .hadithShare: return "പങ്കിടുക"

        // Qada Tracker
        case .qadaAllCaughtUp: return "എല്ലാം ശരി! അൽഹംദുലില്ലാഹ്"
        case .qadaTotalToMakeUp: return "ഖദ ആക്കാനുള്ള മൊത്തം"
        case .qadaSmartEstimate: return "സ്മാർട്ട് കണക്ക്"
        case .qadaApplyEstimate: return "കണക്ക് ചേർക്കുക"
        case .qadaNoMissed30Days: return "കഴിഞ്ഞ 30 ദിവസത്തിൽ വിട്ടുപോയ നമസ്കാരങ്ങൾ ഇല്ല. അൽഹംദുലില്ലാഹ്!"
        case .qadaMissedPrayersToMakeUp: return "ഖദ ആക്കേണ്ട നമസ്കാരം"
        case .qadaRemaining: return "ബാക്കി"
        }
    }
}
