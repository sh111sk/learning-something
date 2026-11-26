# 比較 2: リスト反転(純粋関数)

主張: 「2 回反転すると元に戻る」「反転は連結の順序を逆にする」。

| ツール | ファイル | 実行 |
|---|---|---|
| Lean | `compare/reverse/Reverse.lean` | `lake env lean ../compare/reverse/Reverse.lean`(`lean/` ディレクトリから) |
| TLA+ | `compare/reverse/Reverse.tla` `.cfg` | `tlc -config Reverse.cfg Reverse.tla` |
| Alloy | `compare/reverse/reverse.als` | GUI で Execute All |

## 3 つの書き方

```lean
-- Lean: 関数として定義し、すべてのリストについて証明
def rev : List α → List α
  | [] => []
  | x :: xs => rev xs ++ [x]

theorem rev_rev (xs : List α) : rev (rev xs) = xs := by ...   -- 補題 rev_append を先に証明
```

```tla
\* TLA+: 小さな範囲(長さ ≤ 5, 要素 0/1)の全列を数え上げて検査
Rev(s) == [i \in 1..Len(s) |-> s[Len(s) - i + 1]]
ASSUME \A s \in SeqsUpTo(5) : Rev(Rev(s)) = s
```

```alloy
// Alloy: 「a と b は互いの反転」という関係として書く(関数ではなく述語)
pred isRev[a, b: seq Elem] {
  #a = #b
  all i: a.inds | b[i] = a[minus[minus[#a, 1], i]]
}
assert RevInvolution { all a, b, c: seq Elem | isRev[a, b] and isRev[b, c] implies a = c }
```

## 比較

| 観点 | Lean | TLA+ | Alloy |
|---|---|---|---|
| 主張の範囲 | **すべての長さ・すべての要素型**(証明) | 長さ ≤ 5・要素 2 種の **全列**(網羅テスト) | 各 sig ≤ 4 個、長さ ≤ 4 の全列 |
| 労力 | 補題 `rev_append` を発見する必要あり | ほぼゼロ(数行) | 反転を **関係** で書く必要がある |
| 偽の主張(`rev xs = xs`) | 反例 `[0,1]` を **自分で** 見つけて否定を証明 | 反例を TLC が表示 | 反例を図で表示 |
| 実装との関係 | **この `rev` がそのまま実行できる**(`#eval rev [1,2,3]`) | モデルであって実装ではない | モデルであって実装ではない |
| 適性 | ◎ | △(列を数え上げるだけなら使える) | △(再帰が苦手で関係で書き直す) |

## この題材での結論

> [!IMPORTANT]
> **純粋関数の正しさは Lean の領分** です。
>
> - 再帰的に定義した関数が **プログラムとして実行可能** で、**その同じ定義** について「全入力で正しい」を証明できる。
> - TLA+/Alloy は **小さな範囲の網羅テスト** としては動くが、(1) 実装そのものではない、
>   (2) 範囲外は保証されない、(3) 再帰・帰納の表現が不自然、という限界がある。
>
> ただし、Lean は **証明を書く労力** が必要です。「とりあえず反例が欲しい」だけなら、
> TLA+ の `ASSUME` や Alloy の `check` の方が圧倒的に速い。
> Lean の `#eval` / `decide`(L5)で小さな範囲を確認してから証明に進むと効率的です。

## 発展課題

- 3 ツールで「ソート済みリストへの挿入が、ソート済みを保つ」を書く(Lean は帰納法、TLA+/Alloy は網羅)。
- Alloy で `seq` を使わず、`Elem -> Elem` の `next` 関係で連結リストを定義し直して反転を書く。
