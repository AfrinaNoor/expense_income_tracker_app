import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String selectedDateFilter = 'Today';
  String selectedCategoryFilter = 'All';
  String searchQuery = '';
  late User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Transaction History',
          style: TextStyle(fontSize: 22.0, color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          _buildDateFilters(),
          _buildCategoryFilters(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Transactions',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fetchTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No transactions found.'));
                }

                var transactions = snapshot.data!.docs.where((doc) {
                  final title = doc['title'].toString().toLowerCase();
                  final category = doc['category'].toString();
                  return title.contains(searchQuery.toLowerCase()) &&
                      (selectedCategoryFilter == 'All' ||
                          category == selectedCategoryFilter);
                }).toList();

                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Dismissible(
                      key: Key(transaction.id),
                      onDismissed: (direction) {
                        _deleteTransaction(transaction.id);
                      },
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title: Text(transaction['title']),
                        subtitle: Text(transaction['category']),
                        trailing: Text(
                          transaction['amount'].toStringAsFixed(2),
                          style: TextStyle(
                            color: transaction['amount'] >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _fetchTransactions() {
    final userId = currentUser?.uid;

    if (userId == null) {
      return Stream.empty();
    }

    DateTime filterDate = _getFilterDate();
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(filterDate))
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> _deleteTransaction(String transactionId) async {
    await FirebaseFirestore.instance
        .collection('transactions')
        .doc(transactionId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaction deleted')),
    );
  }

  Widget _buildDateFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildDateFilterButton('Today'),
            _buildDateFilterButton('Last Week'),
            _buildDateFilterButton('Last Month'),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryFilterButton('All'),
            _buildCategoryFilterButton('Food'),
            _buildCategoryFilterButton('Transport'),
            _buildCategoryFilterButton('Entertainment'),
            _buildCategoryFilterButton('Health'),
            _buildCategoryFilterButton('Income'),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterButton(String period) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDateFilter = period;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Chip(
          label: Text(period),
          backgroundColor:
          selectedDateFilter == period ? Colors.purple : Colors.grey.shade200,
          labelStyle: TextStyle(
            color: selectedDateFilter == period ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilterButton(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategoryFilter = category;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Chip(
          label: Text(category),
          backgroundColor: selectedCategoryFilter == category
              ? Colors.purple
              : Colors.grey.shade200,
          labelStyle: TextStyle(
            color: selectedCategoryFilter == category ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  DateTime _getFilterDate() {
    DateTime now = DateTime.now();
    switch (selectedDateFilter) {
      case 'Today':
        return DateTime(now.year, now.month, now.day);
      case 'Last Week':
        return now.subtract(Duration(days: 7));
      case 'Last Month':
        return DateTime(now.year, now.month - 1, now.day);
      default:
        return DateTime(2000);
    }
  }
}
