import Foundation

// MARK: - Hadith Collection Model
struct HadithCollection: Identifiable {
    let id: String
    let name: String
    let nameMl: String
    let author: String
    let authorMl: String
    let arabicName: String
    let icon: String
    let color: String
    let totalHadith: Int
    let description: String
    let descriptionMl: String
    let chapters: [HadithChapter]

    func localizedName(isMalayalam: Bool) -> String {
        isMalayalam ? nameMl : name
    }

    func localizedAuthor(isMalayalam: Bool) -> String {
        isMalayalam ? authorMl : author
    }

    func localizedDescription(isMalayalam: Bool) -> String {
        isMalayalam ? descriptionMl : description
    }
}

struct HadithChapter: Identifiable {
    let id: Int
    let title: String
    let titleMl: String
    let arabicTitle: String
    let hadiths: [HadithEntry]

    func localizedTitle(isMalayalam: Bool) -> String {
        isMalayalam ? titleMl : title
    }
}

struct HadithEntry: Identifiable {
    let id: Int
    let number: Int
    let narrator: String
    let narratorMl: String
    let arabic: String
    let english: String
    let englishMl: String
    let grade: String
    let gradeMl: String
    let reference: String
    var isBookmarked: Bool = false

    func localizedNarrator(isMalayalam: Bool) -> String {
        isMalayalam ? narratorMl : narrator
    }

    func localizedText(isMalayalam: Bool) -> String {
        isMalayalam ? englishMl : english
    }

