/-!
# 比較題材 3: 権限モデル ― Lean 版

Alloy の `^parent`(推移閉包)は Lean では自前で定義し、性質も自分で証明する。
-/

namespace Cmp

/-- 祖先関係(1 回以上 parent をたどる)。Alloy の `^parent` に相当。 -/
inductive Anc {G : Type} (parent : G → G → Prop) : G → G → Prop
  | base {a b : G} : parent a b → Anc parent a b
  | step {a b c : G} : parent a b → Anc parent b c → Anc parent a c

theorem Anc.trans {G : Type} {parent : G → G → Prop} {a b c : G} :
    Anc parent a b → Anc parent b c → Anc parent a c := by
  intro h1
  induction h1 with
  | base h => intro h2; exact Anc.step h h2
  | step h _ ih => intro h2; exact Anc.step h (ih h2)

structure Policy (U F : Type) where
  allow : U → F → Prop
  deny  : U → F → Prop

def Policy.canRead {U F : Type} (p : Policy U F) (u : U) (f : F) : Prop :=
  p.allow u f ∧ ¬ p.deny u f

/-- 拒否が常に優先される。Alloy の `DenyWins` に相当。 -/
theorem deny_wins {U F : Type} (p : Policy U F) (u : U) (f : F) :
    p.deny u f → ¬ p.canRead u f :=
  fun hd ⟨_, hnd⟩ => hnd hd

end Cmp
