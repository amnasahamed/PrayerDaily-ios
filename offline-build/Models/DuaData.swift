import SwiftUI

// MARK: - Dua Category
struct DuaCategory: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let titleMl: String
    let icon: String
    let color: Color
    let duas: [DuaEntry]

    func localizedTitle(isMalayalam: Bool) -> String {
        isMalayalam ? titleMl : title
    }

    static func == (lhs: DuaCategory, rhs: DuaCategory) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct DuaEntry: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let titleMl: String
    let arabic: String
    let transliteration: String
    let translation: String
    let translationMl: String
    let reference: String
    var isFavorite: Bool = false

    func localizedTitle(isMalayalam: Bool) -> String {
        isMalayalam ? titleMl : title
    }
    func localizedTranslation(isMalayalam: Bool) -> String {
        isMalayalam ? translationMl : translation
    }
}

// MARK: - Dua Database
struct DuaDatabase {

    static let morning = DuaCategory(
        title: "Morning", titleMl: "പ്രഭാത ദുആകൾ",
        icon: "sunrise.fill", color: Color.alehaAmber,
        duas: [
            DuaEntry(number: 1, title: "Morning Remembrance", titleMl: "പ്രഭാത സ്മരണ",
                     arabic: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ",
                     transliteration: "Asbahna wa asbahal mulku lillahi walhamdu lillah",
                     translation: "We have entered the morning and at this very time the dominion belongs to Allah, and all praise is for Allah.",
                     translationMl: "ഞങ്ങൾ പ്രഭാതത്തിലേക്ക് പ്രവേശിച്ചു; ഈ നിമിഷം ആധിപത്യം അള്ളാഹുവിനും, സർവ സ്തുതിയും അള്ളാഹുവിനും.",
                     reference: "Abu Dawud 5076"),
            DuaEntry(number: 2, title: "Gratitude at Dawn", titleMl: "ഉഷഃകാല നന്ദി",
                     arabic: "اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ",
                     transliteration: "Allahumma bika asbahna wa bika amsayna wa bika nahya wa bika namutu",
                     translation: "O Allah, by Your leave we have reached the morning and by Your leave we have reached the evening, by Your leave we live and die.",
                     translationMl: "അല്ലാഹുവേ, നിന്റെ അനുഗ്രഹത്തിലൂടെ ഞങ്ങൾ പ്രഭാതം കണ്ടു; ഞങ്ങൾ ജീവിക്കുന്നതും മരിക്കുന്നതും നിന്നിൽ.",
                     reference: "Tirmidhi 3391"),
            DuaEntry(number: 3, title: "Seeking Allah's Blessing", titleMl: "അള്ളാഹുവിന്റെ അനുഗ്രഹം",
                     arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ",
                     transliteration: "Allahumma anta rabbi la ilaha illa anta, khalaqtani wa ana abduk",
                     translation: "O Allah, You are my Lord, none has the right to be worshipped except You, You created me and I am Your servant.",
                     translationMl: "അല്ലാഹുവേ, നീ എന്റെ രക്ഷിതാവ്; നിന്നല്ലാതെ ആരാധ്യനില്ല. നീ എന്നെ സൃഷ്ടിച്ചു, ഞാൻ നിന്റെ ദാസൻ.",
                     reference: "Bukhari 6306"),
            DuaEntry(number: 4, title: "Protection from Evil", titleMl: "തിന്മയിൽ നിന്ന് കാവൽ",
                     arabic: "أَعُوذُ بِاللَّهِ السَّمِيعِ الْعَلِيمِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
                     transliteration: "A'udhu billahis-sami'il 'alimi minash-shaytanir-rajim",
                     translation: "I seek refuge in Allah, the All-Hearing, All-Knowing, from the accursed devil.",
                     translationMl: "സർവ്വം കേൾക്കുന്ന, അറിയുന്ന അള്ളാഹുവിൽ ശപിക്കപ്പെട്ട പിശാചിൽ നിന്ന് ഞാൻ അഭയം തേടുന്നു.",
                     reference: "Abu Dawud 775"),
            DuaEntry(number: 5, title: "Morning Tasbih", titleMl: "പ്രഭാത തസ്ബീഹ്",
                     arabic: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
                     transliteration: "Subhanallahi wa bihamdih",
                     translation: "Glory be to Allah and praise be to Him.",
                     translationMl: "അള്ളാഹു പരിശുദ്ധൻ, അവനു സ്തുതി.",
                     reference: "Bukhari 6405"),
            DuaEntry(number: 6, title: "Ayat al-Kursi", titleMl: "ആയത്തുൽ കുർസി",
                     arabic: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ",
                     transliteration: "Allahu la ilaha illa huwal-hayyul-qayyum",
                     translation: "Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence.",
                     translationMl: "അള്ളാഹു — അവനല്ലാതെ ആരാധ്യനില്ല, നിത്യജീവനുള്ളവൻ, സ്വയം നിലനിൽക്കുന്നവൻ.",
                     reference: "Quran 2:255"),
            DuaEntry(number: 7, title: "Seeking Good Day", titleMl: "നല്ല ദിനം ചോദിക്കൽ",
                     arabic: "اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ هَذَا الْيَوْمِ",
                     transliteration: "Allahumma inni as'aluka khayra hadhal-yawm",
                     translation: "O Allah, I ask You for the good of this day, its victory, its light, its blessings and its guidance.",
                     translationMl: "അല്ലാഹുവേ, ഈ ദിവസത്തിന്റെ ഗുണവും വിജയവും പ്രകാശവും ബർക്കത്തും ഹിദായത്തും ഞാൻ നിന്നോട് ചോദിക്കുന്നു.",
                     reference: "Abu Dawud 5084"),
            DuaEntry(number: 8, title: "Morning Salawat", titleMl: "പ്രഭാത സ്വലാത്ത്",
                     arabic: "اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ",
                     transliteration: "Allahumma salli wa sallim 'ala nabiyyina Muhammad",
                     translation: "O Allah, bestow peace and blessings upon our Prophet Muhammad.",
                     translationMl: "അല്ലാഹുവേ, നമ്മുടെ നബി മുഹമ്മദ് (സ)യുടെ മേൽ സ്വലാത്തും സലാമും ചൊരിയണേ.",
                     reference: "Hadith")
        ]
    )

