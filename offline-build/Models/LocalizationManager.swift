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
    case homeIslamicGuides, homeStreak, homeQadaLeft, homeNow, homeProgress, homeHadithOfDay, homeLocating
    case homeTodaySalah, homeSave, homeSaved, homeTafsirLess, homeTafsir
    case homeHadithOfTheDay, homeQuickAccess
    case homeKidsSection, homeComingSoon, homeKidsDescription, homeKids
    case homeToday, homeAllPrayersDone, homeThisWeek
    case homeMinutesUntil, homeHoursUntil, homeHoursMinutesUntil
    case homeTapToUnmark, homeTapToMark, homeCompleted, homeNotCompleted
    case prayerTimesTitle, prayerTimesEnableLocation

    // Prayer names
    case prayerFajr, prayerDhuhr, prayerAsr, prayerMaghrib, prayerIsha, prayerJumuah

    // Salah Dashboard
    case salahTitle, salahToday, salahCalendar, salahQada, salahDhikr
    case salahCompleted, salahMissed, salahQadaTracker, salahLogPrayer
    case salahStreak, salahThisWeek, salahTotalLogged
    case salahAllPrayers, salahDayStreak, salahWeeklyConsistency
    case salahMarkDone, salahUndone, salahPrayerLog
    case salahAllPrayersDone, salahMinMinutesUntil, salahHoursMinutesUntil
    case salahPrayed, salahClear

    // Quran
    case quranTitle, quranSurahList, quranVerse, quranVerses, quranJuz
    case quranMakki, quranMadani, quranContinueReading, quranLastRead
    case quranTranslation, quranTransliteration, quranBookmark, quranShare
    case quranSearch, quranSearchPrompt
    case quranNoSurahsYet, quranStartReading, quranFilterAll, quranFilterJuz
    case quranFilterMeccan, quranFilterMedinan, quranFilterCompleted, quranMinRemaining
    case quranPercentQuran, quranAyahs, quranLoadingSurah, quranConnectionIssue
    case quranRetry, quranOffline, quranOfflineBanner, quranSurahTypeBadge, quranUnableLoad
    case quranAyah, quranReadingModeArabic, quranReadingModeTranslation, quranReadingModeBoth
    case quranReadingModeFocus, surahMinRemaining, surahOfQuranProgress, surahBismillahTranslation

    // Library
    case libraryTitle, libraryKnowledge, libraryDuas, libraryTools, libraryGuides
    case libraryContinueReading, libraryHadith, libraryHadithCollection
    case libraryHadithCollections, libraryDuaCollection
    case libraryQibla, libraryTasbih, libraryIslamicCalendar
    case libraryIslamicTools, libraryIslamicGuides, libraryQiblaDesc, libraryDhikrDesc
    case libraryHijriDesc, libraryPrayerTrackerDesc, libraryEmergencyGuidesDesc
    case libraryNewMuslimGuideDesc, libraryFiqhBasicsDesc
    case libraryNewMuslimGuide, libraryFiqhBasics

    // Quick Tools
    case quickToolQibla, quickToolHijriCalendar, quickToolDhikrCounter, quickToolQuran, quickToolDuas
    case guideCategoryPurification, guideCategoryPrayer, guideCategoryWorship
    case guideCategoryFinanceFiqh, guideCategorySupplications

    // Hijri Date
    case hijriDate, hijriLoading

    // Qibla
    case qiblaTitle, qiblaDirection, qiblaFaceDirection, qiblaCalibrated
    case qiblaNeedsCalibration, qiblaAligned, qiblaPerfectAlignment
    case qiblaDistanceTo, qiblaMakkah, qiblaShareDirection
    case qiblaSpiritual1, qiblaSpiritual2
    case qiblaDetecting, qiblaLocationUnavailable, qiblaKmFrom, qiblaKmFromDecimal
    case qiblaAccurate, qiblaCalibrating, qiblaQiblaLabel
    case qiblaCardinalN, qiblaCardinalE, qiblaCardinalS, qiblaCardinalW
    case qiblaMyDirection, qiblaSharedVia

    // Dhikr / Tasbih
    case dhikrTitle, dhikrCount, dhikrReset, dhikrLifetime, dhikrTarget
    case dhikrSubhanAllah, dhikrAlhamdulillah, dhikrAllahuAkbar
    case dhikrAstaghfirullah, dhikrSalawat
    case dhikrSession, dhikrTargetReached, dhikrTapToCount, dhikrAllDhikr
    case dhikrSessionOverview, dhikrContinueReading

    // Duas
    case duaTitle, duaMorning, duaEvening, duaAfterPrayer, duaForProtection
    case duaForForgiveness, duaForHealth, duaCategory

    // More / Settings
    case moreTitle, moreProfile, moreAppearance, morePrayerCalc, moreOffline
    case moreEmergency, moreStreakHistory, moreExport, moreCommunity
    case moreShare, moreInvite, moreAbout, moreLanguage
    case moreReset, moreResetTitle, moreResetMessage, moreResetConfirm
    case moreProfileSubtitle, moreAppearanceSubtitle, morePrayerCalcSubtitle
    case moreStreakHistorySubtitle, moreExportSubtitle, moreAboutSubtitle, moreResetSubtitle
    case moreAppLanguage, moreLanguageDesc, moreLanguageFooter
    case aboutPrayerdaily

    // Profile
    case profileTitle, profileName, profileLocation, profileMadhab
    case profileMemberSince, profileEditName, profileSave, profileEdit
    case profileStreak, profilePrayers, profileThisWeek
    case profileCityCountry

    // Appearance
    case appearanceTitle, appearanceTheme, appearanceDark, appearanceLight, appearanceSystem
    case appearanceArabicSize, appearanceTranslation, appearanceTransliteration
    case appearanceFontSize, appearanceTakesEffect, appearanceThemeSet, appearanceAppliedIn
    case appearanceEnglishMeaning, appearanceRomanized

    // Prayer Settings
    case prayerSettingsTitle, prayerSettingsMethod, prayerSettingsAsr
    case prayerSettingsStandard, prayerSettingsHanafi
    case prayerSettingsLocation, prayerSettingsUsing, prayerSettingsAutoDetect
    case prayerTimes, prayerEnableLocation, prayerWhyMatter, prayerActiveMethod
    case prayerFajrIsha, prayerHanafiSchool, prayerLaterAsr, prayerShafiMalikiHanbali
    case prayerTodaysTimes, prayerSettingsApplied

    // Emergency Guides
    case emergencyTitle, emergencyJanazah, emergencyRuqyah, emergencyNikah, emergencyTravel
    case emergencySteps, emergencySections, emergencyStepCount, emergencySectionCount
    case emergencyIslamicGuides

    // Offline
    case offlineTitle, offlineSaved, offlineDownload, offlineSize
    case offlineStorageUsed, offlineSurahsSaved, offlineClearAll, offlineSavedInfo

    // Common
    case commonDone, commonCancel, commonSave, commonEdit, commonClose, commonShare
    case commonNext, commonBack, commonSearch, commonLoading, commonError
    case commonNotSet, commonVersion, commonMadeWith

    // Streak / Stats
    case streakCurrent, streakBest, streakHistory, streakLast7, streakLast30
    case streakAll5, streakNone
    case streakLegend34, streakLegend12
    case streakThisWeek

    // Export
    case exportTitle, exportButton, exportReady, exportPrayerLogs
    case exportTotalPrayers, exportDhikrLifetime, exportDaysTracked
    case exportYourData, exportDescription, exportCurrentStreakLabel

    // Tracker
    case trackerPrayerTracker, trackerTodaysLog, trackerClear

    // Hijri Calendar
    case hijriUpcomingEvents, hijriIslamicMonths, hijriSacredMonth
    case hijriBirthProphet, hijriMonthFasting, hijriEidFitr, hijriHajjEid, hijriAH

    // Dua Source
    case duaSource

    // Today Salah
    case todayPrayersCount, todayAllDone, todayRemainingPrayers, todayShareProgress
    case todayShareSubtitle, todayExceptional, todayGreatProgress, todayGettingStarted
    case todayBuildHabit, todayLogPrayers, todaySwipeToLog, todayPrayed
    case todayStreakDay, todayShareProgressTitle, todayShareReady, todayShareInspire
    case todayShareCard, todayPrayersCompleted, todayAllToday
    case todayOf5Prayers, todayAllPrayersDone, todayPrayersRemaining, todayLabel
    case shareProgressTitle, shareReadyToInspire, shareInspireDescription
    case shareCard, sharePrayersCompleted, sharePrayersLoggedToday
    case shareDayStreak, shareAll, shareAllToday, todayShareStatsDesc

    // Calendar Salah
    case calendarPrayersLogged, calendarCompletion, calendarLegend34, calendarLegend12, calendarOf5
    case calendarLegendAll5, calendarLegend3to4, calendarLegendLess3, calendarLegendNone, calendarBestStreak

    // Onboarding
    case onboardWelcome, onboardWelcomeSub, onboardTrack, onboardTrackSub, onboardRead, onboardReadSub
    case onboardNeverMiss, onboardNeverMissSub, onboardPrayerReminders, onboardDailyVerse
    case onboardDailyVerseSub, onboardPeaceful, onboardPeacefulSub, onboardRemindersOn, onboardRemindersOff
    case onboardLanguage, onboardLanguageSub, onboardTheme, onboardThemeSub
    case onboardAlmostThere, onboardAlmostThereSub, onboardSkip, onboardMaybeLater
    case onboardEnableReminders, onboardContinueAnyway, onboardGetStarted
    case onboardMadhabLabel, onboardNameOptional
    case onboardMadhabHanafi, onboardMadhabMaliki, onboardMadhabShafii, onboardMadhabHanbali
    case onboardLanguageLabel, onboardPreferredLanguage

    // Verse / Tafsir
    case verseSave, verseSaved, verseShare, verseTafsir, verseLess, verseOfDay
    case tafsirTitle, tafsirAyah, tafsirIbnKathir, tafsirNotAvailable
    case verseResumeAudio, versePauseAudio, versePlayAudio, verseViewTafsir
    case verseShareVerse, verseRemoveBookmark, verseAddBookmark

    // Smart Header
    case headerNextPrayer, headerIn, headerKm, headerToMakkah

    // Hadith
    case hadithTitle, hadithNarrated, hadithSource, hadithShare
    case hadithChapters, hadithCount, hadithChapterCount

    // Qada Tracker
    case qadaAllCaughtUp, qadaTotalToMakeUp, qadaSmartEstimate, qadaApplyEstimate
    case qadaNoMissed30Days, qadaMissedPrayersToMakeUp, qadaRemaining
    case qadaWhatIs, qadaHowToUse

    // Profile - Madhab schools for picker
    case profileMadhabHanafi, profileMadhabMaliki, profileMadhabShafii, profileMadhabHanbali

    // Prayer Settings - Asr chip titles/subtitles and descriptions
    case prayerSettingsWhyMatterDescription, prayerSettingsAsrDescription
    case prayerSettingsAsrStandard, prayerSettingsAsrShafiiSubtitle
    case prayerSettingsAsrHanafi, prayerSettingsAsrHanafiSubtitle

    // Appearance
    case appearanceAppTheme, appearanceArabicTextSize

    // Offline Content
    case offlineClearConfirmTitle

    // Language Picker
    case languagePreferredHeader

    // Share App
    case shareWithFriends, shareDescription
    case shareMessage, shareEmail, shareCopyLink
    case shareAppTitle, sharePrayerDaily

    // About
    case aboutPrayerDaily, aboutVersion, aboutDescription

    // Export
    case exportCurrentStreak

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
        case .homeIslamicGuides: return "Islamic Guides"
        case .homeStreak: return "Streak"
        case .homeQadaLeft: return "Qada left"
        case .homeNow: return "Now"
        case .homeProgress: return "Progress"
        case .homeHadithOfDay: return "Hadith of the Day"
        case .homeLocating: return "Locating..."
        case .homeTodaySalah: return "Today's Salah"
        case .homeSave: return "Save"
        case .homeSaved: return "Saved"
        case .homeTafsirLess: return "Less"
        case .homeTafsir: return "Tafsir"
        case .homeHadithOfTheDay: return "Hadith of the Day"
        case .homeQuickAccess: return "Quick Access"
        case .homeKidsSection: return "Kids Section"
        case .homeComingSoon: return "Coming Soon"
        case .homeKidsDescription: return "We're building a fun, age-appropriate Islamic learning experience for children. Stay tuned!"
        case .homeKids: return "Kids"
        case .homeToday: return "Today"
        case .homeAllPrayersDone: return "All prayers done today"
        case .homeThisWeek: return "This Week"
        case .homeMinutesUntil: return "%d minutes until %@"
        case .homeHoursUntil: return "%dh until %@"
        case .homeHoursMinutesUntil: return "%dh %dm until %@"
        case .homeTapToUnmark: return "Tap to unmark"
        case .homeTapToMark: return "Tap to mark as prayed"
        case .homeCompleted: return "Completed"
        case .homeNotCompleted: return "Not completed"
        case .prayerTimesTitle: return "Prayer Times"
        case .prayerTimesEnableLocation: return "Enable Location"

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
        case .salahAllPrayersDone: return "All prayers done today"
        case .salahMinMinutesUntil: return "minutes until"
        case .salahHoursMinutesUntil: return "h m until"
        case .salahPrayed: return "Prayed"
        case .salahClear: return "Clear"

        // Today & Share
        case .todayOf5Prayers: return "of 5 Prayers"
        case .todayAllPrayersDone: return "All prayers done today — Alhamdulillah"
        case .todayPrayersRemaining: return "prayer remaining"
        case .todayLabel: return "Today"
        case .todayShareStatsDesc: return "Beautiful card with today's stats"
        case .shareProgressTitle: return "Share Progress"
        case .shareReadyToInspire: return "Ready to inspire others?"
        case .shareInspireDescription: return "Share your consistency with family and friends."
        case .shareCard: return "Share Card"
        case .sharePrayersCompleted: return "Prayers Completed"
        case .sharePrayersLoggedToday: return "Prayers Logged Today"
        case .shareDayStreak: return "Day\nStreak"
        case .shareAll: return "All"
        case .shareAllToday: return "All\nToday"

        // Calendar
        case .calendarLegendAll5: return "All 5"
        case .calendarLegend3to4: return "3–4"
        case .calendarLegendLess3: return "<3"
        case .calendarLegendNone: return "None"
        case .calendarBestStreak: return "Best Streak"

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
        case .quranNoSurahsYet: return "No Surahs Yet"
        case .quranStartReading: return "Start reading to track your progress"
        case .quranFilterAll: return "All"
        case .quranFilterJuz: return "Juz"
        case .quranFilterMeccan: return "Meccan"
        case .quranFilterMedinan: return "Medinan"
        case .quranFilterCompleted: return "Completed"
        case .quranMinRemaining: return "min remaining"
        case .quranPercentQuran: return "% of Quran"
        case .quranAyahs: return "Ayahs"
        case .quranLoadingSurah: return "Loading Surah…"
        case .quranConnectionIssue: return "Connection Issue"
        case .quranRetry: return "Retry"
        case .quranOffline: return "Offline"
        case .quranOfflineBanner: return "You're offline — connect to load this surah"
        case .quranSurahTypeBadge: return "type • verses Ayahs"
        case .quranUnableLoad: return "Unable to load verses.\nPlease check your internet connection."
        case .quranAyah: return "Ayah"
        case .quranReadingModeArabic: return "Arabic"
        case .quranReadingModeTranslation: return "Translation"
        case .quranReadingModeBoth: return "Both"
        case .quranReadingModeFocus: return "Focus"
        case .surahMinRemaining: return "~%d min remaining"
        case .surahOfQuranProgress: return "%.0f%% of Quran"
        case .surahBismillahTranslation: return "In the name of Allah, the Most Gracious, the Most Merciful"

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
        case .libraryIslamicTools: return "Islamic Tools"
        case .libraryIslamicGuides: return "Islamic Guides"
        case .libraryQiblaDesc: return "Instant accurate direction anywhere"
        case .libraryDhikrDesc: return "Digital tasbeeh with streak tracking"
        case .libraryHijriDesc: return "Convert Gregorian to Islamic date"
        case .libraryPrayerTrackerDesc: return "Log and review your daily salah"
        case .libraryEmergencyGuidesDesc: return "Janazah, Ruqyah & Nikah procedures"
        case .libraryNewMuslimGuideDesc: return "Essential knowledge for new Muslims"
        case .libraryFiqhBasicsDesc: return "Practical rulings for everyday life"
        case .libraryNewMuslimGuide: return "New Muslim Guide"
        case .libraryFiqhBasics: return "Fiqh Basics"

        // Quick Tools
        case .quickToolQibla: return "Qibla"
        case .quickToolHijriCalendar: return "Hijri Calendar"
        case .quickToolDhikrCounter: return "Dhikr Counter"
        case .quickToolQuran: return "Quran"
        case .quickToolDuas: return "Duas"
        case .guideCategoryPurification: return "PURIFICATION"
        case .guideCategoryPrayer: return "PRAYER"
        case .guideCategoryWorship: return "WORSHIP"
        case .guideCategoryFinanceFiqh: return "FINANCE & FIQH"
        case .guideCategorySupplications: return "SUPPLICATIONS"

        // Hijri Date
        case .hijriDate: return "Hijri Date"
        case .hijriLoading: return "Loading..."

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
        case .qiblaDetecting: return "Detecting..."
        case .qiblaLocationUnavailable: return "Location unavailable. Enable Location Services in Settings."
        case .qiblaKmFrom: return "%.0f km from Makkah"
        case .qiblaKmFromDecimal: return "%.1f km from Makkah"
        case .qiblaAccurate: return "Accurate"
        case .qiblaCalibrating: return "Calibrating"
        case .qiblaQiblaLabel: return "QIBLA"
        case .qiblaCardinalN: return "N"
        case .qiblaCardinalE: return "E"
        case .qiblaCardinalS: return "S"
        case .qiblaCardinalW: return "W"
        case .qiblaMyDirection: return "My Qibla Direction"
        case .qiblaSharedVia: return "Shared via PrayerDaily"

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
        case .dhikrSession: return "Session"
        case .dhikrTargetReached: return "Target reached! Tap to continue"
        case .dhikrTapToCount: return "Tap circle to count"
        case .dhikrAllDhikr: return "All Dhikr"
        case .dhikrSessionOverview: return "Session Overview"
        case .dhikrContinueReading: return "Continue Reading"

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
        case .moreProfileSubtitle: return "Your name, madhab & preferences"
        case .moreAppearanceSubtitle: return "Theme, Arabic size & reading options"
        case .morePrayerCalcSubtitle: return "Method, madhab & Asr juristic rule"
        case .moreStreakHistorySubtitle: return "View your prayer consistency over time"
        case .moreExportSubtitle: return "Download your prayer logs & notes"
        case .moreAboutSubtitle: return "Version • alehalearn.com"
        case .moreResetSubtitle: return "Erase all data, logs & preferences"
        case .moreAppLanguage: return "App Language"
        case .moreLanguageDesc: return "Controls UI text, prayer names and guide content."
        case .moreLanguageFooter: return "Quran translation is currently only available in English. UI language changes apply immediately."
        case .aboutPrayerdaily: return "About PrayerDaily"

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
        case .profileCityCountry: return "City, Country"

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
        case .appearanceTakesEffect: return "Takes effect immediately across the whole app."
        case .appearanceThemeSet: return "Theme set to"
        case .appearanceAppliedIn: return "Applied in Quran reader & Dua screens."
        case .appearanceEnglishMeaning: return "English meaning below each ayah"
        case .appearanceRomanized: return "Romanized Arabic pronunciation"

        // Prayer Settings
        case .prayerSettingsTitle: return "Prayer Calculation"
        case .prayerSettingsMethod: return "Calculation Method"
        case .prayerSettingsAsr: return "Asr Juristic Rule"
        case .prayerSettingsStandard: return "Standard (Shafi'i / Maliki / Hanbali)"
        case .prayerSettingsHanafi: return "Hanafi (Later)"
        case .prayerSettingsLocation: return "Location"
        case .prayerSettingsUsing: return "Using"
        case .prayerSettingsAutoDetect: return "Auto-detect"
        case .prayerTimes: return "Prayer Times"
        case .prayerEnableLocation: return "Enable Location"
        case .prayerWhyMatter: return "Why does this matter?"
        case .prayerActiveMethod: return "Active:"
        case .prayerFajrIsha: return "Fajr & Isha angles"
        case .prayerHanafiSchool: return "The Hanafi school uses a later Asr time."
        case .prayerLaterAsr: return "Later Asr"
        case .prayerShafiMalikiHanbali: return "Shafi'i · Maliki · Hanbali"
        case .prayerTodaysTimes: return "Today's Calculated Times"
        case .prayerSettingsApplied: return "Settings applied — recalculating…"

        // Emergency
        case .emergencyTitle: return "Emergency Guides"
        case .emergencyJanazah: return "Janazah Guide"
        case .emergencyRuqyah: return "Ruqyah"
        case .emergencyNikah: return "Nikah"
        case .emergencyTravel: return "Travel Prayer"
        case .emergencySteps: return "Steps"
        case .emergencySections: return "Sections"
        case .emergencyStepCount: return "steps"
        case .emergencySectionCount: return "sections"
        case .emergencyIslamicGuides: return "Islamic Guides"

        // Offline
        case .offlineTitle: return "Offline Content"
        case .offlineSaved: return "surahs saved"
        case .offlineDownload: return "Download"
        case .offlineSize: return "Size"
        case .offlineStorageUsed: return "Storage Used"
        case .offlineSurahsSaved: return "of surahs saved"
        case .offlineClearAll: return "Clear All"
        case .offlineSavedInfo: return "Saved surahs are available without internet."

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
        case .streakLegend34: return "3–4"
        case .streakLegend12: return "1–2"
        case .streakThisWeek: return "This Week"

        // Export
        case .exportTitle: return "Export Data"
        case .exportButton: return "Export Summary"
        case .exportReady: return "Export ready — sharing…"
        case .exportPrayerLogs: return "Prayer logs"
        case .exportTotalPrayers: return "Total prayers logged"
        case .exportDhikrLifetime: return "Dhikr lifetime"
        case .exportDaysTracked: return "Days tracked"
        case .exportYourData: return "Your prayer logs, dhikr counts, and notes are ready to export as a summary."
        case .exportDescription: return "Download your prayer logs and dhikr data as a summary."

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
        case .hadithChapters: return "Chapters"
        case .hadithCount: return "hadith"
        case .hadithChapterCount: return "hadith"

        // Qada Tracker
        case .qadaAllCaughtUp: return "All caught up! Alhamdulillah"
        case .qadaTotalToMakeUp: return "Total Qada to Make Up"
        case .qadaSmartEstimate: return "Smart Estimate"
        case .qadaApplyEstimate: return "Apply Estimate"
        case .qadaNoMissed30Days: return "No missed prayers detected in your last 30 days of logs. Keep it up!"
        case .qadaMissedPrayersToMakeUp: return "Missed Prayers to Make Up"
        case .qadaRemaining: return "remaining"
        case .qadaWhatIs: return "What is Qada?"
        case .qadaHowToUse: return "How to use this tracker"

        // Profile - Madhab schools
        case .profileMadhabHanafi: return "Hanafi"
        case .profileMadhabMaliki: return "Maliki"
        case .profileMadhabShafii: return "Shafi'i"
        case .profileMadhabHanbali: return "Hanbali"

        // Prayer Settings - descriptions and Asr chips
        case .prayerSettingsWhyMatterDescription: return "Different scholarly bodies use slightly different formulas for Fajr & Isha. Select the method followed in your region or by your madhab for the most accurate times."
        case .prayerSettingsAsrDescription: return "The Hanafi school uses a shadow length multiplier of 2x (later Asr), while all other schools use 1x (earlier Asr)."
        case .prayerSettingsAsrStandard: return "Standard"
        case .prayerSettingsAsrShafiiSubtitle: return "Shafi'i · Maliki · Hanbali"
        case .prayerSettingsAsrHanafi: return "Hanafi"
        case .prayerSettingsAsrHanafiSubtitle: return "Later Asr"

        // Appearance
        case .appearanceAppTheme: return "App Theme"
        case .appearanceArabicTextSize: return "Arabic Text Size"

        // Offline Content
        case .offlineClearConfirmTitle: return "Clear all offline data?"

        // Language Picker
        case .languagePreferredHeader: return "PREFERRED LANGUAGE"

        // Share App
        case .shareWithFriends: return "Share with Friends"
        case .shareDescription: return "Help your friends build better habits with PrayerDaily."
        case .shareMessage: return "Message"
        case .shareEmail: return "Email"
        case .shareCopyLink: return "Copy Link"
        case .shareAppTitle: return "Share PrayerDaily"
        case .sharePrayerDaily: return "Share PrayerDaily"

        // About
        case .aboutPrayerDaily: return "PrayerDaily"
        case .aboutVersion: return "Version"
        case .aboutDescription: return "Your companion for prayer, Quran reading, and daily remembrance — designed to make Islamic practice beautiful and accessible."

        // Export
        case .exportCurrentStreak: return "Current streak"
        case .exportCurrentStreakLabel: return "Current Streak"

        // Tracker
        case .trackerPrayerTracker: return "Prayer Tracker"
        case .trackerTodaysLog: return "Today's Log"
        case .trackerClear: return "Clear"

        // Hijri Calendar
        case .hijriUpcomingEvents: return "Upcoming Islamic Events"
        case .hijriIslamicMonths: return "Islamic Months"
        case .hijriSacredMonth: return "Sacred month"
        case .hijriBirthProphet: return "Birth of the Prophet"
        case .hijriMonthFasting: return "Month of fasting"
        case .hijriEidFitr: return "Eid al-Fitr"
        case .hijriHajjEid: return "Hajj & Eid al-Adha"
        case .hijriAH: return "AH"

        // Dua Source
        case .duaSource: return "Source:"

        // Today Salah
        case .todayPrayersCount: return "of 5 Prayers"
        case .todayAllDone: return "All prayers done today — Alhamdulillah"
        case .todayRemainingPrayers: return "prayer remaining"
        case .todayShareProgress: return "Share My Progress"
        case .todayShareSubtitle: return "Beautiful card with today's stats"
        case .todayExceptional: return "Exceptional — keep it up!"
        case .todayGreatProgress: return "Great progress this week!"
        case .todayGettingStarted: return "Getting started — keep it up!"
        case .todayBuildHabit: return "Building a habit takes time"
        case .todayLogPrayers: return "Log Your Prayers"
        case .todaySwipeToLog: return "Swipe to log"
        case .todayPrayed: return "Prayed"
        case .todayStreakDay: return "day streak"
        case .todayShareProgressTitle: return "Share Progress"
        case .todayShareReady: return "Ready to inspire others?"
        case .todayShareInspire: return "Share your consistency with family and friends."
        case .todayShareCard: return "Share Card"
        case .todayPrayersCompleted: return "Prayers Completed"
        case .todayAllToday: return "All Today"

        // Calendar Salah
        case .calendarPrayersLogged: return "Prayers Logged"
        case .calendarCompletion: return "Completion"
        case .calendarLegend34: return "3–4"
        case .calendarLegend12: return "1–2"
        case .calendarOf5: return "/5"

        // Onboarding
        case .onboardWelcome: return "Welcome to PrayerDaily"
        case .onboardWelcomeSub: return "Your companion for prayer, Quran, and daily remembrance — beautiful and always with you."
        case .onboardTrack: return "Track Every Prayer"
        case .onboardTrackSub: return "Log Fajr to Isha, build streaks, manage Qada, and see your weekly consistency at a glance."
        case .onboardRead: return "Read the Quran"
        case .onboardReadSub: return "Full Arabic text with translation, transliteration, and verse-by-verse Tafsir."
        case .onboardNeverMiss: return "Never Miss a Prayer"
        case .onboardNeverMissSub: return "Get gentle reminders at each prayer time and a daily verse every morning."
        case .onboardPrayerReminders: return "Prayer Reminders"
        case .onboardDailyVerse: return "Daily Verse"
        case .onboardDailyVerseSub: return "A verse from the Quran every morning at 8 AM"
        case .onboardPeaceful: return "Peaceful & Minimal"
        case .onboardPeacefulSub: return "No marketing, no noise — only what matters"
        case .onboardRemindersOn: return "Reminders are on — you're all set!"
        case .onboardRemindersOff: return "No worries, you can enable this in Settings later."
        case .onboardLanguage: return "Choose Your Language"
        case .onboardLanguageSub: return "PrayerDaily works beautifully in English and Malayalam."
        case .onboardTheme: return "Pick Your Theme"
        case .onboardThemeSub: return "Light, dark, or follow your system settings."
        case .onboardAlmostThere: return "Almost There"
        case .onboardAlmostThereSub: return "Set your name and madhab to personalise your experience."
        case .onboardSkip: return "Skip"
        case .onboardMaybeLater: return "Maybe later"
        case .onboardEnableReminders: return "Enable Reminders"
        case .onboardContinueAnyway: return "Continue Anyway"
        case .onboardGetStarted: return "Get Started"
        case .onboardMadhabLabel: return "Madhab"
        case .onboardNameOptional: return "Your name (optional)"
        case .onboardMadhabHanafi: return "Hanafi"
        case .onboardMadhabMaliki: return "Maliki"
        case .onboardMadhabShafii: return "Shafi'i"
        case .onboardMadhabHanbali: return "Hanbali"
        case .onboardLanguageLabel: return "Language"
        case .onboardPreferredLanguage: return "PREFERRED LANGUAGE"

        // Verse / Tafsir
        case .verseSave: return "Save"
        case .verseSaved: return "Saved"
        case .verseShare: return "Share"
        case .verseTafsir: return "Tafsir"
        case .verseLess: return "Less"
        case .verseOfDay: return "Verse of the Day"
        case .tafsirTitle: return "Tafsir"
        case .tafsirAyah: return "Ayah"
        case .tafsirIbnKathir: return "Ibn Kathir Commentary"
        case .tafsirNotAvailable: return "Tafsir not available for this verse."
        case .verseResumeAudio: return "Resume audio"
        case .versePauseAudio: return "Pause audio"
        case .versePlayAudio: return "Play audio"
        case .verseViewTafsir: return "View tafsir"
        case .verseShareVerse: return "Share verse"
        case .verseRemoveBookmark: return "Remove bookmark"
        case .verseAddBookmark: return "Add bookmark"

        // Qada Tracker
        case .qadaWhatIs: return "What is Qada?"
        case .qadaHowToUse: return "How to use this tracker"

        // Hadith
        case .hadithChapters: return "Chapters"
        case .hadithChapterCount: return "hadith"

        // Calendar
        case .calendarLegendAll5: return "All 5"
        case .calendarLegend3to4: return "3–4"
        case .calendarLegendLess3: return "<3"
        case .calendarLegendNone: return "None"
        case .calendarBestStreak: return "Best Streak"

        // Today & Share
        case .todayOf5Prayers: return "of 5 Prayers"
        case .todayAllPrayersDone: return "All prayers done today — Alhamdulillah"
        case .todayPrayersRemaining: return "prayer remaining"
        case .todayLabel: return "Today"
        case .todayShareStatsDesc: return "Beautiful card with today's stats"

        // Share
        case .shareProgressTitle: return "Share Progress"
        case .shareReadyToInspire: return "Ready to inspire others?"
        case .shareInspireDescription: return "Share your consistency with family and friends."
        case .shareCard: return "Share Card"
        case .sharePrayersCompleted: return "Prayers Completed"
        case .sharePrayersLoggedToday: return "Prayers Logged Today"
        case .shareDayStreak: return "Day\nStreak"
        case .shareAll: return "All"
        case .shareAllToday: return "All\nToday"

        // Quran
        case .quranReadingModeFocus: return "Focus"
        case .surahMinRemaining: return "min remaining"
        case .surahOfQuranProgress: return "% of Quran"
        case .surahBismillahTranslation: return "In the name of Allah, the Most Gracious, the Most Merciful"

        // Prayer Settings
        case .prayerSettingsWhyMatterDescription: return "Different scholarly bodies use slightly different formulas for Fajr & Isha. Select the method followed in your region or by your madhab for the most accurate times."
        case .prayerSettingsAsrDescription: return "The Hanafi school uses a shadow length multiplier of 2x (later Asr), while all other schools use 1x (earlier Asr)."
        case .prayerSettingsAsrStandard: return "Standard"
        case .prayerSettingsAsrShafiiSubtitle: return "Shafi'i · Maliki · Hanbali"
        case .prayerSettingsAsrHanafi: return "Hanafi"
        case .prayerSettingsAsrHanafiSubtitle: return "Later Asr"

        // Appearance
        case .appearanceAppTheme: return "App Theme"
        case .appearanceArabicTextSize: return "Arabic Text Size"

        // Offline Content
        case .offlineClearConfirmTitle: return "Clear all offline data?"

        // Language Picker
        case .languagePreferredHeader: return "PREFERRED LANGUAGE"

        // Share App
        case .shareWithFriends: return "Share with Friends"
        case .shareDescription: return "Help your friends build better habits with PrayerDaily."
        case .shareMessage: return "Message"
        case .shareEmail: return "Email"
        case .shareCopyLink: return "Copy Link"

        // About
        case .aboutPrayerDaily: return "PrayerDaily"
        case .aboutVersion: return "Version"
        case .aboutDescription: return "Your companion for prayer, Quran reading, and daily remembrance — designed to make Islamic practice beautiful and accessible."
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
        case .homeIslamicGuides: return "ഇസ്‌ലാമിക ഗൈഡുകൾ"
        case .homeStreak: return "സ്ട്രീക്ക്"
        case .homeQadaLeft: return "ഖദ ബാക്കി"
        case .homeNow: return "ഇപ്പോൾ"
        case .homeProgress: return "പുരോഗതി"
        case .homeHadithOfDay: return "ഇന്നത്തെ ഹദീസ്"
        case .homeLocating: return "സ്ഥലം കണ്ടുപിടിക്കുന്നു..."
        case .homeTodaySalah: return "ഇന്നത്തെ നമസ്കാരം"
        case .homeSave: return "സേവ്"
        case .homeSaved: return "സൂക്ഷിച്ചു"
        case .homeTafsirLess: return "കുറയ്ക്കുക"
        case .homeTafsir: return "തഫ്സീർ"
        case .homeHadithOfTheDay: return "ഇന്നത്തെ ഹദീസ്"
        case .homeQuickAccess: return "ദ്രുത ആക്സസ്"
        case .homeKidsSection: return "കുട്ടികളുടെ വിഭാഗം"
        case .homeComingSoon: return "ഉടൻ വരുന്നു"
        case .homeKidsDescription: return "കുട്ടികൾക്കായി രസകരവും വയറേറിയതുമായ ഇസ്‌ലാമിക പഠന അനുഭവം ഞങ്ങൾ നിർമ്മിക്കുന്നു. ശ്രദ്ധിക്കുക!"
        case .homeKids: return "കുട്ടികൾ"
        case .homeToday: return "ഇന്ന്"
        case .homeAllPrayersDone: return "ഇന്നത്തെ എല്ലാ നമസ്കാരവും കഴിഞ്ഞു"
        case .homeThisWeek: return "ഈ ആഴ്ച"
        case .homeMinutesUntil: return "%d മിനിറ്റ് %@ വരെ"
        case .homeHoursUntil: return "%d മണിക്കൂർ %@ വരെ"
        case .homeHoursMinutesUntil: return "%d മിനിറ്റ് %d %@ വരെ"
        case .homeTapToUnmark: return "അണിഞ്ഞൊടങ്ങാൻ ടാപ്പ് ചെയ്യുക"
        case .homeTapToMark: return "നമസ്കരിച്ചു എന്ന് അടയാളപ്പെടുത്താൻ ടാപ്പ് ചെയ്യുക"
        case .homeCompleted: return "പൂർത്തിയാക്കി"
        case .homeNotCompleted: return "പൂർത്തിയാക്കിയിട്ടില്ല"
        case .prayerTimesTitle: return "നമസ്കാര സമയം"
        case .prayerTimesEnableLocation: return "സ്ഥലം പ്രവർത്തനക്ഷമമാക്കുക"

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
        case .salahPrayed: return "നിർവ്വഹിച്ചു"
        case .salahClear: return "നീക്കം ചെയ്യുക"
        case .salahAllPrayersDone: return "എല്ലാ നമസ്കാരവും പൂർത്തിയായി"
        case .salahMinMinutesUntil: return "വരെ മിനിറ്റ്"
        case .salahHoursMinutesUntil: return "വരെ മ മിനിറ്റ്"

        // Today & Share
        case .todayOf5Prayers: return "of 5 Prayers"
        case .todayAllPrayersDone: return "ഇന്നത്തെ എല്ലാ നമസ്കാരവും — അൽഹംദുലില്ലാഹ്"
        case .todayPrayersRemaining: return "നമസ്കാരം ബാക്കി"
        case .todayLabel: return "ഇന്ന്"
        case .todayShareStatsDesc: return "ഇന്നത്തെ സ്ഥിതിവിവരക്കണക്ക്"
        case .shareProgressTitle: return "പ്രോഗ്രസ് പങ്കിടുക"
        case .shareReadyToInspire: return "മറ്റുള്ളവരെ പ്രേരിപ്പിക്കാൻ തയ്യാറാണോ?"
        case .shareInspireDescription: return "നിങ്ങളുടെ കൃത്യത കുടുംബത്തിനും സുഹൃത്തുക്കൾക്കും പങ്കിടുക."
        case .shareCard: return "കാർഡ് പങ്കിടുക"
        case .sharePrayersCompleted: return "പൂർത്തിയാക്കിയ നമസ്കാരം"
        case .sharePrayersLoggedToday: return "ഇന്നത്തെ രേഖ"
        case .shareDayStreak: return "ദിവസ\nസ്ട്രീക്ക്"
        case .shareAll: return "എല്ലാം"
        case .shareAllToday: return "ഇന്നത്തെ\nഎല്ലാം"

        // Calendar
        case .calendarLegendAll5: return "5-ഉം"
        case .calendarLegend3to4: return "3–4"
        case .calendarLegendLess3: return "<3"
        case .calendarLegendNone: return "ഒന്നുമില്ല"
        case .calendarBestStreak: return "മികച്ച സ്ട്രീക്ക്"

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
        case .quranNoSurahsYet: return "സൂറകളില്ല"
        case .quranStartReading: return "വായന ആരംഭിച്ച് നിങ്ങളുടെ പുരോഗതി ട്രാക്ക് ചെയ്യുക"
        case .quranFilterAll: return "എല്ലാം"
        case .quranFilterJuz: return "ജുസ്"
        case .quranFilterMeccan: return "മക്കി"
        case .quranFilterMedinan: return "മദനി"
        case .quranFilterCompleted: return "പൂർത്തിയായി"
        case .quranMinRemaining: return "ഏകദേശം മിനിറ്റ് ബാക്കി"
        case .quranPercentQuran: return "ഖുർആനിൻ്റെ %"
        case .quranAyahs: return "ആയത്തുകൾ"
        case .quranLoadingSurah: return "സൂറ ലോഡ് ആകുന്നു..."
        case .quranConnectionIssue: return "കണക്ഷൻ പ്രശ്നം"
        case .quranRetry: return "വീണ്ടും ശ്രമിക്കുക"
        case .quranOffline: return "ഓഫ്‌ലൈൻ"
        case .quranOfflineBanner: return "നിങ്ങൾ ഓഫ്‌ലൈനിലാണ് — സൂറ ലോഡ് ചെയ്യാൻ ബന്ധിപ്പിക്കുക"
        case .quranSurahTypeBadge: return "ആയത്തുകൾ"
        case .quranUnableLoad: return "ആയത്തുകൾ ലോഡ് ചെയ്യാൻ കഴിയുന്നില്ല.\nനിങ്ങളുടെ ഇന്റനെറ്റ് ബന്ധം പരിശോധിക്കുക."
        case .quranAyah: return "ആയത്ത്"
        case .quranReadingModeArabic: return "അറബി"
        case .quranReadingModeTranslation: return "പരിഭാഷ"
        case .quranReadingModeBoth: return "രണ്ടും"
        case .quranReadingModeFocus: return "ഫോക്കസ്"
        case .surahMinRemaining: return "മിനിറ്റ് ശേഷിക്കുന്നു"
        case .surahOfQuranProgress: return "ഖുർആനിൻറെ"
        case .surahBismillahTranslation: return "അല്ലാഹുവിൻറെ പേരിലാണ്, പരമകാരുണികനും കരുണാനിധിയും"

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
        case .libraryIslamicTools: return "ഇസ്‌ലാമിക ഉപകരണങ്ങൾ"
        case .libraryIslamicGuides: return "ഇസ്‌ലാമിക ഗൈഡുകൾ"
        case .libraryQiblaDesc: return "എവിടെയും കൃത്യമായ ദിശ ഉടൻ ലഭിക്കും"
        case .libraryDhikrDesc: return "സ്ട്രീക്ക് ട്രാക്കിംഗോടുകൂടിയ ഡിജിറ്റൽ തസ്ബീഹ്"
        case .libraryHijriDesc: return "ഗ്രിഗോറിയൻ ഇസ്‌ലാമിക തീയതിയാക്കി മാറ്റുക"
        case .libraryPrayerTrackerDesc: return "നിങ്ങളുടെ ദൈനംചില നമസ്കാരം രേഖപ്പെടുത്തുകയും അവലോകനം ചെയ്യുകയും ചെയ്യുക"
        case .libraryEmergencyGuidesDesc: return "ജനാസ, റുഖ്‌യ, നിക്കാഹ് നടപടിക്രമങ്ങൾ"
        case .libraryNewMuslimGuideDesc: return "പുതിയ മുസ്‌ലിംകൾക്കുള്ള അവശ്യ അറിവ്"
        case .libraryFiqhBasicsDesc: return "ദൈനംചില ജീവിതത്തിനുള്ള പരിശീലന വിധികൾ"
        case .libraryNewMuslimGuide: return "പുതിയ മുസ്‌ലിം ഗൈഡ്"
        case .libraryFiqhBasics: return "ഫിഖ്‌ഹ് അടിസ്ഥാനങ്ങൾ"

        // Quick Tools
        case .quickToolQibla: return "ഖിബ്‌ല"
        case .quickToolHijriCalendar: return "ഹിജ്രി കലണ്ടർ"
        case .quickToolDhikrCounter: return "സിക്ക് കൗണ്ടർ"
        case .quickToolQuran: return "ഖുർആൻ"
        case .quickToolDuas: return "ദുആ"
        case .guideCategoryPurification: return "ശുദ്ധി"
        case .guideCategoryPrayer: return "നമസ്കാരം"
        case .guideCategoryWorship: return "ആരാധന"
        case .guideCategoryFinanceFiqh: return "സാമ്പത്തികം & ഫിഖ്‌ഹ്"
        case .guideCategorySupplications: return "ദുആ"

        // Hijri Date
        case .hijriDate: return "ഹിജ്രി തീയതി"
        case .hijriLoading: return "ലോഡിംഗ്..."

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
        case .qiblaDetecting: return "കണ്ടുപിടിക്കുന്നു..."
        case .qiblaLocationUnavailable: return "സ്ഥലം ലഭ്യമല്ല. സെറ്റിംഗ്‌സിൽ ലൊക്കേഷൻ സർവീസുകൾ പ്രവർത്തനക്ഷമമാക്കുക."
        case .qiblaKmFrom: return "മക്കയിൽ നിന്ന് %.0f കി.മീ"
        case .qiblaKmFromDecimal: return "മക്കയിൽ നിന്ന് %.1f കി.മീ"
        case .qiblaAccurate: return "കൃത്യം"
        case .qiblaCalibrating: return "ശരിയാക്കുന്നു"
        case .qiblaQiblaLabel: return "ഖിബ്‌ല"
        case .qiblaCardinalN: return "N"
        case .qiblaCardinalE: return "E"
        case .qiblaCardinalS: return "S"
        case .qiblaCardinalW: return "W"
        case .qiblaMyDirection: return "എന്റെ ഖിബ്‌ല ദിശ"
        case .qiblaSharedVia: return "PrayerDaily വഴി പങ്കിട്ടുന്നു"

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
        case .dhikrSession: return "സെഷൻ"
        case .dhikrTargetReached: return "ലക്ഷ്യം എത്തി! തുടരാൻ ടാപ്പ് ചെയ്യുക"
        case .dhikrTapToCount: return "എണ്ണാൻ വളയം ടാപ്പ് ചെയ്യുക"
        case .dhikrAllDhikr: return "എല്ലാ ദിക്ര്"
        case .dhikrSessionOverview: return "സെഷൻ അവലോകനം"
        case .dhikrContinueReading: return "വായന തുടരുക"

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
        case .moreProfileSubtitle: return "നിങ്ങളുടെ പേര്, മദ്ഹബ്, ക്രമീകരണങ്ങൾ"
        case .moreAppearanceSubtitle: return "തീം, അറബി വലിപ്പം, വായന ഓപ്ഷനുകൾ"
        case .morePrayerCalcSubtitle: return "രീതി, മദ്ഹബ്, അസ്ർ ഫിഖ്ഹ് നിയമം"
        case .moreStreakHistorySubtitle: return "കാലം മുഴുവനും നിങ്ങളുടെ നമസ്കാര കൃത്യത കാണുക"
        case .moreExportSubtitle: return "നിങ്ങളുടെ നമസ്കാര ലോഗുകളും കുറിപ്പുകളും ഡൗൺലോഡ് ചെയ്യുക"
        case .moreAboutSubtitle: return "പതിപ്പ് • alehalearn.com"
        case .moreResetSubtitle: return "എല്ലാ ഡാറ്റ, ലോഗ്, ക്രമീകരണങ്ങൾ മായ്ക്കുക"
        case .moreAppLanguage: return "ആപ്പ് ഭാഷ"
        case .moreLanguageDesc: return "UI ടെക്സ്റ്റ്, നമസ്കാര നാമങ്ങൾ, ഗൈഡ് ഉള്ളടക്കം എന്നിവ നിയന്ത്രിക്കുന്നു."
        case .moreLanguageFooter: return "ഖുർആൻ പരിഭാഷ ഇപ്പോൾ ഇംഗ്ലീഷിൽ മാത്രം ലഭ്യമാണ്. UI ഭാഷ മാറ്റങ്ങൾ ഉടൻ പ്രയോഗതിൽ വരും."
        case .aboutPrayerdaily: return "ആലിഹ നെ കുറിച്ച്"

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
        case .profileCityCountry: return "നഗരം, രാജ്യം"

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
        case .appearanceTakesEffect: return "ആപ്പ് മുഴുവനും ഉടൻ പ്രയോഗതിൽ വരും."
        case .appearanceThemeSet: return "തീം സജ്ജമാക്കി"
        case .appearanceAppliedIn: return "ഖുർആൻ റീഡറും ദുആ സ്ക്രീനുകളിലും പ്രയോഗതിൽ വരും."
        case .appearanceEnglishMeaning: return "ഓരോ ആയത്തിന് താഴെ ഇംഗ്ലീഷ് അർത്ഥം"
        case .appearanceRomanized: return "റോമനൈസ്ഡ് അറബി ഉച്ചാരണം"

        // Prayer Settings
        case .prayerSettingsTitle: return "നമസ്കാര കണക്കുകൂട്ടൽ"
        case .prayerSettingsMethod: return "കണക്കുകൂട്ടൽ രീതി"
        case .prayerSettingsAsr: return "അസ്ർ ഫിഖ്ഹ് നിയമം"
        case .prayerSettingsStandard: return "സ്റ്റാൻഡേർഡ് (ശാഫിഈ / മാലിക്കി / ഹൻബലി)"
        case .prayerSettingsHanafi: return "ഹനഫി (വൈകിയ)"
        case .prayerSettingsLocation: return "സ്ഥലം"
        case .prayerSettingsUsing: return "ഉപയോഗിക്കുന്നത്"
        case .prayerSettingsAutoDetect: return "സ്വയം കണ്ടെത്തുക"
        case .prayerTimes: return "നമസ്കാര സമയങ്ങൾ"
        case .prayerEnableLocation: return "സ്ഥലം പ്രവർത്തനക്ഷമമാക്കുക"
        case .prayerWhyMatter: return "ഇത് എന്തുകൊണ്ട് വിഷയമാണ്?"
        case .prayerActiveMethod: return "സജ്ജം"
        case .prayerFajrIsha: return "ഫജ്ർ, ഇശാ കോണുകൾ"
        case .prayerHanafiSchool: return "ഹനഫി മദ്ഹബ് വൈകിയ അസ്ർ സമയം ഉപയോഗിക്കുന്നു."
        case .prayerLaterAsr: return "വൈകിയ അസ്ർ"
        case .prayerShafiMalikiHanbali: return "ശാഫിഈ · മാലിക്കി · ഹൻബലി"
        case .prayerTodaysTimes: return "ഇന്നത്തെ കണക്കാക്കിയ സമയങ്ങൾ"
        case .prayerEnableLocation: return "നമസ്കാര സമയങ്ങൾ കാണാൻ ലൊക്കേഷൻ ആക്സസ് പ്രവർത്തനക്ഷമമാക്കുക."
        case .prayerSettingsApplied: return "ക്രമീകരണങ്ങൾ സേവ് ചെയ്തു — വീണ്ടും കണക്കാക്കുന്നു..."

        // Emergency
        case .emergencyTitle: return "അടിയന്തര ഗൈഡുകൾ"
        case .emergencyJanazah: return "ജനാസ ഗൈഡ്"
        case .emergencyRuqyah: return "റുഖ്‌യ"
        case .emergencyNikah: return "നിക്കാഹ്"
        case .emergencyTravel: return "യാത്രാ നമസ്കാരം"
        case .emergencySteps: return "ഘട്ടങ്ങൾ"
        case .emergencySections: return "വിഭാഗങ്ങൾ"
        case .emergencyStepCount: return "ഘട്ടങ്ങൾ"
        case .emergencySectionCount: return "വിഭാഗങ്ങൾ"
        case .emergencyIslamicGuides: return "ഇസ്‌ലാമിക ഗൈഡുകൾ"

        // Offline
        case .offlineTitle: return "ഓഫ്‌ലൈൻ ഉള്ളടക്കം"
        case .offlineSaved: return "സൂറകൾ സേവ് ചെയ്തു"
        case .offlineDownload: return "ഡൗൺലോഡ്"
        case .offlineSize: return "വലിപ്പം"
        case .offlineStorageUsed: return "ഉപയോഗിച്ച സംഭരണം"
        case .offlineSurahsSaved: return "സൂറകൾ സേവ് ചെയ്തു"
        case .offlineClearAll: return "എല്ലാം വൃത്തിയാക്കുക"
        case .offlineSavedInfo: return "സേവ് ചെയ്ത സൂറകൾ ഇന്റനെറ്റ് ഇല്ലാതെ ലഭ്യമാണ്."

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
        case .streakLegend34: return "3–4"
        case .streakLegend12: return "1–2"
        case .streakThisWeek: return "ഈ ആഴ്ച"

        // Export
        case .exportTitle: return "ഡാറ്റ എക്സ്പോർട്ട്"
        case .exportButton: return "സംഗ്രഹം എക്സ്പോർട്ട്"
        case .exportReady: return "എക്സ്പോർട്ട് തയ്യാർ — പങ്കിടുന്നു…"
        case .exportPrayerLogs: return "നമസ്കാര ലോഗ്"
        case .exportTotalPrayers: return "മൊത്തം നമസ്കാരം"
        case .exportDhikrLifetime: return "ദിക്ർ ആകെ"
        case .exportDaysTracked: return "ട്രാക്ക് ചെയ്ത ദിവസങ്ങൾ"
        case .exportCurrentStreak: return "ഇപ്പോഴത്തെ സ്ട്രീക്ക്"
        case .exportCurrentStreakLabel: return "ഇപ്പോഴത്തെ സ്ട്രീക്ക്"

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
        case .hadithChapters: return "അധ്യായങ്ങൾ"
        case .hadithCount: return "ഹദീസ്"
        case .hadithChapterCount: return "ഹദീസ്"

        // Qada Tracker
        case .qadaAllCaughtUp: return "എല്ലാം ശരി! അൽഹംദുലില്ലാഹ്"
        case .qadaTotalToMakeUp: return "ഖദ ആക്കാനുള്ള മൊത്തം"
        case .qadaSmartEstimate: return "സ്മാർട്ട് കണക്ക്"
        case .qadaApplyEstimate: return "കണക്ക് ചേർക്കുക"
        case .qadaNoMissed30Days: return "കഴിഞ്ഞ 30 ദിവസത്തിൽ വിട്ടുപോയ നമസ്കാരങ്ങൾ ഇല്ല. അൽഹംദുലില്ലാഹ്!"
        case .qadaMissedPrayersToMakeUp: return "ഖദ ആക്കേണ്ട നമസ്കാരം"
        case .qadaRemaining: return "ബാക്കി"
        case .qadaWhatIs: return "ഖദ എന്താണ്?"
        case .qadaHowToUse: return "ഈ ട്രാക്കർ എങ്ങനെ ഉപയോഗിക്കാം"

        // Profile - Madhab schools
        case .profileMadhabHanafi: return "ഹനഫി"
        case .profileMadhabMaliki: return "മാലികി"
        case .profileMadhabShafii: return "ശാഫിഈ"
        case .profileMadhabHanbali: return "ഹൻബലി"

        // Prayer Settings
        case .prayerSettingsWhyMatterDescription: return "വിവിധ പണ്ഡിത സമൂഹങ്ങൾ ഫജർ ആയത്തിന്റെ സമയം കണക്കാക്കാൻ വ്യത്യസ്ത സൂത്രങ്ങൾ ഉപയോഗിക്കുന്നു."
        case .prayerSettingsAsrDescription: return "ഹനഫി സ്‌കൂളിൽ 2x തണ്ല ദൈർഘ്യ ഗുണകം, മറ്റുള്ളവർ 1x ഉപയോഗിക്കുന്നു."
        case .prayerSettingsAsrStandard: return "സ്റ്റാൻഡേർഡ്"
        case .prayerSettingsAsrShafiiSubtitle: return "ശാഫിഈ · മാലികി · ഹൻബലി"
        case .prayerSettingsAsrHanafi: return "ഹനഫി"
        case .prayerSettingsAsrHanafiSubtitle: return "വൈകിയ അസ്ര്"

        // Appearance
        case .appearanceAppTheme: return "ആപ്പിന്റെ തീം"
        case .appearanceArabicTextSize: return "അറബി ടെക്സ്റ്റ് വലിപ്പം"

        // Offline Content
        case .offlineClearConfirmTitle: return "എല്ലാ ഓഫ്‌ലൈൻ ഡാറ്റയും മായ്ക്കണോ?"

        // Language Picker
        case .languagePreferredHeader: return "ഇഷ്ടപ്പെട്ട ഭാഷ"

        // Share App
        case .shareWithFriends: return "സുഹൃത്തുക്കളുമായി പങ്കിടുക"
        case .shareDescription: return "നിങ്ങളുടെ സുഹൃത്തുക്കൾക്ക് പ്രേരിപ്പിക്കാൻ സഹായിക്കുക."
        case .shareMessage: return "സന്ദേശം"
        case .shareEmail: return "ഇമെയിൽ"
        case .shareCopyLink: return "ലിങ്ക് പകർത്തുക"
        case .shareAppTitle: return "പ്രാർഥന ഡെയ്‌ലി പങ്കിടുക"
        case .sharePrayerDaily: return "പ്രാർഥന ഡെയ്‌ലി പങ്കിടുക"

        // About
        case .aboutPrayerDaily: return "PrayerDaily"
        case .aboutVersion: return "പതിപ്പ്"
        case .aboutDescription: return "നമസ്കാരം, ഖുർആൻ വായന ദൈനംനടത്ത ഓർമ്മപ്പെടുത്തലുകൾ എന്നിവയ്ക്കുള്ള സഹായി."

        // Export
        case .exportYourData: return "നിങ്ങളുടെ ഡാറ്റ"
        case .exportDescription: return "നിങ്ങളുടെ നമസ്കാര ലോഗുകളും ദിക്ര് ഡാറ്റയും സംഗ്രഹമായി ഡൗൺലോഡ് ചെയ്യുക."

        // Tracker
        case .trackerPrayerTracker: return "നമസ്കാര ട്രാക്കർ"
        case .trackerTodaysLog: return "ഇന്നത്തെ രേഖ"
        case .trackerClear: return "വൃത്തിയാക്കുക"

        // Hijri Calendar
        case .hijriUpcomingEvents: return "വരാനിരിക്കുന്ന സംഭവങ്ങൾ"
        case .hijriIslamicMonths: return "ഇസ്‌ലാമിക മാസങ്ങൾ"
        case .hijriSacredMonth: return "വിശുദ്ധ മാസം"
        case .hijriBirthProphet: return "നബിയുടെ ജനനം"
        case .hijriMonthFasting: return "നോമ്പ് മാസം"
        case .hijriEidFitr: return "ഈദ് അൽ-ഫിത്തിർ"
        case .hijriHajjEid: return "ഈദ് അൽ-അദ്ഹ"
        case .hijriAH: return "AH"

        // Dua Source
        case .duaSource: return "ഉറവിടം"

        // Today Salah
        case .todayPrayersCount: return "%d / 5"
        case .todayAllDone: return "എല്ലാ നമസ്കാരവും പൂർത്തിയായി"
        case .todayRemainingPrayers: return "ബാക്കി നമസ്കാരം"
        case .todayShareProgress: return "പ്രോഗ്രസ് പങ്കിടുക"
        case .todayShareSubtitle: return "ഇന്നത്തെ പുരോഗതി പങ്കിടുക"
        case .todayExceptional: return "അസാധാരണം!"
        case .todayGreatProgress: return "മികച്ച പുരോഗതി"
        case .todayGettingStarted: return "ആരംഭിക്കുന്നു"
        case .todayBuildHabit: return "ശീലം വളർത്തുക"
        case .todayLogPrayers: return "നമസ്കാരം രേഖപ്പെടുത്തുക"
        case .todaySwipeToLog: return "രേഖപ്പെടുത്താൻ സ്വൈപ്പ് ചെയ്യുക"
        case .todayPrayed: return "നിർവ്വഹിച്ചു"
        case .todayStreakDay: return "സ്ട്രീക്ക് ദിവസം"
        case .todayShareProgressTitle: return "എന്റെ നമസ്കാര പുരോഗതി"
        case .todayShareReady: return "പങ്കിടാൻ തയ്യാറാണ്"
        case .todayShareInspire: return "മറ്റുള്ളവരെ പ്രേരിപ്പിക്കുക"
        case .todayShareCard: return "കാർഡ് പങ്കിടുക"
        case .todayPrayersCompleted: return "നമസ്കാരം പൂർത്തിയായി"
        case .todayAllToday: return "ഇന്നത്തെ എല്ലാം"

        // Calendar Salah
        case .calendarPrayersLogged: return "നമസ്കാരം രേഖപ്പെടുത്തി"
        case .calendarCompletion: return "പൂർത്തിയാക്കൽ"
        case .calendarLegend34: return "3–4"
        case .calendarLegend12: return "1–2"
        case .calendarOf5: return "5-ഉം"

        // Onboarding
        case .onboardWelcome: return "സ്വാഗതം"
        case .onboardWelcomeSub: return "നിങ്ങളുടെ ദൈനംചില ഇസ്‌ലാമിക ജീവിതത്തിനുള്ള സഹായി"
        case .onboardTrack: return "നമസ്കാരം ട്രാക്ക് ചെയ്യുക"
        case .onboardTrackSub: return "എല്ലാ 5 നമസ്കാരങ്ങളും ദൈനംചില രേഖപ്പെടുത്തുക"
        case .onboardRead: return "ഖുർആൻ വായിക്കുക"
        case .onboardReadSub: return "ഓരോ ആയത്തിന്റെയും അർത്ഥം മനസിലാക്കുക"
        case .onboardNeverMiss: return "ഒരിക്കലും വിട്ടുപോകരുത്"
        case .onboardNeverMissSub: return "ഓർമ്മപ്പെടുത്തലുകൾ സജ്ജമാക്കുക"
        case .onboardPrayerReminders: return "നമസ്കാര ഓർമ്മപ്പെടുത്തലുകൾ"
        case .onboardDailyVerse: return "ദൈനംചില ആയത്ത്"
        case .onboardDailyVerseSub: return "ഓരോ ദിവസവും പുതിയ ആയത്ത്"
        case .onboardPeaceful: return "സമാധാനം"
        case .onboardPeacefulSub: return "ഖുർആൻ വായനയിൽ സമാധാനം കണ്ടെത്തുക"
        case .onboardRemindersOn: return "ഓർമ്മപ്പെടുത്തലുകൾ ഓണാക്കി"
        case .onboardRemindersOff: return "ഓർമ്മപ്പെടുത്തലുകൾ ഓഫാക്കി"
        case .onboardLanguage: return "ഭാഷ തിരഞ്ഞെടുക്കുക"
        case .onboardLanguageSub: return "നിങ്ങളുടെ ഇഷ്ടപ്പെട്ട ഭാഷ തിരഞ്ഞെടുക്കുക"
        case .onboardTheme: return "തീം തിരഞ്ഞെടുക്കുക"
        case .onboardThemeSub: return "ഇരുൾ, പ്രകാശം അല്ലെങ്കിൽ സിസ്റ്റം"
        case .onboardAlmostThere: return "ഒരു നിമിഷം!"
        case .onboardAlmostThereSub: return "നിങ്ങളുടെ ക്രമീകരണങ്ങൾ സജ്ജമാക്കുക"
        case .onboardSkip: return "ഒഴിവാക്കുക"
        case .onboardMaybeLater: return "പിന്നീട് ശ്രമിക്കാം"
        case .onboardEnableReminders: return "ഓർമ്മപ്പെടുത്തലുകൾ പ്രവർത്തനക്ഷമമാക്കുക"
        case .onboardContinueAnyway: return "എങ്കിലും തുടരുക"
        case .onboardGetStarted: return "ആരംഭിക്കുക"
        case .onboardMadhabLabel: return "മദ്ഹബ് (ഐച്ഛികം)"
        case .onboardNameOptional: return "പേര് (ഐച്ഛികം)"
        case .onboardMadhabHanafi: return "ഹനഫി"
        case .onboardMadhabMaliki: return "മാലികി"
        case .onboardMadhabShafii: return "ശാഫിഈ"
        case .onboardMadhabHanbali: return "ഹൻബലി"
        case .onboardLanguageLabel: return "ഭാഷ"
        case .onboardPreferredLanguage: return "ഇഷ്ടപ്പെട്ട ഭാഷ"

        // Verse / Tafsir
        case .verseSave: return "സേവ്"
        case .verseSaved: return "സൂക്ഷിച്ചു"
        case .verseShare: return "പങ്കിടുക"
        case .verseTafsir: return "തഫ്സീർ"
        case .verseLess: return "കുറയ്ക്കുക"
        case .verseOfDay: return "ഇന്നത്തെ ആയത്ത്"
        case .tafsirTitle: return "തഫ്സീർ"
        case .tafsirAyah: return "ആയത്ത്"
        case .tafsirIbnKathir: return "ഇബ്നു കഥീർ"
        case .tafsirNotAvailable: return "തഫ്സീർ ലഭ്യമല്ല"
        case .verseResumeAudio: return "ഓഡിയോ തുടരുക"
        case .versePauseAudio: return "ഓഡിയോ നിർത്തുക"
        case .versePlayAudio: return "ഓഡിയോ പ്രവർത്തിപ്പിക്കുക"
        case .verseViewTafsir: return "തഫ്സീർ കാണുക"
        case .verseShareVerse: return "ആയത്ത് പങ്കിടുക"
        case .verseRemoveBookmark: return "ബുക്ക്മാർക്ക് നീക്കുക"
        case .verseAddBookmark: return "ബുക്ക്മാർക്ക് ചേർക്കുക"
        }
    }
}
