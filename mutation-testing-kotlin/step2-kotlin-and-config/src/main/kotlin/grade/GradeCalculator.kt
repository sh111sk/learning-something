package grade

enum class Grade { A, B, C, F }

/**
 * 点数 → 成績の判定。Kotlin の `when`・null 安全・コレクション操作を使った題材。
 *
 *  - 90 以上: A / 70 以上: B / 50 以上: C / それ未満: F
 *  - 点数が null(未受験)の場合は null を返す
 *  - 点数が 0..100 の範囲外なら IllegalArgumentException
 */
class GradeCalculator {
    fun grade(score: Int?): Grade? {
        if (score == null) return null
        require(score in 0..100) { "score must be 0..100: $score" }
        return when {
            score >= 90 -> Grade.A
            score >= 70 -> Grade.B
            score >= 50 -> Grade.C
            else -> Grade.F
        }
    }

    /** 平均点(未受験 null は除外)。受験者がいなければ 0.0 */
    fun average(scores: List<Int?>): Double {
        val taken = scores.filterNotNull()
        if (taken.isEmpty()) return 0.0
        return taken.sum().toDouble() / taken.size
    }

    /** 合格者(C 以上)の人数 */
    fun passedCount(scores: List<Int?>): Int =
        scores.count { grade(it)?.let { g -> g != Grade.F } ?: false }

    /** step を n 回足す。ループ境界(`i < n`)の変異を n = 0 のケースで殺す練習用 */
    fun sumOfFirst(n: Int, step: Int): Int {
        var total = 0
        var i = 0
        while (i < n) {
            total += step
            i++
        }
        return total
    }
}
