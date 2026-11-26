/-!
# L2: 帰納法 ― 「すべてのリスト」について証明する

標準ライブラリの `List.reverse` / `++` と名前が衝突しないよう、
自前の関数は `app` / `myRev` という名前にしている。
-/

namespace Handson

variable {α : Type}

/-! ## 自前の append -/

def app : List α → List α → List α
  | [], ys => ys
  | x :: xs, ys => x :: app xs ys

#eval app [1, 2] [3, 4]

theorem app_nil (xs : List α) : app xs [] = xs := by
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [app, ih]

-- simp が最後まで閉じるか分からないときは `simp only` + `omega` が確実。
theorem app_length (xs ys : List α) :
    (app xs ys).length = xs.length + ys.length := by
  induction xs with
  | nil => simp [app]
  | cons x xs ih =>
    simp only [app, List.length_cons, ih]
    omega

/-! ## 自前の reverse(素朴版: O(n^2)) -/

def myRev : List α → List α
  | [] => []
  | x :: xs => myRev xs ++ [x]

#eval myRev [1, 2, 3]

theorem myRev_append (xs ys : List α) :
    myRev (xs ++ ys) = myRev ys ++ myRev xs := by
  induction xs with
  | nil => simp [myRev]
  | cons x xs ih => simp [myRev, ih, List.append_assoc]

theorem myRev_myRev (xs : List α) : myRev (myRev xs) = xs := by
  induction xs with
  | nil => simp [myRev]
  | cons x xs ih => simp [myRev, myRev_append, ih]

theorem myRev_length (xs : List α) : (myRev xs).length = xs.length := by
  induction xs with
  | nil => simp [myRev]
  | cons x xs ih => simp [myRev, ih]

/-! ## 演習 -/

-- 演習 2-1: app は結合的
theorem app_assoc (xs ys zs : List α) :
    app (app xs ys) zs = app xs (app ys zs) := by
  sorry

-- 演習 2-2: app は標準の ++ と同じ
theorem app_eq_append (xs ys : List α) : app xs ys = xs ++ ys := by
  sorry

-- 演習 2-3: 偽の主張。反例を示して否定する(L5 の decide が使える)
theorem myRev_not_id : ¬ (∀ xs : List Nat, myRev xs = xs) := by
  sorry

end Handson
