# L3. プログラムの仕様を証明する

コード: `LeanHandson/L3_Programs.lean`

Lean の最も実用的な使い方は「**素朴で明らかに正しい実装** と **高速な実装** が同じ結果を返す」ことの証明です。

## 例 1: 末尾再帰の sum

```lean
def sum : List Nat → Nat
  | [] => 0
  | x :: xs => x + sum xs

def sumAcc : List Nat → Nat → Nat
  | [], acc => acc
  | x :: xs, acc => sumAcc xs (acc + x)
```

欲しい定理は `sumAcc xs 0 = sum xs`。しかしこれを直接帰納法で示そうとすると詰まります。
`cons` ケースで `sumAcc xs (0 + x)` が出てきて、`ih : sumAcc xs 0 = sum xs` が**合わない**からです。

**解決: acc を一般化する**(`generalizing acc`)。

```lean
theorem sumAcc_eq (xs : List Nat) (acc : Nat) : sumAcc xs acc = acc + sum xs := by
  induction xs generalizing acc with
  | nil => simp [sumAcc, sum]
  | cons x xs ih =>
    simp only [sumAcc, sum, ih]
    omega
```

こうすると `ih : ∀ acc, sumAcc xs acc = acc + sum xs` と強くなり、`acc + x` を渡せます。

> [!IMPORTANT]
> 「元の主張より **一般化した主張** の方が証明しやすい」のは形式検証の基本テクニックです。
> 後の L4 の「強い不変条件」も、まったく同じ発想(主張を強くして帰納法を通す)です。

## 例 2: 性質を述べる(count ≤ length)

```lean
theorem count_le_length {α : Type} (p : α → Bool) (xs : List α) :
    count p xs ≤ xs.length := by
  induction xs with
  | nil => simp [count]
  | cons x xs ih =>
    simp only [count, List.length_cons]
    split <;> omega       -- if p x then ... else ... を場合分けして omega
```

`split` は `if` を「真の場合」「偽の場合」の 2 ゴールに分けます。

## 例 3: 失敗しうる関数(Option)と構造体

```lean
structure Account where
  balance : Nat

def withdraw (amt : Nat) (a : Account) : Option Account :=
  if amt ≤ a.balance then some { balance := a.balance - amt } else none
```

`withdraw_le` は「出金に成功したなら残高は減っている」。`split at h` で `if` を場合分けし、
成功側で `injection` / `subst` を使います。

> [!NOTE]
> これは TLA+/Alloy では書きにくい種類の性質です。TLA+ は「システム全体の振る舞い」、
> Alloy は「構造の制約」を書く道具で、**1 つの関数の入出力仕様** を書くのは Lean(や他の定理証明器)の領分です。

## 演習

- 3-1 `count_append`
- 3-2 `lenAcc` を正しく定義して `lenAcc xs 0 = xs.length` を証明
- 3-3 `withdraw_exact`: 出金成功なら `b.balance + amt = a.balance`

> [!NOTE]
> <details><summary>解答(まず自力で)</summary>
>
> ```lean
> theorem count_append {α : Type} (p : α → Bool) (xs ys : List α) :
>     count p (xs ++ ys) = count p xs + count p ys := by
>   induction xs with
>   | nil => simp [count]
>   | cons x xs ih =>
>     simp only [List.cons_append, count, ih]
>     omega
>
> def lenAcc {α : Type} : List α → Nat → Nat
>   | [], acc => acc
>   | _ :: xs, acc => lenAcc xs (acc + 1)
>
> theorem lenAcc_eq {α : Type} (xs : List α) (acc : Nat) :
>     lenAcc xs acc = acc + xs.length := by
>   induction xs generalizing acc with
>   | nil => simp [lenAcc]
>   | cons x xs ih =>
>     simp only [lenAcc, List.length_cons, ih]
>     omega
>
> theorem lenAcc_correct {α : Type} (xs : List α) : lenAcc xs 0 = xs.length := by
>   rw [lenAcc_eq]
>   omega
>
> theorem withdraw_exact {amt : Nat} {a b : Account} (h : withdraw amt a = some b) :
>     b.balance + amt = a.balance := by
>   unfold withdraw at h
>   split at h
>   · rename_i hle
>     injection h with h1
>     subst h1
>     show a.balance - amt + amt = a.balance
>     omega
>   · cases h
> ```
>
> (`lenAcc_correct` を解くには、補助の `lenAcc_eq` を先に証明する必要があります。L2 の教訓どおりです。)
>
> </details>

## まとめ

- 「実装 A = 実装 B」の証明が Lean の王道。**一般化した補題** を立てるのが鍵。
- `omega`(線形算術)・`split`(if の場合分け)・`injection`/`subst`(等式の分解)を覚えれば大半が進む。
