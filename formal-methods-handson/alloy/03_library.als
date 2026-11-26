module library

/*
 * A3: スコープ・反例の読み方・不変条件 ― 状態を sig にした古典的スタイル(Alloy 5 以前の書き方)
 * 題材: 図書館の貸出。「1 冊は同時に 1 人まで」「1 人 3 冊まで」が貸出操作で保たれるか。
 */

sig Book {}
sig Member {}
sig State { borrowed: Member -> Book }

pred inv[s: State] {
  all b: Book | lone s.borrowed.b            // 1 冊を借りている人は高々 1 人
  all m: Member | #(s.borrowed[m]) =< 3      // 1 人 3 冊まで
}

pred borrow[s, s2: State, m: Member, b: Book] {
  b not in Member.(s.borrowed)               // まだ誰にも借りられていない本
  s2.borrowed = s.borrowed + m -> b
}

// 「不変条件を満たす状態から borrow すると、また不変条件を満たす」
assert BorrowPreservesInv {
  all s, s2: State, m: Member, b: Book |
    inv[s] and borrow[s, s2, m, b] implies inv[s2]
}

// スコープが小さすぎると反例が見つからない。3 と 5 を試して違いを確かめる。
check BorrowPreservesInv for 3
check BorrowPreservesInv for 5

// 修正: borrow の事前条件に「まだ 3 冊未満」を足す
// pred borrow ... { #(s.borrowed[m]) < 3  ... }
