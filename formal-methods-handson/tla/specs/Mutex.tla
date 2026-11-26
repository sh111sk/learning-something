------------------------------ MODULE Mutex ------------------------------
\* T2: test-and-set ロックによる相互排他。
\* 「ロックが空いているか確認する」と「ロックを取る」を **1 ステップ(不可分)** で行う。
EXTENDS Naturals, TLC

CONSTANT Procs          \* プロセスの集合(cfg でモデル値を割り当てる)

VARIABLES pc, lock
vars == <<pc, lock>>

Init == /\ pc = [p \in Procs |-> "idle"]
        /\ lock = FALSE

Enter(p) == /\ pc[p] = "idle"
            /\ ~lock
            /\ lock' = TRUE
            /\ pc' = [pc EXCEPT ![p] = "crit"]

Leave(p) == /\ pc[p] = "crit"
            /\ lock' = FALSE
            /\ pc' = [pc EXCEPT ![p] = "idle"]

Next == \E p \in Procs : Enter(p) \/ Leave(p)

Spec == Init /\ [][Next]_vars

-----------------------------------------------------------------------------
\* 検査したい性質

TypeOK == /\ pc \in [Procs -> {"idle", "crit"}]
          /\ lock \in BOOLEAN

\* 安全性: 2 つの異なるプロセスが同時に crit にいてはいけない
MutualExclusion ==
    \A p, q \in Procs : (p # q) => ~(pc[p] = "crit" /\ pc[q] = "crit")

\* 補助的な不変条件: crit にいるなら lock は取られている
LockHeld == \A p \in Procs : pc[p] = "crit" => lock

\* 状態爆発対策(T5)で使う対称性。プロセスの名前を入れ替えても同じ状態とみなす
Perms == Permutations(Procs)
=============================================================================
