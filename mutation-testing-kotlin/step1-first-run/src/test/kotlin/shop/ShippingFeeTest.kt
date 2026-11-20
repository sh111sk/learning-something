package shop

import kotlin.test.Test
import kotlin.test.assertEquals

/**
 * わざと「弱い」テスト。行カバレッジは 100% に近いが、境界値や会員分岐を十分に検証していない。
 * → PIT を走らせると生き残る(SURVIVED)ミュータントが出る。
 */
class ShippingFeeTest {
    private val sut = ShippingFee()

    @Test
    fun `高額な注文は送料無料`() {
        assertEquals(0, sut.calculate(totalAmount = 10_000, isMember = false))
    }

    @Test
    fun `少額な注文は送料がかかる`() {
        assertEquals(500, sut.calculate(totalAmount = 1_000, isMember = false))
    }

    @Test
    fun `会員でも計算できる`() {
        // 戻り値を検証していない(例外が出ないことしか見ていない)
        sut.calculate(totalAmount = 1_000, isMember = true)
    }
}
