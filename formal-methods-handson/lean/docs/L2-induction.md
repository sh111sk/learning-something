# L2. 帰納法: 「すべてのリスト」について証明する

コード: `LeanHandson/L2_Induction.lean`

## なぜ帰納法か

テストは `[1,2,3]` のような **個別の** リストでしか確かめられません。
Lean では「**あらゆる長さ・あらゆる要素のリスト `xs` について** `rev (rev xs) = xs`」を証明できます。
これが TLC/Alloy(有限の範囲を数え上げる)との根本的な違いです。

リストは 2 つの作り方しかありません。

```lean
inductive List (α : Type) where
  | nil  : List α                    -- 空リスト []
  | cons : α → List α → List α       -- 先頭要素 + 残り  (x :: xs)
```

だから「すべてのリストで P」は次の 2 つを示せば十分です(帰納法)。

1. `P []` が成り立つ(base case)
2. `P xs` が成り立つと **仮定** して(帰納法の仮定 `ih`)、`P (x :: xs)` が成り立つ

## 例: `app xs [] = xs`

```lean
def app : List α → List α → List α
  | [], ys => ys
  | x :: xs, ys => x :: app xs ys

theorem app_nil (xs : List α) : app xs [] = xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [app, ih]
```

- `induction xs with | nil => ... | cons x xs ih => ...` が基本の型。
- `cons` ケースのゴールは `app (x :: xs) [] = x :: xs`。`app` の定義を使うと
  `x :: app xs [] = x :: xs` になり、`ih : app xs [] = xs` で書き換えれば終わり。
- `simp [app, ih]` は「`app` の定義と `ih` を書き換え規則として使って簡約」。

> [!TIP]
> `simp` が「何をしたか」を知りたいときは `simp?` を使うと、実際に使われた補題が提案されます。
> 最後まで閉じるか分からないときは `simp only [...]` で 1 歩ずつ進め、残ったゴールを見て `omega` 等で閉じるのが確実です。

## 補題を使い回す: reverse

```lean
def myRev : List α → List α
  | [] => []
  | x :: xs => myRev xs ++ [x]

theorem myRev_append (xs ys : List α) :
    myRev (xs ++ ys) = myRev ys ++ myRev xs := by
  induction xs with
  | nil => simp [myRev]
  | cons x xs ih => simp [myRev, ih, List.append_assoc]

theorem myRev_myRev (xs : List α) : myRev (myRev xs) = xs := by
  induction xs with
  | nil => simp [myRev]
  | cons x xs ih => simp [myRev, myRev_append, ih]
```

**教訓**: `rev (rev xs) = xs` をいきなり帰納法で示そうとすると、`cons` ケースで
`rev (rev xs ++ [x])` が出て詰まります。そこで **「連結の反転」補題 `myRev_append` を先に証明** します。
証明では「必要な補題を発見する」ことが技術の中心になります。TLC のようにボタンを押せば終わりではありません。

## 偽の主張の扱い

「`myRev xs = xs`(反転しても同じ)」は偽です。Lean は反例を **自動では探してくれません**。
否定を証明するには、自分で反例(`[0, 1]`)を見つけて渡します(演習 2-3)。

## 演習

`L2_Induction.lean` の 3 問。

- 2-1 `app` の結合律
- 2-2 `app xs ys = xs ++ ys`
- 2-3 `¬ (∀ xs : List Nat, myRev xs = xs)`(L5 の `decide` を先取りしてよい)

> [!NOTE]
> <details><summary>解答(まず自力で)</summary>
>
> ```lean
> theorem app_assoc (xs ys zs : List α) :
>     app (app xs ys) zs = app xs (app ys zs) := by
>   induction xs with
>   | nil => rfl
>   | cons x xs ih => simp [app, ih]
>
> theorem app_eq_append (xs ys : List α) : app xs ys = xs ++ ys := by
>   induction xs with
>   | nil => rfl
>   | cons x xs ih => simp [app, ih]
>
> theorem myRev_not_id : ¬ (∀ xs : List Nat, myRev xs = xs) :=
>   fun h => absurd (h [0, 1]) (by decide)
> ```
>
> `simp` が閉じない場合は `simp only [app, ih]` や `List.cons_append` を足して、残ったゴールを確認してください。
>
> </details>

## まとめ

- 再帰的データの証明 = 帰納法。ケースは **データ型の構成子の数** だけある。
- 必要な補題を見つけて先に証明するのが証明の腕。
- Lean は「すべての入力」について保証するが、**反例探しは自分でやる**。
