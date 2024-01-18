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
  List<double> balanceHistory = []; // New list to store balance history
  TextEditingController amountController = TextEditingController();
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  bool emptyAmountCheck(){
    if (amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
        ),
      );
      return true;
    }
    return false;
  }

  void addToBalance() async {
    if (emptyAmountCheck()) {
      return;
    }
    setState(() {
      double enteredAmount = double.tryParse(amountController.text) ?? 0.0;
      balance += enteredAmount;
      amountController.clear();
      balanceHistory.add(balance); // Add balance to history
    });
    await dbHelper.insertBalance(balance);
  }

  void removeFromBalance() async {
    if (emptyAmountCheck()) {
      return;
    }
    setState(() {
      double enteredAmount = double.tryParse(amountController.text) ?? 0.0;
      balance -= enteredAmount;
      amountController.clear();
      balanceHistory.add(balance); // Add balance to history
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
            padding: const EdgeInsets.symmetric(horizontal: 48.0), // Adjusted padding
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
              ElevatedButton(
                onPressed: addToBalance,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                ),
                child: const Text(
                  '+',
                  style: TextStyle(fontSize: 18, color: Colors.teal),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: removeFromBalance,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                ),
                child: const Text(
                  '-',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 180,
            padding: const EdgeInsets.all(30),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: false,
                  border: Border.all(color: Colors.teal),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      balanceHistory.length,
                          (index) => FlSpot(index.toDouble(), balanceHistory[index]),
                    ),
                    isCurved: false,
                    color: Colors.teal,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: false),
                    aboveBarData: BarAreaData(show: false),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}