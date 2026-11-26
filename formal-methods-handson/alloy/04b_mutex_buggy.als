module mutex_buggy

/*
 * A4: バグ版。「確認(test)」と「取得(set)」を別ステップに分けると相互排他が破れる。
 * Alloy が反例トレース(Alloy 6 ではステップごとの状態遷移)を出すことを確認する。
 */

enum Pc { Idle, Trying, Ready, Crit }

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

// 確認: 空いているのを見て Ready へ(ロックはまだ取らない)
pred test[p: Proc] {
  p.pc = Trying
  no Lock.holder
  pc' = pc ++ (p -> Ready)
  holder' = holder
}

// 取得: Ready の人が取る(他の人が先に取っていても気にしない = バグ)
pred setLock[p: Proc] {
  p.pc = Ready
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
  init and always (stutter or (some p: Proc |
    request[p] or test[p] or setLock[p] or leave[p]))
}

assert MutualExclusion { always (lone pc.Crit) }
check MutualExclusion for 3 but 1..20 steps
