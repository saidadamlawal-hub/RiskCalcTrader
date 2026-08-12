package com.riskcalctrader.app

object CalculatorEngine {
    fun calculateRiskAmount(balance: Double, riskPercent: Double) = balance * (riskPercent / 100.0)

    fun calculatePositionSize(riskAmount: Double, slDistance: Double, contractSize: Double): Double {
        return if (slDistance <= 0.0) 0.0 else riskAmount / (slDistance * contractSize)
    }
}
