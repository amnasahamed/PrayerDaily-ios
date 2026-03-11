import Foundation
import StoreKit

// MARK: - Daily Verse Service
/// Picks a verse that changes each calendar day (deterministic rotation from a curated pool)
class DailyVerseService {

    static let shared = DailyVerseService()

    struct DailyVerse {
        let arabic: String
        let translation: String
        let reference: String
        let tafsir: String
    }

    // Curated pool of 30 production-quality verses
    private let pool: [DailyVerse] = [
        DailyVerse(
            arabic: "إِنَّ مَعَ الْعُسْرِ يُسْرًا",
            translation: "Indeed, with hardship comes ease.",
            reference: "Quran 94:6",
            tafsir: "After every difficulty, Allah promises relief. The indefinite form of 'ease' suggests multiple blessings accompany each single hardship."
        ),
        DailyVerse(
            arabic: "وَنَحْنُ أَقْرَبُ إِلَيْهِ مِنْ حَبْلِ الْوَرِيدِ",
            translation: "And We are closer to him than his jugular vein.",
            reference: "Quran 50:16",
            tafsir: "Allah's knowledge and awareness of every person is more intimate than any physical proximity. Nothing is hidden from Him."
        ),
        DailyVerse(
            arabic: "فَاذْكُرُونِي أَذْكُرْكُمْ",
            translation: "So remember Me; I will remember you.",
            reference: "Quran 2:152",
            tafsir: "A direct divine promise — when a servant remembers Allah, Allah responds with His remembrance, enveloping the servant in mercy and blessings."
        ),
        DailyVerse(
            arabic: "حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ",
            translation: "Allah is sufficient for us, and He is the best Disposer of affairs.",
            reference: "Quran 3:173",
            tafsir: "This was the proclamation of the Companions when faced with overwhelming odds. Complete reliance on Allah is itself a form of worship."
        ),
        DailyVerse(
            arabic: "إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
            translation: "Indeed, Allah is with the patient.",
            reference: "Quran 2:153",
            tafsir: "Divine companionship is promised to those who exercise patience — in hardship, in worship, and in refraining from sin."
        ),
        DailyVerse(
            arabic: "وَتَوَكَّلْ عَلَى اللَّهِ ۚ وَكَفَىٰ بِاللَّهِ وَكِيلًا",
            translation: "And rely upon Allah; and sufficient is Allah as Disposer of affairs.",
            reference: "Quran 33:3",
            tafsir: "True tawakkul means taking all necessary steps, then entrusting outcomes entirely to Allah — the best of guardians."
        ),
        DailyVerse(
            arabic: "وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ",
            translation: "Do not despair of relief from Allah.",
            reference: "Quran 12:87",
            tafsir: "Despair of Allah's mercy is a major sin. No matter how severe the trial, Allah's relief can arrive in an instant."
        ),
        DailyVerse(
            arabic: "وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ",
            translation: "And He is with you wherever you are.",
            reference: "Quran 57:4",
            tafsir: "Allah's knowledge and care encompass every place and moment. The believer is never truly alone."
        ),
        DailyVerse(
            arabic: "إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ",
            translation: "Indeed, Allah will not change the condition of a people until they change what is in themselves.",
            reference: "Quran 13:11",
            tafsir: "Internal transformation precedes external change. Allah's law ties worldly conditions to the sincerity and effort of the people."
        ),
        DailyVerse(
            arabic: "وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ",
            translation: "And seek help through patience and prayer.",
            reference: "Quran 2:45",
            tafsir: "Prayer and patience are the twin anchors of the believer's life — one connects to Allah, the other sustains through trials."
        ),
        DailyVerse(
            arabic: "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً",
            translation: "Our Lord, grant us good in this world and good in the Hereafter.",
            reference: "Quran 2:201",
            tafsir: "The most comprehensive dua in the Quran, encompassing all worldly and eternal goodness in one supplication."
        ),
        DailyVerse(
            arabic: "وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ",
            translation: "And my success is not but through Allah.",
            reference: "Quran 11:88",
            tafsir: "The words of Prophet Shu'ayb — a reminder that all achievement, guidance, and ability to do good come solely from Allah."
        ),
        DailyVerse(
            arabic: "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا",
            translation: "For indeed, with hardship comes ease.",
            reference: "Quran 94:5",
            tafsir: "Scholars note this verse is paired with verse 6 — repetition of the promise doubles its certainty. One hardship; two easements."
        ),
        DailyVerse(
            arabic: "وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ",
            translation: "And when My servants ask you about Me — indeed I am near.",
            reference: "Quran 2:186",
            tafsir: "Among the most intimate verses in the Quran — Allah directly reassures His servants of His closeness whenever they call upon Him."
        ),
        DailyVerse(
            arabic: "أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ",
            translation: "Verily, in the remembrance of Allah do hearts find rest.",
            reference: "Quran 13:28",
            tafsir: "True tranquility is not found in wealth, status, or comfort — only in the remembrance of the Creator of the heart itself."
        ),
        DailyVerse(
            arabic: "يُرِيدُ اللَّهُ بِكُمُ الْيُسْرَ وَلَا يُرِيدُ بِكُمُ الْعُسْرَ",
            translation: "Allah intends for you ease and does not intend for you hardship.",
            reference: "Quran 2:185",
            tafsir: "Islam is a religion of ease. Where difficulty arises, Allah has provided concessions — reflecting His ultimate mercy for humanity."
        ),
        DailyVerse(
            arabic: "وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا",
            translation: "And whoever fears Allah — He will make for him a way out.",
            reference: "Quran 65:2",
            tafsir: "Taqwa — God-consciousness — is the master key. Allah guarantees a solution to every predicament for those who maintain it."
        ),
        DailyVerse(
            arabic: "وَهُوَ الْغَفُورُ الرَّحِيمُ",
            translation: "And He is the Forgiving, the Merciful.",
            reference: "Quran 2:173",
            tafsir: "Two of Allah's most beloved names — Al-Ghafur (the One who covers sins) and Al-Raheem (the continually merciful) — appear together frequently."
        ),
        DailyVerse(
            arabic: "رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي",
            translation: "My Lord, expand for me my breast, and ease for me my task.",
            reference: "Quran 20:25–26",
            tafsir: "The opening supplication of Prophet Musa before his mission. A perfect dua before any difficult undertaking."
        ),
        DailyVerse(
            arabic: "وَلَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا",
            translation: "Do not despair of the mercy of Allah. Indeed, Allah forgives all sins.",
            reference: "Quran 39:53",
            tafsir: "A verse of immense hope — no sin is too great for Allah's forgiveness if one sincerely repents and returns to Him."
        ),
        DailyVerse(
            arabic: "إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ",
            translation: "Indeed we belong to Allah, and indeed to Him we will return.",
            reference: "Quran 2:156",
            tafsir: "Inna lillahi — a declaration said at times of loss or trial. It reorients the believer: we are Allah's trust, and our return to Him is certain."
        ),
        DailyVerse(
            arabic: "سَنُرِيهِمْ آيَاتِنَا فِي الْآفَاقِ وَفِي أَنفُسِهِمْ",
            translation: "We will show them Our signs in the universe and within themselves.",
            reference: "Quran 41:53",
            tafsir: "Allah's signs exist in the cosmos and in human physiology. Reflection on either leads to recognition of the Creator."
        ),
        DailyVerse(
            arabic: "قُلْ هُوَ اللَّهُ أَحَدٌ",
            translation: "Say: He is Allah, the One.",
            reference: "Quran 112:1",
            tafsir: "The opening of Surah Al-Ikhlas — a declaration of pure monotheism that the Prophet ﷺ described as equal to a third of the Quran."
        ),
        DailyVerse(
            arabic: "وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ",
            translation: "And Allah loves the doers of good.",
            reference: "Quran 3:134",
            tafsir: "Ihsan — excellence in worship and dealings — is the highest station of a Muslim and one that earns the love of Allah Himself."
        ),
        DailyVerse(
            arabic: "رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا",
            translation: "Our Lord, do not impose blame upon us if we forget or make error.",
            reference: "Quran 2:286",
            tafsir: "Allah responded to this dua saying 'I have done so' — confirming that sincere mistakes and forgetfulness are pardoned for the believer."
        ),
        DailyVerse(
            arabic: "وَقِيلَ لِلَّذِينَ اتَّقَوُا مَاذَا أَنزَلَ رَبُّكُمْ ۚ قَالُوا خَيْرًا",
            translation: "And it is said to those who feared Allah, 'What did your Lord send down?' They say, 'Good.'",
            reference: "Quran 16:30",
            tafsir: "The people of taqwa see the Quran as purely good — their perception refined by faith, unlike those blinded by arrogance."
        ),
        DailyVerse(
            arabic: "وَمَا خَلَقْتُ الْجِنَّ وَالْإِنسَ إِلَّا لِيَعْبُدُونِ",
            translation: "And I did not create the jinn and mankind except to worship Me.",
            reference: "Quran 51:56",
            tafsir: "The clearest statement of human purpose in the Quran — a constant anchor when life feels directionless."
        ),
        DailyVerse(
            arabic: "وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ",
            translation: "And it may be that you dislike a thing while it is good for you.",
            reference: "Quran 2:216",
            tafsir: "Allah's wisdom exceeds human perception. What we resist may carry the greatest blessing; what we desire may hold hidden harm."
        ),
        DailyVerse(
            arabic: "إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ",
            translation: "Indeed, Allah loves those who repent and loves those who purify themselves.",
            reference: "Quran 2:222",
            tafsir: "Repentance is not a sign of weakness but of spiritual vitality. Allah does not merely accept tawbah — He loves those who return to Him."
        ),
        DailyVerse(
            arabic: "مَن جَاءَ بِالْحَسَنَةِ فَلَهُ خَيْرٌ مِّنْهَا",
            translation: "Whoever comes with a good deed will have better than it.",
            reference: "Quran 27:89",
            tafsir: "Every good action is multiplied — rewarded by something even greater. Allah's generosity far exceeds what our deeds merit."
        ),
    ]

    var todaysVerse: DailyVerse {
        var utcCal = Calendar(identifier: .gregorian)
        utcCal.timeZone = TimeZone(identifier: "UTC") ?? .current
        let dayOfYear = utcCal.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return pool[(dayOfYear - 1) % pool.count]
    }
}

// MARK: - App Review Request
struct AppReviewManager {
    private static let sessionCountKey = "app_session_count"
    private static let lastReviewVersionKey = "last_review_version"
    private static let reviewThreshold = 5

    static func incrementSession() {
        let count = UserDefaults.standard.integer(forKey: sessionCountKey) + 1
        UserDefaults.standard.set(count, forKey: sessionCountKey)
    }

    static func requestReviewIfAppropriate() {
        let count = UserDefaults.standard.integer(forKey: sessionCountKey)
        let lastVersion = UserDefaults.standard.string(forKey: lastReviewVersionKey) ?? ""
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

        guard count >= reviewThreshold, lastVersion != currentVersion else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
                UserDefaults.standard.set(currentVersion, forKey: lastReviewVersionKey)
            }
        }
    }
}