    static let evening = DuaCategory(
        title: "Evening", titleMl: "സന്ധ്യ ദുആകൾ",
        icon: "sunset.fill", color: Color.alehaDarkGreen,
        duas: [
            DuaEntry(number: 1, title: "Evening Remembrance", titleMl: "സന്ധ്യ സ്മരണ",
                     arabic: "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ",
                     transliteration: "Amsayna wa amsal-mulku lillahi walhamdu lillah",
                     translation: "We have entered the evening and at this very time the dominion belongs to Allah, and all praise is for Allah.",
                     translationMl: "ഞങ്ങൾ സന്ധ്യയിലേക്ക് പ്രവേശിച്ചു; ഈ നിമിഷം ആധിപത്യം അള്ളാഹുവിനും, സർവ സ്തുതിയും അള്ളാഹുവിനും.",
                     reference: "Abu Dawud 5076"),
            DuaEntry(number: 2, title: "Before Sleep", titleMl: "ഉറക്കത്തിനു മുൻപ്",
                     arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا",
                     transliteration: "Bismika Allahumma amutu wa ahya",
                     translation: "In Your name, O Allah, I die and I live.",
                     translationMl: "അല്ലാഹുവേ, നിന്റെ നാമത്തിൽ ഞാൻ ഉറങ്ങുന്നു, നിന്റെ നാമത്തിൽ ഉണരുന്നു.",
                     reference: "Bukhari 6312"),
            DuaEntry(number: 3, title: "Heart at Peace", titleMl: "ഹൃദയ ശാന്തി",
                     arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ",
                     transliteration: "Allahumma inni a'udhu bika minal-hammi wal-hazan",
                     translation: "O Allah, I seek Your protection from anxiety and grief.",
                     translationMl: "അല്ലാഹുവേ, ഉത്കണ്ഠയിൽ നിന്നും ദുഃഖത്തിൽ നിന്നും ഞാൻ നിന്നിൽ അഭയം തേടുന്നു.",
                     reference: "Bukhari 2893"),
            DuaEntry(number: 4, title: "Evening Protection", titleMl: "സന്ധ്യ സംരക്ഷണം",
                     arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
                     transliteration: "A'udhu bikalimatillahit-tammati min sharri ma khalaq",
                     translation: "I seek refuge in the perfect words of Allah from the evil of what He has created.",
                     translationMl: "അള്ളാഹു സൃഷ്ടിച്ചതിന്റെ തിന്മകളിൽ നിന്ന് അവന്റെ പൂർണ്ണ വചനങ്ങളിൽ ഞാൻ അഭയം തേടുന്നു.",
                     reference: "Muslim 2708"),
            DuaEntry(number: 5, title: "Evening Salawat", titleMl: "സന്ധ്യ സ്വലാത്ത്",
                     arabic: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ",
                     transliteration: "Allahumma salli 'ala Muhammadin wa 'ala ali Muhammad",
                     translation: "O Allah, send blessings upon Muhammad and the family of Muhammad.",
                     translationMl: "അല്ലാഹുവേ, മുഹമ്മദ് നബി (സ)യുടെ മേലും കുടുംബത്തിന്റെ മേലും സ്വലാത്ത് ചൊരിയണേ.",
                     reference: "Bukhari 3370")
        ]
    )

