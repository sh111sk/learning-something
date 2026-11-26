/-!
# L4: 状態遷移系と不変条件 ― TLA+ / Alloy と同じ題材を Lean で

2 プロセスの test-and-set ロックを「状態」「遷移」「到達可能性」で書き、
相互排他を **帰納的不変条件** で証明する。
TLC が「全状態を数える」ところを、Lean では「帰納法で一撃」にする。
-/

namespace Mutex

structure S where
  p0 : Bool     -- プロセス 0 が臨界区間にいる
  p1 : Bool     -- プロセス 1 が臨界区間にいる
  lock : Bool   -- ロックが取られている
  deriving Repr

/-- 遷移関係。test-and-set は「lock が空いていることの確認」と「取得」が不可分。 -/
inductive Step : S → S → Prop
  | enter0 {p1 : Bool} : Step ⟨false, p1, false⟩ ⟨true, p1, true⟩
  | enter1 {p0 : Bool} : Step ⟨p0, false, false⟩ ⟨p0, true, true⟩
  | leave0 {p1 l : Bool} : Step ⟨true, p1, l⟩ ⟨false, p1, false⟩
  | leave1 {p0 l : Bool} : Step ⟨p0, true, l⟩ ⟨p0, false, false⟩

/-- 初期状態から遷移を繰り返して到達できる状態(= TLC が探索する集合)。 -/
inductive Reach : S → Prop
  | init : Reach ⟨false, false, false⟩
  | step {s t : S} : Reach s → Step s t → Reach t

/-- 帰納的不変条件。「相互排他」そのままでは帰納的にならないので、
    「臨界区間にいるなら lock が立っている」を足して強くしてある。 -/
def Inv (s : S) : Prop :=
  (s.p0 = true → s.lock = true) ∧
  (s.p1 = true → s.lock = true) ∧
  ¬ (s.p0 = true ∧ s.p1 = true)

theorem inv_step {s t : S} (hs : Step s t) (h : Inv s) : Inv t := by
  cases hs <;> simp_all [Inv]

theorem inv_reach {s : S} (h : Reach s) : Inv s := by
  induction h with
  | init => simp [Inv]
  | step _ hs ih => exact inv_step hs ih

/-- 相互排他: 到達可能などの状態でも、2 人同時に臨界区間にはいない。 -/
theorem mutual_exclusion {s : S} (h : Reach s) : ¬ (s.p0 = true ∧ s.p1 = true) :=
  (inv_reach h).2.2

end Mutex

/-! ## バグ版: 「確認」と「取得」を分けると何が起きるか

lock の確認だけして取得しない遷移(= チェックと取得が別ステップ)を入れると、
2 人同時に入れてしまう。TLC/Alloy は反例トレースを出すが、
Lean では「到達可能な悪い状態」を自分で構成して示す。 -/

namespace MutexBuggy

open Mutex (S)

inductive Step : S → S → Prop
  -- lock を見ずに入る(チェック済みとみなして、lock の値が古い状況を模している)
  | enter0 {p1 l : Bool} : Step ⟨false, p1, l⟩ ⟨true, p1, true⟩
  | enter1 {p0 l : Bool} : Step ⟨p0, false, l⟩ ⟨p0, true, true⟩

inductive Reach : S → Prop
  | init : Reach ⟨false, false, false⟩
  | step {s t : S} : Reach s → Step s t → Reach t

/-! ## 演習 -/

-- 演習 4-1: 2 人同時に臨界区間にいる状態に到達できることを示す
theorem buggy_violates : ∃ s : S, Reach s ∧ s.p0 = true ∧ s.p1 = true := by
  sorry

end MutexBuggy

/-! 演習 4-2(任意): Mutex に「プロセスが 3 人」の版を作って不変条件を証明する。
    状態は `Fin 3 → Bool` を使う。どこが面倒になるか観察しよう。 -/
