import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piggy Bank App',
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

  void addToBalance() {
    setState(() {
      double enteredAmount = double.tryParse(amountController.text) ?? 0.0;
      balance += enteredAmount;
      amountController.clear();
      balanceHistory.add(balance); // Add balance to history
    });
  }

  void removeFromBalance() {
    setState(() {
      double enteredAmount = double.tryParse(amountController.text) ?? 0.0;
      balance -= enteredAmount;
      amountController.clear();
      balanceHistory.add(balance); // Add balance to history
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Piggy Bank'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            '🐷 Piggy Bank 🐷',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(height: 20),
          Text(
            'Balance: \$${balance.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 24, color: Colors.black87),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0), // Adjusted padding
            child: TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: addToBalance,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                ),
                child: Text(
                  '+',
                  style: TextStyle(fontSize: 18, color: Colors.teal),
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: removeFromBalance,
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                ),
                child: Text(
                  '-',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.teal),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      balanceHistory.length,
                          (index) => FlSpot(index.toDouble(), balanceHistory[index]),
                    ),
                    isCurved: true,
                    // colors: [Colors.teal],
                    barWidth: 4,
                    belowBarData: BarAreaData(show: false),
                    aboveBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: false),
                  ),
                ],
                // titlesInAxis: [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}