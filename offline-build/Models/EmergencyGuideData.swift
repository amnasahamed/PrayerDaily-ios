import Foundation

// MARK: - Guide Models
struct EmergencyGuide: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let titleMl: String
    let icon: String
    let color: String
    let subtitle: String
    let subtitleMl: String
    let sections: [GuideSection]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: EmergencyGuide, rhs: EmergencyGuide) -> Bool { lhs.id == rhs.id }

    func localizedTitle(isMalayalam: Bool) -> String { isMalayalam ? titleMl : title }
    func localizedSubtitle(isMalayalam: Bool) -> String { isMalayalam ? subtitleMl : subtitle }
}

struct GuideSection: Identifiable, Hashable {
    let id = UUID()
    let heading: String
    let headingMl: String
    let steps: [GuideStep]

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: GuideSection, rhs: GuideSection) -> Bool { lhs.id == rhs.id }

    func localizedHeading(isMalayalam: Bool) -> String { isMalayalam ? headingMl : heading }
}

struct GuideStep: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let title: String
    let titleMl: String
    let detail: String
    let detailMl: String
    let arabic: String?

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: GuideStep, rhs: GuideStep) -> Bool { lhs.id == rhs.id }

    func localizedTitle(isMalayalam: Bool) -> String { isMalayalam ? titleMl : title }
    func localizedDetail(isMalayalam: Bool) -> String { isMalayalam ? detailMl : detail }
}

