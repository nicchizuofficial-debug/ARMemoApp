import ARKit

/// メモの内容・色をARWorldMapと一緒に保存/復元するためのARAnchorサブクラス。
/// NSSecureCodingに準拠させることで、ARWorldMapのアーカイブに含めて
/// ローカルへ保存し、次回起動時に復元できる。
final class MemoAnchor: ARAnchor {
    let text: String
    let textColorHex: String
    let backgroundColorHex: String

    init(
        name: String,
        transform: simd_float4x4,
        text: String,
        textColorHex: String,
        backgroundColorHex: String
    ) {
        self.text = text
        self.textColorHex = textColorHex
        self.backgroundColorHex = backgroundColorHex
        super.init(name: name, transform: transform)
    }

    required init(anchor: ARAnchor) {
        let other = anchor as! MemoAnchor
        self.text = other.text
        self.textColorHex = other.textColorHex
        self.backgroundColorHex = other.backgroundColorHex
        super.init(anchor: anchor)
    }

    override class var supportsSecureCoding: Bool { true }

    required init?(coder: NSCoder) {
        guard
            let text = coder.decodeObject(of: NSString.self, forKey: "memoText") as String?,
            let textColorHex = coder.decodeObject(of: NSString.self, forKey: "memoTextColor") as String?,
            let backgroundColorHex = coder.decodeObject(of: NSString.self, forKey: "memoBackgroundColor") as String?
        else {
            return nil
        }
        self.text = text
        self.textColorHex = textColorHex
        self.backgroundColorHex = backgroundColorHex
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(text as NSString, forKey: "memoText")
        coder.encode(textColorHex as NSString, forKey: "memoTextColor")
        coder.encode(backgroundColorHex as NSString, forKey: "memoBackgroundColor")
    }
}
