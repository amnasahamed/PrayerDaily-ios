import Foundation

// MARK: - Hadith Collection Model
struct HadithCollection: Identifiable {
    let id: String
    let name: String
    let author: String
    let arabicName: String
    let icon: String
    let color: String
    let totalHadith: Int
    let description: String
    let chapters: [HadithChapter]
}

struct HadithChapter: Identifiable {
    let id: Int
    let title: String
    let arabicTitle: String
    let hadiths: [HadithEntry]
}

struct HadithEntry: Identifiable {
    let id: Int
    let number: Int
    let narrator: String
    let arabic: String
    let english: String
    let grade: String
    let reference: String
    var isBookmarked: Bool = false
}

// MARK: - Sample Hadith Collections
struct HadithLibrary {
    static let collections: [HadithCollection] = [
        nawawiForty, bukhariSelected, muslimSelected, riyadhSaliheen, tibrizi
    ]

    // MARK: - Nawawi 40
    static let nawawiForty = HadithCollection(
        id: "nawawi40",
        name: "40 Hadith Nawawi",
        author: "Imam An-Nawawi",
        arabicName: "الأربعون النووية",
        icon: "text.book.closed.fill",
        color: "NoorPrimary",
        totalHadith: 42,
        description: "The most famous collection of 42 hadiths covering the foundations of Islam.",
        chapters: [
            HadithChapter(id: 1, title: "Foundations of Faith", arabicTitle: "أسس الإيمان", hadiths: [
                HadithEntry(id: 101, number: 1, narrator: "Umar ibn Al-Khattab (RA)",
                    arabic: "إنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى",
                    english: "Actions are judged by intentions, and every person will get what they intended. Whoever emigrated for Allah and His Messenger, his emigration is for Allah and His Messenger. Whoever emigrated for worldly gain or to marry a woman, his emigration is for what he emigrated for.",
                    grade: "Sahih", reference: "Bukhari & Muslim"),
                HadithEntry(id: 102, number: 2, narrator: "Umar ibn Al-Khattab (RA)",
                    arabic: "بَيْنَمَا نَحْنُ عِنْدَ رَسُولِ اللَّهِ ﷺ ذَاتَ يَوْمٍ",
                    english: "One day while we were sitting with the Messenger of Allah ﷺ, there appeared before us a man whose clothes were exceedingly white and whose hair was exceedingly black. He asked about Islam, Iman, and Ihsan.",
                    grade: "Sahih", reference: "Muslim"),
                HadithEntry(id: 103, number: 3, narrator: "Abdullah ibn Umar (RA)",
                    arabic: "بُنِيَ الإِسْلامُ عَلَى خَمْسٍ",
                    english: "Islam is built upon five pillars: testifying that there is no god but Allah and Muhammad is His Messenger, establishing prayer, paying Zakat, making Hajj, and fasting Ramadan.",
                    grade: "Sahih", reference: "Bukhari & Muslim"),
                HadithEntry(id: 104, number: 4, narrator: "Abdullah ibn Masud (RA)",
                    arabic: "إِنَّ أَحَدَكُمْ يُجْمَعُ خَلْقُهُ فِي بَطْنِ أُمِّهِ",
                    english: "Each one of you is constituted in the womb of the mother for forty days as a seed, then he is a clot of blood for a like period, then a morsel of flesh for a like period, then the angel is sent and he breathes the soul into him.",
                    grade: "Sahih", reference: "Bukhari & Muslim"),
            ]),
            HadithChapter(id: 2, title: "Worship & Good Deeds", arabicTitle: "العبادة والأعمال الصالحة", hadiths: [
                HadithEntry(id: 105, number: 5, narrator: "Aisha (RA)",
                    arabic: "مَنْ أَحْدَثَ فِي أَمْرِنَا هَذَا مَا لَيْسَ مِنْهُ فَهُوَ رَدٌّ",
                    english: "Whoever introduces into this affair of ours something that does not belong to it, it is to be rejected.",
                    grade: "Sahih", reference: "Bukhari & Muslim"),
                HadithEntry(id: 106, number: 6, narrator: "An-Numan ibn Bashir (RA)",
                    arabic: "إِنَّ الْحَلاَلَ بَيِّنٌ وَإِنَّ الْحَرَامَ بَيِّنٌ",
                    english: "What is lawful is clear and what is unlawful is clear, and between the two are doubtful matters about which many people are not aware. Whoever avoids doubtful matters clears himself in regard to his religion and his honor.",
                    grade: "Sahih", reference: "Bukhari & Muslim"),
                HadithEntry(id: 107, number: 7, narrator: "Tamim ad-Dari (RA)",
                    arabic: "الدِّينُ النَّصِيحَةُ",
                    english: "The religion is sincerity. We said: To whom? He said: To Allah, to His Book, to His Messenger, to the leaders of the Muslims, and to their common folk.",
                    grade: "Sahih", reference: "Muslim"),
            ]),
            HadithChapter(id: 3, title: "Character & Conduct", arabicTitle: "الأخلاق والسلوك", hadiths: [
                HadithEntry(id: 108, number: 13, narrator: "Anas ibn Malik (RA)",
                    arabic: "لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ",
                    english: "None of you truly believes until he loves for his brother what he loves for himself.",
                    grade: "Sahih", reference: "Bukhari & Muslim"),
                HadithEntry(id: 109, number: 15, narrator: "Abu Hurairah (RA)",
                    arabic: "مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ",
                    english: "Whoever believes in Allah and the Last Day, let him speak good or remain silent. Whoever believes in Allah and the Last Day, let him honor his neighbor. Whoever believes in Allah and the Last Day, let him honor his guest.",
                    grade: "Sahih", reference: "Bukhari & Muslim"),
                HadithEntry(id: 110, number: 18, narrator: "Abu Dharr & Muadh (RA)",
                    arabic: "اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ",
                    english: "Fear Allah wherever you are, follow up a bad deed with a good deed and it will erase it, and deal with people with good character.",
                    grade: "Hasan", reference: "Tirmidhi"),
            ]),
        ]
    )

