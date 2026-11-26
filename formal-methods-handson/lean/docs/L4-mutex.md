# L4. 状態遷移系と不変条件: 相互排他を Lean で証明する

コード: `LeanHandson/L4_Mutex.lean`

TLA+ や Alloy 6 のコースでも同じ題材(2 プロセスの test-and-set ロック)を扱います。
ここでは **TLC が全状態を数え上げる性質を、Lean では帰納法で証明する** のを体験します。

## 1. システムを Lean でモデル化する

```lean
structure S where
  p0 : Bool     -- プロセス 0 が臨界区間にいる
  p1 : Bool
  lock : Bool

inductive Step : S → S → Prop        -- 遷移関係(TLA+ の Next に相当)
  | enter0 {p1} : Step ⟨false, p1, false⟩ ⟨true, p1, true⟩
  | enter1 {p0} : Step ⟨p0, false, false⟩ ⟨p0, true, true⟩
  | leave0 {p1 l} : Step ⟨true, p1, l⟩ ⟨false, p1, false⟩
  | leave1 {p0 l} : Step ⟨p0, true, l⟩ ⟨p0, false, false⟩

inductive Reach : S → Prop           -- 到達可能な状態(TLC が探索する集合)
  | init : Reach ⟨false, false, false⟩
  | step {s t} : Reach s → Step s t → Reach t
```

- `Step s t` は「s から t へ 1 ステップで遷移できる」。`enter0` は `lock = false` の状態にしか
  適用できない(確認と取得が **不可分**)。
- `Reach` は **帰納的に定義された集合**。「初期状態は到達可能」「到達可能な状態から遷移した先も到達可能」。

## 2. 示したい性質

```lean
theorem mutual_exclusion {s : S} (h : Reach s) : ¬ (s.p0 = true ∧ s.p1 = true)
```

「到達可能などの状態でも、2 人同時に臨界区間にはいない」。

## 3. 帰納的不変条件

`Reach` についての帰納法で示すには、**遷移で保たれる** 性質が必要です。
ところが「2 人同時にいない」だけでは遷移で保たれることが言えません
(`⟨true, false, false⟩`: p0 が臨界区間なのに lock が空 → そこから `enter1` できてしまう。
ただしこの状態は実際には到達不能)。

そこで **強い不変条件** を用意します。

```lean
def Inv (s : S) : Prop :=
  (s.p0 = true → s.lock = true) ∧       -- 臨界区間にいるなら lock が立っている
  (s.p1 = true → s.lock = true) ∧
  ¬ (s.p0 = true ∧ s.p1 = true)         -- 本命
```

1. `Inv` が **遷移で保たれる**: `Step s t → Inv s → Inv t`
2. `Inv` が **初期状態で成り立つ**
3. したがって `Reach s → Inv s`(`Reach` についての帰納法)
4. `Inv` から本命を取り出す

```lean
theorem inv_step {s t : S} (hs : Step s t) (h : Inv s) : Inv t := by
  cases hs <;> simp_all [Inv]

theorem inv_reach {s : S} (h : Reach s) : Inv s := by
  induction h with
  | init => simp [Inv]
  | step _ hs ih => exact inv_step hs ih
```

> [!IMPORTANT]
> **ここが Lean と TLC の最大の違いです。**
> TLC は到達可能な状態だけを全部たどるので、`MutualExclusion` だけ書けば足ります。
> Lean(を含む演繹的な検証)では **帰納的不変条件を自分で発見** しなければなりません。
> 一方で、この証明は「プロセス数が 2 でも 100 でも」「状態がどれだけ巨大でも」成り立つ形にできます
> (TLC は状態数が爆発すると終わらない)。

> [!TIP]
> `cases hs <;> simp_all [Inv]` が通らないときの定石:
> `cases hs` の後に `<;> rename_i ...` で名前を付け、`Bool` の変数を `cases` で `true`/`false` に分け、
> `simp [Inv] at *` で調べる。各ゴールを 1 つずつ見て、どの仮定が効くかを確かめます。

## 4. バグ版を作ってみる

`enter0` から `lock = false` の条件を外すと(= 確認を飛ばす)、`Inv` は遷移で保たれません。
実際、2 人同時に入った状態に **到達できる** ことを示せます(演習 4-1)。
TLC / Alloy は反例トレースを **自動で出す** が、Lean では **自分で構成する**。

## 演習

- 4-1 `MutexBuggy` で `∃ s, Reach s ∧ s.p0 = true ∧ s.p1 = true` を示す
- 4-2(任意)3 プロセス版(状態を `Fin 3 → Bool` にする)。どこが面倒になるか観察

> [!NOTE]
> <details><summary>解答 4-1(まず自力で)</summary>
>
> `init → enter0 → enter1` の順に遷移すれば `⟨true, true, true⟩` に到達します。
>
> ```lean
> theorem buggy_violates : ∃ s : S, Reach s ∧ s.p0 = true ∧ s.p1 = true := by
>   refine ⟨⟨true, true, true⟩, ?_, rfl, rfl⟩
>   exact Reach.step (Reach.step Reach.init Step.enter0) Step.enter1
> ```
>
> 型推論で通らない場合は、中間状態を明示します。
>
> ```lean
>   have h1 : Reach ⟨true, false, true⟩ := Reach.step Reach.init Step.enter0
>   exact Reach.step h1 Step.enter1
> ```
>
> </details>

## まとめ

- 状態遷移系も Lean では「データ型 + 帰納的関係」として普通に書ける。
- 不変条件の証明 = 「遷移で保たれる」「初期状態で成り立つ」を示す帰納法。**強い不変条件を見つけるのが人間の仕事**。
- 反例は自動では出ない。**探索の自動化(TLC/Alloy)と一般性(Lean)のトレードオフ** が見えた。
