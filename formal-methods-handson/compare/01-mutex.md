# 比較 1: ロック/相互排他プロトコル

2 プロセスの test-and-set ロック。**同じ設計** を 3 ツールで書き、バグ版も検査します。
(コードは各コースのファイルを使います)

| ツール | ファイル | 実行 |
|---|---|---|
| Lean | `lean/LeanHandson/L4_Mutex.lean` | `lake env lean LeanHandson/L4_Mutex.lean` |
| TLA+ | `tla/specs/Mutex.tla` `MutexBuggy.tla` | `tlc -config Mutex.cfg Mutex.tla` |
| Alloy | `alloy/04_mutex.als` `04b_mutex_buggy.als` | GUI で Execute All |

## 並べて読む

**状態と遷移 `enter`**

```lean
-- Lean
inductive Step : S → S → Prop
  | enter0 {p1} : Step ⟨false, p1, false⟩ ⟨true, p1, true⟩
```

```tla
\* TLA+
Enter(p) == /\ pc[p] = "idle" /\ ~lock
            /\ lock' = TRUE /\ pc' = [pc EXCEPT ![p] = "crit"]
```

```alloy
// Alloy 6
pred enter[p: Proc] {
  p.pc = Trying   no Lock.holder
  pc' = pc ++ (p -> Crit)   holder' = Lock -> p
}
```

**相互排他の性質**

```lean
theorem mutual_exclusion (h : Reach s) : ¬ (s.p0 = true ∧ s.p1 = true)    -- + 帰納的不変条件 Inv が必要
```

```tla
MutualExclusion == \A p, q \in Procs : p # q => ~(pc[p] = "crit" /\ pc[q] = "crit")   \* そのまま検査
```

```alloy
assert MutualExclusion { always (lone pc.Crit) }                                      // そのまま検査
```

## 結果の比較

| 観点 | Lean | TLA+ | Alloy |
|---|---|---|---|
| 正しい版の検査 | 帰納的不変条件を **発見して** 証明(`Inv` に補助条件が必要) | `INVARIANT` を書くだけ。数秒 | `check` を書くだけ。数秒 |
| 保証の範囲 | **プロセス数に依存しない形にできる**(L4 は 2 プロセスで固定だが一般化可) | 2〜3 プロセスのモデル | 3 Proc・20 ステップ以内 |
| バグ版 | 「到達可能な悪い状態」を **自分で構成** | **最短トレース** が自動で出る | トレースが自動で出る(ステップ送りで見る) |
| 活性(いつか入れる) | 標準では貧弱。自前の定義が必要 | **`WF`/`SF`/`~>`** で自然に書ける | `eventually` + 自前の公平性式 |
| 状態数が増えると | 影響なし(証明は状態を数えない) | 指数的に増える(対称性削減などで緩和) | SAT 次第 |

## この題材での結論

> [!IMPORTANT]
> **並行プロトコルのバグ探しは TLA+(または Alloy 6)が圧倒的に速い。**
> バグ版の反例が **自動で最短の手順として出る** からです。Lean ではこの体験は得られません。
>
> 一方で、**プロセス数が不定(N)・状態が無限** で「すべての N について正しい」と言いたいなら、
> Lean のような証明系が必要になります(TLC は N を固定した有限モデルしか見られない)。
>
> **公平性・活性の記述は TLA+ が最も自然**(言語に `WF`/`SF`/`~>` が組み込まれている)です。

## 発展課題

- Peterson のアルゴリズムを 3 ツールで書く。TLA+ では `flag[2]` と `turn` を使う。
- Lean で不変条件がなぜ強化されたのか(`LockHeld` 相当)、TLC ではなぜ不要だったのかを言葉で説明する。
