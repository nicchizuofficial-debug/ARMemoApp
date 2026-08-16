import SwiftUI

/// メモ入力モーダル（Step 3）。文字色・背景色の選択と「配置する」「キャンセル」を提供。
struct MemoInputView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var text: String
    @State private var textColor: Color
    @State private var backgroundColor: Color

    let onConfirm: (String, String, String) -> Void
    let onCancel: () -> Void

    init(
        initialText: String,
        initialTextColorHex: String,
        initialBackgroundColorHex: String,
        onConfirm: @escaping (String, String, String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _text = State(initialValue: initialText)
        _textColor = State(initialValue: Color(hex: initialTextColorHex))
        _backgroundColor = State(initialValue: Color(hex: initialBackgroundColorHex))
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Memo Content") {
                    TextField("Enter text", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Appearance") {
                    ColorPicker("Text Color", selection: $textColor, supportsOpacity: false)
                    ColorPicker("Background Color", selection: $backgroundColor, supportsOpacity: false)
                }

                Section("Preview") {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(backgroundColor)
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                        Text(text.isEmpty ? String(localized: "Preview") : text)
                            .foregroundColor(textColor)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 70)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4))
                }
            }
            .navigationTitle("Place Memo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Place") {
                        onConfirm(text, UIColor(textColor).hexString, UIColor(backgroundColor).hexString)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
