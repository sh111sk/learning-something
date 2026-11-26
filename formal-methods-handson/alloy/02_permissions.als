module permissions

/*
 * A2: 関係論理 ― join(.)、閉包(^ *)、集合演算、量化子
 * 題材: グループ階層つきのファイルアクセス権限
 */

sig Group { parent: lone Group }
sig User  { member: set Group }
sig File  {
  owner:   one User,
  readers: set Group,   // 読み取りを許可されたグループ
  denied:  set User     // 明示的に拒否されたユーザ
}

fact NoGroupCycle { no g: Group | g in g.^parent }

// ユーザが属するグループ + その祖先グループ(* は 0 回以上の推移閉包)
fun effectiveGroups[u: User]: set Group { u.member.*parent }

pred canRead[u: User, f: File] {
  u not in f.denied
  u = f.owner or some (effectiveGroups[u] & f.readers)
}

// 1) 拒否リストが常に優先される(成り立つはず)
assert DenyWins {
  all u: User, f: File | u in f.denied implies not canRead[u, f]
}
check DenyWins for 5

// 2) 「owner 以外が読めるなら、直接そのグループのメンバーのはず」(偽の主張!)
//    反例を見て、親グループの継承が原因だと確かめる
assert OnlyDirectMembers {
  all u: User, f: File |
    (canRead[u, f] and u != f.owner) implies some (u.member & f.readers)
}
check OnlyDirectMembers for 5

// 3) 例が欲しいとき: run で具体例を出させる
run { some u: User, f: File | canRead[u, f] and u != f.owner and no (u.member & f.readers) } for 4
