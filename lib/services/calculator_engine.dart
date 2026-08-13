import 'dart:math';

class CalculationResult {
  final double riskAmount;
  final double slDistance;
  final double positionSize;
  final double units;
  final double potentialLoss;
  final double potentialProfit;
  final String riskReward;

  CalculationResult({
    required this.riskAmount,
    required this.slDistance,
    required this.positionSize,
    required this.units,
    required this.potentialLoss,
    required this.potentialProfit,
    required this.riskReward,
  });
}

class CalculatorEngine {
  static CalculationResult calculate({
    required double balance,
    required double riskPercent,
    required double entry,
    required double sl,
    double? tp,
    required String direction,
    required String instrument,
    required double contractSize,
  }) {
    final double riskAmount = balance * (riskPercent / 100.0);
    final double slDistance = (entry - sl).abs();

    if (slDistance == 0) {
      return CalculationResult(
        riskAmount: riskAmount,
        slDistance: 0,
        positionSize: 0,
        units: 0,
        potentialLoss: 0,
        potentialProfit: 0,
        riskReward: "—",
      );
    }

    double positionSize = 0.0;
    double units = 0.0;

    if (instrument == "Forex") {
      positionSize = riskAmount / (slDistance * contractSize);
      units = positionSize * contractSize;
    } else if (instrument == "Crypto" || instrument == "Stocks" || instrument == "Custom") {
      units = riskAmount / slDistance;
      positionSize = units / contractSize;
    } else {
      positionSize = riskAmount / (slDistance * contractSize);
      units = positionSize * contractSize;
    }

    final double potentialLoss = riskAmount;
    double potentialProfit = 0.0;
    String rrRatio = "—";

    if (tp != null && tp > 0) {
      if (direction == "BUY / LONG") {
        potentialProfit = units * (tp - entry);
      } else {
        potentialProfit = units * (entry - tp);
      }

      if (potentialLoss > 0) {
        final double ratioVal = potentialProfit / potentialLoss;
        rrRatio = "1 : ${ratioVal.toStringAsFixed(1)}";
      }
    }

    return CalculationResult(
      riskAmount: riskAmount,
      slDistance: slDistance,
      positionSize: positionSize,
      units: units,
      potentialLoss: potentialLoss,
      potentialProfit: potentialProfit,
      riskReward: rrRatio,
    );
  }
}
