import SwiftUI

struct AppearanceView: View {
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"
    @AppStorage("arabicFontSize") private var arabicFontSize: Double = 28
    @AppStorage("translationEnabled") private var translationEnabled: Bool = true
    @AppStorage("transliterationEnabled") private var transliterationEnabled: Bool = true

    private let modes: [(String, String, String)] = [
        ("system", "sparkles", "System"),
        ("light", "sun.max.fill", "Light"),
        ("dark", "moon.fill", "Dark")
    ]

    var body: some View {
        ZStack {
            CalmingBackground().ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    themePicker
                    arabicSection
                    readingSection
                }
                .padding(.horizontal, AppTheme.screenPadding)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.large)
        .modifier(AlehaNavStyle())
    }

    // MARK: - Theme
    private var themePicker: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("App Theme").font(.headline.weight(.bold))
            HStack(spacing: 12) {
                ForEach(modes, id: \.0) { id, icon, label in
                    let selected = appearanceMode == id
                    Button { appearanceMode = id } label: {
                        VStack(spacing: 10) {
                            ZStack {
                                Circle()
                                    .fill(selected ? Color.alehaGreen.opacity(0.15) : Color(.systemGray5))
                                    .frame(width: 54, height: 54)
                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(selected ? Color.alehaGreen : .secondary)
                            }
                            Text(label).font(.caption.weight(selected ? .semibold : .regular))
                                .foregroundStyle(selected ? Color.alehaGreen : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(selected ? Color.alehaGreen : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(SpringPressStyle())
                }
            }
        }
        .noorCard()
    }

    // MARK: - Arabic Font
    private var arabicSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Arabic Text Size").font(.headline.weight(.bold))
            Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                .font(.system(size: arabicFontSize))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .multilineTextAlignment(.trailing)
                .padding(.vertical, 4)
            HStack {
                Text("A").font(.caption)
                Slider(value: $arabicFontSize, in: 20...42, step: 2)
                    .tint(Color.alehaGreen)
                Text("A").font(.title2)
            }
            HStack {
                Spacer()
                Text("Size: \(Int(arabicFontSize))pt")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .noorCard()
    }

    // MARK: - Reading Prefs
    private var readingSection: some View {
        VStack(spacing: 0) {
            toggleRow(title: "Show Translation", subtitle: "English meaning below each ayah",
                      icon: "text.bubble.fill", color: Color.alehaGreen, binding: $translationEnabled, divider: true)
            toggleRow(title: "Show Transliteration", subtitle: "Romanized Arabic pronunciation",
                      icon: "character.book.closed.fill", color: Color.alehaAmber, binding: $transliterationEnabled, divider: false)
        }
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous))
    }

    private func toggleRow(title: String, subtitle: String, icon: String, color: Color,
                           binding: Binding<Bool>, divider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(color.opacity(0.12)).frame(width: 34, height: 34)
                    Image(systemName: icon).font(.system(size: 15)).foregroundStyle(color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.subheadline.weight(.medium))
                    Text(subtitle).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("", isOn: binding).labelsHidden().tint(Color.alehaGreen)
            }
            .padding(.horizontal, 16).padding(.vertical, 13)
            if divider { Divider().padding(.leading, 64) }
        }
    }
}
