import SwiftUI
import UserNotifications

// MARK: - Onboarding Page Model
private struct OnboardingPage {
    let icon: String
    let iconColors: [Color]
    let title: String
    let subtitle: String
    let accentColor: Color
    var isNotifications: Bool = false
    var isProfile: Bool = false
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var appeared = false
    @State private var name: String = ""
    @State private var madhab: String = "Hanafi"
    @State private var notifGranted: Bool? = nil        // nil = not asked yet
    @State private var notifLoading = false
    @AppStorage("profileName")   private var profileName: String = "Muslim"
    @AppStorage("profileMadhab") private var profileMadhab: String = "Hanafi"
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "moon.stars.fill",
            iconColors: [Color.alehaGreen, Color.alehaDarkGreen],
            title: "Welcome to Muslim Pro",
            subtitle: "Your companion for prayer, Quran, and daily remembrance — beautiful and always with you.",
            accentColor: .alehaGreen
        ),
        OnboardingPage(
            icon: "clock.badge.checkmark.fill",
            iconColors: [Color.alehaAmber, Color(red: 0.80, green: 0.45, blue: 0.05)],
            title: "Track Every Prayer",
            subtitle: "Log Fajr to Isha, build streaks, manage Qada, and see your weekly consistency at a glance.",
            accentColor: .alehaAmber
        ),
        OnboardingPage(
            icon: "book.fill",
            iconColors: [Color(red: 0.20, green: 0.50, blue: 0.88), Color(red: 0.08, green: 0.22, blue: 0.60)],
            title: "Read the Quran",
            subtitle: "Full Arabic text with translation, transliteration, and verse-by-verse Tafsir.",
            accentColor: Color(red: 0.20, green: 0.50, blue: 0.88)
        ),
        OnboardingPage(
            icon: "bell.badge.fill",
            iconColors: [Color(red: 0.55, green: 0.20, blue: 0.88), Color(red: 0.30, green: 0.05, blue: 0.60)],
            title: "Never Miss a Prayer",
            subtitle: "Get gentle reminders at each prayer time and a daily verse every morning.",
            accentColor: Color(red: 0.55, green: 0.20, blue: 0.88),
            isNotifications: true
        ),
        OnboardingPage(
            icon: "person.crop.circle.fill",
            iconColors: [Color.alehaGreen, Color.alehaDarkGreen],
            title: "Personalise for You",
            subtitle: "Set your name and madhab so prayer times and Asr calculations are tailored to your practice.",
            accentColor: .alehaGreen,
            isProfile: true
        ),
    ]

    var body: some View {
        ZStack {
            CalmingBackground().ignoresSafeArea()
            VStack(spacing: 0) {
                pageContent
                bottomControls
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.78).delay(0.1)) { appeared = true }
        }
    }

    // MARK: - Page Content
    private var pageContent: some View {
        TabView(selection: $currentPage) {
            ForEach(Array(pages.enumerated()), id: \.offset) { idx, page in
                pageSlide(page: page)
                    .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: currentPage)
    }

    @ViewBuilder
    private func pageSlide(page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()
            iconBubble(page: page)
            textBlock(page: page)
            if page.isNotifications { notificationsPanel(page: page) }
            if page.isProfile       { profileForm(page: page) }
            Spacer()
        }
        .padding(.horizontal, 28)
    }

    // MARK: - Icon Bubble
    private func iconBubble(page: OnboardingPage) -> some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: page.iconColors.map { $0.opacity(0.18) },
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 130, height: 130)
            Circle()
                .fill(LinearGradient(colors: page.iconColors,
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 96, height: 96)
                .shadow(color: page.iconColors.first?.opacity(0.4) ?? .clear, radius: 20, y: 8)
            Image(systemName: page.icon)
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.white)
        }
        .scaleEffect(appeared ? 1 : 0.7)
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - Text Block
    private func textBlock(page: OnboardingPage) -> some View {
        VStack(spacing: 12) {
            Text(page.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Notifications Panel
    @ViewBuilder
    private func notificationsPanel(page: OnboardingPage) -> some View {
        VStack(spacing: 14) {
            // Feature bullets
            ForEach(notifFeatures, id: \.icon) { feature in
                HStack(spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(page.accentColor)
                        .frame(width: 36, height: 36)
                        .background(page.accentColor.opacity(0.12))
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.subheadline.weight(.semibold))
                        Text(feature.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            // Status badge (shown after permission resolves)
            if let granted = notifGranted {
                HStack(spacing: 8) {
                    Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(granted ? .green : .secondary)
                    Text(granted
                         ? "Reminders are on — you're all set!"
                         : "No worries, you can enable this in Settings later.")
                        .font(.caption)
                        .foregroundStyle(granted ? .green : .secondary)
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }

    private var notifFeatures: [(icon: String, title: String, subtitle: String)] {[
        (icon: "bell.fill",          title: "Prayer Reminders",  subtitle: "Fajr · Dhuhr · Asr · Maghrib · Isha"),
        (icon: "book.closed.fill",   title: "Daily Verse",       subtitle: "A verse from the Quran every morning at 8 AM"),
        (icon: "moon.zzz.fill",      title: "Peaceful & Minimal", subtitle: "No marketing, no noise — only what matters"),
    ]}

    // MARK: - Profile Form
    @ViewBuilder
    private func profileForm(page: OnboardingPage) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.body).foregroundStyle(page.accentColor)
                TextField("Your name (optional)", text: $name)
                    .font(.body)
                    .submitLabel(.done)
            }
            .padding(14)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            HStack(spacing: 12) {
                Image(systemName: "book.fill")
                    .font(.body).foregroundStyle(Color.alehaAmber)
                Text("Madhab")
                    .font(.body).foregroundStyle(.secondary)
                Spacer()
                Picker("Madhab", selection: $madhab) {
                    ForEach(["Hanafi", "Maliki", "Shafi'i", "Hanbali"], id: \.self) { Text($0) }
                }
                .pickerStyle(.menu)
                .tint(page.accentColor)
            }
            .padding(14)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 20) {
            pageIndicator
            primaryButton
            if currentPage == 0 {
                Button("Skip") {
                    withAnimation { hasCompletedOnboarding = true }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            // "Maybe later" on notifications page (before tapping Enable)
            if pages[currentPage].isNotifications && notifGranted == nil && !notifLoading {
                Button("Maybe later") {
                    withAnimation { currentPage += 1 }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 48)
    }

    private var pageIndicator: some View {
        HStack(spacing: 7) {
            ForEach(0..<pages.count, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? Color.alehaGreen : Color(.systemGray4))
                    .frame(width: i == currentPage ? 22 : 7, height: 7)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    // Unified primary button — adapts per page
    @ViewBuilder
    private var primaryButton: some View {
        let page = pages[currentPage]

        if page.isNotifications {
            notificationsButton(page: page)
        } else if page.isProfile {
            getStartedButton
        } else {
            nextButton
        }
    }

    // MARK: - Next Button
    private var nextButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation { currentPage += 1 }
        } label: {
            Text("Continue")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Color.alehaGreen)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(SpringPressStyle())
    }

    // MARK: - Notifications Button
    @ViewBuilder
    private func notificationsButton(page: OnboardingPage) -> some View {
        if let granted = notifGranted {
            // Already resolved — show Continue
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                withAnimation { currentPage += 1 }
            } label: {
                Label(granted ? "Continue" : "Continue Anyway",
                      systemImage: granted ? "arrow.right.circle.fill" : "arrow.right.circle")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(granted ? page.accentColor : Color(.systemGray3))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(SpringPressStyle())
        } else {
            // Not yet asked
            Button {
                requestNotifications(accentColor: page.accentColor)
            } label: {
                Group {
                    if notifLoading {
                        ProgressView().tint(.white)
                    } else {
                        Label("Enable Reminders", systemImage: "bell.badge.fill")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(colors: page.iconColors,
                                   startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: page.iconColors.first?.opacity(0.35) ?? .clear, radius: 12, y: 5)
            }
            .buttonStyle(SpringPressStyle())
            .disabled(notifLoading)
        }
    }

    // MARK: - Get Started Button
    private var getStartedButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            let trimmed = name.trimmingCharacters(in: .whitespaces)
            if !trimmed.isEmpty { profileName = trimmed }
            profileMadhab = madhab
            PrayerTimesService.shared.applyMadhab(madhab)
            withAnimation { hasCompletedOnboarding = true }
        } label: {
            Label("Get Started", systemImage: "arrow.right.circle.fill")
                .font(.body.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(colors: [Color.alehaGreen, Color.alehaDarkGreen],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.alehaGreen.opacity(0.35), radius: 12, y: 5)
        }
        .buttonStyle(SpringPressStyle())
    }

    // MARK: - Request Permission
    private func requestNotifications(accentColor: Color) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        notifLoading = true
        NotificationService.shared.requestPermission { granted in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                notifLoading = false
                notifGranted = granted
                notificationsEnabled = granted
            }
            if granted {
                NotificationService.shared.scheduleDailyPrayerReminders()
                NotificationService.shared.scheduleDailyVerseNotification()
            }
            UINotificationFeedbackGenerator().notificationOccurred(granted ? .success : .warning)
        }
    }
}
