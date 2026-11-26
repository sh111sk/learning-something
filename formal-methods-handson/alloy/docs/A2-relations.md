# A2. 関係論理: join・閉包・集合演算で権限モデルを検査

モデル: `02_permissions.als`

## 1. Alloy の本質は「関係」

Alloy では **集合も関数もリストもすべて関係** です。値は 1 次元の関係(集合)、field は 2 次元以上の関係。
この統一が、式を短く保つ秘密です。

| 演算 | 記法 | 例 |
|---|---|---|
| join(結合) | `a.b` | `u.member` = `u` が属するグループの集合 |
| 転置 | `~r` | `~member` = (Group -> User) |
| 推移閉包 | `^r`(1回以上)/ `*r`(0回以上) | `g.^parent` = `g` の全ての祖先 |
| 積 | `a -> b` | `p -> Trying` = 組 |
| 上書き | `r ++ s` | Alloy 6 の状態更新(A4) |
| 集合演算 | `+` `&` `-` | 和・積・差 |
| 比較 | `in` `=` `!=` | 部分集合・等しい |

### join が一番大事

`a.r` は「`a` から関係 `r` をたどった先」。`u.member.*parent` は次のように読みます。

```
u               User の 1 要素
u.member        u が属するグループの集合
u.member.*parent   それらのグループと、その全ての祖先グループの集合(* = 0回以上)
```

プログラミングでいう「配列のループ・map・flatMap・再帰」が **1 つの式** になります。
(Lean では推移閉包を自分で定義して推移性まで証明、TLA+ では再帰を自作。→ compare)

## 2. モデル

```alloy
sig Group { parent: lone Group }
sig User  { member: set Group }
sig File  { owner: one User, readers: set Group, denied: set User }

fun effectiveGroups[u: User]: set Group { u.member.*parent }

pred canRead[u: User, f: File] {
  u not in f.denied
  u = f.owner or some (effectiveGroups[u] & f.readers)
}
```

- 権限は **グループ階層を継承** する(子グループのメンバーは、祖先グループに許可されたファイルも読める)。
- 拒否リスト `denied` は許可より優先。
- pred の本体の複数行は **すべて満たす(and)** という意味。

## 3. 検査する

### (1) 成り立つはずの主張

```alloy
assert DenyWins { all u: User, f: File | u in f.denied implies not canRead[u, f] }
check DenyWins for 5
```

→ 反例なし(`No counterexample found`)。

### (2) 偽の主張 ― 反例を読む

```alloy
assert OnlyDirectMembers {
  all u: User, f: File |
    (canRead[u, f] and u != f.owner) implies some (u.member & f.readers)
}
check OnlyDirectMembers for 5
```

→ **反例が出ます**。想定される反例の図: `User$0` は `Group$0` のメンバー、`Group$0.parent = Group$1`、
`File$0.readers = Group$1`。`User$0` は直接のメンバーではないが親グループ経由で読める。

「継承があるのだから当たり前」と気付く人は多いはずですが、**実際のアクセス制御の設計では、
こういう『継承による予想外の許可』が頻繁に脆弱性になります**。

### (3) run で例を出す

```alloy
run { some u: User, f: File | canRead[u, f] and u != f.owner and no (u.member & f.readers) } for 4
```

「継承によって読めるケースの具体例を見せて」。

## 4. Table 表示を使う

図が複雑なときは GUI の結果ウィンドウで **Table** 表示に切り替えると、
`member` や `readers` の中身が `Group$0 -> ...` の一覧で見えます。

## 演習

1. 「**拒否リストにあるユーザは、ファイルの所有者でも読めない**」ことは `DenyWins` で保証されている。
   この仕様は適切か? 「所有者は常に読める」という要件と衝突するので、`canRead` を直して `DenyWins` を
   「所有者以外の拒否ユーザ」に限定して検査する。
2. **グループ階層に循環** があると何が起きるか? `NoGroupCycle` を消して `check DenyWins` を実行。
   結果は変わる? `^parent` や `*parent` は循環があっても有限で終わる(閉包は有限関係)ことに注目。
3. 「子グループのメンバー全員は、親グループのメンバーでもある」という逆方向の継承(上方向継承)に変えると、
   `OnlyDirectMembers` の反例はどう変わる?
4. ファイルに `sig Dir` を追加し、権限をディレクトリから継承する(`File.dir.readers`)モデルに拡張する。

> [!NOTE]
> <details><summary>ヒント / 解答の方針</summary>
>
> 1. `canRead` を `u = f.owner or (u not in f.denied and some (effectiveGroups[u] & f.readers))` に直し、
>    `DenyWins` を `u in f.denied and u != f.owner implies not canRead[u, f]` に。
> 2. 閉包 `^parent` は関係の有限集合なので終了する。`DenyWins` 自体は循環に依存しないので結果は変わらない。
>    ただし「祖先に自分が含まれる」奇妙な世界が出現する。**現実にあり得ない世界を排除するのが fact の役目**。
> 3. 祖先ではなく子孫方向をたどる式 `u.member.*(~parent)` に変える。`~parent` は parent の転置(子方向)。
>
> </details>

## まとめ

- Alloy の式は `join`(`.`)と閉包で、構造のたどり方を 1 行で書ける。
- 偽の主張を `check` して反例を見ることで、**設計の誤解** が見つかる。
- 「複雑な継承・委譲のルール」は Alloy の得意中の得意。
