import SwiftUI
import RealityKit
import ARKit

/// RealityKitのARViewをSwiftUIに橋渡しするUIViewRepresentableラッパー（Step 1）。
/// 平面検知（水平・垂直）を有効化し（Step 2）、タップで既存メモの選択も扱う。
struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var viewModel: ARViewModel

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        arView.session.run(config)

        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)

        viewModel.attach(arView: arView)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    final class Coordinator: NSObject {
        let viewModel: ARViewModel

        init(viewModel: ARViewModel) {
            self.viewModel = viewModel
        }

        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            let point = sender.location(in: arView)
            viewModel.handleTap(at: point)
        }
    }
}