// MARK: - Static Guide Data
struct EmergencyGuideData {
    static let allGuides: [EmergencyGuide] = [
        EmergencyGuide(
            title: "Ghusl (Ritual Bath)",
            titleMl: "ഗുസ്ൽ (കുളി)",
            icon: "drop.fill",
            color: "NoorBlue",
            subtitle: "Steps for purification bath",
            subtitleMl: "ശുദ്ധിവരുത്തൽ കുളിയുടെ ഘട്ടങ്ങൾ",
            sections: [
                GuideSection(
                    heading: "Obligatory Acts",
                    headingMl: "നിർബന്ധ കർമ്മങ്ങൾ",
                    steps: [
                        GuideStep(number: 1, title: "Intention (Niyyah)", titleMl: "നിയ്യത്ത്", detail: "Make the intention in your heart to perform Ghusl.", detailMl: "ഗുസ്ൽ ചെയ്യാൻ മനസ്സിൽ നിയ്യത്ത് ചെയ്യുക.", arabic: "نَوَيْتُ الْغُسْلَ لِرَفْعِ الْحَدَثِ"),
                        GuideStep(number: 2, title: "Wash the entire body", titleMl: "ശരീരം മുഴുവൻ കഴുകുക", detail: "Pour water over the entire body ensuring no part remains dry.", detailMl: "ശരീരത്തിൽ ഒരിടത്തും വെള്ളം ഏൽക്കാതിരിക്കാതെ മുഴുവൻ കഴുകുക.", arabic: nil),
                        GuideStep(number: 3, title: "Rinse mouth and nose", titleMl: "വായും മൂക്കും കഴുകുക", detail: "Rinse the mouth and sniff water into the nose.", detailMl: "വായ് കൊപ്ലിക്കുകയും മൂക്കിൽ വെള്ളം കയറ്റുകയും ചെയ്യുക.", arabic: nil)
                    ]
                )
            ]
        ),
        EmergencyGuide(
            title: "Wudu (Ablution)",
            titleMl: "വുളൂ",
            icon: "hand.raised.fill",
            color: "NoorGreen",
            subtitle: "Step-by-step guide to wudu",
            subtitleMl: "വുളൂ ഘട്ടങ്ങൾ",
            sections: [
                GuideSection(
                    heading: "Steps of Wudu",
                    headingMl: "വുളൂ ഘട്ടങ്ങൾ",
                    steps: [
                        GuideStep(number: 1, title: "Bismillah & Intention", titleMl: "ബിസ്മി & നിയ്യത്ത്", detail: "Say Bismillah and make intention for wudu.", detailMl: "ബിസ്മി ചൊല്ലി വുളൂ ചെയ്യാൻ നിയ്യത്ത് ചെയ്യുക.", arabic: "بِسْمِ اللهِ"),
                        GuideStep(number: 2, title: "Wash hands", titleMl: "കൈ കഴുകുക", detail: "Wash both hands up to the wrists three times.", detailMl: "കൈമുട്ട് വരെ മൂന്ന് തവണ കഴുകുക.", arabic: nil),
                        GuideStep(number: 3, title: "Rinse mouth & nose", titleMl: "വായും മൂക്കും", detail: "Rinse your mouth three times, then sniff water into your nose three times.", detailMl: "മൂന്ന് തവണ വായ് കൊപ്ലിക്കുക, മൂക്കിൽ വെള്ളം കയറ്റുക.", arabic: nil),
                        GuideStep(number: 4, title: "Wash face", titleMl: "മുഖം കഴുകുക", detail: "Wash the face three times from hairline to chin.", detailMl: "ചുടലമൂടി മുതൽ താടി വരെ മൂന്ന് തവണ കഴുകുക.", arabic: nil),
                        GuideStep(number: 5, title: "Wash arms", titleMl: "കൈകൾ കഴുകുക", detail: "Wash both arms to the elbows three times, right first.", detailMl: "വലത് ആദ്യം, കൈമുട്ട് ഉൾപ്പെടെ മൂന്ന് തവണ.", arabic: nil),
                        GuideStep(number: 6, title: "Wipe head & ears", titleMl: "തല-കാതുകൾ", detail: "Wipe the head once, then wipe inside and outside of ears.", detailMl: "ഒരു തവണ തലനനക്കി കാതിനകവും പുറവും തുടക്കുക.", arabic: nil),
                        GuideStep(number: 7, title: "Wash feet", titleMl: "കാലുകൾ കഴുകുക", detail: "Wash both feet to the ankles three times, right first.", detailMl: "ഞൊണ്ടി ഉൾപ്പെടെ മൂന്ന് തവണ, വലത് ആദ്യം.", arabic: nil)
                    ]
                )
            ]
        ),
        EmergencyGuide(
            title: "Salah (Prayer)",
            titleMl: "നമസ്കാരം",
            icon: "star.and.crescent",
            color: "NoorGold",
            subtitle: "How to perform the daily prayers",
            subtitleMl: "ദൈനദിന നമസ്കാരം",
            sections: [
                GuideSection(
                    heading: "Standing (Qiyam)",
                    headingMl: "നിൽക്കൽ (ക്വിയാം)",
                    steps: [
                        GuideStep(number: 1, title: "Takbir al-Ihram", titleMl: "തക്ബീറതുൽ ഇഹ്‌റാം", detail: "Raise hands to ears and say Allahu Akbar.", detailMl: "ചെവി വരെ കൈ ഉയർത്തി 'അല്ലാഹു അക്ബർ' ചൊല്ലുക.", arabic: "اللَّهُ أَكْبَرُ"),
                        GuideStep(number: 2, title: "Recite Al-Fatiha", titleMl: "ഫാതിഹ പാരായണം", detail: "Recite Surah Al-Fatiha followed by any surah.", detailMl: "സൂറ അൽ-ഫാതിഹ ഓതി ഏതെങ്കിലും സൂറ ചേർക്കുക.", arabic: "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                    ]
                ),
                GuideSection(
                    heading: "Ruku & Sujood",
                    headingMl: "റുകൂ & സുജൂദ്",
                    steps: [
                        GuideStep(number: 3, title: "Ruku (Bowing)", titleMl: "റുകൂ", detail: "Bow with hands on knees and say SubhanAllah 3 times.", detailMl: "കൈ മുട്ടിൽ വച്ച് കുനിഞ്ഞ് 'സുബ്ഹാനല്ലാഹ്' മൂന്ന് തവണ ചൊല്ലുക.", arabic: "سُبْحَانَ رَبِّيَ الْعَظِيمِ"),
                        GuideStep(number: 4, title: "Sujood (Prostration)", titleMl: "സുജൂദ്", detail: "Prostrate on 7 body parts and say SubhanAllah 3 times.", detailMl: "ഏഴ് അവയവം ഉപയോഗിച്ച് സുജൂദ് ചെയ്ത് മൂന്ന് തവണ ചൊല്ലുക.", arabic: "سُبْحَانَ رَبِّيَ الْأَعْلَى")
                    ]
                )
            ]
        ),
        EmergencyGuide(
            title: "Janazah Prayer",
            titleMl: "ജനാസ നമസ്കാരം",
            icon: "heart.fill",
            color: "NoorPurple",
            subtitle: "Funeral prayer guide",
            subtitleMl: "ജനാസ നമസ്കാര മാർഗ്ഗദർശി",
            sections: [
                GuideSection(
                    heading: "Four Takbirs",
                    headingMl: "നാല് തക്ബീറുകൾ",
                    steps: [
                        GuideStep(number: 1, title: "First Takbir", titleMl: "ഒന്നാം തക്ബീർ", detail: "Say Allahu Akbar and recite Al-Fatiha.", detailMl: "അല്ലാഹു അക്ബർ ചൊല്ലി ഫാതിഹ ഓതുക.", arabic: "اللَّهُ أَكْبَرُ"),
                        GuideStep(number: 2, title: "Second Takbir", titleMl: "രണ്ടാം തക്ബീർ", detail: "Say Allahu Akbar and recite Salawat (Durood).", detailMl: "അല്ലാഹു അക്ബർ ചൊല്ലി ദുറൂദ് ഓതുക.", arabic: "اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ"),
                        GuideStep(number: 3, title: "Third Takbir", titleMl: "മൂന്നാം തക്ബീർ", detail: "Say Allahu Akbar and make dua for the deceased.", detailMl: "അല്ലാഹു അക്ബർ ചൊല്ലി മയ്യിത്തിന് വേണ്ടി ദുആ ചെയ്യുക.", arabic: "اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ"),
                        GuideStep(number: 4, title: "Fourth Takbir", titleMl: "നാലാം തക്ബീർ", detail: "Say Allahu Akbar and end with Tasleem on both sides.", detailMl: "അല്ലാഹു അക്ബർ ചൊല്ലി ഇരുഭാഗത്തേക്കും സലാം വീഴ്ത്തുക.", arabic: "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللَّهِ")
                    ]
                )
            ]
        ),

        // MARK: Tayammum
        EmergencyGuide(
            title: "Tayammum (Dry Ablution)",
            titleMl: "തയമ്മും",
            icon: "sun.dust.fill",
            color: "NoorGold",
            subtitle: "Purification without water",
            subtitleMl: "വെള്ളമില്ലാതെ ശുദ്ധി",
            sections: [
                GuideSection(
                    heading: "When is Tayammum Allowed?",
                    headingMl: "തയമ്മും അനുവദനീയമാകുന്നത് എപ്പോൾ?",
                    steps: [
                        GuideStep(number: 1, title: "No water available", titleMl: "വെള്ളം ലഭ്യമല്ല", detail: "When water is completely unavailable in the area.", detailMl: "പ്രദേശത്ത് വെള്ളം ലഭ്യമല്ലാത്തപ്പോൾ.", arabic: nil),
                        GuideStep(number: 2, title: "Illness or injury", titleMl: "അസുഖം / പരിക്ക്", detail: "When using water would cause harm or worsen an illness.", detailMl: "വെള്ളം ഉപയോഗിക്കുന്നത് ദോഷം ചെയ്യുകയോ രോഗം മോശമാക്കുകയോ ചെയ്യുമ്പോൾ.", arabic: nil),
                        GuideStep(number: 3, title: "Extreme cold", titleMl: "കഠിനമായ തണുപ്പ്", detail: "When using cold water poses a serious health risk.", detailMl: "തണുത്ത വെള്ളം ഉപയോഗിക്കുന്നത് ആരോഗ്യ അപകടം ഉണ്ടാക്കുമ്പോൾ.", arabic: nil)
                    ]
                ),
                GuideSection(
                    heading: "How to Perform Tayammum",
                    headingMl: "തയമ്മും ചെയ്യുന്ന വിധം",
                    steps: [
                        GuideStep(number: 4, title: "Intention (Niyyah)", titleMl: "നിയ്യത്ത്", detail: "Make intention in your heart to perform Tayammum for purification.", detailMl: "ശുദ്ധിക്കായി തയമ്മും ചെയ്യാൻ മനസ്സിൽ നിയ്യത്ത് ചെയ്യുക.", arabic: "نَوَيْتُ التَّيَمُّمَ لِاسْتِبَاحَةِ الصَّلَاةِ"),
                        GuideStep(number: 5, title: "Strike clean earth", titleMl: "ഭൂമിയിൽ കൈ വയ്ക്കുക", detail: "Strike both palms lightly on clean earth, sand, dust, or stone.", detailMl: "ശുദ്ധമായ മണ്ണ്, മണൽ, പൊടി അല്ലെങ്കിൽ കല്ലിൽ രണ്ട് കൈ ഒന്നിച്ച് ഹൽകയായി അടിക്കുക.", arabic: nil),
                        GuideStep(number: 6, title: "Wipe the face", titleMl: "മുഖം തടവുക", detail: "Wipe the entire face once with both palms.", detailMl: "രണ്ട് കൈകൊണ്ടും ഒരു തവണ മുഖം മുഴുവൻ തടവുക.", arabic: nil),
                        GuideStep(number: 7, title: "Wipe the hands", titleMl: "കൈ തടവുക", detail: "Wipe the back of both hands up to and including the wrists.", detailMl: "കൈപ്പത്തി ഉൾപ്പെടെ ഇരു കൈകളും ഒരു തവണ തടവുക.", arabic: nil)
                    ]
                ),
                GuideSection(
                    heading: "What Invalidates Tayammum?",
                    headingMl: "തയമ്മും മുറിയുന്ന കാരണങ്ങൾ",
                    steps: [
                        GuideStep(number: 8, title: "Wudu-breaking acts", titleMl: "വുളൂ ഭഞ്ജകങ്ങൾ", detail: "Anything that breaks Wudu also breaks Tayammum.", detailMl: "വുളൂ മുറിക്കുന്ന ഏതൊരു കാര്യവും തയമ്മും മുറിക്കും.", arabic: nil),
                        GuideStep(number: 9, title: "Water becomes available", titleMl: "വെള്ളം ലഭ്യമാകൽ", detail: "If water becomes available before prayer, Tayammum is invalidated.", detailMl: "നമസ്കാരത്തിന് മുൻപ് വെള്ളം ലഭ്യമായാൽ തയമ്മും ബാത്വിലാകും.", arabic: nil)
                    ]
                )
            ]
        ),

        // MARK: Zakat Calculation
        EmergencyGuide(
            title: "Zakat Calculation",
            titleMl: "സകാത്ത് കണക്കുകൂട്ടൽ",
            icon: "percent",
            color: "NoorGreen",
            subtitle: "Calculate your annual charity",
            subtitleMl: "വാർഷിക ദാനം കണക്കാക്കുക",
            sections: [
                GuideSection(
                    heading: "Understanding Zakat",
                    headingMl: "സകാത്ത് മനസ്സിലാക്കൽ",
                    steps: [
                        GuideStep(number: 1, title: "What is Zakat?", titleMl: "സകാത്ത് എന്ത്?", detail: "Zakat is the 3rd Pillar of Islam — 2.5% of qualifying wealth given annually to those in need.", detailMl: "ഇസ്‌ലാമിന്റെ മൂന്നാം സ്തംഭം — ആവശ്യക്കാർക്ക് പ്രതിവർഷം നൽകേണ്ട 2.5% സ്വത്ത്.", arabic: nil),
                        GuideStep(number: 2, title: "Nisab (Minimum Threshold)", titleMl: "നിസ്വാബ്", detail: "Gold nisab: 87.48g of gold. Silver nisab: 612.36g of silver. Wealth must be held for one full lunar year.", detailMl: "സ്വർണ്ണ നിസ്വാബ്: 87.48 ഗ്രാം. വെള്ളി നിസ്വാബ്: 612.36 ഗ്രാം. ഒരു ചന്ദ്ര വർഷം മുഴുവൻ കൈവശം ഉണ്ടായിരിക്കണം.", arabic: nil)
                    ]
                ),
                GuideSection(
                    heading: "What is Zakatable?",
                    headingMl: "ഏതൊക്കെ സ്വത്തിന് സകാത്ത് ബാധകം?",
                    steps: [
                        GuideStep(number: 3, title: "Cash & Savings", titleMl: "പണം & സേവിംഗ്സ്", detail: "All cash, bank savings, and deposits held for one year above nisab.", detailMl: "നിസ്വാബിന് മുകളിൽ ഒരു വർഷം കൈവശമുള്ള പണം, ബാങ്ക് നിക്ഷേപം.", arabic: nil),
                        GuideStep(number: 4, title: "Gold & Silver", titleMl: "സ്വർണ്ണം & വെള്ളി", detail: "All gold and silver jewellery or bullion that meets or exceeds nisab.", detailMl: "നിസ്വാബ് തികഞ്ഞ സ്വർണ്ണ-വെള്ളി ആഭരണങ്ങളും കട്ടിയും.", arabic: nil),
                        GuideStep(number: 5, title: "Business Assets", titleMl: "ബിസിനസ് ആസ്തി", detail: "Stock in trade, receivables, and investment returns.", detailMl: "ട്രേഡ് സ്റ്റോക്ക്, ലഭ്യമാകേണ്ട തുക, നിക്ഷേപ ലാഭം.", arabic: nil),
                        GuideStep(number: 6, title: "Rental Income", titleMl: "വാടക വരുമാനം", detail: "Net rental income after expenses that remains for one year.", detailMl: "ചെലവ് കഴിഞ്ഞ് ഒരു വർഷം കൈവശം നിൽക്കുന്ന വാടക വരുമാനം.", arabic: nil)
                    ]
                ),
                GuideSection(
                    heading: "Calculation Steps",
                    headingMl: "കണക്കുകൂട്ടൽ ഘട്ടങ്ങൾ",
                    steps: [
                        GuideStep(number: 7, title: "Step 1 — Add all assets", titleMl: "ഘട്ടം 1 — ആസ്തി ചേർക്കുക", detail: "Total = Cash + Gold value + Silver value + Business stock + Investments.", detailMl: "ആകെ = പണം + സ്വർണ്ണ മൂല്യം + വെള്ളി മൂല്യം + ബിസിനസ് സ്റ്റോക്ക് + നിക്ഷേപം.", arabic: nil),
                        GuideStep(number: 8, title: "Step 2 — Subtract liabilities", titleMl: "ഘട്ടം 2 — ബാധ്യത കുറക്കുക", detail: "Deduct debts due within the year and essential expenses.", detailMl: "ഈ വർഷം കൊടുക്കേണ്ട കടങ്ങളും അനിവാര്യ ചെലവുകളും കുറക്കുക.", arabic: nil),
                        GuideStep(number: 9, title: "Step 3 — Check Nisab", titleMl: "ഘട്ടം 3 — നിസ്വാബ് പരിശോധിക്കുക", detail: "If net wealth ≥ nisab value held for 1 lunar year, Zakat is due.", detailMl: "അറ്റ സ്വത്ത് ≥ നിസ്വാബ് ആണെങ്കിൽ ഒരു ചന്ദ്ര വർഷം കൈവശം ഉണ്ടെങ്കിൽ സകാത്ത് നിർബന്ധം.", arabic: nil),
                        GuideStep(number: 10, title: "Step 4 — Pay 2.5%", titleMl: "ഘട്ടം 4 — 2.5% നൽകുക", detail: "Zakat = Net Zakatable Wealth × 2.5%. Pay to eligible recipients (Quran 9:60).", detailMl: "സകാത്ത് = അറ്റ സകാത്ത് യോഗ്യ സ്വത്ത് × 2.5%. അർഹർക്ക് നൽകുക (ഖുർആൻ 9:60).", arabic: "وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ")
                    ]
                )
            ]
        ),

        // MARK: Common Duas
        EmergencyGuide(
            title: "Essential Duas",
            titleMl: "അത്യാവശ്യ ദുആകൾ",
            icon: "hands.and.sparkles.fill",
            color: "NoorBlue",
            subtitle: "Duas for daily occasions",
            subtitleMl: "ദൈനദിന ദുആകൾ",
            sections: [
                GuideSection(
                    heading: "Morning & Evening",
                    headingMl: "പ്രഭാതവും സന്ധ്യയും",
                    steps: [
                        GuideStep(number: 1, title: "Waking up", titleMl: "ഉണർന്നെഴുന്നേൽക്കുമ്പോൾ", detail: "Recite upon waking to thank Allah for restoring life.", detailMl: "ഉണർന്നെഴുന്നേൽക്കുമ്പോൾ അല്ലാഹുവിന് നന്ദി പറഞ്ഞ് ഓതുക.", arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ"),
                        GuideStep(number: 2, title: "Before sleeping", titleMl: "ഉറങ്ങുന്നതിന് മുൻപ്", detail: "Say three times before sleeping for protection.", detailMl: "ഉറക്കത്തിന് മുൻപ് മൂന്ന് തവണ ചൊല്ലുക.", arabic: "بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا"),
                        GuideStep(number: 3, title: "Leaving home", titleMl: "വീട്ടിൽ നിന്ന് ഇറങ്ങുമ്പോൾ", detail: "Recite to seek Allah's protection when leaving the house.", detailMl: "വീട്ടിൽ നിന്ന് ഇറങ്ങുമ്പോൾ അല്ലാഹുവിന്റെ സംരക്ഷണം തേടി ഓതുക.", arabic: "بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ")
                    ]
                ),
                GuideSection(
                    heading: "Food & Travel",
                    headingMl: "ഭക്ഷണവും യാത്രയും",
                    steps: [
                        GuideStep(number: 4, title: "Before eating", titleMl: "ഭക്ഷണത്തിന് മുൻപ്", detail: "Say Bismillah before starting any meal.", detailMl: "ഏത് ഭക്ഷണത്തിനും ആദ്യം ബിസ്മി ചൊല്ലുക.", arabic: "بِسْمِ اللَّهِ"),
                        GuideStep(number: 5, title: "After eating", titleMl: "ഭക്ഷണശേഷം", detail: "Praise Allah after finishing your meal.", detailMl: "ഭക്ഷണം കഴിഞ്ഞ ശേഷം അല്ലാഹുവിനെ സ്തുതിക്കുക.", arabic: "الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ"),
                        GuideStep(number: 6, title: "Before travel", titleMl: "യാത്ര തുടങ്ങുമ്പോൾ", detail: "Recite when boarding any vehicle for a safe journey.", detailMl: "ഏത് വാഹനത്തിൽ കയറുമ്പോഴും സുരക്ഷിതമായ യാത്രക്കായി ഓതുക.", arabic: "سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ")
                    ]
                ),
                GuideSection(
                    heading: "Seeking Forgiveness",
                    headingMl: "പൊറുക്കലിനായി",
                    steps: [
                        GuideStep(number: 7, title: "Sayyidul Istighfar", titleMl: "സയ്യിദുൽ ഇസ്തിഗ്ഫാർ", detail: "The master supplication for seeking forgiveness — recite morning and evening.", detailMl: "പൊറുക്കൽ തേടലിന്റെ ശ്രേഷ്ഠ ദുആ — രാവിലെയും സന്ധ്യക്കും ഓതുക.", arabic: "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ"),
                        GuideStep(number: 8, title: "Simple Istighfar", titleMl: "ലളിതമായ ഇസ്തിഗ്ഫാർ", detail: "Repeat 100 times daily for continuous forgiveness.", detailMl: "ദിവസം 100 തവണ ആവർത്തിക്കുക.", arabic: "أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ")
                    ]
                )
            ]
        ),

        // MARK: Islamic Inheritance
        EmergencyGuide(
            title: "Islamic Inheritance (Mirath)",
            titleMl: "ഇസ്‌ലാമിക അനന്തരാവകാശം",
            icon: "person.3.fill",
            color: "NoorPurple",
            subtitle: "Shariah inheritance shares",
            subtitleMl: "ശരീഅത്ത് അനുസരിച്ചുള്ള ഓഹരി",
            sections: [
                GuideSection(
                    heading: "Order of Distribution",
                    headingMl: "വിതരണ ക്രമം",
                    steps: [
                        GuideStep(number: 1, title: "Funeral expenses", titleMl: "ജനാസ ചെലവ്", detail: "First, pay all reasonable funeral and burial expenses from the estate.", detailMl: "ആദ്യം സ്വത്തിൽ നിന്ന് ന്യായമായ ജനാസ, ഖബർ ചെലവ് നൽകുക.", arabic: nil),
                        GuideStep(number: 2, title: "Debts", titleMl: "കടം", detail: "Pay all outstanding debts owed by the deceased in full.", detailMl: "മരണപ്പെട്ടയാളുടെ സർവ കടങ്ങളും പൂർണ്ണമായി അടക്കുക.", arabic: nil),
                        GuideStep(number: 3, title: "Bequests (Wasiyyah)", titleMl: "വസ്വിയ്യത്ത്", detail: "Execute up to 1/3 of the remaining estate per the deceased's valid will.", detailMl: "ശേഷിക്കുന്ന സ്വത്തിന്റെ 1/3 വരെ വസ്വിയ്യത്ത് നടപ്പാക്കുക.", arabic: nil),
                        GuideStep(number: 4, title: "Distribute to heirs", titleMl: "അനന്തരാവകാശികൾക്ക്", detail: "Remaining estate is distributed per Quran & Sunnah shares.", detailMl: "ബാക്കി ഖുർആൻ-സുന്നത്ത് അനുസരിച്ച് അനന്തരാവകാശികൾക്ക് നൽകുക.", arabic: nil)
                    ]
                ),
                GuideSection(
                    heading: "Fixed Shares (Fardh)",
                    headingMl: "നിശ്ചിത ഓഹരികൾ",
                    steps: [
                        GuideStep(number: 5, title: "Spouse", titleMl: "ഭാര്യ/ഭർത്താവ്", detail: "Husband: 1/4 (if children), 1/2 (if no children). Wife: 1/8 (if children), 1/4 (if no children).", detailMl: "ഭർത്താവ്: 1/4 (മക്കളുള്ളപ്പോൾ), 1/2 (ഇല്ലാത്തപ്പോൾ). ഭാര്യ: 1/8 (മക്കളുള്ളപ്പോൾ), 1/4 (ഇല്ലാത്തപ്പോൾ).", arabic: nil),
                        GuideStep(number: 6, title: "Daughter only", titleMl: "മകൾ മാത്രം", detail: "One daughter: 1/2. Two or more daughters: 2/3 shared equally.", detailMl: "ഒരു മകൾ: 1/2. രണ്ടോ അതിലേറെ: 2/3 തുല്യമായി.", arabic: nil),
                        GuideStep(number: 7, title: "Son & daughter", titleMl: "മകനും മകളും", detail: "Son receives double the share of a daughter (Asaba).", detailMl: "മകൾക്ക് ലഭിക്കുന്നതിന്റെ ഇരട്ടി മകന് ലഭിക്കും (അസ്വബ).", arabic: "لِلذَّكَرِ مِثْلُ حَظِّ الْأُنثَيَيْنِ"),
                        GuideStep(number: 8, title: "Parents", titleMl: "മാതാ-പിതാക്കൾ", detail: "Each parent gets 1/6 if the deceased has children. If no children, mother gets 1/3, father takes the rest.", detailMl: "മക്കളുള്ളപ്പോൾ ഓരോ മാതാ-പിതാവിനും 1/6. മക്കളില്ലെങ്കിൽ ഉമ്മ 1/3, ഉപ്പ ബാക്കി.", arabic: nil)
                    ]
                )
            ]
        )
    ]
}

