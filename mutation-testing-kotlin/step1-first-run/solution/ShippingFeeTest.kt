package shop

import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * 模範解答: 生き残りミュータントを全て殺すテスト。
 * 使い方: このファイルを src/test/kotlin/shop/ShippingFeeTest.kt に上書きコピーして再度 `./gradlew pitest`。
 */
class ShippingFeeTest {
    private val sut = ShippingFee()

    @Test
    fun `高額な注文は送料無料`() {
        assertEquals(0, sut.calculate(totalAmount = 10_000, isMember = false))
    }

    // 境界値: ちょうど閾値 → 無料 (>= を > に変えられると失敗する)
    @Test
    fun `閾値ちょうどは送料無料`() {
        assertEquals(0, sut.calculate(totalAmount = 5_000, isMember = false))
    }

    // 境界値の一つ下 → 有料 (>= を < や <= 系に変えられると失敗する)
    @Test
    fun `閾値の1円下は送料がかかる`() {
        assertEquals(500, sut.calculate(totalAmount = 4_999, isMember = false))
    }

    @Test
    fun `会員の送料は半額`() {
        assertEquals(250, sut.calculate(totalAmount = 1_000, isMember = true))
    }

    @Test
    fun `会員でも閾値以上は無料`() {
        assertEquals(0, sut.calculate(totalAmount = 5_000, isMember = true))
    }

    @Test
    fun `半額は切り捨て`() {
        assertEquals(125, ShippingFee(baseFee = 251).calculate(totalAmount = 0, isMember = true))
    }
}
