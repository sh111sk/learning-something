package grade

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull

/** 模範解答。src/test/kotlin/grade/GradeCalculatorTest.kt に上書きコピーして `./gradlew pitest`。 */
class GradeCalculatorTest {
    private val sut = GradeCalculator()

    @Test
    fun `境界値の成績`() {
        assertEquals(Grade.A, sut.grade(90))
        assertEquals(Grade.B, sut.grade(89))
        assertEquals(Grade.B, sut.grade(70))
        assertEquals(Grade.C, sut.grade(69))
        assertEquals(Grade.C, sut.grade(50))
        assertEquals(Grade.F, sut.grade(49))
        assertEquals(Grade.F, sut.grade(0))
        assertEquals(Grade.A, sut.grade(100))
    }

    @Test
    fun `未受験はnull`() {
        assertNull(sut.grade(null))
    }

    @Test
    fun `範囲外は例外`() {
        assertFailsWith<IllegalArgumentException> { sut.grade(-1) }
        assertFailsWith<IllegalArgumentException> { sut.grade(101) }
    }

    @Test
    fun `平均点は null を除いて計算する`() {
        assertEquals(70.0, sut.average(listOf(80, null, 60)))
        assertEquals(2.5, sut.average(listOf(2, 3)))
    }

    @Test
    fun `受験者がいなければ平均は0`() {
        assertEquals(0.0, sut.average(emptyList()))
        assertEquals(0.0, sut.average(listOf(null, null)))
    }

    @Test
    fun `合格者数は未受験とFを除く`() {
        assertEquals(3, sut.passedCount(listOf(95, 60, 50, 49, null)))
        assertEquals(0, sut.passedCount(emptyList()))
    }

    @Test
    fun `sumOfFirst`() {
        assertEquals(6, sut.sumOfFirst(3, 2))
        assertEquals(0, sut.sumOfFirst(0, 2))
    }
}
