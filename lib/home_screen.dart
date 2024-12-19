import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart'; // New screen for adding income
import 'model/expense_model.dart';
import 'theme_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> financialTips = [
    'Set a budget and track your spending daily to achieve your financial goals.',
    'Save a portion of your income before you start spending.',
    'Pay off high-interest debts first to save on interest.',
    'Track your subscriptions and cancel any unused ones.',
    'Invest in a retirement plan as early as possible.'
  ];

  String currentTip = '';

  @override
  void initState() {
    super.initState();
    currentTip = _getRandomTip();
  }

  String _getRandomTip() {
    return (financialTips..shuffle()).first;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final expenseModel = Provider.of<ExpenseModel>(context);

    Color primaryTextColor = themeProvider.isDarkMode ? Colors.white : Colors.black;
    Color primaryBackgroundColor = themeProvider.isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purpleAccent.shade400, Colors.purpleAccent.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Home',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.black : Colors.white,
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
              color: themeProvider.isDarkMode ? Colors.black : Colors.white,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: primaryBackgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purpleAccent.shade400, Colors.purple.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Text('Error loading username');
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return Text('No user data available');
                    }

                    String username = snapshot.data!['username'] ?? 'User';

                    return Text(
                      'Hello, $username!',
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.black : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              _buildDrawerItem(
                context,
                'Add Expense',
                Icons.add,
                primaryTextColor,
                AddExpenseScreen(),
              ),
              _buildDrawerItem(
                context,
                'Add Income',
                Icons.add_circle,
                primaryTextColor,
                AddIncomeScreen(),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickActionCard(
                    context,
                    'Add Expense',
                    Icons.add,
                    Colors.pink.shade400,
                    AddExpenseScreen(),
                    primaryTextColor,
                  ),
                  _buildQuickActionCard(
                    context,
                    'Add Income',
                    Icons.add_circle,
                    Colors.green.shade400,
                    AddIncomeScreen(),
                    primaryTextColor,
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Expense Summary',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.pink : Colors.deepPurple,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              _buildSummaryCard(
                'Total Expenses',
                '\$${expenseModel.totalExpenses.toStringAsFixed(2)}',
                Icons.monetization_on,
                Colors.red.shade400,
                primaryTextColor,
              ),
              SizedBox(height: 10),
              _buildSummaryCard(
                'Total Income',
                '\$${expenseModel.totalIncome.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green.shade400,
                primaryTextColor,
              ),
              SizedBox(height: 10),
              _buildSummaryCard(
                'Remaining Balance',
                '\$${expenseModel.remainingBalance.toStringAsFixed(2)}',
                Icons.savings,
                Colors.teal.shade400,
                primaryTextColor,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            currentTip = _getRandomTip();
          });
          _showFinancialTip(context, themeProvider);
        },
        backgroundColor: themeProvider.isDarkMode ? Colors.pink : Colors.purple,
        child: Icon(Icons.lightbulb, color: themeProvider.isDarkMode ? Colors.black : Colors.white),
        tooltip: 'Daily Insight',
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, Color textColor, Widget targetScreen) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, Widget targetScreen, Color textColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Card(
        color: color,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: textColor),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, Color textColor) {
    return Card(
      color: color,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 40, color: textColor),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFinancialTip(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'Financial Tip of the Day',
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          currentTip,
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Close',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.pink : Colors.deepPurple),
            ),
          ),
        ],
      ),
    );
  }
}
