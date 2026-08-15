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
                Section("メモの内容") {
                    TextField("テキストを入力", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("見た目") {
                    ColorPicker("文字色", selection: $textColor, supportsOpacity: false)
                    ColorPicker("背景色", selection: $backgroundColor, supportsOpacity: false)
                }

                Section("プレビュー") {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                        Text(text.isEmpty ? "プレビュー" : text)
                            .foregroundColor(textColor)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: 60)
                }
            }
            .navigationTitle("メモを配置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        onCancel()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("配置する") {
                        onConfirm(text, UIColor(textColor).hexString, UIColor(backgroundColor).hexString)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
