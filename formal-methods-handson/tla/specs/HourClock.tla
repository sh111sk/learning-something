---------------------------- MODULE HourClock ----------------------------
\* T1: 最小の TLA+ 仕様。12 時間表示の時計。
EXTENDS Naturals

VARIABLE hr

Init == hr \in 1..12
Next == hr' = IF hr = 12 THEN 1 ELSE hr + 1

Spec == Init /\ [][Next]_hr

TypeOK == hr \in 1..12

THEOREM Spec => []TypeOK
=============================================================================
