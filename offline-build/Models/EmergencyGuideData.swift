import Foundation

// MARK: - Guide Models
struct EmergencyGuide: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: String
    let subtitle: String
    let sections: [GuideSection]
}

struct GuideSection: Identifiable {
    let id = UUID()
    let heading: String
    let steps: [GuideStep]
}

struct GuideStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let detail: String
    let arabic: String?
}

// MARK: - All Guides
struct EmergencyGuideData {
    static let allGuides: [EmergencyGuide] = [janazahGuide, ruqyahGuide, nikahGuide, travelDuasGuide]

    // MARK: - Janazah
    static let janazahGuide = EmergencyGuide(
        title: "Janazah",
        icon: "heart.text.square.fill",
        color: "NoorSecondary",
        subtitle: "Islamic Funeral Procedures",
        sections: [
            GuideSection(heading: "Preparation of the Body (Ghusl)", steps: [
                GuideStep(number: 1, title: "Intention (Niyyah)", detail: "Make intention to wash the deceased for the sake of Allah. The body should be placed on an elevated surface.", arabic: nil),
                GuideStep(number: 2, title: "Cover the Awrah", detail: "Cover the area between the navel and knees. Remove clothing and replace with a sheet.", arabic: nil),
                GuideStep(number: 3, title: "Perform Wudu", detail: "Wash the body starting with wudu — face, arms to elbows, head, and feet. Begin from the right side.", arabic: nil),
                GuideStep(number: 4, title: "Full Body Wash", detail: "Wash the entire body 3 times (or odd number) with water mixed with sidr (lote leaves). Start right side, then left.", arabic: nil),
                GuideStep(number: 5, title: "Final Wash", detail: "The last wash may include camphor. Dry the body and apply perfume (non-alcohol). Braid women's hair into 3 braids.", arabic: nil),
            ]),
            GuideSection(heading: "Shrouding (Kafan)", steps: [
                GuideStep(number: 1, title: "Men's Kafan", detail: "Three white cotton sheets (izaar, qamees, lifafah). Wrap right side over left. Tie at head, middle, and feet.", arabic: nil),
                GuideStep(number: 2, title: "Women's Kafan", detail: "Five pieces — izaar, qamees, khimaar (head cover), lifafah (wrapper), and a waist wrapper.", arabic: nil),
            ]),
            GuideSection(heading: "Salat al-Janazah", steps: [
                GuideStep(number: 1, title: "First Takbir", detail: "Raise hands and say Allahu Akbar. Recite Surah Al-Fatihah.", arabic: "اللَّهُ أَكْبَرُ"),
                GuideStep(number: 2, title: "Second Takbir", detail: "Say Allahu Akbar (without raising hands). Recite Salawat upon the Prophet ﷺ (Ibrahimiyyah).", arabic: "اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ"),
                GuideStep(number: 3, title: "Third Takbir", detail: "Say Allahu Akbar. Make dua for the deceased:", arabic: "اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ"),
                GuideStep(number: 4, title: "Fourth Takbir", detail: "Say Allahu Akbar. Make a brief dua, then give one Tasleem to the right.", arabic: "اللَّهُمَّ لَا تَحْرِمْنَا أَجْرَهُ وَلَا تَفْتِنَّا بَعْدَهُ"),
            ]),
            GuideSection(heading: "Burial", steps: [
                GuideStep(number: 1, title: "Lowering the Body", detail: "Lower feet first into the grave, on the right side, facing the Qiblah. Say:", arabic: "بِسْمِ اللَّهِ وَعَلَىٰ مِلَّةِ رَسُولِ اللَّهِ"),
                GuideStep(number: 2, title: "Covering with Soil", detail: "Each person throws three handfuls of soil. The grave should be raised about a hand-span above ground, not flattened.", arabic: nil),
                GuideStep(number: 3, title: "Dua After Burial", detail: "Stand at the grave and make dua for the deceased. Ask Allah to grant them firmness during questioning.", arabic: "اللَّهُمَّ ثَبِّتْهُ"),
            ]),
        ]
    )

