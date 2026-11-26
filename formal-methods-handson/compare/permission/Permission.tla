---------------------------- MODULE Permission ----------------------------
\* 比較題材 3: 権限モデル ― TLA+ 版
\* TLA+ には推移閉包が組み込まれていないので、再帰で自前定義する(有限の深さに限定)。
EXTENDS Naturals, FiniteSets, TLC

Groups == {"dev", "staff", "org"}

\* group -> 親 group("none" は親なし)。レコード = 文字列をキーにした関数
Parent == [dev |-> "staff", staff |-> "org", org |-> "none"]

RECURSIVE Anc(_, _)
Anc(g, n) ==
    IF n = 0 \/ Parent[g] = "none"
    THEN {}
    ELSE {Parent[g]} \cup Anc(Parent[g], n - 1)

ASSUME Anc("dev", 3) = {"staff", "org"}
ASSUME Anc("org", 3) = {}

\* 推移性: 祖先の祖先も祖先
ASSUME \A g \in Groups : \A h \in Anc(g, 3) : Anc(h, 3) \subseteq Anc(g, 3)

\* 注: これは「この具体的な 3 グループの階層」についての検査。
\* 任意の階層について言いたければ Alloy(スコープ内で全階層を探索)か Lean(証明)が向く。

VARIABLE x
Init == x = 0
Next == x' = x
Spec == Init /\ [][Next]_x
=============================================================================
