import SwiftUI

struct PrivacyPolicyView: View {
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.openURL) var openURL

    var body: some View {
        ZStack {
            CalmingBackground().ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    dataCollectionSection
                    thirdPartySection
                    dataStorageSection
                    childPrivacySection
                    changesSection
                    contactSection
                }
                .padding(AppTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle(localization.t(.morePrivacyPolicy))
        .navigationBarTitleDisplayMode(.inline)
        .modifier(AlehaNavStyle())
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Privacy Policy")
                .font(.title.weight(.bold))
            Text("Last updated: March 24, 2026")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .noorCard()
    }

    // MARK: - Data Collection
    private var dataCollectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("1. Information We Collect")

            infoRow(icon: "location.fill", color: .alehaGreen,
                    title: "Location Data",
                    body: "PrayerDaily uses your device's location (only while the app is in use) to calculate accurate prayer times for your area. Your location is processed locally and is never stored on our servers.")

            infoRow(icon: "iphone", color: .alehaGreen,
                    title: "Local Storage",
                    body: "The app stores the following data on your device using UserDefaults:\n• Prayer log records (dates and prayer completion status)\n• App preferences (appearance mode, language, font size)\n• Prayer calculation settings\n• Notification preferences")

            infoRow(icon: "bell.fill", color: .alehaGreen,
                    title: "Notification Data",
                    body: "If you enable prayer time reminders, notification permissions are requested. No personal data is sent to any server for this purpose.")
        }
    }

    // MARK: - Third-Party Services
    private var thirdPartySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("2. Third-Party Services")

            infoRow(icon: "book.closed.fill", color: .alehaAmber,
                    title: "Al-Quran Cloud API",
                    body: "The app fetches Quran verses (Arabic text and English translation) and tafsir from Al-Quran Cloud API. When you open a Surah, your device connects to this service. Only the Surah number is transmitted — no personal data is sent.")

            infoRow(icon: "clock.fill", color: .alehaAmber,
                    title: "Al-Adhan API",
                    body: "Your approximate location (latitude/longitude) is sent to the Al-Adhan API to calculate daily prayer times for your area.")
        }
    }

    // MARK: - Data Storage
    private var dataStorageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("3. Data Storage")
            infoRow(icon: "internaldrive.fill", color: .alehaDarkGreen,
                    title: "Local Storage Only",
                    body: "All data is stored locally on your device. We do not operate any cloud backend or external database for user data.")
        }
    }

    // MARK: - Children's Privacy
    private var childPrivacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("4. Children's Privacy")
            infoRow(icon: "person.2.fill", color: .alehaDarkGreen,
                    title: "Not for Children",
                    body: "PrayerDaily is not intended for children under the age of 13, and we do not knowingly collect personal information from children.")
        }
    }

    // MARK: - Changes
    private var changesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("5. Changes to This Policy")
            infoRow(icon: "arrow.triangle.2.circlepath", color: .alehaDarkGreen,
                    title: "Policy Updates",
                    body: "We may update this privacy policy from time to time. Any changes will be reflected on this page with an updated revision date.")
        }
    }

    // MARK: - Contact
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("6. Contact Us")
            Button {
                if let url = URL(string: "https://www.alehalearn.com/prayerdaily/privacy") {
                    openURL(url)
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.alehaGreen.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: "link")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.alehaGreen)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("View Full Policy")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.alehaGreen)
                        Text("https://www.alehalearn.com/prayerdaily/privacy")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundStyle(Color.alehaGreen)
                }
                .noorCard()
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline.weight(.bold))
            .foregroundStyle(Color.alehaGreen)
    }

    private func infoRow(icon: String, color: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .noorCard()
    }
}
