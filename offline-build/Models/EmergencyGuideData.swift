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


