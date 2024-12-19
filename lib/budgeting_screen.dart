import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/expense_model.dart';

class BudgetingScreen extends StatefulWidget {
  @override
  _BudgetingScreenState createState() => _BudgetingScreenState();
}

class _BudgetingScreenState extends State<BudgetingScreen> {
  double _budgetLimit = 500.0; // Default total budget limit
  final List<String> _categories = [
    'Food',
    'Transport',
    'Entertainment',
    'Housing',
    'Utilities',
    'Healthcare',
    'Savings',
    'Education',
    'Shopping',
    'Miscellaneous',
  ];

  // Initial budget allocation for each category
  late Map<String, double> _categoryBudgets;

  @override
  void initState() {
    super.initState();
    // Initialize category budgets equally distributed
    _categoryBudgets = {
      for (var category in _categories) category: _budgetLimit / _categories.length
    };
  }

  @override
  Widget build(BuildContext context) {
    // Access ExpenseModel
    final expenseModel = Provider.of<ExpenseModel>(context);
    double spentAmount = expenseModel.totalExpenses;
    double remainingAmount = _budgetLimit - spentAmount;

    // Access selected currency from the provider
    final selectedCurrency = Provider.of<ExpenseModel>(context).selectedCurrency;

    // AppBar text color based on the theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Set Budget',
          style: TextStyle(
            fontSize: 22.0,
            color: appBarTextColor,
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display budget and remaining balance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Monthly Budget: $selectedCurrency ${_budgetLimit.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Flexible(
                  child: Text(
                    'Remaining: $selectedCurrency ${remainingAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: remainingAmount >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Circular progress indicator
            Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  value: spentAmount / (_budgetLimit == 0 ? 1 : _budgetLimit),
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Budget limit slider
            Text(
              'Adjust Total Monthly Budget:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _budgetLimit,
              min: 100,
              max: 1000,
              divisions: 18,
              label: '$selectedCurrency ${_budgetLimit.toStringAsFixed(0)}',
              onChanged: (value) {
                setState(() {
                  _budgetLimit = value;
                  _updateCategoryBudgets(); // Recalculate category budgets proportionally
                });
              },
            ),
            SizedBox(height: 10),

            // Save Budget Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  expenseModel.setBudget(_budgetLimit);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Total budget set to $selectedCurrency ${_budgetLimit.toStringAsFixed(2)}"),
                    ),
                  );
                },
                child: Text('Save Budget'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
              ),
            ),

            SizedBox(height: 20),
            Divider(),

            // Budget breakdown
            Text(
              'Category-Wise Budgets:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // List of category budgets
            Expanded(
              child: ListView.builder(
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$category: $selectedCurrency ${_categoryBudgets[category]!.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Slider(
                        value: _categoryBudgets[category]!,
                        min: 0,
                        max: _budgetLimit,
                        divisions: 20,
                        label: '$selectedCurrency ${_categoryBudgets[category]!.toStringAsFixed(0)}',
                        onChanged: (value) {
                          setState(() {
                            _categoryBudgets[category] = value;
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recalculate category budgets when total budget changes
  void _updateCategoryBudgets() {
    double totalAllocated = _categoryBudgets.values.fold(0, (sum, value) => sum + value);
    if (totalAllocated == 0) return;

    // Proportionally adjust each category's budget
    _categoryBudgets = {
      for (var category in _categories)
        category: (_categoryBudgets[category]! / totalAllocated) * _budgetLimit
    };
  }
}
