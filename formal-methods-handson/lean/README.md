# コース A: Lean 4 ハンズオン

Lean 4 を「プログラミング言語 + 定理証明器」として、ゼロから学びます。
Mathlib は使わず、標準ライブラリのタクティク(`simp` / `omega` / `decide` / `induction`)だけで進めます。

## レッスン

| # | テーマ | 解説 | コード |
|---|---|---|---|
| L1 | 式・型・命題・タクティクの基本(Curry-Howard) | [L1](./docs/L1-basics.md) | `LeanHandson/L1_Basics.lean` |
| L2 | 帰納法: 「すべてのリスト」について証明する | [L2](./docs/L2-induction.md) | `LeanHandson/L2_Induction.lean` |
| L3 | プログラムの仕様証明(素朴版 = 高速版) | [L3](./docs/L3-programs.md) | `LeanHandson/L3_Programs.lean` |
| L4 | 状態遷移系と不変条件(相互排他を証明) | [L4](./docs/L4-mutex.md) | `LeanHandson/L4_Mutex.lean` |
| L5 | `decide`: 有限なら全探索(モデル検査との接点)と Lean の限界 | [L5](./docs/L5-decide.md) | `LeanHandson/L5_Decide.lean` |

## 進め方

1. 解説を読む → コードファイルを VS Code で開く。
2. **カーソルを動かしながら右ペイン(Infoview)のゴールを見る**。これが Lean 学習の 8 割。
3. 各ファイル末尾の「演習」の `sorry` を自分で埋める。解答は解説末尾の折りたたみ。
4. `lake env lean LeanHandson/Lx_*.lean` で検査(`sorry` が残っていると警告が出る)。

## 先に知っておくと楽な 5 つの事実

1. **命題は型、証明は値**。`p ∧ q` は「p の証明と q の証明のペア」という型。
2. `theorem foo : 主張 := by タクティク...` で「ゴールを小さくしていく」のが基本の書き方。
3. `sorry` は「あとで埋める穴」。穴が残った定理は **証明として未完成**(`#print axioms` で `sorryAx` が出る)。
4. 自動で閉じてくれる主力は `rfl`(計算で等しい)、`simp`(書き換え)、`omega`(線形整数算術)、`decide`(有限の全探索)。
5. 閉じてくれないとき、**何が残っているかを見る**のが最重要。`simp` を `simp only [...]` にして1歩ずつ進める。

## 用語

| 用語 | 意味 |
|---|---|
| ゴール | いま証明したい命題(`⊢ ...` で表示される) |
| 仮定(hypothesis) | 使える既知の事実(`h : ...`) |
| タクティク | ゴールを変形するコマンド(`intro`, `exact`, `cases`, `induction`, `simp`...) |
| カーネル | 最終的に証明を機械検査する小さな核。`sorry` や `native_decide` を使わなければ信頼できる |
