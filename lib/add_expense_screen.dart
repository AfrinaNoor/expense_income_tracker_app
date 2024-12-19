import 'package:flutter/material.dart';
import 'package:expense_tracker_app/services/firebase_service.dart'; // Import your Firebase service

class AddExpenseScreen extends StatefulWidget {
  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedCategory = 'Food';
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false; // Add loading state

  // Function to save the expense
  Future<void> _saveExpense(BuildContext context) async {
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    final amountText = _amountController.text.trim();
    final noteText = _noteController.text.trim();

    // Validate amount
    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid amount')),
      );
      setState(() {
        _isLoading = false; // Hide loading spinner
      });
      return;
    }

    // Validate category and note
    if (_selectedCategory.isEmpty || noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      setState(() {
        _isLoading = false; // Hide loading spinner
      });
      return;
    }

    try {
      // Save the expense to Firestore
      await _firebaseService.saveTransaction(
        double.parse(amountText),  // Amount
        DateTime.now(),             // Date
        _selectedCategory,         // Category
        noteText.isNotEmpty ? noteText : 'No Note',// Note
      );

      // Show success message and return to the previous screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense Saved Successfully')),
      );
      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      print('Error saving expense: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save expense. Try again!')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading spinner
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Expense',
          style: TextStyle(fontSize: 22.0, color: appBarTextColor),
        ),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input Field
              TextField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.purple),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),

              // Note Input Field
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: 'Note',
                  labelStyle: TextStyle(color: Colors.purple),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.purple),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Category Dropdown
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                isExpanded: true,
                style: TextStyle(color: Colors.purple),
                underline: Container(
                  height: 2,
                  color: Colors.purple,
                ),
                items: <String>[
                  'Food',
                  'Transport',
                  'Entertainment',
                  'Cloth',
                  'Education',
                  'Medicine',
                  'Hospital',
                  'Loan',
                  'Bill',
                  'Shopping',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(Icons.category, color: Colors.purple),
                        SizedBox(width: 15),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              // Save Expense Button
              Center(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 50.0),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _saveExpense(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Save Expense',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
