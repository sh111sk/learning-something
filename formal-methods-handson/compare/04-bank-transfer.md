# 比較 4: 銀行口座の送金

題材: 口座間の送金で **総額が保存される** こと、**残高が負にならない** こと。

| ツール | ファイル | 実行 |
|---|---|---|
| Lean | `compare/bank/Bank.lean` | `lean/` から `lake env lean ../compare/bank/Bank.lean` |
| TLA+ | `compare/bank/Bank.tla` `Bank.cfg` `BankBuggy.cfg` | `tlc -config Bank.cfg Bank.tla` |
| Alloy | `compare/bank/bank.als` | GUI で Execute All |

## 3 つの書き方

```lean
-- Lean: 任意の残高・任意の送金額について総額保存を証明
theorem transfer_conserves (h : Transfer amt s t) : s.1 + s.2 = t.1 + t.2
theorem reach_conserves (h : Reach init s) : s.1 + s.2 = init.1 + init.2    -- 何回送金しても
```

```tla
\* TLA+: 3 口座 × 初期 10。全状態(約 500)を列挙
Transfer(from, to) == /\ from # to
                      /\ \E amt \in 1..bal[from] : bal' = [bal EXCEPT ![from] = @ - amt, ![to] = @ + amt]
Conserved == bal["a"] + bal["b"] + bal["c"] = 30
```

```alloy
// Alloy 6: 3 口座、7 ビット整数、10 ステップ以内
pred transfer[from, to: Account, amt: Int] {
  from != to  amt > 0  amt =< from.bal
  from.bal' = minus[from.bal, amt]   to.bal' = plus[to.bal, amt]
  all a: Account - (from + to) | a.bal' = a.bal
}
assert Conserved { always ((sum a: Account | a.bal) = 30) }
```

## バグ版を試す

| ツール | 方法 | 予想される結果 |
|---|---|---|
| TLA+ | `tlc -config BankBuggy.cfg Bank.tla` | `NonNegative` 違反。**最短で「残高 10 から 1 回で 11 以上送る」トレース** |
| Alloy | `transfer` の `amt =< from.bal` を削除 | `NonNegative` の反例。口座が負になる世界が出る |
| Lean | `Transfer` の `amt ≤ a` を削除(Nat の引き算は 0 で止まる)| `transfer_conserves` が **証明できなくなる**。**なぜか、どの状態が反例か** は自分で見つける(演習 B-1) |

> [!WARNING]
> Lean の `Nat` では `a - amt` は `a < amt` のとき 0 になるので、総額保存は **破れる**(`a + b ≠ 0 + (b + amt)`)が、
> 「残高が負になる」という表現自体が型で消える点に注意。**モデリング(型の選び方)が検証対象の意味を変える** 例です。
> Alloy の整数は有限ビットで回り込み、TLA+ の `Int` は任意精度。ここもツールごとの差が出ます。

## 比較

| 観点 | Lean | TLA+ | Alloy |
|---|---|---|---|
| 総額保存の保証範囲 | **任意の初期残高・任意回の送金** | 初期 10 × 3 口座の **約 500 状態** | 3 口座・7 ビット・10 ステップ内 |
| 整数の扱い | 任意精度。`omega` で自動証明 | 範囲を絞れば自然 | **有限ビット幅**。範囲外で回り込み |
| バグ検出 | 手で反例を構成 | ◎ 自動で最短トレース | ○ 自動で反例 |
| 並行する送金(競合) | 自前で細かいステップ化が必要 | ◎ 自然に書ける(PlusCal でも)| ○ 可能 |
| 労力 | 中(定理 2 つ + 証明) | 低 | 低 |

## この題材での結論

> [!IMPORTANT]
> **目的次第で 3 者 3 様** になる題材です。
>
> - **「総額が保存される」を任意の入力で保証したい**(例: 会計の核) → **Lean**。
>   `omega` が算術を自動で閉じてくれるので証明は軽い。
> - **「並行して複数の送金が走っても壊れないか」を設計段階で潰したい** → **TLA+**。
>   送金を「残高確認 → 引き落とし → 入金」に細かくステップ化すると、競合のバグが最短トレースで出る
>   (T4 の PlusCal lost update と同じ構造)。
> - **「口座とルールの組み合わせ(限度額・凍結・名義)」の設計に矛盾がないか** → **Alloy**。
>   数値より構造・ルールが主役なら Alloy の出番。整数の計算に頼る検証は Alloy の苦手分野。

## 発展課題

- TLA+ で送金を 2 ステップ(`Withdraw` → `Deposit`)に分け、途中状態を許したときの総額保存を検査する
  (途中状態では保存されない。`Conserved` を「処理中の金額も含める」形に直す = **仕様の抽象度の選択**)。
- Lean で `Transfer` を 3 口座に拡張する。`Fin 3 → Nat` と `Function.update` を使うと、場合分けがどう増えるか。
