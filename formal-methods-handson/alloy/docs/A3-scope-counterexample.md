# A3. スコープと反例の読み方: 不変条件が操作で保たれるか

モデル: `03_library.als`

## 1. 古典的スタイル: 状態を sig にする

Alloy 5 までは時間の概念がなく、「操作前の状態」「操作後の状態」を **別々の原子** として扱いました。
A4 の Alloy 6 より冗長ですが、**不変条件の保存を示す基本形** なので、一度は書いておく価値があります。

```alloy
sig Book {}
sig Member {}
sig State { borrowed: Member -> Book }      // 誰がどの本を借りているか

pred inv[s: State] {
  all b: Book | lone s.borrowed.b           // 1 冊を借りている人は高々 1 人
  all m: Member | #(s.borrowed[m]) =< 3     // 1 人 3 冊まで
}

pred borrow[s, s2: State, m: Member, b: Book] {
  b not in Member.(s.borrowed)              // まだ誰にも借りられていない
  s2.borrowed = s.borrowed + m -> b
}

assert BorrowPreservesInv {
  all s, s2: State, m: Member, b: Book |
    inv[s] and borrow[s, s2, m, b] implies inv[s2]
}
```

- `s.borrowed.b`: `borrowed`(Member -> Book)の右側が `b` である Member の集合。
- `s.borrowed[m]`: `m` が借りている本の集合(box join。`m.(s.borrowed)` と同じ)。
- `#x`: 要素数。`=<` が「以下」。
- 「不変条件を満たす状態 `s` から操作 `borrow` で `s2` に遷移したら、`s2` も不変条件を満たす」が `assert`。
  これは **L4(Lean)の `inv_step`** とまったく同じ形です(Alloy は有界ながら自動で検査する)。

## 2. スコープの違いを体験する

```alloy
check BorrowPreservesInv for 3
check BorrowPreservesInv for 5
```

| スコープ | 結果(予想) | 理由 |
|---|---|---|
| `for 3` | 反例なし | 「3 冊借りている人がさらに 1 冊借りる」には本が **4 冊** 必要。3 では存在できない |
| `for 5` | **反例あり** | `Member$0` が 3 冊借りた状態から 4 冊目を借りられてしまう(`borrow` に冊数の事前条件がない) |

> [!IMPORTANT]
> **`check` が反例を見つけなかったときの意味は「スコープ内の世界に反例がない」だけ** です。
> 反例に必要な原子数を超えたスコープでは見逃します。
> 目安: **「境界の値 + 余裕」を含むスコープ**(上限 3 なら 4 冊以上を許す `for 5`)で検査する。
> 時間が許す限り広げて、反例が出ない/出るを確認する。

## 3. 反例を読む手順

反例のウィンドウが開いたら、次の順で見ます。

1. **どの assert のどの変数に何が束縛されたか**(`s`, `s2`, `m`, `b` が図のどの原子か)。
2. `s` の `borrowed` と `s2` の `borrowed` の差 = 操作の効果。
3. 不変条件のどの行が破れたか(ここでは `#(s2.borrowed[m]) =< 3`)。
4. **モデルの不備なのか、主張の誤りなのか** を判断する。ここでは「操作に事前条件が欠けていた」= モデルの不備。

## 4. 直す

`borrow` に事前条件を足します。

```alloy
pred borrow[s, s2: State, m: Member, b: Book] {
  b not in Member.(s.borrowed)
  #(s.borrowed[m]) < 3                 // ← 追加
  s2.borrowed = s.borrowed + m -> b
}
```

`check BorrowPreservesInv for 5` を再実行。反例がなくなるはずです。

## 5. Int のビット幅に注意

Alloy の整数は **有限のビット幅**(既定 4 ビット = -8〜7)で、**あふれると回り込みます**。
`for 5 but 6 Int` のようにビット幅を指定できます。整数を多用するモデル(A5 の比較題材: 銀行送金)では、
**あふれが原因で偽の反例/見逃しが出る** ことがあります。

## 演習

1. 「1 冊を借りている人は高々 1 人」(`lone s.borrowed.b`)が破れる反例を作りたい。
   `borrow` の事前条件のどれを消すと破れる?(消して `check` → 反例を読む)
2. `return[s, s2, m, b]`(返却)の操作を追加して、`inv` が保たれるか検査する。
3. 「延滞中のメンバーは借りられない」というルール(`overdue: set Member`)を `State` に足し、
   `inv` と `borrow` を拡張する。
4. `run` で「3 冊借りている人がいる状態」を見て、モデルが **空っぽでない** ことを確認する(vacuity の確認)。

> [!NOTE]
> <details><summary>ヒント / 解答の方針</summary>
>
> 1. `b not in Member.(s.borrowed)` を消すと、他人が借りている本を借りられてしまい `lone` が破れる。
> 2. `pred return[s, s2: State, m: Member, b: Book] { m -> b in s.borrowed and s2.borrowed = s.borrowed - m -> b }`。
> 4. `run { some s: State, m: Member | #(s.borrowed[m]) = 3 } for 5`。
>    **`check` が通ったのに、実は `inv` が矛盾していて空っぽの世界を見ていた** という事故を防ぐため、
>    `run` で「中身のある世界」が存在することを必ず確認する習慣をつけよう。
>
> </details>

## まとめ

- `check` の結果は **スコープつき** の保証。境界を超える大きさで試す。
- 不変条件が操作で保たれるかは Alloy の定番の検査パターン(Lean の帰納法と同型)。
- 反例の読み方: 束縛 → 差分 → 破れた条件 → モデルの不備か主張の誤りか。
