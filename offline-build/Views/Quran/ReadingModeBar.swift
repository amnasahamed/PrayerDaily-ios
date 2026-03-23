import SwiftUI

enum ReadingMode: String, CaseIterable {
    case arabicOnly      = "Arabic"
    case both            = "Arabic + Translation"
    case translationOnly = "Translation"
    case focus           = "Focus"

    var icon: String {
        switch self {
        case .arabicOnly:       return "textformat.arabic"
        case .both:             return "text.alignleft"
        case .translationOnly:  return "character.book.closed"
        case .focus:            return "moon.fill"
        }
    }

    func shortLabel(localization: LocalizationManager) -> String {
        switch self {
        case .arabicOnly:       return localization.t(.quranReadingModeArabic)
        case .both:             return localization.t(.quranReadingModeBoth)
        case .translationOnly:  return localization.t(.quranReadingModeTranslation)
        case .focus:            return localization.t(.quranReadingModeFocus)
        }
    }
}

struct ReadingModeBar: View {
    @Binding var mode: ReadingMode
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ReadingMode.allCases, id: \.self) { m in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            mode = m
                        }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: m.icon)
                                .font(.caption)
                            Text(m.shortLabel(localization: localization))
                                .font(.caption.weight(.medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(modeBackground(m))
                        .foregroundStyle(modeForeground(m))
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
    }

    private func modeBackground(_ m: ReadingMode) -> Color {
        m == mode ? Color.alehaGreen : Color.alehaGreen.opacity(0.08)
    }

    private func modeForeground(_ m: ReadingMode) -> Color {
        m == mode ? .white : Color.alehaGreen
    }
}
