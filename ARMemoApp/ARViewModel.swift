import SwiftUI
import RealityKit
import ARKit
import Combine

/// ARSessionの状態、メモの配置/編集/削除、ARWorldMapの保存/復元を管理する。
final class ARViewModel: NSObject, ObservableObject {
    @Published var isModalPresented = false
    @Published var statusMessage: String = ""
    @Published var selectedMemoForAction: MemoAnchor?

    private(set) var editingMemoID: UUID?
    private(set) var memoAnchorsByID: [UUID: MemoAnchor] = [:]

    weak var arView: ARView?

    private var pendingPlacementTransform: simd_float4x4?
    private var anchorEntities: [UUID: AnchorEntity] = [:]

    private let worldMapURL: URL = {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent("ARMemoWorldMap.data")
    }()

    func attach(arView: ARView) {
        self.arView = arView
        arView.session.delegate = self
    }

    // MARK: - 配置フロー（Step 2, 3）

    /// 画面中央のクロスヘア位置からレイキャストし、検知済みの平面にヒットしたら入力モーダルを開く。
    func requestPlacementFromCenter() {
        guard let arView = arView else { return }
        let center = arView.center
        let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .any)
        guard let result = results.first else {
            statusMessage = String(localized: "No plane detected. Point the camera at a desk or wall.")
            return
        }
        pendingPlacementTransform = result.worldTransform
        editingMemoID = nil
        isModalPresented = true
    }

    func requestEdit(for anchor: MemoAnchor) {
        pendingPlacementTransform = anchor.transform
        editingMemoID = anchor.identifier
        isModalPresented = true
    }

    func confirmPlacement(text: String, textColorHex: String, backgroundColorHex: String) {
        guard let arView = arView, let transform = pendingPlacementTransform else { return }

        if let editingID = editingMemoID, let existing = memoAnchorsByID[editingID] {
            arView.session.remove(anchor: existing)
        }

        let anchor = MemoAnchor(
            name: "memo",
            transform: transform,
            text: text,
            textColorHex: textColorHex,
            backgroundColorHex: backgroundColorHex
        )
        arView.session.add(anchor: anchor)

        isModalPresented = false
        pendingPlacementTransform = nil
        editingMemoID = nil
    }

    func cancelPlacement() {
        isModalPresented = false
        pendingPlacementTransform = nil
        editingMemoID = nil
    }

    // MARK: - 編集・削除（Step 2要件）

    func handleTap(at point: CGPoint) {
        guard let arView = arView, let tappedEntity = arView.entity(at: point) else { return }
        var current: Entity? = tappedEntity
        while let entity = current {
            if entity.name == "MemoContainer",
               let anchorEntity = entity.anchor,
               let anchorID = anchorEntity.anchorIdentifier,
               let memoAnchor = memoAnchorsByID[anchorID] {
                selectedMemoForAction = memoAnchor
                return
            }
            current = entity.parent
        }
    }

    func deleteMemo(_ anchor: MemoAnchor) {
        arView?.session.remove(anchor: anchor)
    }

    private func removeVisual(for id: UUID) {
        if let anchorEntity = anchorEntities[id] {
            arView?.scene.removeAnchor(anchorEntity)
            anchorEntities[id] = nil
        }
        memoAnchorsByID[id] = nil
    }

    // MARK: - 空間の保存・復元（Step 4）

    func saveWorldMap() {
        guard let arView = arView else { return }
        arView.session.getCurrentWorldMap { [weak self] worldMap, error in
            guard let self = self else { return }
            guard let map = worldMap else {
                DispatchQueue.main.async {
                    let reason = error?.localizedDescription ?? String(localized: "Unknown error")
                    self.statusMessage = "\(String(localized: "Save failed")): \(reason)"
                }
                return
            }
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try data.write(to: self.worldMapURL, options: .atomic)
                DispatchQueue.main.async {
                    self.statusMessage = "\(String(localized: "Space saved")) (\(map.anchors.count))"
                }
            } catch {
                DispatchQueue.main.async {
                    self.statusMessage = "\(String(localized: "Save failed")): \(error.localizedDescription)"
                }
            }
        }
    }

    func loadWorldMap() {
        guard let arView = arView else { return }
        guard FileManager.default.fileExists(atPath: worldMapURL.path) else {
            statusMessage = String(localized: "No saved space found")
            return
        }
        do {
            let data = try Data(contentsOf: worldMapURL)
            guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
                statusMessage = String(localized: "Failed to load space")
                return
            }

            for id in Array(anchorEntities.keys) {
                removeVisual(for: id)
            }

            let config = ARWorldTrackingConfiguration()
            config.planeDetection = [.horizontal, .vertical]
            config.initialWorldMap = worldMap
            arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
            statusMessage = String(localized: "Space loaded. Slowly move the camera to look around.")
        } catch {
            statusMessage = "\(String(localized: "Failed to load space")): \(error.localizedDescription)"
        }
    }
}

// MARK: - ARSessionDelegate

extension ARViewModel: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let arView = arView else { return }
        for anchor in anchors {
            guard let memoAnchor = anchor as? MemoAnchor else { continue }
            memoAnchorsByID[memoAnchor.identifier] = memoAnchor

            let entity = MemoEntityFactory.makeMemoEntity(
                text: memoAnchor.text,
                textColorHex: memoAnchor.textColorHex,
                backgroundColorHex: memoAnchor.backgroundColorHex
            )
            let anchorEntity = AnchorEntity(anchor: memoAnchor)
            anchorEntity.addChild(entity)
            arView.scene.addAnchor(anchorEntity)
            anchorEntities[memoAnchor.identifier] = anchorEntity
        }
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors {
            guard anchor is MemoAnchor else { continue }
            removeVisual(for: anchor.identifier)
        }
    }
}
