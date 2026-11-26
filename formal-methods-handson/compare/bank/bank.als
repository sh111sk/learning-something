module bank

/*
 * 比較題材 4: 銀行口座の送金 ― Alloy 6 版
 * 3 口座・初期残高 10。Int のビット幅(overflow)がモデルの一部になる点に注意。
 */

sig Account { var bal: one Int }

pred init { all a: Account | a.bal = 10 }

pred transfer[from, to: Account, amt: Int] {
  from != to
  amt > 0
  amt =< from.bal                      // ← バグ版では、この行を消してみる
  from.bal' = minus[from.bal, amt]
  to.bal'   = plus[to.bal, amt]
  all a: Account - (from + to) | a.bal' = a.bal
}

pred stutter { all a: Account | a.bal' = a.bal }

fact traces {
  init and always (stutter or (some f, t: Account, n: Int | transfer[f, t, n]))
}

// 総額保存。Int は 7 ビット(-64..63)あれば合計 30 を表現できる
assert Conserved { always ((sum a: Account | a.bal) = 30) }
check Conserved for exactly 3 Account, 7 Int, 1..10 steps

assert NonNegative { always (all a: Account | a.bal >= 0) }
check NonNegative for exactly 3 Account, 7 Int, 1..10 steps
