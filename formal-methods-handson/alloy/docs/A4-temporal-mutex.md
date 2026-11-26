# A4. Alloy 6 の時相論理: 相互排他

モデル: `04_mutex.als`, `04b_mutex_buggy.als`

Alloy 6 で **可変な状態(`var`)と時相論理** が加わり、TLA+ のように「システムの振る舞い」を書けるようになりました。
L4(Lean)・T2/T3(TLA+)と同じ題材です。

## 1. 新しい要素

| 記法 | 意味 |
|---|---|
| `var` field / `var sig` | 時間とともに値が変わる関係 |
| `x'` | 次のステップの `x`(TLA+ の `x'` と同じ) |
| `always P` | 以後ずっと P |
| `eventually P` | いつか P |
| `after P` | 次のステップで P |
| `P until Q` | Q になるまで P |
| `historically` / `once` / `before` | 過去方向の演算子 |

実行(トレース)は **有限のステップ数のあと、ある時点にループして戻る(lasso)** 形です。
`check ... for 3 but 1..20 steps` で、トレースの長さを 1〜20 ステップに制限します。

## 2. モデル

```alloy
enum Pc { Idle, Trying, Crit }

sig Proc { var pc: one Pc }
one sig Lock { var holder: lone Proc }

pred init {
  all p: Proc | p.pc = Idle
  no Lock.holder
}

pred enter[p: Proc] {                   // test-and-set(確認と取得が 1 ステップ)
  p.pc = Trying
  no Lock.holder
  pc' = pc ++ (p -> Crit)               // p の行だけ上書き(他は不変 = フレーム条件)
  holder' = Lock -> p
}
...
fact traces {
  init and always (stutter or (some p: Proc | request[p] or enter[p] or leave[p]))
}
```

TLA+ との対応:

| TLA+ | Alloy 6 |
|---|---|
| `Init` | `pred init` |
| `Next` | `always (... or ... )` の各 pred |
| `[][Next]_vars` | `always (stutter or ...)`(`stutter` を明示) |
| `UNCHANGED x` | `x' = x` |
| `[pc EXCEPT ![p] = v]` | `pc ++ (p -> v)` |
| `INVARIANT P` | `assert { always P }` + `check` |
| 全アクション列を最短で探索 | SAT/SMT ソルバでトレースを探索 |

> [!NOTE]
> Alloy 6 は「遷移を書く fact」と「主張を書く assert」を **同じ言語** で書き、
> `check` は「fact を満たすトレースのうち、assert を破るものを探す」ことで動きます。

## 3. 検査する

```alloy
assert MutualExclusion { always (lone pc.Crit) }
check MutualExclusion for 3 but 1..20 steps
```

`pc.Crit` は「`Crit` 状態にいる Proc の集合」(`pc` は `Proc -> Pc` の関係。右側が `Crit` の組の左側)。
`lone` で「高々 1 人」。期待: **反例なし**(スコープ: Proc 3 個以内、トレース 20 ステップ以内)。

## 4. バグ版

`04b_mutex_buggy.als` では `enter` を `test`(確認だけ)と `setLock`(取得)に分けています。

```alloy
check MutualExclusion for 3 but 1..20 steps
```

→ **反例あり**。GUI の結果で **時間軸を進める(次ステップ `→`)** と、T2 の TLC トレースと同じ構造
「(両者 request →)p1 test → p2 test → p1 setLock → p2 setLock」が見えるはずです
(Alloy 版は `request` ステップがあるぶん、T2 より少し長い。状態数で 7 ほど)。

## 5. 活性: 公平性なしでは破れる

```alloy
assert NoStarvation {
  all p: Proc | always (p.pc = Trying implies eventually p.pc = Crit)
}
check NoStarvation for 3 but 1..20 steps
```

反例: `stutter` を永遠に繰り返す(何も起きない)トレース。**TLA+ の `SpecNoFair` と同じ理由** です。

Alloy 6 には `WF` / `SF` が組み込まれていないので、公平性は **自分で時相論理式として書きます**(演習 2)。

## 演習

1. `04b_mutex_buggy.als` の反例トレースを、T2 の TLC のトレースと並べて比べる。違いは?
2. `NoStarvation` を通すための公平性を `fact` として書く(下のヒント)。
3. `check MutualExclusion for 3 but 1..3 steps` と `1..20 steps` で、`04b`(バグ版)の結果が変わる?
   ステップ数の下限・上限と、反例の見つけやすさの関係を考える。
4. `Proc` を `for 8` にしても検査が現実的な時間で終わるか試す。TLC の状態爆発と比べる。

> [!NOTE]
> <details><summary>ヒント / 解答の方針</summary>
>
> 2. 例:
>
>    ```alloy
>    fact fairness {
>      // Crit にいるプロセスは、いつか leave する(WF 相当)
>      all p: Proc | always (p.pc = Crit implies eventually leave[p])
>      // Trying かつロックが空き、が何度も起きるなら、いつか enter する(SF 相当)
>      all p: Proc |
>        (always eventually (p.pc = Trying and no Lock.holder)) implies
>        (always eventually enter[p])
>    }
>    ```
>
>    こうすると `NoStarvation` が通るはず。TLA+ の `SpecSF` と対応している。
> 3. 反例には 7 状態ほど必要(request ×2、test ×2、setLock ×2)なので、上限 3 では見つからない
>    (`1..8` 程度なら見つかる)。
>    **有界検査の「境界」は、状態数のスコープとステップ数の両方にある**。
> 4. Alloy は SAT ソルバで探索するので、状態を列挙する TLC とは爆発の形が違う。
>    原子数・ステップ数が増えると SAT の問題サイズが増えるが、必ずしも指数的に増えるとは限らない
>    (ただし、大きいと現実的でなくなる点は同じ)。
>
> </details>

## まとめ

- Alloy 6 は `var` / `'` / `always` / `eventually` で TLA+ のような遷移系を書ける。
- 検査は **ステップ数とスコープ** の有界。TLC のような「全状態の完全探索」ではないが、反例は同様に出る。
- 公平性は自前の式として書く。
