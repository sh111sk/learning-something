# L5. `decide`: 有限なら全探索で証明できる / Lean の限界

コード: `LeanHandson/L5_Decide.lean`

## 1. decide とは

命題が **判定可能(Decidable)** なら、Lean は計算して真偽を決められます。
有限範囲(Bool の全組み合わせ、`n < 10` など)ではこれが「全部試す」証明になります。

```lean
example : ∀ a b : Bool, (a && b) = (b && a) := by decide
example : ∀ n < 10, n * n < 100 := by decide
example : ¬ (∀ n < 20, n * n < 100) := by decide     -- 反例(n = 10)があるので否定は真
```

これは TLC/Alloy の「全部数え上げる」と同種のことを **Lean のカーネルが検査する証明** として行うものです。

- `decide` は小さな範囲向け。大きいと「最大再帰深度」や時間切れになる。
- `native_decide` はコンパイル済みコードで評価する(速いが **信頼の基盤が増える** ため、証明の信頼性は下がる)。
  このコースでは使いません。

## 2. L4 の不変条件を 8 状態で確認

```lean
theorem inv_implies_mutex :
    ∀ p0 p1 l : Bool,
      ((p0 = true → l = true) ∧ (p1 = true → l = true) ∧ ¬ (p0 = true ∧ p1 = true)) →
      ¬ (p0 = true ∧ p1 = true) := by
  decide
```

`Bool` が 3 つなので 8 通りしかなく、`decide` で終わります。**状態空間が有限・小さいなら、証明を書かずに全探索で済む**
(TLC の発想)。状態が無限・巨大なら、L2〜L4 の帰納法の出番です。

## 3. 公理の確認

```lean
#print axioms inv_implies_mutex
```

`sorryAx` が出ていたら、どこかに `sorry` が混じっている証明です。**「証明が通った」と言う前に必ず確認**する習慣を。

## 4. Lean の限界と付き合い方

| 限界 | 内容 |
|---|---|
| 反例が自動で出ない | 偽の主張は「証明できない」としか言ってくれない。`decide` や `#eval` で自分で探す |
| 帰納的不変条件を自分で発見する | 状態遷移系(L4)ではここが最大の難所 |
| 時相論理(活性/公平性)は標準では貧弱 | 「いつか必ず」系は自分で定義する必要がある。TLA+ は言語に組み込み |
| 学習コスト・記述量 | 同じ性質でも TLC なら数行で済むものが、証明だと数十行になりやすい |
| 一方で | 「すべての入力」「無限の状態」「実行可能なコードそのもの」を保証できるのは Lean 側 |

> [!NOTE]
> 実務では「設計は TLA+/Alloy で素早く検証し、**核になるアルゴリズムや仕様** は Lean で証明する」
> という組み合わせも考えられます。詳細は `compare/README.md` の使い分けガイドへ。

## 演習

- 5-1 `∀ a b c : Bool, (a && (b || c)) = ((a && b) || (a && c))`
- 5-2 `¬ (∀ n < 8, 2 ^ n ≥ n * n)`

> [!NOTE]
> <details><summary>解答(まず自力で)</summary>
>
> ```lean
> theorem ex1_distrib : ∀ a b c : Bool, (a && (b || c)) = ((a && b) || (a && c)) := by
>   decide
>
> theorem ex2_find : ¬ (∀ n < 8, 2 ^ n ≥ n * n) := by
>   decide
> ```
>
> `2 ^ 3 = 8 < 9 = 3 * 3` なので `n = 3` が反例。`decide` が通らなければ
> `example : 2 ^ 3 < 3 * 3 := by decide` から始めて、`∀ n < 8, ...` の形(`Nat.decidableBallLT`)を調べてみてください。
>
> </details>

## Lean コース修了チェック

- [ ] `theorem` / `induction` / `simp` / `omega` / `decide` の役割を説明できる
- [ ] 「一般化した主張を立てて帰納法を通す」を実際にやった(L3, L4)
- [ ] 状態遷移系の不変条件を、帰納法で証明する流れを説明できる
- [ ] Lean の弱点(反例が出ない、不変条件を自分で発見)を実感した
