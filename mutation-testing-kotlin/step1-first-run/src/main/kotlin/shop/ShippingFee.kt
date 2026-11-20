package shop

/**
 * 送料計算。ミューテーションテストの「最初の一歩」用のごく小さなクラス。
 *
 * ルール:
 *  - 合計金額が 5,000 円以上なら送料無料
 *  - それ未満なら 500 円
 *  - 会員(isMember)は送料が半額(切り捨て)
 */
class ShippingFee(private val baseFee: Int = BASE_FEE) {
    fun calculate(totalAmount: Int, isMember: Boolean): Int {
        if (totalAmount >= FREE_SHIPPING_THRESHOLD) {
            return 0
        }
        return if (isMember) baseFee / 2 else baseFee
    }

    companion object {
        const val FREE_SHIPPING_THRESHOLD = 5_000
        const val BASE_FEE = 500
    }
}
