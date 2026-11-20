# Step 1: 最初のミューテーションテスト

## 学ぶ概念

- PIT の Gradle 導入(`id("info.solidsoft.pitest")` と `pitest {}` ブロック)
- JUnit 5 を使う場合は `junit5PluginVersion` が必須(PIT は標準で JUnit 4 しか認識しない)
- レポートの読み方: KILLED / SURVIVED / NO_COVERAGE
- 代表的なミューテーター
  - `ConditionalsBoundaryMutator`: `>=` ⇔ `>`、`<` ⇔ `<=`(→ **境界値テスト**で殺す)
  - `NegateConditionalsMutator`: 条件の反転
  - `MathMutator`: `/` → `*` など(→ **具体的な値の assert**で殺す)
  - `PrimitiveReturnsMutator`: 戻り値を 0 に(→ **戻り値を検証**して殺す)

## 題材

`src/main/kotlin/shop/ShippingFee.kt`: 5,000 円以上で送料無料、未満は 500 円、会員は半額(切り捨て)。
`ShippingFeeTest.kt` は**わざと弱い**テスト(行カバレッジはほぼ 100%)。

## 手を動かす課題

1. `./gradlew test` を実行し、全テスト成功を確認する。
2. `./gradlew pitest` を実行する。`Generated 5 mutations Killed 3 (60%)` となるはず。
3. `build/reports/pitest/index.html` を開き、`ShippingFee.kt` の赤い行(13 行目・16 行目)と、各ミュータントの説明を読む。
4. 生き残った 2 つのミュータントがそれぞれ「どんなバグを見逃しているか」を言葉にする。
5. テストを追加・修正して 100% を目指す。
6. 詰まったら `solution/ShippingFeeTest.kt` を参照。

## 確認ポイント

- 「会員でも計算できる」テストは**呼び出しているだけで assert がない**ので、行は実行されたことになりカバレッジは 100% でも何も守れていない。
- `>=` の境界は「ちょうど 5,000」と「4,999」の**両側**を押さえて初めて殺せる。

## つまずきやすいポイント

- **`BASE_FEE / 2` のように定数同士の演算は Kotlin コンパイラが定数畳み込みするため、ミュータントが生成されません。** このサンプルで `baseFee` をコンストラクタ引数にしているのはそのためです(`const val` 同士だと `/` → `*` の変異が起きない)。
- PIT は「元のテストが全部成功している」ことが前提です。`pitest` 実行前に `./gradlew test` で成功を確認すると原因の切り分けが楽です。

## 理解度チェック

1. 行カバレッジ 100% でも SURVIVED が出るのはなぜですか。
2. `>=` → `>` のミュータントを殺すために、最低限必要なテスト入力は何ですか。
3. 「戻り値を検証しないテスト」を PIT はどのミュータントで暴きますか。
