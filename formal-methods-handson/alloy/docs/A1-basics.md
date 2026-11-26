# A1. Alloy の基本: sig / field / fact / run / check

モデル: `01_filesystem.als`

## 1. 構造を宣言する

```alloy
abstract sig Obj { parent: lone Dir }   // Obj は親を 0 または 1 個持つ
sig Dir extends Obj {}
sig File extends Obj {}
one sig Root extends Dir {}             // Root はちょうど 1 個
```

| 記法 | 意味 |
|---|---|
| `sig A {}` | 原子の集合 `A` |
| `sig B extends A {}` | `B` は `A` の部分集合(`B` 同士は互いに素) |
| `abstract sig` | 直接の要素を持たない(サブ sig だけが要素を持つ) |
| `one / lone / some sig` | 要素数がちょうど 1 / 0か1 / 1以上 |
| field `f: one A` | 各要素に `A` の要素がちょうど 1 つ |
| `lone` / `some` / `set` | 0か1 / 1以上 / 制限なし |

field は **関係**(`Obj -> Dir` の集合)で、`o.parent` は「`o` の親の集合」です。

## 2. 制約を書く

```alloy
fact RootHasNoParent { no Root.parent }                   // no X = X は空
fact Acyclic { no o: Obj | o in o.^parent }               // ^ は推移閉包
```

- `no x`: 集合 `x` が空。`some x`: 空でない。`lone x`: 高々 1 つ。`one x`: ちょうど 1 つ。
- `all o: Obj | ...`(全称)/ `some o: Obj | ...`(存在)。
- `o.^parent`: `o` から parent を **1 回以上** たどって到達できる要素の集合(`*parent` は 0 回以上)。
- `in`: 部分集合。`=`: 集合として等しい。`+`(和)`&`(積)`-`(差)。

## 3. 世界を眺める: run

```alloy
pred show {}
run show for 4
```

「制約を満たす世界を 1 つ見せて」。**まず `run` でモデルの形を目で見る** のが Alloy の基本動作です。
Next で次の解を出して、「想定外の世界(例: ディレクトリが孤立している)」を探しましょう。

## 4. 主張を検査する: check

```alloy
assert AllReachRoot { all o: Obj - Root | Root in o.^parent }
check AllReachRoot for 5
```

「`Root` 以外の全員が root に到達できる」を検査すると、**反例が出ます**。

反例の読み方(予想): `Root` ではないのに **親を持たない** `Obj`(例: 親なしの `File$0` や `Dir$0`)がいる。
→ **孤立した要素・孤立した木が存在できる**。
`fact RootHasNoParent` は「Root に親はいない」としか言っていませんが、
「Root 以外は必ず親がいる」とは言っていないのです。

## 5. モデルを直して再検査

`01_filesystem.als` 末尾のコメントアウトされた fact を有効にします。

```alloy
fact OnlyRootIsOrphan { all o: Obj | no o.parent implies o = Root }
```

再度 `check AllReachRoot for 5` → 反例なし。

> [!IMPORTANT]
> 「反例が出る → モデル(制約)の不足に気付く → 直す → 再検査」のサイクルが Alloy の学習・設計の全てです。
> 仕様を書く前に頭の中にあった前提(= 暗黙の仮定)が、反例によって **明示化** されます。

## 演習

1. `Acyclic` を消して `check AllReachRoot for 5` を実行すると、反例は変わる? 変わるなら何が出る?
2. 「ディレクトリの深さは高々 3」という制約を、`fact` として書いてみる(ヒント: `#` は要素数)。
3. 「ファイルは直下に `Dir` を持てない」ではなく、`File` が **親になれない** のはなぜ(どの宣言のおかげ)?
4. `check` を `for 1` に変えても反例は見つかる? 最小の反例はどんな世界?(スコープと反例の関係に気付く。A3 で再訪)

> [!NOTE]
> <details><summary>ヒント / 解答の方針</summary>
>
> 1. 循環(`Dir$0` の親が `Dir$1`、`Dir$1` の親が `Dir$0`)があり、Root に到達できないインスタンスが出る。
> 2. 例: `fact { all o: Obj | #(o.^parent) =< 3 }`(深さ = 祖先の数)。`=<` が「以下」。
> 3. `parent: lone Dir` と宣言されているため、parent の値は `Dir` 型の要素に限られる。**型が構造制約になる**。
> 4. `for 1` でも見つかる。`Root` と、親を持たない `File` の 2 原子(各 sig 1 個以内)で十分。
>    反例が **小さい世界で出る** ことが多い(小スコープ仮説)ことの実例。
>    逆に、必要な原子数がスコープを超える反例は見逃される(A3 で体験)。
>
> </details>

## まとめ

- `sig` / field で構造、`fact` で制約、`run` で世界を観察、`check` で主張を検査。
- 反例 = モデルの不足の指摘。直して再検査する。
