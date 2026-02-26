import Foundation

// MARK: - Guide Models
struct EmergencyGuide: Identifiable {
    let id = UUID()
    let title: String
    let titleMl: String
    let icon: String
    let color: String
    let subtitle: String
    let subtitleMl: String
    let sections: [GuideSection]

    func localizedTitle(isMalayalam: Bool) -> String { isMalayalam ? titleMl : title }
    func localizedSubtitle(isMalayalam: Bool) -> String { isMalayalam ? subtitleMl : subtitle }
}

struct GuideSection: Identifiable {
    let id = UUID()
    let heading: String
    let headingMl: String
    let steps: [GuideStep]

    func localizedHeading(isMalayalam: Bool) -> String { isMalayalam ? headingMl : heading }
}

struct GuideStep: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let titleMl: String
    let detail: String
    let detailMl: String
    let arabic: String?

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
        )
    ]
}

