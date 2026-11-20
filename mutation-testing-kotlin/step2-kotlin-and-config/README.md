# Step 2: Kotlin らしいコードと PIT の設定

## 学ぶ概念

- `when` / null 安全(`?.let`, `?:`)/ コレクション操作(`filterNotNull`, `count`)に対するミュータント
- **同値ミュータント(equivalent mutant)**: 変異してもプログラムの振る舞いが変わらないため、**原理的に殺せない**ミュータント。無理に殺そうとせず「殺す価値がない」と判断する。
- **Kotlin 特有のノイズ**: `count` など `inline` 関数は呼び出し側にバイトコードが展開されるため、ソースにない行(このファイルは 48 行なのに 51・53 行目)のミュータントが出る。標準の PIT は Kotlin を完全には理解しないので、その分 SURVIVED が増える(有償の Arcmutate Kotlin プラグインで軽減できる)。
- 設定
  - `mutators`: `DEFAULTS` < `STRONGER` < `ALL`。このステップは `STRONGER`(`RemoveConditional` など追加)
  - `mutationThreshold`: mutation score がしきい値未満なら `pitest` タスクを失敗させる(CI ゲート)
  - `excludedClasses` / `targetClasses`: 対象の絞り込み

## 題材

`src/main/kotlin/grade/GradeCalculator.kt`: 点数 → 成績(`when`)、平均点、合格者数、ループの合計。
`GradeCalculatorTest.kt` は代表値しか見ない弱いテスト。

## 手を動かす課題

1. `./gradlew pitest` を実行する。**mutation score 58% < しきい値 80% でビルドが失敗**することを確認する(失敗してもレポートは出る)。
2. レポートを開き、`grade()` の `when` の各行(15〜19 行目)のミュータントを確認する。境界値(90/89, 70/69, 50/49)を追加して殺す。
3. `average` の `assertNotNull` が弱い理由(何を返しても通る)を説明し、具体値で検証する。`null` 除外・空リストの分岐も押さえる。
4. `require(score in 0..100)` の範囲外(-1 / 101)を `assertFailsWith` で検証する。
5. 生き残りが残ったら 1 件ずつ「殺せるか / 同値か / Kotlin ノイズか」に分類する。
   - 解答テストでも残る SURVIVED: 51〜53 行目(`count` の inline 展開由来)。
   - `sumOfFirst` の `i < n` → `i <= n` 系は、`n = 0` のケースを足すと殺せる(このコードには純粋な同値ミュータントは無いので、概念は自分の書いたコードで探してみる)。
6. `mutators` を `DEFAULTS` に、`mutationThreshold` を 100 に変えて結果がどう変わるか比べる。

## 確認ポイント

- 解答テスト適用後は 87% でしきい値 80% を超え、`BUILD SUCCESSFUL` になる。
- **100% を目指すことが目的ではない。** 残ったミュータントを読んで「意味のあるものだけ」殺すのが実務の使い方。
- `TIMED_OUT`(例: `i++` を消して無限ループ)は PIT では「検出された」扱い。

## 理解度チェック

1. 同値ミュータントとは何か。なぜ mutation score を 100% にしなくてよいのか。
2. なぜ 48 行しかないファイルに 51・53 行目のミュータントが出るのか。
3. `mutationThreshold` を CI に入れると何が嬉しく、どんな運用上の注意が要るか(ヒント: 新規コードのみ対象にしたい場合、履歴 `withHistory` や `targetClasses` の絞り込み)。
