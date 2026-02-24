import SwiftUI

struct HadithCard: View {
    let hadith: Hadith

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerRow
            quoteText
            sourceRow
        }
        .noorCard()
    }

    private var headerRow: some View {
        HStack {
            Image(systemName: "quote.opening")
                .foregroundStyle(Color("NoorAccent"))
            Text("Hadith of the Day")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var quoteText: some View {
        Text("\"\(hadith.textEnglish)\"")
            .font(.callout)
            .italic()
            .foregroundStyle(.primary.opacity(0.85))
            .lineSpacing(4)
    }

    private var sourceRow: some View {
        HStack {
            Text("— \(hadith.narrator)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(hadith.source)
                .font(.caption2)
                .foregroundStyle(Color("NoorAccent"))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color("NoorAccent").opacity(0.12))
                .clipShape(Capsule())
        }
    }
}
