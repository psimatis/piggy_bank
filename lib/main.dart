import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';

void main() => runApp(PiggyBank());

class PiggyBank extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piggy Bank App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: PiggyBankScreen(),
    );
  }
}

class PiggyBankScreen extends StatefulWidget {
  @override
  _PiggyBankScreenState createState() => _PiggyBankScreenState();
}

class _PiggyBankScreenState extends State<PiggyBankScreen> {
  double balance = 0.0;
  List<double> balanceHistory = [];
  TextEditingController amountController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  bool emptyAmountCheck() {
    String text = amountController.text.trim();
    if (text.isEmpty || double.tryParse(text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
        ),
      );
      amountController.clear();
      return true;
    }
    return false;
  }

  void updateBalance(String operator) async {
    if (emptyAmountCheck()) {
      return;
    }
    setState(() {
      double amount = double.tryParse(amountController.text) ?? 0.0;
      amountController.clear();
      balance = (operator == '+') ? balance + amount : balance - amount;
      balanceHistory.add(balance);
    });
    await dbHelper.insertBalance(balance);
  }

  @override
  void initState() {
    super.initState();
    dbHelper.getBalanceHistory().then((history) {
      setState(() {
        balanceHistory = history;
        balance = balanceHistory.last;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piggy Bank'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            '🐷 Piggy Bank 🐷',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 10),
          Text(
            'Balance: \$${balance.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 24, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              updateBalanceButton('+'),
              const SizedBox(width: 10),
              updateBalanceButton('-'),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 180,
            padding: const EdgeInsets.all(30),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  // leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: false,
                  border: Border.all(color: Colors.teal),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      balanceHistory.length,
                      (index) =>
                          FlSpot(index.toDouble(), balanceHistory[index]),
                    ),
                    isCurved: false,
                    color: Colors.teal,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: false),
                    aboveBarData: BarAreaData(show: false),
                    dotData: const FlDotData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton updateBalanceButton(String operator) {
    return ElevatedButton(
      onPressed: () => updateBalance(operator),
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
      ),
      child: Text(
        operator,
        style: const TextStyle(fontSize: 18, color: Colors.teal),
      ),
    );
  }
}
