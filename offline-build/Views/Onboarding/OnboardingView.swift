import SwiftUI

// MARK: - Onboarding Page Model
private struct OnboardingPage {
    let icon: String
    let iconColors: [Color]
    let title: String
    let subtitle: String
    let accentColor: Color
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var appeared = false
    @State private var name: String = ""
    @State private var madhab: String = "Hanafi"
    @State private var isNameFocused = false
    @AppStorage("profileName") private var profileName: String = "Muslim"
    @AppStorage("profileMadhab") private var profileMadhab: String = "Hanafi"

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "moon.stars.fill",
            iconColors: [Color.alehaGreen, Color.alehaDarkGreen],
            title: "Welcome to Aleha",
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
            subtitle: "Full Arabic text with translation, transliteration, audio recitation, and verse-by-verse Tafsir.",
            accentColor: Color(red: 0.20, green: 0.50, blue: 0.88)
        ),
        OnboardingPage(
            icon: "person.crop.circle.fill",
            iconColors: [Color.alehaGreen, Color.alehaDarkGreen],
            title: "Personalise for You",
            subtitle: "Set your name and madhab so prayer times and Asr calculations are tailored to your practice.",
            accentColor: .alehaGreen
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
                pageSlide(page: page, isProfile: idx == pages.count - 1)
                    .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.spring(response: 0.45, dampingFraction: 0.82), value: currentPage)
    }

    @ViewBuilder
    private func pageSlide(page: OnboardingPage, isProfile: Bool) -> some View {
        VStack(spacing: 32) {
            Spacer()
            iconBubble(page: page)
            textBlock(page: page)
            if isProfile { profileForm(page: page) }
            Spacer()
        }
        .padding(.horizontal, 28)
    }

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

    @ViewBuilder
    private func profileForm(page: OnboardingPage) -> some View {
        VStack(spacing: 14) {
            // Name field
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

            // Madhab picker
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
            if currentPage < pages.count - 1 {
                nextButton
            } else {
                getStartedButton
            }
            if currentPage == 0 {
                Button("Skip") {
                    withAnimation { hasCompletedOnboarding = true }
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

    private var getStartedButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                profileName = name
            }
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
}
