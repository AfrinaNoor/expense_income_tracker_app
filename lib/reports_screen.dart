import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String selectedPeriod = 'Daily';
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser; // Get current user
    if (currentUser == null) {
      print("Error: User not logged in.");
    } else {
      print("User ID: ${currentUser!.uid}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Report',
          style: TextStyle(fontSize: 22.0),
        ),
        backgroundColor: Colors.purple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _fetchTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Error fetching transactions: ${snapshot.error}");
            return Center(child: Text('Error loading data'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No transactions found.'));
          }

          // Parse transactions from Firestore
          List<QueryDocumentSnapshot> transactions = snapshot.data!.docs;

          // Filter transactions by the selected period
          List<QueryDocumentSnapshot> filteredTransactions =
          _getTransactionsForPeriod(transactions, selectedPeriod);

          if (filteredTransactions.isEmpty) {
            return Center(child: Text('No transactions found for $selectedPeriod.'));
          }

          // Calculate category sums
          Map<String, double> categorySums = _getCategorySums(filteredTransactions);

          // Generate PieChart sections
          List<PieChartSectionData> pieChartSections = categorySums.entries.map((entry) {
            return PieChartSectionData(
              value: entry.value,
              color: _getCategoryColor(entry.key),
              title: '${entry.value.toStringAsFixed(0)}',
            );
          }).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildToggleButton('Daily'),
                        _buildToggleButton('Weekly'),
                        _buildToggleButton('Monthly'),
                        _buildToggleButton('Yearly'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sections: pieChartSections,
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categorySums.keys.map((category) {
                      return Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            color: _getCategoryColor(category),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '$category: ${categorySums[category]?.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Fetch transactions for the current user
  Stream<QuerySnapshot> _fetchTransactions() {
    final userId = currentUser?.uid;

    if (userId == null) {
      print("Error: User not authenticated.");
      return Stream.empty();
    }

    print("Fetching transactions for user: $userId");

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Filter transactions based on the selected period
  List<QueryDocumentSnapshot> _getTransactionsForPeriod(
      List<QueryDocumentSnapshot> transactions, String period) {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (period) {
      case 'Daily':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Weekly':
        startDate = now.subtract(Duration(days: 7));
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'Yearly':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = DateTime(2000);
    }

    return transactions.where((tx) {
      DateTime txDate = (tx['date'] as Timestamp).toDate();
      return txDate.isAfter(startDate);
    }).toList();
  }

  // Calculate category sums
  Map<String, double> _getCategorySums(List<QueryDocumentSnapshot> transactions) {
    Map<String, double> categorySums = {};
    for (var tx in transactions) {
      String category = tx['category'] ?? 'Uncategorized';
      double amount = (tx['amount'] ?? 0.0).toDouble();
      categorySums[category] = (categorySums[category] ?? 0) + amount;
    }
    return categorySums;
  }

  // Get color based on category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Entertainment':
        return Colors.red;
      case 'Health':
        return Colors.pink;
      case 'Education':
        return Colors.green;
      case 'Bills':
        return Colors.purple;
      case 'Shopping':
        return Colors.brown;
      case 'Other':
        return Colors.grey;
      default:
        return Colors.grey.shade400;
    }
  }

  // Build toggle buttons for periods
  Widget _buildToggleButton(String period) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Chip(
          label: Text(
            period,
            style: TextStyle(
              color: selectedPeriod == period ? Colors.white : Colors.black,
            ),
          ),
          backgroundColor: selectedPeriod == period
              ? Colors.purple
              : Colors.grey.shade200,
        ),
      ),
    );
  }
}
