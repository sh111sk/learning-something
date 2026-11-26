module reverse
open util/sequniv

/*
 * 比較題材 2: リスト反転 ― Alloy 版
 * 関数として定義するより「a と b は互いの反転である」という関係として書くのが Alloy 流。
 */

sig Elem {}

pred isRev[a, b: seq Elem] {
  #a = #b
  all i: a.inds | b[i] = a[minus[minus[#a, 1], i]]
}

// 2 回反転すると元に戻る(スコープ内の全ての列で検査)
assert RevInvolution {
  all a, b, c: seq Elem | isRev[a, b] and isRev[b, c] implies a = c
}
check RevInvolution for 4

// 偽の主張: 「反転しても同じ」 → 要素が 2 種類以上あれば反例
assert RevIsId { all a, b: seq Elem | isRev[a, b] implies a = b }
check RevIsId for 4
