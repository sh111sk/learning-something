/-!
# L3: プログラムの仕様を証明する

「素朴な実装」と「高速な実装」が同じ結果を返すことを証明するのは、
Lean で最もよく使う検証パターン。
-/

namespace Handson

/-! ## 例 1: 末尾再帰版 sum と素朴版 sum -/

def sum : List Nat → Nat
  | [] => 0
  | x :: xs => x + sum xs

def sumAcc : List Nat → Nat → Nat
  | [], acc => acc
  | x :: xs, acc => sumAcc xs (acc + x)

-- `generalizing acc` が肝。acc を固定したまま帰納法すると ih が弱すぎて詰む。
theorem sumAcc_eq (xs : List Nat) (acc : Nat) : sumAcc xs acc = acc + sum xs := by
  induction xs generalizing acc with
  | nil => simp [sumAcc, sum]
  | cons x xs ih =>
    simp only [sumAcc, sum, ih]
    omega

theorem sumAcc_correct (xs : List Nat) : sumAcc xs 0 = sum xs := by
  rw [sumAcc_eq]
  omega

/-! ## 例 2: 条件を満たす要素の個数 -/

def count {α : Type} (p : α → Bool) : List α → Nat
  | [] => 0
  | x :: xs => (if p x then 1 else 0) + count p xs

theorem count_le_length {α : Type} (p : α → Bool) (xs : List α) :
    count p xs ≤ xs.length := by
  induction xs with
  | nil => simp [count]
  | cons x xs ih =>
    simp only [count, List.length_cons]
    split <;> omega

/-! ## 例 3: 構造体と Option で「失敗しうる関数」 -/

structure Account where
  balance : Nat
  deriving Repr

def withdraw (amt : Nat) (a : Account) : Option Account :=
  if amt ≤ a.balance then some { balance := a.balance - amt } else none

#eval withdraw 30 { balance := 100 }
#eval withdraw 300 { balance := 100 }

-- 「成功したなら残高は減っている」
theorem withdraw_le {amt : Nat} {a b : Account} (h : withdraw amt a = some b) :
    b.balance ≤ a.balance := by
  unfold withdraw at h
  split at h
  · injection h with h1
    subst h1
    show a.balance - amt ≤ a.balance
    omega
  · cases h

/-! ## 演習 -/

-- 演習 3-1: count は ++ に分配する
theorem count_append {α : Type} (p : α → Bool) (xs ys : List α) :
    count p (xs ++ ys) = count p xs + count p ys := by
  sorry

-- 演習 3-2: 長さを返す末尾再帰版 lenAcc を定義し、`lenAcc xs 0 = xs.length` を証明する
def lenAcc {α : Type} : List α → Nat → Nat
  | _, acc => acc  -- ← 間違った定義。正しく書き換えること

theorem lenAcc_correct {α : Type} (xs : List α) : lenAcc xs 0 = xs.length := by
  sorry

-- 演習 3-3: 出金に成功したら、出金額ぶん正確に減っている
theorem withdraw_exact {amt : Nat} {a b : Account} (h : withdraw amt a = some b) :
    b.balance + amt = a.balance := by
  sorry

end Handson
