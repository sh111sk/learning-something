/-!
# 比較題材 4: 銀行口座の送金 ― Lean 版

2 口座。総額保存を **任意の残高・任意の送金額** について証明する。
(TLA+ は具体的な合計 30 で全状態探索、Alloy は 3 口座・小さい整数範囲で探索)
-/

namespace Bank

abbrev St := Nat × Nat   -- (口座 a の残高, 口座 b の残高)

/-- a から b へ amt 送金する。残高不足なら遷移しない。 -/
inductive Transfer (amt : Nat) : St → St → Prop
  | ab {a b : Nat} : amt ≤ a → Transfer amt (a, b) (a - amt, b + amt)
  | ba {a b : Nat} : amt ≤ b → Transfer amt (a, b) (a + amt, b - amt)

inductive Reach (init : St) : St → Prop
  | refl : Reach init init
  | step {s t : St} {amt : Nat} : Reach init s → Transfer amt s t → Reach init t

theorem transfer_conserves {amt : Nat} {s t : St} (h : Transfer amt s t) :
    s.1 + s.2 = t.1 + t.2 := by
  cases h with
  | ab hle => dsimp only; omega
  | ba hle => dsimp only; omega

/-- 何回送金しても総額は変わらない(到達可能なすべての状態で) -/
theorem reach_conserves {init s : St} (h : Reach init s) : s.1 + s.2 = init.1 + init.2 := by
  induction h with
  | refl => rfl
  | step _ ht ih =>
    have := transfer_conserves ht
    omega

/-! 演習 B-1: `Transfer` の `amt ≤ a` を外したバグ版を作る(Nat の引き算は 0 で止まる)。
    どの定理が証明できなくなるか? 反例の状態を自分で見つけて `example` で示す。
    演習 B-2: 3 口座に拡張すると、遷移の場合分けがどう増えるか観察する(`Fin 3 → Nat` を使う)。
-/

end Bank
