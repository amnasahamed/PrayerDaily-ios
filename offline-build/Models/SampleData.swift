import Foundation

struct SampleData {
    // MARK: - Surahs
    static let surahs: [Surah] = [
        Surah(id: 1, nameArabic: "الفاتحة", nameEnglish: "Al-Fatihah", verses: 7, type: "Meccan"),
        Surah(id: 2, nameArabic: "البقرة", nameEnglish: "Al-Baqarah", verses: 286, type: "Medinan"),
        Surah(id: 3, nameArabic: "آل عمران", nameEnglish: "Aal-E-Imran", verses: 200, type: "Medinan"),
        Surah(id: 36, nameArabic: "يس", nameEnglish: "Ya-Sin", verses: 83, type: "Meccan"),
        Surah(id: 55, nameArabic: "الرحمن", nameEnglish: "Ar-Rahman", verses: 78, type: "Medinan"),
        Surah(id: 67, nameArabic: "الملك", nameEnglish: "Al-Mulk", verses: 30, type: "Meccan"),
        Surah(id: 112, nameArabic: "الإخلاص", nameEnglish: "Al-Ikhlas", verses: 4, type: "Meccan"),
        Surah(id: 113, nameArabic: "الفلق", nameEnglish: "Al-Falaq", verses: 5, type: "Meccan"),
        Surah(id: 114, nameArabic: "الناس", nameEnglish: "An-Nas", verses: 6, type: "Meccan"),
    ]

    // MARK: - Daily Reflection
    static let dailyAyah = (
        arabic: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
        translation: "Indeed, with hardship comes ease.",
        reference: "Quran 94:6",
        tafsir: "This verse provides profound comfort — after every difficulty, Allah promises relief. The use of the definite article with 'hardship' and the indefinite for 'ease' suggests that each hardship is accompanied by multiple forms of ease."
    )

    // MARK: - Streak
    static let streak = ReadingStreak(
        currentDays: 12,
        bestDays: 21,
        todayRead: true,
        pagesReadToday: 3
    )

    // MARK: - Duas
    static let duas: [Dua] = [
        Dua(id: 1, title: "Morning Remembrance",
            arabic: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ",
            transliteration: "Asbahna wa asbahal mulku lillah",
            translation: "We have reached the morning and the dominion belongs to Allah",
            category: "Morning"),
        Dua(id: 2, title: "Before Sleeping",
            arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
            transliteration: "Bismika Allahumma amutu wa ahya",
            translation: "In Your name, O Allah, I die and I live",
            category: "Evening"),
        Dua(id: 3, title: "Entering the Mosque",
            arabic: "اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
            transliteration: "Allahumma aftah li abwaba rahmatik",
            translation: "O Allah, open for me the gates of Your mercy",
            category: "Mosque"),
    ]

    // MARK: - Knowledge Categories
    static let knowledgeCategories: [KnowledgeCategory] = [
        KnowledgeCategory(title: "40 Hadith", subtitle: "Imam An-Nawawi", icon: "text.book.closed.fill", count: 42, color: "NoorPrimary"),
        KnowledgeCategory(title: "Stories of Prophets", subtitle: "25 Prophets", icon: "person.2.fill", count: 25, color: "NoorAccent"),
        KnowledgeCategory(title: "Seerah Timeline", subtitle: "Life of the Prophet ﷺ", icon: "timeline.selection", count: 64, color: "NoorGold"),
        KnowledgeCategory(title: "Dua Collection", subtitle: "By situation", icon: "hands.sparkles.fill", count: 120, color: "NoorPrimary"),
        KnowledgeCategory(title: "Islamic Quotes", subtitle: "Scholars & Companions", icon: "quote.opening", count: 200, color: "NoorSecondary"),
        KnowledgeCategory(title: "Emergency Guide", subtitle: "Janazah, Ruqyah & more", icon: "cross.case.fill", count: 15, color: "NoorAccent"),
    ]

    // MARK: - Hadiths
    static let hadiths: [Hadith] = [
        Hadith(id: 1, narrator: "Umar ibn Al-Khattab (RA)",
               textEnglish: "Actions are judged by intentions, and every person will get what they intended.",
               source: "Sahih al-Bukhari 1"),
        Hadith(id: 2, narrator: "Abu Hurairah (RA)",
               textEnglish: "Whoever believes in Allah and the Last Day, let him speak good or remain silent.",
               source: "Sahih al-Bukhari 6018"),
    ]

    // MARK: - Today's Prayers
    static func todayPrayers() -> [SalahLogEntry] {
        let today = Date()
        return [
            SalahLogEntry(prayer: .fajr, completed: true, date: today),
            SalahLogEntry(prayer: .dhuhr, completed: true, date: today),
            SalahLogEntry(prayer: .asr, completed: true, date: today),
            SalahLogEntry(prayer: .maghrib, completed: false, date: today),
            SalahLogEntry(prayer: .isha, completed: false, date: today),
        ]
    }
}
