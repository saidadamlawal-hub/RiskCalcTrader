import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculation History"),
        actions: [
          if (state.history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Clear History"),
                    content: const Text("Are you sure you want to delete all historical logs?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                      TextButton(
                        onPressed: () {
                          state.clearHistory();
                          Navigator.pop(ctx);
                        },
                        child: const Text("Clear", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: state.history.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text("No records yet. Completed calculations will list here dynamically.", textAlign: TextAlign.center),
              ),
            )
          : ListView.builder(
              itemCount: state.history.length,
              itemBuilder: (context, i) {
                final item = state.history[i];
                final isBuy = item.direction == "BUY / LONG";

                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => state.deleteFromHistory(item.id),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isBuy ? Colors.green[900] : Colors.red[900],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(isBuy ? "BUY" : "SELL", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text("${item.instrument} | Size: ${item.positionSize.toStringAsFixed(2)}"),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text("Risked: ${state.formatCurrency(item.riskAmount)} (${item.riskPercent}%)"),
                          Text("Entry: ${item.entryPrice} | SL: ${item.stopLoss}"),
                          if (item.takeProfit != null) Text("Target TP: ${item.takeProfit}"),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("R:R", style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                          Text(item.riskRewardRatio, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
