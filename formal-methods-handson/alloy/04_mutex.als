module mutex

/*
 * A4: Alloy 6 の時相論理(var / always / eventually / プライム記法)
 * 題材: test-and-set ロックの相互排他(TLA+ の Mutex.tla、Lean の L4_Mutex.lean と同じもの)
 */

enum Pc { Idle, Trying, Crit }

sig Proc { var pc: one Pc }
one sig Lock { var holder: lone Proc }

pred init {
  all p: Proc | p.pc = Idle
  no Lock.holder
}

pred request[p: Proc] {
  p.pc = Idle
  pc' = pc ++ (p -> Trying)
  holder' = holder
}

// test-and-set: 「空いているか確認」と「取得」が 1 ステップ
pred enter[p: Proc] {
  p.pc = Trying
  no Lock.holder
  pc' = pc ++ (p -> Crit)
  holder' = Lock -> p
}

pred leave[p: Proc] {
  p.pc = Crit
  pc' = pc ++ (p -> Idle)
  no holder'
}

pred stutter { pc' = pc and holder' = holder }

fact traces {
  init and always (stutter or (some p: Proc | request[p] or enter[p] or leave[p]))
}

// 安全性: 同時に Crit にいるのは高々 1 人(pc.Crit = Crit にいるプロセスの集合)
assert MutualExclusion { always (lone pc.Crit) }
check MutualExclusion for 3 but 1..20 steps

// 補助: Crit にいるプロセスがロックの保持者
assert HolderConsistent { always (all p: Proc | p.pc = Crit implies Lock.holder = p) }
check HolderConsistent for 3 but 1..20 steps

// 活性: Trying なら、いつか Crit(公平性の仮定がないと破れる ― 演習 A4-2)
assert NoStarvation {
  all p: Proc | always (p.pc = Trying implies eventually p.pc = Crit)
}
check NoStarvation for 3 but 1..20 steps

// 到達可能性の確認: 誰かが Crit に入る実行が存在する(モデルが空っぽでないことの確認)
run SomeoneEnters { eventually (some p: Proc | p.pc = Crit) } for 3 but 1..20 steps
