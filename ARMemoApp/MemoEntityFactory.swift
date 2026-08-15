import RealityKit
import UIKit

/// メモのテキスト＋背景カードを1つのRealityKitエンティティとして生成する。
enum MemoEntityFactory {
    static func makeMemoEntity(
        text: String,
        textColorHex: String,
        backgroundColorHex: String
    ) -> Entity {
        let textColor = UIColor(hex: textColorHex)
        let backgroundColor = UIColor(hex: backgroundColorHex)

        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: 0.03, weight: .medium),
            containerFrame: .zero,
            alignment: .left,
            lineBreakMode: .byWordWrapping
        )
        let textMaterial = UnlitMaterial(color: textColor)
        let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])

        let bounds = textMesh.bounds
        let padding: Float = 0.015
        let width = max(bounds.extents.x + padding * 2, 0.06)
        let height = max(bounds.extents.y + padding * 2, 0.04)

        let cardMesh = MeshResource.generatePlane(width: width, height: height, cornerRadius: 0.006)
        let cardMaterial = UnlitMaterial(color: backgroundColor)
        let cardEntity = ModelEntity(mesh: cardMesh, materials: [cardMaterial])
        cardEntity.position.z = -0.001

        textEntity.position = SIMD3<Float>(-bounds.extents.x / 2, -bounds.extents.y / 2, 0)

        let container = Entity()
        container.name = "MemoContainer"
        container.addChild(cardEntity)
        container.addChild(textEntity)
        container.components.set(
            CollisionComponent(shapes: [.generateBox(size: SIMD3<Float>(width, height, 0.02))])
        )
        container.components.set(InputTargetComponent())

        return container
    }
}
