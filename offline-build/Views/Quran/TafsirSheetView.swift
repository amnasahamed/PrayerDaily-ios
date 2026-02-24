import SwiftUI

struct TafsirSheetView: View {
    let verse: Verse
    let tafsirText: String?
    @State private var isLoadingTafsir = false
    @State private var loadedTafsir: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    verseHeader
                    Divider()
                    tafsirContent
                }
                .padding(AppTheme.screenPadding)
            }
            .background(Color("NoorSurface").ignoresSafeArea())
            .navigationTitle("Tafsir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color("NoorPrimary"))
                }
            }
        }
    }

    private var verseHeader: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                Text("Ayah \(verse.number)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("NoorPrimary"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color("NoorPrimary").opacity(0.1))
                    .clipShape(Capsule())
                Spacer()
            }
            Text(verse.arabic)
                .font(.system(size: 24))
                .lineSpacing(12)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(verse.translation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .noorCard()
    }

    private var tafsirContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Ibn Kathir Commentary", systemImage: "text.book.closed.fill")
                .font(.headline)
                .foregroundStyle(Color("NoorPrimary"))

            let text = tafsirText ?? loadedTafsir
            if let t = text, !t.isEmpty {
                Text(t)
                    .font(.body)
                    .lineSpacing(6)
                    .foregroundStyle(.primary)
            } else if isLoadingTafsir {
                HStack {
                    ProgressView()
                    Text("Loading tafsir...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Tafsir not available for this verse. Please check your connection and try again.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
