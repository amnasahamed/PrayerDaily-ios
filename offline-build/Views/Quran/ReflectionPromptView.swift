import SwiftUI

struct ReflectionPromptView: View {
    let verseNumber: Int
    let surahId: Int
    @State private var isExpanded = false
    @State private var noteText = ""
    @State private var isSaved = false
    @Environment(\.colorScheme) var colorScheme

    private var prompt: String {
        let prompts = [
            "What does this verse teach you about gratitude?",
            "How can you apply this guidance in your daily life?",
            "What quality of Allah is highlighted here?",
            "How does this verse bring you peace today?",
            "What action can you take after reading this?"
        ]
        return prompts[(verseNumber / 5 - 1) % prompts.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            reflectionHeader
            if isExpanded { noteEditor }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(bgColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color("NoorGold").opacity(0.35), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var bgColor: Color {
        colorScheme == .dark
            ? Color(red: 0.18, green: 0.15, blue: 0.05)
            : Color(red: 1.0, green: 0.97, blue: 0.88)
    }

    private var reflectionHeader: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(spacing: 10) {
                Text("💭")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reflection Prompt")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color("NoorGold"))
                    Text(prompt)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "pencil")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("NoorGold"))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }

    private var noteEditor: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Divider().padding(.horizontal, 14)
            TextEditor(text: $noteText)
                .font(.subheadline)
                .frame(height: 90)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("NoorSurface"))
                )
                .padding(.horizontal, 14)
                .overlay(
                    Group {
                        if noteText.isEmpty {
                            Text("Write your reflection…")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 22)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        }
                    }
                )

            Button {
                isSaved = true
                withAnimation(.spring()) {
                    isExpanded = false
                }
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            } label: {
                Label(isSaved ? "Saved ✓" : "Save Note", systemImage: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(Color("NoorGold"))
                    .clipShape(Capsule())
            }
            .padding(.trailing, 14)
            .padding(.bottom, 10)
        }
    }
}
