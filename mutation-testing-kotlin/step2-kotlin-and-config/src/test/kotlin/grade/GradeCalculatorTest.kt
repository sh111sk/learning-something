package grade

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

/** わざと弱いテスト。代表値しか見ておらず、境界値・例外・集計の細部が未検証。 */
class GradeCalculatorTest {
    private val sut = GradeCalculator()

    @Test
    fun `代表的な点数の成績`() {
        assertEquals(Grade.A, sut.grade(95))
        assertEquals(Grade.B, sut.grade(80))
        assertEquals(Grade.C, sut.grade(60))
        assertEquals(Grade.F, sut.grade(10))
    }

    @Test
    fun `未受験はnull`() {
        assertNull(sut.grade(null))
    }

    @Test
    fun `平均点が計算できる`() {
        assertNotNull(sut.average(listOf(80, null, 60)))
    }

    @Test
    fun `合格者数が数えられる`() {
        assertEquals(2, sut.passedCount(listOf(95, 60, 10)))
    }

    @Test
    fun `sumOfFirst`() {
        assertEquals(6, sut.sumOfFirst(3, 2))
    }
}