    func localizedGrade(isMalayalam: Bool) -> String {
        isMalayalam ? gradeMl : grade
    }
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
        nameMl: "നവവി 40 ഹദീസ്",
        author: "Imam An-Nawawi",
        authorMl: "ഇമാം നവവി",
        arabicName: "الأربعون النووية",
        icon: "text.book.closed.fill",
        color: "NoorPrimary",
        totalHadith: 42,
        description: "The most famous collection of 42 hadiths covering the foundations of Islam.",
        descriptionMl: "ഇസ്‌ലാമിന്റെ അടിസ്ഥാനങ്ങൾ ഉൾക്കൊള്ളുന്ന 42 ഹദീസുകളുടെ ഏറ്റവും പ്രശസ്തമായ ശേഖരം.",
        chapters: [
            HadithChapter(id: 1, title: "Foundations of Faith", titleMl: "വിശ്വാസത്തിന്റെ അടിസ്ഥാനങ്ങൾ", arabicTitle: "أسس الإيمان", hadiths: [
                HadithEntry(id: 101, number: 1, narrator: "Umar ibn Al-Khattab (RA)", narratorMl: "ഉമർ ഇബ്‌നുൽ ഖത്താബ് (റഅ)",
                    arabic: "إنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى",
                    english: "Actions are judged by intentions, and every person will get what they intended. Whoever emigrated for Allah and His Messenger, his emigration is for Allah and His Messenger. Whoever emigrated for worldly gain or to marry a woman, his emigration is for what he emigrated for.",
                    englishMl: "പ്രവൃത്തികൾ ഉദ്ദേശ്യങ്ങളാൽ വിധിക്കപ്പെടുന്നു, ഓരോ വ്യക്തിക്കും അവൻ ഉദ്ദേശിച്ചതിനനുസരിച്ച് ലഭിക്കും. ആരെങ്കിലും അല്ലാഹുവിനും അവന്റെ ദൂതനും വേണ്ടി ഹിജ്‌റ ചെയ്താൽ, അവന്റെ ഹിജ്‌റ അല്ലാഹുവിനും അവന്റെ ദൂതനും വേണ്ടിയാണ്. ലൗകിക നേട്ടത്തിനോ സ്ത്രീയെ വിവാഹം ചെയ്യുന്നതിനോ വേണ്ടി ഹിജ്‌റ ചെയ്താൽ, അത് അവൻ ഹിജ്‌റ ചെയ്ത കാര്യത്തിനു വേണ്ടിയാണ്.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari & Muslim"),
                HadithEntry(id: 102, number: 2, narrator: "Umar ibn Al-Khattab (RA)", narratorMl: "ഉമർ ഇബ്‌നുൽ ഖത്താബ് (റഅ)",
                    arabic: "بَيْنَمَا نَحْنُ عِنْدَ رَسُولِ اللَّهِ ﷺ ذَاتَ يَوْمٍ",
                    english: "One day while we were sitting with the Messenger of Allah ﷺ, there appeared before us a man whose clothes were exceedingly white and whose hair was exceedingly black. He asked about Islam, Iman, and Ihsan.",
                    englishMl: "ഒരിക്കൽ ഞങ്ങൾ അല്ലാഹുവിന്റെ ദൂതന്റെ കൂടെ ഇരിക്കുമ്പോൾ, അങ്ങേയറ്റം വെളുത്ത വസ്ത്രവും അങ്ങേയറ്റം കറുത്ത മുടിയും ഉള്ള ഒരാൾ ഞങ്ങളുടെ മുന്നിൽ എത്തി. അദ്ദേഹം ഇസ്ലാം, വിശ്വാസം, സൗന്ദര്യം എന്നിവയെക്കുറിച്ച് ചോദിച്ചു.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Muslim"),
                HadithEntry(id: 103, number: 3, narrator: "Abdullah ibn Umar (RA)", narratorMl: "അബ്ദല്ലാഹ് ഇബ്‌നു ഉമർ (റഅ)",
                    arabic: "بُنِيَ الإِسْلامُ عَلَى خَمْسٍ",
                    english: "Islam is built upon five pillars: testifying that there is no god but Allah and Muhammad is His Messenger, establishing prayer, paying Zakat, making Hajj, and fasting Ramadan.",
                    englishMl: "ഇസ്ലാം അഞ്ച് തൂണുകളിലാണ് നിലനിൽക്കുന്നത്: അല്ലാഹുവിനു പുറമെ ഒരു ദൈവവുമില്ലെന്നും മുഹമ്മദ് അവന്റെ ദൂതനാണെന്നും സാക്ഷ്യപ്പെടുത്തൽ, നമസ്കാരം സ്ഥാപിക്കൽ, സകാത്ത് നൽകൽ, ഹജ്ജ് ചെയ്യൽ, രംഗസാൻ വ്രതം എന്നിവയാണ്.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari & Muslim"),
                HadithEntry(id: 104, number: 4, narrator: "Abdullah ibn Masud (RA)", narratorMl: "അബ്ദല്ലാഹ് ഇബ്‌നു മസ്ഊദ് (റഅ)",
                    arabic: "إِنَّ أَحَدَكُمْ يُجْمَعُ خَلْقُهُ فِي بَطْنِ أُمِّهِ",
                    english: "Each one of you is constituted in the womb of the mother for forty days as a seed, then he is a clot of blood for a like period, then a morsel of flesh for a like period, then the angel is sent and he breathes the soul into him.",
                    englishMl: "നിങ്ങളിൽ ഓരോരുത്തിനും അമ്മയുടെ ഗർഭപാത്രത്തിൽ നാല്പത് ദിവസം വിത്തായി രൂപം കൊള്ളുന്നു, പിന്നീട് അതേ കാലയളവിൽ രക്തക്കട്ടയാകുന്നു, പിന്നീട് അതേ കാലയളവിൽ മാംസം കഷണമാകുന്നു, പിന്നീട് മലക്ക് അയക്കപ്പെടുകയും അവന്റെ ഉള്ളിൽ ആത്മാവ് ഊതിക്കുകയും ചെയ്യുന്നു.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari & Muslim"),
            ]),
            HadithChapter(id: 2, title: "Worship & Good Deeds", titleMl: "ആരാധനയും നന്മയും", arabicTitle: "العبادة والأعمال الصالحة", hadiths: [
                HadithEntry(id: 105, number: 5, narrator: "Aisha (RA)", narratorMl: "ആഇശ (റഅ)",
                    arabic: "مَنْ أَحْدَثَ فِي أَمْرِنَا هَذَا مَا لَيْسَ مِنْهُ فَهُوَ رَدٌّ",
                    english: "Whoever introduces into this affair of ours something that does not belong to it, it is to be rejected.",
                    englishMl: "ആരെങ്കിലും ഞങ്ങളുടെ ഈ കാര്യത്തിൽ അതിനു ചേർന്നതല്ലാത്ത ഒന്ന് കടത്തിവരുകയാണെങ്കിൽ, അത് തിരസ്കരിക്കപ്പെടും.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari & Muslim"),
                HadithEntry(id: 106, number: 6, narrator: "An-Numan ibn Bashir (RA)", narratorMl: "അന്‍-നുമാൻ ഇബ്‌നു ബശീർ (റഅ)",
                    arabic: "إِنَّ الْحَلاَلَ بَيِّنٌ وَإِنَّ الْحَرَامَ بَيِّنٌ",
                    english: "What is lawful is clear and what is unlawful is clear, and between the two are doubtful matters about which many people are not aware. Whoever avoids doubtful matters clears himself in regard to his religion and his honor.",
                    englishMl: "നിയമവിധേയമായത് വ്യക്തമാണ്, നിഷിദ്ധമായതും വ്യക്തമാണ്, ഈ രണ്ടിനും ഇടയിൽ സംശയാസ്പദമായ കാര്യങ്ങളുണ്ട്, അവയെക്കുറിച്ച് പലരും അറിഞ്ഞിരിക്കുന്നില്ല. സംശയാസ്പദമായ കാര്യങ്ങൾ ഒഴിവാക്കുന്നവൻ തന്റെ മതത്തിലും ബഹുമാനത്തിലും സ്വയം വൃത്തിയാക്കുന്നു.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari & Muslim"),
                HadithEntry(id: 107, number: 7, narrator: "Tamim ad-Dari (RA)", narratorMl: "തമീം അദ്-ദാരി (റഅ)",
                    arabic: "الدِّينُ النَّصِيحَةُ",
                    english: "The religion is sincerity. We said: To whom? He said: To Allah, to His Book, to His Messenger, to the leaders of the Muslims, and to their common folk.",
                    englishMl: "മതം സത്യസന്ധതയാണ്. ഞങ്ങൾ ചോദിച്ചു: ആര്ക്ക്? അദ്ദേഹം പറഞ്ഞു: അല്ലാഹുവിന്, അവന്റെ ഗ്രന്ഥത്തിന്, അവന്റെ ദൂതന്, മുസ്‌ലിംകളുടെ നേതാക്കൾക്ക്, അവരുടെ സാധാരണക്കാർക്ക്.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Muslim"),
            ]),
            HadithChapter(id: 3, title: "Character & Conduct", titleMl: "സ്വഭാവവും പെരുമാറ്റവും", arabicTitle: "الأخلاق والسلوك", hadiths: [
                HadithEntry(id: 108, number: 13, narrator: "Anas ibn Malik (RA)", narratorMl: "അനസ് ഇബ്‌നു മാലിക് (റഅ)",
                    arabic: "لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ",
                    english: "None of you truly believes until he loves for his brother what he loves for himself.",
                    englishMl: "നിങ്ങളിൽ ആരും തനിക്ക് സ്നേഹിക്കുന്നത് തന്റെ സഹോദരനും സ്നേഹിക്കുന്നില്ല വരെ ശരിക്കും വിശ്വസിക്കുന്നില്ല.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari & Muslim"),
                HadithEntry(id: 109, number: 15, narrator: "Abu Hurairah (RA)", narratorMl: "അബൂ ഹുറൈറ (റഅ)",
                    arabic: "مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ",
                    english: "Whoever believes in Allah and the Last Day, let him speak good or remain silent. Whoever believes in Allah and the Last Day, let him honor his neighbor. Whoever believes in Allah and the Last Day, let him honor his guest.",
                    englishMl: "അല്ലാഹുവിലും അന്ത്യദിനത്തിലും വിശ്വസിക്കുന്നവൻ നല്ലത് പറയട്ടെ അല്ലെങ്കിൽ മിണക്കട്ടെ. അല്ലാഹുവിലും അന്ത്യദിനത്തിലും വിശ്വസിക്കുന്നവൻ തന്റെ അയൽക്കാരനെ ബഹുമാനിക്കട്ടെ. അല്ലാഹുവിലും അന്ത്യദിനത്തിലും വിശ്വസിക്കുന്നവൻ അതിഥിയെ ബഹുമാനിക്കട്ടെ.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari & Muslim"),
                HadithEntry(id: 110, number: 18, narrator: "Abu Dharr & Muadh (RA)", narratorMl: "അബൂ ധർറും മുആഥ് (റഅ) ഉമ്മ",
                    arabic: "اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ",
                    english: "Fear Allah wherever you are, follow up a bad deed with a good deed and it will erase it, and deal with people with good character.",
                    englishMl: "നീ എവിടെയാണെങ്കിലും അല്ലാഹുവിനെ സൂക്ഷിക്കുക. ഒരു ചീത്ത പ്രവൃത്തിക്ക് ശേഷം ഒരു നല്ല പ്രവൃത്തി ചെയ്യുക, അത് അതിനെ മായ്ച്ചുകളയും. ആളുകളോട് നല്ല സ്വഭാവത്തോടെ ഇടപാടുകൾ നടത്തുക.",
                    grade: "Hasan", gradeMl: "ഹസൻ", reference: "Tirmidhi"),
            ]),
        ]
    )

    // MARK: - Bukhari Selected
    static let bukhariSelected = HadithCollection(
        id: "bukhari",
        name: "Sahih al-Bukhari",
        nameMl: "സഹീഹുൽ ബുഖാരി",
        author: "Imam al-Bukhari",
        authorMl: "ഇമാം ബുഖാരി",
        arabicName: "صحيح البخاري",
        icon: "book.closed.fill",
        color: "NoorSecondary",
        totalHadith: 50,
        description: "Selected authentic hadiths from the most reliable collection in Sunni Islam.",
        descriptionMl: "സുന്നി ഇസ്‌ലാമിലെ ഏറ്റവും വിശ്വസനീയമായ ശേഖരത്തിൽ നിന്നുള്ള തിരഞ്ഞെടുത്ത സഹീഹ് ഹദീസുകൾ.",
        chapters: [
            HadithChapter(id: 10, title: "Book of Revelation", titleMl: "വഹിയുടെ പുസ്തകം", arabicTitle: "كتاب بدء الوحي", hadiths: [
                HadithEntry(id: 201, number: 1, narrator: "Umar ibn Al-Khattab (RA)", narratorMl: "ഉമർ ഇബ്‌നുൽ ഖത്താബ് (റഅ)",
                    arabic: "إنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
                    english: "The reward of deeds depends upon the intentions and every person will get the reward according to what he has intended.",
                    englishMl: "പ്രവൃത്തികളുടെ പ്രതിഫലം ഉദ്ദേശ്യങ്ങളെ ആശ്രയിച്ചിരിക്കുന്നു,  every person will get the reward according to what he has intended.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari 1"),
                HadithEntry(id: 202, number: 3, narrator: "Aisha (RA)", narratorMl: "ആഇശ (റഅ)",
                    arabic: "أَوَّلُ مَا بُدِئَ بِهِ رَسُولُ اللَّهِ ﷺ مِنَ الْوَحْيِ الرُّؤْيَا الصَّالِحَةُ",
                    english: "The commencement of divine revelation to the Messenger of Allah ﷺ was in the form of true dreams. He never had a dream but that it came true like bright daylight.",
                    englishMl: "അല്ലാഹുവിന്റെ ദൂതന് ആമാനവ വെളിപാട് ആരംഭിച്ചത് സത്യസ്വപ്നങ്ങളുടെ രൂപത്തിലായിരുന്നു. അദ്ദേഹത്തിന് സ്വപ്നം കണ്ടിരുന്നതായാണെങ്കിൽ അത് തിളക്കമുള്ള പകൽ പോലെ സത്യമായി.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari 3"),
            ]),
            HadithChapter(id: 11, title: "Book of Faith", titleMl: "വിശ്വാസത്തിന്റെ പുസ്തകം", arabicTitle: "كتاب الإيمان", hadiths: [
                HadithEntry(id: 203, number: 8, narrator: "Abdullah ibn Umar (RA)", narratorMl: "അബ്ദല്ലാഹ് ഇബ്‌നു ഉമർ (റഅ)",
                    arabic: "بُنِيَ الإِسْلامُ عَلَى خَمْسٍ",
                    english: "Islam is based on five principles: to testify that none has the right to be worshipped but Allah and Muhammad ﷺ is His Messenger, to offer prayers, to pay Zakat, to perform Hajj, and to fast during Ramadan.",
                    englishMl: "ഇസ്ലാം അഞ്ച് തത്വങ്ങളിലാണ് അടിസ്ഥാനപ്പെട്ടിരിക്കുന്നത്: അല്ലാഹുവിനു പുറമെ ആരാധനായോഗ്യനായി ആരുമില്ലെന്നും മുഹമ്മദ് ﷺ അവന്റെ ദൂതനാണെന്നും സാക്ഷ്യപ്പെടുത്തൽ, നമസ്കാരം നിർവഹിക്കൽ, സകാത്ത് നൽകൽ, ഹജ്ജ് ചെയ്യൽ, രംഗസാൻ വ്രതം എന്നിവയാണ്.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari 8"),
                HadithEntry(id: 204, number: 13, narrator: "Anas (RA)", narratorMl: "അനസ് (റഅ)",
                    arabic: "لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى أَكُونَ أَحَبَّ إِلَيْهِ",
                    english: "None of you will have faith till he loves me more than his father, his children, and all mankind.",
                    englishMl: "എനിക്ക് തന്റെ പിതാവിനേക്കാളും കുട്ടികളേക്കാളും എല്ലാ മനുഷ്യരേക്കാളും ഞാൻ കൂടുതൽ സ്നേഹിക്കുന്നിടത്തോളം വരെ നിങ്ങളിൽ ആരും വിശ്വാസം ഉണ്ടാകില്ല.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Bukhari 15"),
            ]),
        ]
    )

    // MARK: - Muslim Selected
    static let muslimSelected = HadithCollection(
        id: "muslim",
        name: "Sahih Muslim",
        nameMl: "സഹീഹും മുസ്‌ലിം",
        author: "Imam Muslim",
        authorMl: "ഇമാം മുസ്‌ലിം",
        arabicName: "صحيح مسلم",
        icon: "book.fill",
        color: "NoorAccent",
        totalHadith: 50,
        description: "Selected hadiths from the second most authentic collection in Sunni Islam.",
        descriptionMl: "സുന്നി ഇസ്‌ലാമിലെ രണ്ടാമത്തെ ഏറ്റവും സാധുവായ ശേഖരത്തിൽ നിന്നുള്ള ഹദീസുകൾ.",
        chapters: [
            HadithChapter(id: 20, title: "Book of Faith", titleMl: "വിശ്വാസത്തിന്റെ പുസ്തകം", arabicTitle: "كتاب الإيمان", hadiths: [
                HadithEntry(id: 301, number: 1, narrator: "Umar ibn Al-Khattab (RA)", narratorMl: "ഉമർ ഇബ്‌നുൽ ഖത്താബ് (റഅ)",
                    arabic: "بَيْنَمَا نَحْنُ جُلُوسٌ عِنْدَ رَسُولِ اللَّهِ ﷺ",
                    english: "While we were one day sitting with the Messenger of Allah ﷺ, there appeared before us a man dressed in extremely white clothes and with very black hair. He asked: Tell me about Islam, Iman, and Ihsan.",
                    englishMl: "ഒരിക്കൽ ഞങ്ങൾ അല്ലാഹുവിന്റെ ദൂതന്റെ കൂടെ ഇരിക്കുമ്പോൾ, അങ്ങേയറ്റം വെളുത്ത വസ്ത്രവും വളരെ കറുത്ത മുടിയും ഉള്ള ഒരാൾ ഞങ്ങളുടെ മുന്നിൽ എത്തി. അദ്ദേഹം ചോദിച്ചു: ഇസ്ലാം, വിശ്വാസം, സൗന്ദര്യം എന്നിവയെക്കുറിച്ച് എനിക്ക് പറയൂ.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Muslim 8"),
                HadithEntry(id: 302, number: 2, narrator: "Abu Hurairah (RA)", narratorMl: "അബൂ ഹുറൈറ (റഅ)",
                    arabic: "الإِيمَانُ بِضْعٌ وَسَبْعُونَ شُعْبَةً",
                    english: "Faith has over seventy branches, the highest of which is the declaration that there is no god but Allah, and the lowest is removal of something harmful from the road. Modesty is also a branch of faith.",
                    englishMl: "വിശ്വാസത്തിന് എഴുപതിലധികം ശാഖകളുണ്ട്, അതിൽ ഉന്നതമായത് അല്ലാഹുവിനു പുറമെ ഒരു ദൈവവുമില്ലെന്ന പ്രഖ്യാപനമാണ്, ഏറ്റവും താഴ്ന്നത് വഴിയിൽ നിന്ന് ദോഷകരമായത് നീക്കം ചെയ്യൽകൊണ്ടാണ്. ലജ്ജയും വിശ്വാസത്തിന്റെ ശാഖയാണ്.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Muslim 35"),
            ]),
            HadithChapter(id: 21, title: "Book of Purification", titleMl: "ശുദ്ധിയുടെ പുസ്തകം", arabicTitle: "كتاب الطهارة", hadiths: [
                HadithEntry(id: 303, number: 1, narrator: "Abu Malik al-Ashari (RA)", narratorMl: "അബൂ മാലിക് അൽ-അഷരി (റഅ)",
                    arabic: "الطُّهُورُ شَطْرُ الإِيمَانِ",
                    english: "Purity is half of faith. Alhamdulillah fills the scale, SubhanAllah and Alhamdulillah fill what is between the heavens and the earth.",
                    englishMl: "ശുദ്ധി വിശ്വാസത്തിന്റെ പകുതിയാണ്. അൽഹംദുലില്ലാഹ് ത്രാസിനെ നിറയ്ക്കുന്നു, സുബ്ഹാനല്ലാഹും അൽഹംദുലില്ലാഹും ആകാശങ്ങളും ഭൂമിയും തമ്മിലുള്ളത് നിറയ്ക്കുന്നു.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Muslim 223"),
            ]),
        ]
    )

    // MARK: - Riyad as-Saliheen
    static let riyadhSaliheen = HadithCollection(
        id: "riyadh",
        name: "Riyad as-Saliheen",
        nameMl: "റിയാദുസ് സാലിഹീൻ",
        author: "Imam An-Nawawi",
        authorMl: "ഇമാം നവവി",
        arabicName: "رياض الصالحين",
        icon: "leaf.fill",
        color: "NoorGold",
        totalHadith: 40,
        description: "Gardens of the Righteous — a compilation of hadiths covering everyday Muslim life.",
        descriptionMl: "നീതിമാന്മാരുടെ പൂന്തോട്ടം — ദൈനംചില മുസ്‌ലിം ജീവിതത്തെ ഉൾക്കൊള്ളുന്ന ഹദീസുകളുടെ സമാഹരം.",
        chapters: [
            HadithChapter(id: 30, title: "Book of Sincerity", titleMl: "സാന്തഃപര്യത്തിന്റെ പുസ്തകം", arabicTitle: "كتاب الإخلاص", hadiths: [
                HadithEntry(id: 401, number: 1, narrator: "Umar ibn Al-Khattab (RA)", narratorMl: "ഉമർ ഇബ്‌നുൽ ഖത്താബ് (റഅ)",
                    arabic: "إنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
                    english: "Deeds are judged by intentions, so each man will have what he intended. Thus, he whose migration was to Allah and His Messenger, his migration is to Allah and His Messenger.",
                    englishMl: "പ്രവൃത്തികൾ ഉദ്ദേശ്യങ്ങളാൽ വിധിക്കപ്പെടുന്നു, അതിനാൽ ഓരോ മനുഷ്യനും അവൻ ഉദ്ദേശിച്ചത് ലഭിക്കും. അതിനാൽ, ആരുടെ ഹിജ്‌റ അല്ലാഹുവിനും അവന്റെ ദൂതനും വേണ്ടിയാണോ, അവന്റെ ഹിജ്‌റ അല്ലാഹുവിനും അവന്റെ ദൂതനും വേണ്ടിയാണ്.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Riyad 1"),
                HadithEntry(id: 402, number: 2, narrator: "Aisha (RA)", narratorMl: "ആഇശ (റഅ)",
                    arabic: "سَيَكُونُ جَيْشٌ يَغْزُو الْكَعْبَةَ",
                    english: "An army will invade the Ka'bah and when the invaders reach al-Baida, the ground will swallow them all up. I said: O Messenger of Allah! How will they be swallowed when among them are their markets and people not of them? He said: They will all be swallowed up but will be resurrected according to their intentions.",
                    englishMl: "ഒരു സൈന്യം കഅബയെ ആക്രമിക്കും, ആക്രമണകാരികൾ അൽ-ബൈദയിൽ എത്തിക്കഴിഞ്ഞാൽ, ഭൂമി അവരെല്ലാം വിഴുങ്ങും. ഞാൻ പറഞ്ഞു: അല്ലാഹുവിന്റെ ദൂതരേ! അവരുടെ കച്ചവടസ്ഥലങ്ങളും അവരുടെ കൂടെ ആളുകളും ഉള്ളപ്പോൾ എങ്ങനെയാണ് വിഴുങ്ങുക? അദ്ദേഹം പറഞ്ഞു: അവരെല്ലാം വിഴുങ്ങപ്പെടും, പക്ഷെ അവരുടെ ഉദ്ദേശ്യങ്ങൾക്കനുസരിച്ച് ഉയിർത്തെഴുന്നേൽക്കും.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Riyad 2"),
            ]),
            HadithChapter(id: 31, title: "Book of Repentance", titleMl: "പശ്ചാത്താപത്തിന്റെ പുസ്തകം", arabicTitle: "كتاب التوبة", hadiths: [
                HadithEntry(id: 403, number: 13, narrator: "Abu Hurairah (RA)", narratorMl: "അബൂ ഹുറൈറ (റഅ)",
                    arabic: "وَاللَّهِ إِنِّي لَأَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
                    english: "By Allah, I seek the forgiveness of Allah and I turn to Him in repentance more than seventy times a day.",
                    englishMl: "അല്ലാഹുവിനെ സത്യം, ഞാൻ ഒരു ദിവസം എഴുപതിലധികം തവണ അല്ലാഹുവിനോട് ക്ഷമ ചോദിക്കുകയും അവങ്കലേക്ക് പശ്ചാത്തപിക്കുകയും ചെയ്യുന്നു.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Riyad 13"),
            ]),
        ]
    )

    // MARK: - Mishkat al-Masabih
    static let tibrizi = HadithCollection(
        id: "mishkat",
        name: "Mishkat al-Masabih",
        nameMl: "മിശ്കാതുൽ മസാബീഹ്",
        author: "Al-Khatib at-Tibrizi",
        authorMl: "അൽ-ഖാത്തിബ് അത്-തിബ്രിസി",
        arabicName: "مشكاة المصابيح",
        icon: "lightbulb.fill",
        color: "NoorPrimary",
        totalHadith: 30,
        description: "The Niche of Lamps — an expanded version of Masabih as-Sunnah with additional narrations.",
        descriptionMl: "വിളക്കുകളുടെ മാടം — അധിക റിവായാകളോടെ വിപുലീകരിച്ച പതിപ്പ്.",
        chapters: [
            HadithChapter(id: 40, title: "Chapter on Faith", titleMl: "വിശ്വാസത്തിന്റെ അധ്യായം", arabicTitle: "باب الإيمان", hadiths: [
                HadithEntry(id: 501, number: 1, narrator: "Umar (RA)", narratorMl: "ഉമർ (റഅ)",
                    arabic: "إنَّمَا الأَعْمَالُ بِالنِّيَّاتِ",
                    english: "Actions are according to intentions, and everyone will get what was intended. Whoever migrates with an intention for Allah and His Messenger, the migration will be for Allah and His Messenger.",
                    englishMl: "പ്രവൃത്തികൾ ഉദ്ദേശ്യങ്ങൾക്കനുസരിച്ചാണ്, ഓരോരുത്തിനും അവൻ ഉദ്ദേശിച്ചത് ലഭിക്കും. അല്ലാഹുവിനും അവന്റെ ദൂതനും വേണ്ടി ഉദ്ദേശ്യത്തോടെ ഹിജ്‌റ ചെയ്യുന്നവന്റെ ഹിജ്‌റ അല്ലാഹുവിനും അവന്റെ ദൂതനും വേണ്ടിയാണ്.",
                    grade: "Sahih", gradeMl: "സഹീഹ്", reference: "Mishkat 1"),
            ]),
        ]
    )
}
