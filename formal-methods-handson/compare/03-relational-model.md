# 比較 3: ファイルシステム/権限(関係モデル)

題材: グループ階層つきのアクセス権限。「拒否が優先」「親グループの許可を継承」。

| ツール | ファイル | 実行 |
|---|---|---|
| Alloy | `alloy/02_permissions.als` | GUI で Execute All |
| Lean | `compare/permission/Permission.lean` | `lean/` から `lake env lean ../compare/permission/Permission.lean` |
| TLA+ | `compare/permission/Permission.tla` `.cfg` | `tlc -config Permission.cfg Permission.tla` |

## 「祖先をたどる」を書く

```alloy
// Alloy: 1 行
fun effectiveGroups[u: User]: set Group { u.member.*parent }
```

```tla
\* TLA+: 再帰を自作(深さ n まで)
RECURSIVE Anc(_, _)
Anc(g, n) == IF n = 0 \/ Parent[g] = "none" THEN {}
             ELSE {Parent[g]} \cup Anc(Parent[g], n - 1)
```

```lean
-- Lean: 推移閉包を帰納型として自分で定義(Anc.trans も自分で証明)
inductive Anc (parent : G → G → Prop) : G → G → Prop
  | base : parent a b → Anc parent a b
  | step : parent a b → Anc parent b c → Anc parent a c
```

**同じ「閉包」が、Alloy は 1 記号(`*parent`)、TLA+ は再帰関数、Lean は帰納型 + 証明**。
ここに各ツールの設計思想の違いがそのまま出ます。

## 「拒否が優先」を示す

```alloy
assert DenyWins { all u: User, f: File | u in f.denied implies not canRead[u, f] }
check DenyWins for 5          // 反例なし(スコープ内)
```

```lean
theorem deny_wins (p : Policy U F) (u : U) (f : F) : p.deny u f → ¬ p.canRead u f :=
  fun hd ⟨_, hnd⟩ => hnd hd    -- 数行で「すべての U, F」について証明
```

## 偽の主張で反例を探す

```alloy
assert OnlyDirectMembers { ... }   // 偽
check OnlyDirectMembers for 5      // ← 即座に反例(継承ケースの図)が出る
```

Lean では「偽」と分かっても、**反例の構成は自分で** 行う必要があります。
TLA+ では、同様の検査を `ASSUME` で書けるが、**具体的な階層(3 グループ固定)** についてしか検査していません。

## 比較

| 観点 | Alloy | Lean | TLA+ |
|---|---|---|---|
| 構造の記述 | ◎ `sig` と関係。閉包・転置・join が標準 | ○ 型・構造体・帰納型。閉包は自作 | △ 集合・関数・レコード。閉包は自作 |
| **任意の階層** について | 小スコープ(5 個以内)の **全階層** を探索 | **すべての階層** について証明 | **決め打ちの 1 階層** のみ(`cfg` で定数を変えて複数試すことは可) |
| 反例 | ◎ 図で出る | ✗ | ○(トレースではなく `ASSUME` 違反の表示) |
| 記述量 | 少ない(約 30 行) | 多い(閉包の定義と補題) | 中 |
| 時間・遷移の扱い | Alloy 6 で可 | 自前 | ◎(だがこの題材では不要) |

## この題材での結論

> [!IMPORTANT]
> **構造・関係・ルールの検査は Alloy の領分** です。
>
> - 閉包・join で式が短く、**反例の図** が人間の議論を助ける。「この階層でこの人が読めてしまう」と図で見せれば、
>   非エンジニアのレビュワーとも議論できる。
> - 「小さなスコープでの網羅」で十分なことが多い(設計の抜けは小さな構成で露呈する)。
>
> **「どんな階層でも必ず成り立つ」ことを保証したい** なら Lean(`Anc.trans` のような補題つき)。
> TLA+ は **時間とともに変化するシステム**(権限の付与・剥奪の操作列など)を扱うときに力を発揮するので、
> この題材では静的な構造検査としては不向きです。

## 発展課題

- Alloy に `grant` / `revoke` を Alloy 6 の `var` で足し、「revoke 後は読めない」を `check`(時間つきの権限)。
- 同じことを TLA+ で書くと、どのくらい自然になるか試す(TLA+ はこちらの方が得意)。
