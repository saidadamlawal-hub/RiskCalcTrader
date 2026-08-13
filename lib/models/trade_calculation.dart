class TradeCalculation {
  final String id;
  final DateTime dateTime;
  final String instrument;
  final String direction; 
  final double accountBalance;
  final double riskPercent;
  final double entryPrice;
  final double stopLoss;
  final double? takeProfit;
  final double positionSize;
  final double riskAmount;
  final double potentialProfit;
  final String riskRewardRatio;

  TradeCalculation({
    required this.id,
    required this.dateTime,
    required this.instrument,
    required this.direction,
    required this.accountBalance,
    required this.riskPercent,
    required this.entryPrice,
    required this.stopLoss,
    this.takeProfit,
    required this.positionSize,
    required this.riskAmount,
    required this.potentialProfit,
    required this.riskRewardRatio,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'instrument': instrument,
        'direction': direction,
        'accountBalance': accountBalance,
        'riskPercent': riskPercent,
        'entryPrice': entryPrice,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit,
        'positionSize': positionSize,
        'riskAmount': riskAmount,
        'potentialProfit': potentialProfit,
        'riskRewardRatio': riskRewardRatio,
      };

  factory TradeCalculation.fromJson(Map<String, dynamic> json) =>
      TradeCalculation(
        id: json['id'],
        dateTime: DateTime.parse(json['dateTime']),
        instrument: json['instrument'],
        direction: json['direction'],
        accountBalance: json['accountBalance'].toDouble(),
        riskPercent: json['riskPercent'].toDouble(),
        entryPrice: json['entryPrice'].toDouble(),
        stopLoss: json['stopLoss'].toDouble(),
        takeProfit: json['takeProfit'] != null ? json['takeProfit'].toDouble() : null,
        positionSize: json['positionSize'].toDouble(),
        riskAmount: json['riskAmount'].toDouble(),
        potentialProfit: json['potentialProfit'].toDouble(),
        riskRewardRatio: json['riskRewardRatio'],
      );
}
