---------------------------- MODULE MutexLive ----------------------------
\* T3: 活性(liveness)と公平性(fairness)。
\* 「ロックを待っているプロセスは、いつか必ず crit に入れる」を検査する。
EXTENDS Naturals, TLC

CONSTANT Procs

VARIABLES pc, lock
vars == <<pc, lock>>

Init == /\ pc = [p \in Procs |-> "idle"]
        /\ lock = FALSE

Request(p) == /\ pc[p] = "idle"
              /\ pc' = [pc EXCEPT ![p] = "trying"]
              /\ UNCHANGED lock

Enter(p) == /\ pc[p] = "trying"
            /\ ~lock
            /\ lock' = TRUE
            /\ pc' = [pc EXCEPT ![p] = "crit"]

Leave(p) == /\ pc[p] = "crit"
            /\ lock' = FALSE
            /\ pc' = [pc EXCEPT ![p] = "idle"]

Next == \E p \in Procs : Request(p) \/ Enter(p) \/ Leave(p)

\* 公平性なし: 何も起きずに止まり続ける実行(stuttering)も許してしまう
SpecNoFair == Init /\ [][Next]_vars

\* 弱公平性(WF): 「ずっと実行可能であり続ける」アクションは、いつか実行される
SpecWF == Init /\ [][Next]_vars
          /\ \A p \in Procs : WF_vars(Leave(p)) /\ WF_vars(Enter(p))

\* 強公平性(SF): 「何度も実行可能になる」アクションは、いつか実行される
SpecSF == Init /\ [][Next]_vars
          /\ \A p \in Procs : WF_vars(Leave(p)) /\ SF_vars(Enter(p))

MutualExclusion ==
    \A p, q \in Procs : (p # q) => ~(pc[p] = "crit" /\ pc[q] = "crit")

\* 活性: trying なら、いつか crit(~> は「leads to」)
Liveness == \A p \in Procs : (pc[p] = "trying") ~> (pc[p] = "crit")
=============================================================================
