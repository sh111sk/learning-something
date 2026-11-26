/-!
# 比較題材 2: リスト反転 ― Lean 版

主張: 「2 回反転すると元に戻る」「反転は連結の順序を逆にする」。
Lean は **すべての長さ・すべての要素型** について 1 度で証明する。
-/

namespace Cmp

variable {α : Type}

def rev : List α → List α
  | [] => []
  | x :: xs => rev xs ++ [x]

theorem rev_append (xs ys : List α) : rev (xs ++ ys) = rev ys ++ rev xs := by
  induction xs with
  | nil => simp [rev]
  | cons x xs ih => simp [rev, ih, List.append_assoc]

theorem rev_rev (xs : List α) : rev (rev xs) = xs := by
  induction xs with
  | nil => simp [rev]
  | cons x xs ih => simp [rev, rev_append, ih]

-- 偽の主張は「証明できない」だけでは分からない。反例を自分で見つけて否定する。
theorem rev_not_id : ¬ (∀ xs : List Nat, rev xs = xs) :=
  fun h => absurd (h [0, 1]) (by decide)

end Cmp
