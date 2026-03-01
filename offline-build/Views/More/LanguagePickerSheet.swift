import SwiftUI

// MARK: - Language Picker — Apple Settings style
struct LanguagePickerSheet: View {
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var cs

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(AppLanguage.allCases, id: \.rawValue) { lang in
                        LanguageRow(
                            lang: lang,
                            isSelected: localization.currentLanguage == lang
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                localization.currentLanguage = lang
                            }
                            UISelectionFeedbackGenerator().selectionChanged()
                        }
                    }
                } header: {
                    Text("PREFERRED LANGUAGE")
                } footer: {
                    Text(localization.currentLanguage == .malayalam
                         ? "ഖുർആൻ പരിഭാഷ ഇംഗ്ലീഷിൽ തന്നെ തുടരും."
                         : "Quran translation remains in English.")
                }
            }
            .listStyle(.insetGrouped)
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
}

// MARK: - Language Row
private struct LanguageRow: View {
    let lang: AppLanguage
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(lang.flag)
                    .font(.system(size: 28))
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(lang.displayName)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text(lang == .english ? "English" : "Malayalam")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.alehaGreen)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
