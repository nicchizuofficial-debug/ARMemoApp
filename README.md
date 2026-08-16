# AiRnote

`Claude_App_Requirements_AR_Memo.md` の仕様に基づいた、空間メモアプリ（iOS / SwiftUI + ARKit + RealityKit）です。

現実空間の平面（机・壁など）にテキストメモを配置し、`ARWorldMap` を使って空間ごと保存・復元します。日本語・英語に対応しています（端末の言語設定に応じて自動切り替え、既定は英語）。

## 実装内容（仕様書のStep 1〜4に対応）

| Step | 内容 | 実装ファイル |
|---|---|---|
| 1 | `ARView` を SwiftUI に表示する `UIViewRepresentable` | [ARViewContainer.swift](ARMemoApp/ARViewContainer.swift) |
| 2 | 水平・垂直平面検知、タップ位置への3Dテキスト配置 | [ARViewContainer.swift](ARMemoApp/ARViewContainer.swift), [ARViewModel.swift](ARMemoApp/ARViewModel.swift) |
| 3 | 入力モーダル（テキスト・文字色・背景色） | [MemoInputView.swift](ARMemoApp/MemoInputView.swift) |
| 4 | `ARWorldMap` によるアンカー情報の保存・復元 | [ARViewModel.swift](ARMemoApp/ARViewModel.swift), [MemoAnchor.swift](ARMemoApp/MemoAnchor.swift) |

追加で、メモの編集・削除（仕様書 セクション2）をタップ操作 + 確認ダイアログで実装しています。

このプロジェクトはWindows環境で作成されているため、**Xcodeでのビルド確認はまだ行われていません**。実機での動作確認・微調整が必要です。

## プロジェクト構成

`.xcodeproj` は手書きせず、[XcodeGen](https://github.com/yonaskolb/XcodeGen) の `project.yml` から生成する方式にしています（Windows上では生成できないため、Mac側 or Codemagic のビルドステップで `xcodegen generate` を実行します）。

```
ARMemoApp/
├── project.yml        # XcodeGenのプロジェクト定義
├── codemagic.yaml      # Codemagic CI/CD設定
└── ARMemoApp/           # Swiftソース一式
    ├── ARMemoApp.swift        # @main App
    ├── ContentView.swift      # ホーム画面（AR全画面 + UI）
    ├── ARViewContainer.swift  # ARViewのSwiftUIラッパー + 平面検知 + タップ
    ├── ARViewModel.swift      # 配置/編集/削除/保存/復元のロジック
    ├── MemoAnchor.swift       # ARAnchorサブクラス（NSSecureCoding対応）
    ├── MemoEntityFactory.swift# テキスト+背景カードの3Dエンティティ生成
    ├── MemoInputView.swift    # メモ入力モーダル
    ├── ColorHex.swift         # UIColor/Color <-> hex文字列 変換
    ├── ja.lproj/              # 日本語ローカライズ（既定言語は英語）
    └── Assets.xcassets/
```

## Codemagicでのビルド手順

このリポジトリには2つのワークフローを用意しています（[codemagic.yaml](codemagic.yaml)）。

### 1. `ios-build-check`（署名なし・コンパイル確認）

Apple Developer Programへの登録がなくても実行できます。push のたびにコンパイルが通るか確認する用途です。

1. GitHub/GitLab/Bitbucketなどにこのリポジトリをpush
2. Codemagicで新規アプリとして接続
3. `codemagic.yaml` が自動検出されるので、ワークフロー `ios-build-check` を実行

### 2. `ios-device-build`（TestFlight配信）

ARKitはシミュレータのカメラでは動作しないため、実機で試すにはこちらが必要です。**Apple Developer Program（有料）への登録が必要です。**

Ad Hoc/Development配信ではなく、TestFlight（App Store配信）経由でのインストールを採用しています。デバイスのUDID事前登録が不要なため、セットアップがシンプルです。

事前準備:

1. Apple Developer Portal で App Store Connect API Key を発行
2. Codemagic > Team settings > Integrations > Apple Developer Portal に登録
   （登録した名前を `codemagic.yaml` の `integrations.app_store_connect` の値と一致させる。現在は `"Codemagic"`）
3. Apple Developer Portal で Bundle ID `com.nicchizu.armemoapp` を払い出す
   （変更する場合は `project.yml` の `PRODUCT_BUNDLE_IDENTIFIER` と `codemagic.yaml` の `bundle_identifier` を両方書き換えてください）
4. App Store Connect で、同じBundle IDのAppレコードを作成（審査には出さず、TestFlightの配信先として使うだけ）
5. ワークフロー `ios-device-build` を実行 → ビルド成功後、自動的にTestFlightへアップロードされる
6. アカウント保有者は内部テスターとして自動的にアクセス可能。iPhoneのTestFlightアプリからインストールできます

## ローカル（Mac）で試す場合

```bash
brew install xcodegen
cd ARMemoApp
xcodegen generate
open ARMemoApp.xcodeproj
```

実機（ARKit対応のiPhone/iPad、iOS 17以降）を接続し、Signing & CapabilitiesでチームとBundle IDを設定してから実行してください。ARKitはシミュレータでは動作しません。

## 既知の注意点

* Windows上ではXcodeビルドを検証できていないため、初回ビルドでコンパイルエラーが出る可能性があります。Xcodeのエラーメッセージをそのまま貼っていただければ修正します。
* `AppIcon` / `AccentColor` は仮のプレースホルダーです。App Store提出前に1024x1024のアイコン画像を用意してください。
* `ARWorldMap` の復元は、保存時と近い場所・向きでカメラを動かして再ローカライズさせる必要があります（ARKitの仕様）。
