import SwiftUI

// MARK: - Language Picker — Apple Settings quality
struct LanguagePickerSheet: View {
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss

    // Haptic
    private let selectionFeedback = UISelectionFeedbackGenerator()

    var body: some View {
        NavigationStack {
            List {
                // Hero description section
                Section {
                    languageDescription
                }

                // Language choices
                Section {
                    ForEach(AppLanguage.allCases, id: \.rawValue) { lang in
                        LanguageRow(
                            lang: lang,
                            isSelected: localization.currentLanguage == lang
                        ) {
                            selectionFeedback.selectionChanged()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                localization.currentLanguage = lang
                            }
                        }
                    }
                } header: {
                    Text(localization.t(.languagePreferredHeader))
                } footer: {
                    Text(localization.t(.moreLanguageFooter))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(localization.t(.moreLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(localization.t(.commonDone)) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Description block (not a selectable row)
    private var languageDescription: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.alehaGreen.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "globe")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.alehaGreen)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(localization.t(.moreAppLanguage))
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(localization.t(.moreLanguageDesc))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(Color.alehaGreen.opacity(0.05))
    }
}

// MARK: - Language Row
private struct LanguageRow: View {
    let lang: AppLanguage
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Flag in circle
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 40, height: 40)
                    Text(lang.flag)
                        .font(.system(size: 22))
                }

                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text(lang.displayName)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(nativeName(lang))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Checkmark (native iOS style)
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.alehaGreen)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func nativeName(_ lang: AppLanguage) -> String {
        switch lang {
        case .english:  return "English"
        case .malayalam: return "മലയാളം"
        }
    }
}
