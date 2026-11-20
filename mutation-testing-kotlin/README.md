# Kotlin ミューテーションテスト ハンズオン

Kotlin + Gradle + [PIT (Pitest)](https://pitest.org/) で、ミューテーションテストを手を動かして体験するコースです。
「カバレッジは高いのにテストが本当に守れているか分からない」状態から、「生き残ったミュータントを読んでテストを改善できる」状態を目指します。

## ミューテーションテストとは(要点)

- プロダクションコードに**わざと小さなバグ(ミュータント)**を埋め込み(`>=` → `>`、`+` → `-`、戻り値を `0` に、など)、**テストが失敗するか**を見る手法。
- テストが失敗すれば **KILLED**(テストがバグを検出できた)、全部通ってしまえば **SURVIVED**(テストの穴)。
- 指標は `mutation score = KILLED / 全ミュータント`。行カバレッジは「実行されたか」しか見ないが、ミューテーションテストは「**検証されているか**」を見る。

## 前提

- JDK 17 以上(動作確認は JDK 21)。Gradle Wrapper(9.6.1)が自動ダウンロードされます。
- インターネット接続(Maven Central / Gradle Plugin Portal)。
- 各ステップは**独立した Gradle プロジェクト**です。`cd` してから `./gradlew ...` を実行してください。

## 進め方(各ステップ共通)

1. `./gradlew test` … テストは全部通る(=普通のテストでは問題が見えない)。
2. `./gradlew pitest` … ミューテーションテストを実行。
3. `build/reports/pitest/index.html` をブラウザで開き、赤(SURVIVED)の行と変異内容を確認。
4. **自分で**テストを改善して再度 `./gradlew pitest`。
5. 詰まったら `solution/` の模範解答を `src/test/...` に上書きコピーして比較。
6. 終わったら `git checkout -- .` でテストを初期状態に戻せます。

## ステップ一覧

| Step | ディレクトリ | 学ぶこと | 初期 → 解答後の mutation score |
|---|---|---|---|
| 1 | [`step1-first-run/`](./step1-first-run) | PIT の導入、結果の読み方、境界値・戻り値検証でミュータントを殺す | 60% → 100% |
| 2 | [`step2-kotlin-and-config/`](./step2-kotlin-and-config) | `when` / null 安全 / コレクションを題材にした改善、同値ミュータント、Kotlin 特有のノイズ、`mutators`・`mutationThreshold` の設定 | 58% → 87%(残りは同値/ノイズ) |

## 動作確認メモ

- 検証環境: JDK 21 / Gradle 9.6.1 / Kotlin 2.3.21 / gradle-pitest-plugin 1.19.0 / PIT 1.17.4 / pitest-junit5-plugin 1.2.1
- Maven Central が `429 Too Many Requests` を返すことがあります。その場合は少し待って再実行してください。