    static let travel = DuaCategory(
        title: "Travel", titleMl: "യാത്ര ദുആകൾ",
        icon: "airplane", color: Color.alehaGreen,
        duas: [
            DuaEntry(number: 1, title: "Starting a Journey", titleMl: "യാത്ര തുടങ്ങുമ്പോൾ",
                     arabic: "اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ",
                     transliteration: "Allahu Akbar, Allahu Akbar, Allahu Akbar",
                     translation: "Allah is the Greatest, Allah is the Greatest, Allah is the Greatest.",
                     translationMl: "അള്ളാഹു ഏറ്റവും വലിയവൻ, അള്ളാഹു ഏറ്റവും വലിയവൻ, അള്ളാഹു ഏറ്റവും വലിയവൻ.",
                     reference: "Muslim 1342"),
            DuaEntry(number: 2, title: "Boarding a Vehicle", titleMl: "വാഹനത്തിൽ കയറുമ്പോൾ",
                     arabic: "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا",
                     transliteration: "Subhanal-ladhi sakhkhara lana hadha",
                     translation: "Glory be to Him Who has subjected this to us, and we were not capable of that.",
                     translationMl: "ഇതിനെ ഞങ്ങൾക്ക് കീഴ്പ്പെടുത്തിത്തന്നവൻ പരിശുദ്ധൻ; ഞങ്ങൾക്ക് ഇതു സ്വന്തമായി സാധ്യമാകുമായിരുന്നില്ല.",
                     reference: "Quran 43:13"),
            DuaEntry(number: 3, title: "Returning Home", titleMl: "വീട്ടിലേക്ക് മടങ്ങൽ",
                     arabic: "آيِبُونَ تَائِبُونَ عَابِدُونَ لِرَبِّنَا حَامِدُونَ",
                     transliteration: "Ayibuna, ta'ibuna, 'abiduna, lirabbina hamidun",
                     translation: "We are returning, repenting, worshipping, and praising our Lord.",
                     translationMl: "ഞങ്ങൾ മടങ്ങുന്നു, പശ്ചാത്തപിക്കുന്നു, ആരാധിക്കുന്നു, ഞങ്ങളുടെ രക്ഷിതാവിനെ സ്തുതിക്കുന്നു.",
                     reference: "Bukhari 1797"),
            DuaEntry(number: 4, title: "Safety in Travel", titleMl: "യാത്ര സുരക്ഷ",
                     arabic: "اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ",
                     transliteration: "Allahumma antas-sahibu fis-safari",
                     translation: "O Allah, You are the Companion in travel and the Guardian of the family.",
                     translationMl: "അല്ലാഹുവേ, യാത്രയിൽ നീ ഞങ്ങളുടെ കൂട്ടാളി, കുടുംബത്തിന്റെ കാവൽക്കാരൻ.",
                     reference: "Muslim 1342")
        ]
    )

