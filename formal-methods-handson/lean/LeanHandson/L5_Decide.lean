/-!
# L5: `decide` ― 有限なら全探索で証明できる(モデル検査との接点)

Lean の `decide` は「命題が判定可能(Decidable)なら、計算して True/False を確かめる」。
有限の範囲なら TLC / Alloy の「全部試す」と同じことを Lean の中でやれる。
ただしこれは **証明の一種**(カーネルが検査する)で、探索の網羅はプログラム任せではない。
-/

-- Bool の全組み合わせ
example : ∀ a b : Bool, (a && b) = (b && a) := by decide

-- 有界の自然数
example : ∀ n < 10, n * n < 100 := by decide

-- 偽の主張は否定が decide で示せる(反例 n = 10)
example : ¬ (∀ n < 20, n * n < 100) := by decide

-- L4 の不変条件が「強い」ことを、状態 8 通り全部で確認する
theorem inv_implies_mutex :
    ∀ p0 p1 l : Bool,
      ((p0 = true → l = true) ∧ (p1 = true → l = true) ∧ ¬ (p0 = true ∧ p1 = true)) →
      ¬ (p0 = true ∧ p1 = true) := by
  decide

-- 補足: 「相互排他だけ」は帰納的不変条件ではない。
-- 状態 ⟨p0 = true, p1 = false, lock = false⟩ は相互排他を満たすが、
-- この状態から enter1 すると p0 = p1 = true になり壊れる。
-- この状態は到達不能(臨界区間なのに lock が空)なので、
-- 到達不能な状態を排除する「強い不変条件」(L4 の Inv)が必要になる。
-- TLC はそもそも到達可能な状態しか見ないので、この手間がない。

-- 使った公理を確認する。`sorry` を含むと `sorryAx` が出る。
#print axioms inv_implies_mutex

/-! ## 演習 -/

-- 演習 5-1: 3 変数の Bool で、次を decide で示す(分配則)
theorem ex1_distrib : ∀ a b c : Bool, (a && (b || c)) = ((a && b) || (a && c)) := by
  sorry

-- 演習 5-2: 「n < 8 なら 2^n ≥ n*n」は偽(n = 3 で 8 < 9)。decide で否定を示す。
--   さらに、n = 5 以上に限定した版 `∀ n, 5 ≤ n → n < 30 → 2^n ≥ n*n` が decide で通ることも確認する。
theorem ex2_find : ¬ (∀ n < 8, 2 ^ n ≥ n * n) := by
  sorry
