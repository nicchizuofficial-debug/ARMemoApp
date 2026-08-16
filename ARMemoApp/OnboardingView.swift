import SwiftUI

/// 初回起動時に表示する使い方説明。ツールバーの「?」からいつでも再表示できる。
struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    private let items: [(icon: String, title: LocalizedStringKey, description: LocalizedStringKey)] = [
        (
            "note.text.badge.plus",
            "Add Memo",
            "Point the center cursor at a desk or wall, then tap Add Memo to place a note there."
        ),
        (
            "square.and.arrow.down",
            "Save Space",
            "Saves the shape of the space you're looking at, along with the position of every memo in it."
        ),
        (
            "square.and.arrow.up",
            "Load Space",
            "Restores a space you saved earlier. After loading, slowly move the camera around the same area so it can be recognized — your memos will then reappear in their original spots."
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ForEach(items, id: \.title) { item in
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: item.icon)
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Got it")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
                .padding(24)
            }
            .navigationTitle("How mARk Works")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