    static let protection = DuaCategory(
        title: "Protection", titleMl: "സംരക്ഷണ ദുആകൾ",
        icon: "shield.fill", color: Color(red: 0.55, green: 0.30, blue: 0.85),
        duas: [
            DuaEntry(number: 1, title: "Complete Protection", titleMl: "സർവ്വ സംരക്ഷണം",
                     arabic: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
                     transliteration: "A'udhu bikalimatillahit-tammati min sharri ma khalaq",
                     translation: "I seek refuge in the perfect words of Allah from the evil of that which He has created.",
                     translationMl: "അള്ളാഹു സൃഷ്ടിച്ചതിലെ എല്ലാ ഉപദ്രവങ്ങളിൽ നിന്നും അവന്റെ പൂർണ്ണ വചനങ്ങളിൽ ഞാൻ അഭയം തേടുന്നു.",
                     reference: "Muslim 2708"),
            DuaEntry(number: 2, title: "Surah Al-Falaq", titleMl: "സൂറ അൽ-ഫലഖ്",
                     arabic: "قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ مِنْ شَرِّ مَا خَلَقَ",
                     transliteration: "Qul a'udhu birabbil-falaq, min sharri ma khalaq",
                     translation: "Say: I seek refuge in the Lord of the daybreak, from the evil of what He has created.",
                     translationMl: "പറയൂ: ഉഷഃകാലത്തിന്റെ നാഥനിൽ ഞാൻ അഭയം തേടുന്നു, അവൻ സൃഷ്ടിച്ചതിന്റെ ഉപദ്രവത്തിൽ നിന്ന്.",
                     reference: "Quran 113:1-2"),
            DuaEntry(number: 3, title: "Surah An-Nas", titleMl: "സൂറ അൻ-നാസ്",
                     arabic: "قُلْ أَعُوذُ بِرَبِّ النَّاسِ مَلِكِ النَّاسِ إِلَهِ النَّاسِ",
                     transliteration: "Qul a'udhu birabbin-nas, malikin-nas, ilahin-nas",
                     translation: "Say: I seek refuge in the Lord of mankind, the King of mankind, the God of mankind.",
                     translationMl: "പറയൂ: മനുഷ്യരുടെ നാഥനിൽ, മനുഷ്യരുടെ രാജാവിൽ, മനുഷ്യരുടെ ഇലാഹിൽ ഞാൻ അഭയം തേടുന്നു.",
                     reference: "Quran 114:1-3"),
            DuaEntry(number: 4, title: "Leaving Home", titleMl: "വീട് വിടുമ്പോൾ",
                     arabic: "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
                     transliteration: "Bismillahi tawakkaltu 'alallahi wa la hawla wa la quwwata illa billah",
                     translation: "In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.",
                     translationMl: "അള്ളാഹുവിന്റെ നാമത്തിൽ, ഞാൻ അള്ളാഹുവിൽ ഭരമേൽപ്പിക്കുന്നു; അള്ളാഹു ഇല്ലാതെ ശക്തിയോ കഴിവോ ഇല്ല.",
                     reference: "Abu Dawud 5095"),
            DuaEntry(number: 5, title: "Against Anxiety", titleMl: "ഉൾഭയത്തിനെതിരെ",
                     arabic: "اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ",
                     transliteration: "Allahumma inni a'udhu bika minal-hammi wal-hazani",
                     translation: "O Allah, I seek Your refuge from anxiety, grief and incapacity.",
                     translationMl: "അല്ലാഹുവേ, ഉത്കണ്ഠ, ദുഃഖം, അശക്തി എന്നിവയിൽ നിന്ന് ഞാൻ നിന്നിൽ അഭയം തേടുന്നു.",
                     reference: "Bukhari 6369")
        ]
    )

    static let all: [DuaCategory] = [morning, evening, travel, protection]
}
