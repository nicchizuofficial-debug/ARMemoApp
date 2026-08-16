import SwiftUI

/// ホーム画面（ARビュー）。全画面ARView + 中央クロスヘア + 上部ツールバー + 下部メモ追加ボタン。
struct ContentView: View {
    @StateObject private var viewModel = ARViewModel()
    @State private var isListPresented = false
    @State private var isOnboardingPresented = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            ARViewContainer(viewModel: viewModel)
                .ignoresSafeArea()

            Crosshair()

            VStack {
                topToolbar
                    .padding(.top, 44)
                    .padding(.horizontal, 20)

                if !viewModel.statusMessage.isEmpty {
                    StatusPill(text: viewModel.statusMessage)
                        .padding(.top, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                Spacer()

                addMemoButton
                    .padding(.bottom, 36)
            }
            .animation(.easeInOut(duration: 0.2), value: viewModel.statusMessage)
        }
        .onAppear {
            if !hasSeenOnboarding {
                isOnboardingPresented = true
                hasSeenOnboarding = true
            }
        }
        .sheet(isPresented: $isOnboardingPresented) {
            OnboardingView()
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
        .sheet(isPresented: $isListPresented) {
            MemoListView(viewModel: viewModel)
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

    private var topToolbar: some View {
        HStack(spacing: 14) {
            ToolbarIconButton(systemImage: "square.and.arrow.down") {
                viewModel.saveWorldMap()
            }
            ToolbarIconButton(systemImage: "square.and.arrow.up") {
                viewModel.loadWorldMap()
            }
            ToolbarIconButton(systemImage: "questionmark.circle") {
                isOnboardingPresented = true
            }
            Spacer()
            ToolbarIconButton(systemImage: "list.bullet") {
                isListPresented = true
            }
        }
    }

    private var addMemoButton: some View {
        Button {
            viewModel.requestPlacementFromCenter()
        } label: {
            Label("Add Memo", systemImage: "note.text.badge.plus")
                .font(.headline)
                .padding(.horizontal, 26)
                .padding(.vertical, 16)
        }
        .foregroundStyle(.white)
        .background(
            Capsule().fill(
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.75)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        )
        .shadow(color: Color.accentColor.opacity(0.5), radius: 14, y: 6)
    }
}

/// 画面中央のターゲットカーソル。
private struct Crosshair: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.9), lineWidth: 2)
                .frame(width: 34, height: 34)
            Circle()
                .fill(.white)
                .frame(width: 5, height: 5)
        }
        .shadow(color: .black.opacity(0.4), radius: 4)
    }
}

/// ツールバーの丸い半透明アイコンボタン。
private struct ToolbarIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 46, height: 46)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: .black.opacity(0.15), radius: 6, y: 3)
        }
    }
}

/// ステータスメッセージ用の半透明ピル。
private struct StatusPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote.weight(.medium))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
            .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
            .padding(.horizontal, 32)
    }
}

#Preview {
    ContentView()
}