    // MARK: - Bukhari Selected
    static let bukhariSelected = HadithCollection(
        id: "bukhari",
        name: "Sahih al-Bukhari",
        author: "Imam al-Bukhari",
        arabicName: "صحيح البخاري",
        icon: "book.closed.fill",
        color: "NoorSecondary",
        totalHadith: 50,
        description: "Selected authentic hadiths from the most reliable collection in Sunni Islam.",
        chapters: [
            HadithChapter(id: 10, title: "Book of Revelation", arabicTitle: "كتاب بدء الوحي", hadiths: [
                HadithEntry(id: 201, number: 1, narrator: "Umar ibn Al-Khattab (RA)",
                    arabic: "إنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
                    english: "The reward of deeds depends upon the intentions and every person will get the reward according to what he has intended.",
                    grade: "Sahih", reference: "Bukhari 1"),
                HadithEntry(id: 202, number: 3, narrator: "Aisha (RA)",
                    arabic: "أَوَّلُ مَا بُدِئَ بِهِ رَسُولُ اللَّهِ ﷺ مِنَ الْوَحْيِ الرُّؤْيَا الصَّالِحَةُ",
                    english: "The commencement of divine revelation to the Messenger of Allah ﷺ was in the form of true dreams. He never had a dream but that it came true like bright daylight.",
                    grade: "Sahih", reference: "Bukhari 3"),
            ]),
            HadithChapter(id: 11, title: "Book of Faith", arabicTitle: "كتاب الإيمان", hadiths: [
                HadithEntry(id: 203, number: 8, narrator: "Abdullah ibn Umar (RA)",
                    arabic: "بُنِيَ الإِسْلامُ عَلَى خَمْسٍ",
                    english: "Islam is based on five principles: to testify that none has the right to be worshipped but Allah and Muhammad ﷺ is His Messenger, to offer prayers, to pay Zakat, to perform Hajj, and to fast during Ramadan.",
                    grade: "Sahih", reference: "Bukhari 8"),
                HadithEntry(id: 204, number: 13, narrator: "Anas (RA)",
                    arabic: "لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى أَكُونَ أَحَبَّ إِلَيْهِ",
                    english: "None of you will have faith till he loves me more than his father, his children, and all mankind.",
                    grade: "Sahih", reference: "Bukhari 15"),
            ]),
        ]
    )

