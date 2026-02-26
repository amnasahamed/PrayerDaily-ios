import SwiftUI

struct LanguagePickerSheet: View {
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                CalmingBackground().ignoresSafeArea()
                VStack(spacing: 28) {
                    languageIcon
                    headerText
                    languageCards
                    Spacer()
                    footerNote
                }
                .padding(AppTheme.screenPadding)
                .padding(.top, 8)
            }
            .navigationTitle(localization.t(.moreLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localization.t(.commonDone)) { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.alehaGreen)
                }
            }
        }
    }

    private var languageIcon: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: [Color.alehaGreen.opacity(0.15), Color.alehaAmber.opacity(0.10)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 80, height: 80)
            Text("🌐")
                .font(.system(size: 38))
        }
    }

    private var headerText: some View {
        VStack(spacing: 6) {
            Text(localization.t(.moreLanguage))
                .font(.title2.weight(.bold))
            Text("English · മലയാളം")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var languageCards: some View {
        VStack(spacing: 12) {
            ForEach(AppLanguage.allCases, id: \.rawValue) { lang in
                LanguageCard(language: lang, isSelected: localization.currentLanguage == lang) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        localization.currentLanguage = lang
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                }
            }
        }
    }

    private var footerNote: some View {
        Text(localization.currentLanguage == .malayalam
             ? "ഖുർആൻ പരിഭാഷ സ്ഥിരസ്ഥിതിയിൽ ഇംഗ്ലീഷിൽ തന്നെ."
             : "Quran translation remains in English.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.bottom, 20)
    }
}

// MARK: - Language Card
private struct LanguageCard: View {
    let language: AppLanguage
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Flag circle
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.alehaGreen.opacity(0.12) : Color(.systemGray6))
                        .frame(width: 50, height: 50)
                    Text(language.flag)
                        .font(.system(size: 26))
                }

                // Language info
                VStack(alignment: .leading, spacing: 3) {
                    Text(language.displayName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(language == .english ? "English" : "Malayalam")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Checkmark
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.alehaGreen : Color(.systemGray5))
                        .frame(width: 26, height: 26)
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .opacity(isSelected ? 1 : 0)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.alehaGreen.opacity(0.6) : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(SpringPressStyle())
    }
}
