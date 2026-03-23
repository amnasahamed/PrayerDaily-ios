import SwiftUI

struct HadithCard: View {
    let hadith: Hadith
    @State private var expanded = false
    @Environment(\.colorScheme) var cs
    @EnvironmentObject var localization: LocalizationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow
            quoteText
            sourceRow
        }
        .noorCard()
    }

    private var headerRow: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "quote.opening")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.alehaAmber)
                Text(localization.t(.homeHadithOfTheDay))
                    .font(.subheadline.weight(.semibold))
            }
            Spacer()
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { expanded.toggle() }
            } label: {
                Image(systemName: "arrow.up.left.and.arrow.down.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(6)
                    .background(Color(.systemGray5).opacity(0.6))
                    .clipShape(Circle())
            }
            .buttonStyle(BouncePressStyle())
        }
    }

    private var quoteText: some View {
        Text("\"\(hadith.textEnglish)\"")
            .font(.callout)
            .italic()
            .foregroundStyle(.primary.opacity(0.88))
            .lineSpacing(4)
            .lineLimit(expanded ? nil : 3)
            .animation(.easeInOut(duration: 0.3), value: expanded)
    }

    private var sourceRow: some View {
        HStack {
            Text("— \(hadith.narrator)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(hadith.source)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.alehaAmber)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.alehaAmber.opacity(0.12))
                .clipShape(Capsule())
        }
    }
}
