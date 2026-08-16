import SwiftUI

/// ホーム画面（ARビュー）。全画面ARView + 中央クロスヘア + 上部保存/ロードボタン + 下部メモ追加ボタン。
struct ContentView: View {
    @StateObject private var viewModel = ARViewModel()

    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)
                .ignoresSafeArea()

            Image(systemName: "plus")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(.white)
                .shadow(radius: 2)

            VStack {
                HStack {
                    Button {
                        viewModel.saveWorldMap()
                    } label: {
                        Label("Save Space", systemImage: "square.and.arrow.down")
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()

                    Button {
                        viewModel.loadWorldMap()
                    } label: {
                        Label("Load Space", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .padding(.top, 40)

                if !viewModel.statusMessage.isEmpty {
                    Text(viewModel.statusMessage)
                        .font(.footnote)
                        .padding(8)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding(.top, 4)
                }

                Spacer()

                Button {
                    viewModel.requestPlacementFromCenter()
                } label: {
                    Label("Add Memo", systemImage: "note.text.badge.plus")
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom, 32)
            }
        }
        .sheet(isPresented: $viewModel.isModalPresented) {
            MemoInputView(
                initialText: viewModel.editingMemoID.flatMap { viewModel.memoAnchorsByID[$0]?.text } ?? "",
                initialTextColorHex: viewModel.editingMemoID.flatMap { viewModel.memoAnchorsByID[$0]?.textColorHex } ?? "#000000",
                initialBackgroundColorHex: viewModel.editingMemoID.flatMap { viewModel.memoAnchorsByID[$0]?.backgroundColorHex } ?? "#FFF59D",
                onConfirm: { text, textColor, bgColor in
                    viewModel.confirmPlacement(text: text, textColorHex: textColor, backgroundColorHex: bgColor)
                },
                onCancel: {
                    viewModel.cancelPlacement()
                }
            )
        }
        .confirmationDialog(
            "Edit Memo",
            isPresented: Binding(
                get: { viewModel.selectedMemoForAction != nil },
                set: { if !$0 { viewModel.selectedMemoForAction = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Edit") {
                if let anchor = viewModel.selectedMemoForAction {
                    viewModel.requestEdit(for: anchor)
                }
                viewModel.selectedMemoForAction = nil
            }
            Button("Delete", role: .destructive) {
                if let anchor = viewModel.selectedMemoForAction {
                    viewModel.deleteMemo(anchor)
                }
                viewModel.selectedMemoForAction = nil
            }
            Button("Cancel", role: .cancel) {
                viewModel.selectedMemoForAction = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
