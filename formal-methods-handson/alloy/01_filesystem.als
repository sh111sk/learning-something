module filesystem

/*
 * A1: Alloy の基本 ― sig / field / fact / run / check
 * 題材: ディレクトリ木。「全てのファイルとディレクトリは root にたどり着ける」を検査する。
 */

abstract sig Obj { parent: lone Dir }   // lone = 0 個か 1 個
sig Dir extends Obj {}
sig File extends Obj {}
one sig Root extends Dir {}             // one = ちょうど 1 個

// root には親がいない
fact RootHasNoParent { no Root.parent }

// 親をたどって自分自身に戻ってはいけない(^ は 1 回以上の推移閉包)
fact Acyclic { no o: Obj | o in o.^parent }

// --- モデルが「どんな世界」を許すか眺める ---
pred show {}
run show for 4

// --- 検査したい主張 ---
assert AllReachRoot { all o: Obj - Root | Root in o.^parent }
check AllReachRoot for 5
// ↑ 最初は反例が出る。なぜか? 反例を見て考え、下の fact を追加して再実行する。

// 追加する fact(最初はコメントアウトしておく):
// fact OnlyRootIsOrphan { all o: Obj | no o.parent implies o = Root }
