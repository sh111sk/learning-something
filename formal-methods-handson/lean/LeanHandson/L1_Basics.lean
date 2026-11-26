/-!
# L1: Lean の基本 ― 式・型・命題・タクティク

解説: `lean/docs/L1-basics.md` を参照。
`sorry` が残っている演習の `sorry` を消して通すのがゴール。
-/

/-! ## 1. 計算する(普通のプログラミング言語として) -/

#eval 1 + 2
#eval "Hello, " ++ "Lean"
#eval [1, 2, 3].map (fun x => x * x)

#check Nat
#check (1 : Nat)
#check @List.map
#print Nat

def double (n : Nat) : Nat := n * 2

#eval double 21

/-! ## 2. 命題を述べて、証明する -/

-- `example` は名前を付けない定理。`rfl` は「両辺が計算すると同じ」という証明。
example : double 21 = 42 := rfl

-- `by` 以降がタクティクブロック。ゴールを1歩ずつ小さくしていく。
theorem double_add (a b : Nat) : double (a + b) = double a + double b := by
  unfold double
  omega

-- 命題 = 型、証明 = その型の値(Curry-Howard)。関数として書くこともできる。
theorem and_swap (p q : Prop) : p ∧ q → q ∧ p := by
  intro ⟨hp, hq⟩
  exact ⟨hq, hp⟩

theorem and_swap' (p q : Prop) : p ∧ q → q ∧ p :=
  fun ⟨hp, hq⟩ => ⟨hq, hp⟩

theorem or_swap (p q : Prop) : p ∨ q → q ∨ p := by
  intro h
  cases h with
  | inl hp => exact Or.inr hp
  | inr hq => exact Or.inl hq

theorem imp_trans (p q r : Prop) (hpq : p → q) (hqr : q → r) : p → r :=
  fun hp => hqr (hpq hp)

theorem forall_and (α : Type) (P Q : α → Prop) :
    (∀ x, P x ∧ Q x) → (∀ x, P x) ∧ (∀ x, Q x) := by
  intro h
  constructor
  · intro x
    exact (h x).1
  · intro x
    exact (h x).2

example : ∃ n : Nat, n + 3 = 5 := ⟨2, rfl⟩

/-! ## 演習 -/

-- 演習 1-1
theorem ex1_and_assoc (p q r : Prop) : (p ∧ q) ∧ r ↔ p ∧ (q ∧ r) := by
  sorry

-- 演習 1-2
theorem ex2_double_eq (n : Nat) : double n = n + n := by
  sorry

-- 演習 1-3: 49 になる平方数を見つける(存在証明は「証拠」を渡す)
theorem ex3_square : ∃ n : Nat, n * n = 49 := by
  sorry

-- 演習 1-4: 対偶(`¬` は `→ False` のこと)
theorem ex4_contra (p q : Prop) : (p → q) → (¬ q → ¬ p) := by
  sorry
