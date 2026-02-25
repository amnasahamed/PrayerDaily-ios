import SwiftUI

struct HadithCollectionCard: View {
    let collection: HadithCollection
    @Environment(\.colorScheme) var cs

    var body: some View {
        HStack(spacing: 14) {
            iconView
            textContent
            Spacer()
            chevron
        }
        .padding(14)
        .background(cs == .dark ? Color(.systemGray6) : .white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .shadow(color: .black.opacity(cs == .dark ? 0.3 : 0.05), radius: 6, y: 3)
    }

    private var iconView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(collection.color).opacity(0.15))
                .frame(width: 52, height: 52)
            Image(systemName: collection.icon)
                .font(.title3)
                .foregroundStyle(Color(collection.color))
        }
    }

    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(collection.arabicName)
                .font(.caption)
                .foregroundStyle(Color(collection.color))
            Text(collection.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            HStack(spacing: 6) {
                Text(collection.author)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("•")
                    .font(.caption)
                    .foregroundStyle(.quaternary)
                Text("\(collection.totalHadith) hadith")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let preview = previewLine {
                Text(preview)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
                    .lineLimit(1)
                    .padding(.top, 2)
            }
        }
    }

    private var previewLine: String? {
        let first = collection.chapters.first?.hadiths.first?.english
        guard let text = first else { return nil }
        let words = text.split(separator: " ").prefix(8).joined(separator: " ")
        return "\"\(words)…\""
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.caption)
            .foregroundStyle(.tertiary)
    }
}
