------------------------------ MODULE Reverse ------------------------------
\* 比較題材 2: リスト反転 ― TLA+ 版
\* TLC は「小さい範囲の全列」を数え上げて ASSUME を検査する(証明ではなく網羅テスト)。
EXTENDS Naturals, Sequences, TLC

Elems == 0..1                      \* 要素の候補(増やすと爆発する)

Rev(s) == [i \in 1..Len(s) |-> s[Len(s) - i + 1]]

SeqsUpTo(n) == UNION {[1..k -> Elems] : k \in 0..n}

ASSUME \A s \in SeqsUpTo(5) : Rev(Rev(s)) = s
ASSUME \A s, t \in SeqsUpTo(3) : Rev(s \o t) = Rev(t) \o Rev(s)

\* 偽の主張を試す: 下の行のコメントを外すと TLC が反例を出して止まる
\* ASSUME \A s \in SeqsUpTo(3) : Rev(s) = s

\* TLC は Init/Next が無いと動かないので、何も起きない仕様を置く
VARIABLE x
Init == x = 0
Next == x' = x
Spec == Init /\ [][Next]_x
=============================================================================