    // MARK: - Muslim Selected
    static let muslimSelected = HadithCollection(
        id: "muslim",
        name: "Sahih Muslim",
        author: "Imam Muslim",
        arabicName: "صحيح مسلم",
        icon: "book.fill",
        color: "NoorAccent",
        totalHadith: 50,
        description: "Selected hadiths from the second most authentic collection in Sunni Islam.",
        chapters: [
            HadithChapter(id: 20, title: "Book of Faith", arabicTitle: "كتاب الإيمان", hadiths: [
                HadithEntry(id: 301, number: 1, narrator: "Umar ibn Al-Khattab (RA)",
                    arabic: "بَيْنَمَا نَحْنُ جُلُوسٌ عِنْدَ رَسُولِ اللَّهِ ﷺ",
                    english: "While we were one day sitting with the Messenger of Allah ﷺ, there appeared before us a man dressed in extremely white clothes and with very black hair. He asked: Tell me about Islam, Iman, and Ihsan.",
                    grade: "Sahih", reference: "Muslim 8"),
                HadithEntry(id: 302, number: 2, narrator: "Abu Hurairah (RA)",
                    arabic: "الإِيمَانُ بِضْعٌ وَسَبْعُونَ شُعْبَةً",
                    english: "Faith has over seventy branches, the highest of which is the declaration that there is no god but Allah, and the lowest is removal of something harmful from the road. Modesty is also a branch of faith.",
                    grade: "Sahih", reference: "Muslim 35"),
            ]),
            HadithChapter(id: 21, title: "Book of Purification", arabicTitle: "كتاب الطهارة", hadiths: [
                HadithEntry(id: 303, number: 1, narrator: "Abu Malik al-Ashari (RA)",
                    arabic: "الطُّهُورُ شَطْرُ الإِيمَانِ",
                    english: "Purity is half of faith. Alhamdulillah fills the scale, SubhanAllah and Alhamdulillah fill what is between the heavens and the earth.",
                    grade: "Sahih", reference: "Muslim 223"),
            ]),
        ]
    )

    // MARK: - Riyad as-Saliheen
    static let riyadhSaliheen = HadithCollection(
        id: "riyadh",
        name: "Riyad as-Saliheen",
        author: "Imam An-Nawawi",
        arabicName: "رياض الصالحين",
        icon: "leaf.fill",
        color: "NoorGold",
        totalHadith: 40,
        description: "Gardens of the Righteous — a compilation of hadiths covering everyday Muslim life.",
        chapters: [
            HadithChapter(id: 30, title: "Book of Sincerity", arabicTitle: "كتاب الإخلاص", hadiths: [
                HadithEntry(id: 401, number: 1, narrator: "Umar ibn Al-Khattab (RA)",
                    arabic: "إنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
                    english: "Deeds are judged by intentions, so each man will have what he intended. Thus, he whose migration was to Allah and His Messenger, his migration is to Allah and His Messenger.",
                    grade: "Sahih", reference: "Riyad 1"),
                HadithEntry(id: 402, number: 2, narrator: "Aisha (RA)",
                    arabic: "سَيَكُونُ جَيْشٌ يَغْزُو الْكَعْبَةَ",
                    english: "An army will invade the Ka'bah and when the invaders reach al-Baida, the ground will swallow them all up. I said: O Messenger of Allah! How will they be swallowed when among them are their markets and people not of them? He said: They will all be swallowed up but will be resurrected according to their intentions.",
                    grade: "Sahih", reference: "Riyad 2"),
            ]),
            HadithChapter(id: 31, title: "Book of Repentance", arabicTitle: "كتاب التوبة", hadiths: [
                HadithEntry(id: 403, number: 13, narrator: "Abu Hurairah (RA)",
                    arabic: "وَاللَّهِ إِنِّي لَأَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
                    english: "By Allah, I seek the forgiveness of Allah and I turn to Him in repentance more than seventy times a day.",
                    grade: "Sahih", reference: "Riyad 13"),
            ]),
        ]
    )

    // MARK: - Mishkat al-Masabih
    static let tibrizi = HadithCollection(
        id: "mishkat",
        name: "Mishkat al-Masabih",
        author: "Al-Khatib at-Tibrizi",
        arabicName: "مشكاة المصابيح",
        icon: "lightbulb.fill",
        color: "NoorPrimary",
        totalHadith: 30,
        description: "The Niche of Lamps — an expanded version of Masabih as-Sunnah with additional narrations.",
        chapters: [
            HadithChapter(id: 40, title: "Chapter on Faith", arabicTitle: "باب الإيمان", hadiths: [
                HadithEntry(id: 501, number: 1, narrator: "Umar (RA)",
                    arabic: "إنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
                    english: "Actions are according to intentions, and everyone will get what was intended. Whoever migrates with an intention for Allah and His Messenger, the migration will be for Allah and His Messenger.",
                    grade: "Sahih", reference: "Mishkat 1"),
            ]),
        ]
    )
}
