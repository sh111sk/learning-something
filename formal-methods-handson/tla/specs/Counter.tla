------------------------------ MODULE Counter ------------------------------
\* T4: PlusCal。共有カウンタを 2 プロセスが「読む → 書く」で +1 する。
\* ラベルごとに 1 ステップ(不可分)になる。Read と Write が別ラベル = 間に割り込まれる。
\*
\* 使い方:
\*   1) java -cp tla2tools.jar pcal.trans Counter.tla   ← BEGIN/END TRANSLATION が挿入される
\*   2) java -cp tla2tools.jar tlc2.TLC -config Counter.cfg Counter.tla
EXTENDS Naturals, TLC

(*--algorithm Counter
variables x = 0;

process (Inc \in 1..2)
variables tmp = 0;
begin
  Read:  tmp := x;
  Write: x := tmp + 1;
end process;

end algorithm; *)

\* ↓ pcal.trans が生成する部分(最初は何も書かなくてよい)

\* 全プロセスが終了したら x = 2 であるべき(これは破れる = lost update)
Correct == (\A self \in ProcSet : pc[self] = "Done") => x = 2
=============================================================================