    // MARK: - Ruqyah
    static let ruqyahGuide = EmergencyGuide(
        title: "Ruqyah",
        icon: "shield.lefthalf.filled",
        color: "NoorPrimary",
        subtitle: "Quranic Healing & Protection",
        sections: [
            GuideSection(heading: "Preparation", steps: [
                GuideStep(number: 1, title: "Purify Your Intention", detail: "Ruqyah must be done with full reliance on Allah. It is the Quran and authentic Sunnah supplications — nothing else.", arabic: nil),
                GuideStep(number: 2, title: "Perform Wudu", detail: "Be in a state of purity. Face the Qiblah if possible.", arabic: nil),
            ]),
            GuideSection(heading: "Core Ruqyah Verses", steps: [
                GuideStep(number: 1, title: "Surah Al-Fatihah", detail: "The greatest Surah — recite 7 times. Blow gently on palms and wipe over body.", arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ"),
                GuideStep(number: 2, title: "Ayat al-Kursi (2:255)", detail: "Recite once or 3 times. This is the greatest verse of the Quran — powerful for protection.", arabic: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ"),
                GuideStep(number: 3, title: "Last 2 Verses of Al-Baqarah", detail: "Recite 2:285-286 — they are sufficient for whoever recites them at night.", arabic: "آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ"),
                GuideStep(number: 4, title: "Surah Al-Ikhlas (3x)", detail: "Recite three times — it equals one-third of the Quran.", arabic: "قُلْ هُوَ اللَّهُ أَحَدٌ"),
                GuideStep(number: 5, title: "Surah Al-Falaq (3x)", detail: "Recite three times for protection from external harm.", arabic: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ"),
                GuideStep(number: 6, title: "Surah An-Nas (3x)", detail: "Recite three times for protection from whispers (waswas).", arabic: "قُلْ أَعُوذُ بِرَبِّ النَّاسِ"),
            ]),
            GuideSection(heading: "Sunnah Duas for Healing", steps: [
                GuideStep(number: 1, title: "Place Hand on Pain", detail: "Place your right hand on the area of pain and say:", arabic: "بِسْمِ اللَّهِ — أَعُوذُ بِعِزَّةِ اللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ"),
                GuideStep(number: 2, title: "Dua for the Sick", detail: "Recite 7 times:", arabic: "أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ"),
                GuideStep(number: 3, title: "General Healing Dua", detail: "Wipe over body and say:", arabic: "اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ اشْفِ أَنْتَ الشَّافِي لَا شِفَاءَ إِلَّا شِفَاؤُكَ"),
            ]),
        ]
    )

    // MARK: - Nikah
    static let nikahGuide = EmergencyGuide(
        title: "Nikah",
        icon: "heart.circle.fill",
        color: "NoorGold",
        subtitle: "Islamic Marriage Procedure",
        sections: [
            GuideSection(heading: "Prerequisites", steps: [
                GuideStep(number: 1, title: "Wali (Guardian)", detail: "The bride must have a wali — usually her father or closest male relative. The Prophet ﷺ said there is no nikah without a wali.", arabic: nil),
                GuideStep(number: 2, title: "Two Witnesses", detail: "Two adult Muslim male witnesses are required for validity.", arabic: nil),
                GuideStep(number: 3, title: "Mahr (Dowry)", detail: "The groom must give the bride a mahr — can be money, gold, or even teaching Quran. It is her right.", arabic: nil),
                GuideStep(number: 4, title: "Mutual Consent", detail: "Both parties must freely consent. The bride's silence is considered consent if she is shy, but ideally verbal confirmation.", arabic: nil),
            ]),
            GuideSection(heading: "The Ceremony", steps: [
                GuideStep(number: 1, title: "Khutbat al-Nikah", detail: "Begin with the sermon of need (Khutbat al-Hajah) praising Allah and sending salawat.", arabic: "إِنَّ الْحَمْدَ لِلَّهِ نَحْمَدُهُ وَنَسْتَعِينُهُ وَنَسْتَغْفِرُهُ"),
                GuideStep(number: 2, title: "Ijab (Offer)", detail: "The wali says: 'I marry you my daughter [name] for the mahr of [amount].' This is the offer.", arabic: nil),
                GuideStep(number: 3, title: "Qabul (Acceptance)", detail: "The groom says: 'I accept the marriage' (Qabiltu). Must be in the same sitting.", arabic: "قَبِلْتُ"),
                GuideStep(number: 4, title: "Dua for the Couple", detail: "Attendees make dua:", arabic: "بَارَكَ اللَّهُ لَكَ وَبَارَكَ عَلَيْكَ وَجَمَعَ بَيْنَكُمَا فِي خَيْرٍ"),
            ]),
            GuideSection(heading: "Post-Nikah Sunnah", steps: [
                GuideStep(number: 1, title: "Walimah (Wedding Feast)", detail: "The groom should hold a walimah — even if modest. The Prophet ﷺ said 'Hold a walimah, even with one sheep.'", arabic: nil),
                GuideStep(number: 2, title: "Dua on Wedding Night", detail: "When with your spouse for the first time:", arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا وَخَيْرَ مَا جَبَلْتَهَا عَلَيْهِ"),
                GuideStep(number: 3, title: "Announcement", detail: "Make the marriage known — it should not be secret. Beat the duff (tambourine) as per Sunnah.", arabic: nil),
            ]),
        ]
    )

    // MARK: - Travel Duas
    static let travelDuasGuide = EmergencyGuide(
        title: "Travel Duas",
        icon: "airplane",
        color: "NoorAccent",
        subtitle: "Essential Supplications for Travelers",
        sections: [
            GuideSection(heading: "Before & During Travel", steps: [
                GuideStep(number: 1, title: "Dua When Leaving Home", detail: "Say before stepping out:", arabic: "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ"),
                GuideStep(number: 2, title: "Dua for Riding/Boarding", detail: "When seated in your vehicle/plane:", arabic: "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ"),
                GuideStep(number: 3, title: "Travel Dua", detail: "The comprehensive travel supplication:", arabic: "اللَّهُمَّ إِنَّا نَسْأَلُكَ فِي سَفَرِنَا هَٰذَا الْبِرَّ وَالتَّقْوَىٰ وَمِنَ الْعَمَلِ مَا تَرْضَىٰ"),
                GuideStep(number: 4, title: "Dua When Entering a Town", detail: "When arriving at your destination:", arabic: "اللَّهُمَّ رَبَّ السَّمَاوَاتِ السَّبْعِ وَمَا أَظْلَلْنَ أَسْأَلُكَ خَيْرَ هَٰذِهِ الْقَرْيَةِ"),
            ]),
            GuideSection(heading: "During the Journey", steps: [
                GuideStep(number: 1, title: "Shortening Prayers", detail: "Travelers may shorten 4-rak'ah prayers to 2 (Dhuhr, Asr, Isha). This is valid when travel exceeds ~80km.", arabic: nil),
                GuideStep(number: 2, title: "Combining Prayers", detail: "You may combine Dhuhr+Asr and Maghrib+Isha. Can be at the time of either prayer.", arabic: nil),
                GuideStep(number: 3, title: "Dua of the Traveler", detail: "The traveler's dua is accepted — make lots of dua during your journey.", arabic: "ثَلَاثُ دَعَوَاتٍ مُسْتَجَابَاتٍ — دَعْوَةُ الْمُسَافِرِ"),
            ]),
            GuideSection(heading: "Returning Home", steps: [
                GuideStep(number: 1, title: "Dua When Returning", detail: "Repeat the travel dua and add:", arabic: "آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ"),
                GuideStep(number: 2, title: "Pray 2 Rak'ah at Home", detail: "It is Sunnah to pray 2 rak'ah at the masjid or at home when returning from travel.", arabic: nil),
            ]),
        ]
    )
}
