import SwiftUI

/// 配置済みメモの一覧。付箋カード形式で表示し、タップで編集・削除に進める。
struct MemoListView: View {
    @ObservedObject var viewModel: ARViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.memoOrder.isEmpty {
                    ContentUnavailableView(
                        "No Memos Yet",
                        systemImage: "note.text",
                        description: Text("Memos you place in space will appear here.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.memoOrder, id: \.self) { id in
                                if let memo = viewModel.memoAnchorsByID[id] {
                                    MemoCardView(memo: memo)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            dismiss()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                viewModel.selectedMemoForAction = memo
                                            }
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Memos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

private struct MemoCardView: View {
    let memo: MemoAnchor

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: memo.backgroundColorHex))
                .frame(width: 48, height: 48)
                .overlay(
                    Circle()
                        .fill(Color(hex: memo.textColorHex))
                        .frame(width: 14, height: 14)
                )
                .shadow(color: .black.opacity(0.15), radius: 3, y: 2)

            Text(memo.text)
                .font(.body)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}

#Preview {
    MemoListView(viewModel: ARViewModel())
}
