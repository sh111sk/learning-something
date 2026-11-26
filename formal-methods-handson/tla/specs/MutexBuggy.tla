---------------------------- MODULE MutexBuggy ----------------------------
\* T2: バグ版。「確認」と「取得」を別ステップに分けた(非 test-and-set)。
\* TLC が反例(2 人とも crit に入るトレース)を出すことを確認する。
EXTENDS Naturals, TLC

CONSTANT Procs

VARIABLES pc, lock
vars == <<pc, lock>>

Init == /\ pc = [p \in Procs |-> "idle"]
        /\ lock = FALSE

\* ステップ 1: ロックが空いているのを「見る」だけ
Test(p) == /\ pc[p] = "idle"
           /\ ~lock
           /\ pc' = [pc EXCEPT ![p] = "ready"]
           /\ UNCHANGED lock

\* ステップ 2: 見たあとで取る(その間に他のプロセスが動けてしまう)
SetLock(p) == /\ pc[p] = "ready"
              /\ lock' = TRUE
              /\ pc' = [pc EXCEPT ![p] = "crit"]

Leave(p) == /\ pc[p] = "crit"
            /\ lock' = FALSE
            /\ pc' = [pc EXCEPT ![p] = "idle"]

Next == \E p \in Procs : Test(p) \/ SetLock(p) \/ Leave(p)

Spec == Init /\ [][Next]_vars

MutualExclusion ==
    \A p, q \in Procs : (p # q) => ~(pc[p] = "crit" /\ pc[q] = "crit")
=============================================================================
