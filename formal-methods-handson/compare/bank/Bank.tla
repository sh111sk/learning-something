------------------------------- MODULE Bank -------------------------------
\* 比較題材 4: 銀行口座の送金 ― TLA+ 版
\* 3 口座 × 初期 10。総額 30 が保存され、残高が負にならないことを全状態探索で検査する。
EXTENDS Integers, TLC

Accts == {"a", "b", "c"}

VARIABLE bal
vars == <<bal>>

Init == bal = [x \in Accts |-> 10]

\* 正しい送金: 残高の範囲内でのみ送れる
Transfer(from, to) ==
    /\ from # to
    /\ \E amt \in 1..bal[from] :
         bal' = [bal EXCEPT ![from] = @ - amt, ![to] = @ + amt]

\* バグ版: 残高を気にせず送れる(Next を NextBuggy に差し替えて試す)
TransferBuggy(from, to) ==
    /\ from # to
    /\ \E amt \in 1..10 :
         bal' = [bal EXCEPT ![from] = @ - amt, ![to] = @ + amt]

Next      == \E f, t \in Accts : Transfer(f, t)
NextBuggy == \E f, t \in Accts : TransferBuggy(f, t)

Spec      == Init /\ [][Next]_vars
SpecBuggy == Init /\ [][NextBuggy]_vars

TypeOK       == bal \in [Accts -> Int]
Conserved    == bal["a"] + bal["b"] + bal["c"] = 30
NonNegative  == \A x \in Accts : bal[x] >= 0
=============================================================================
