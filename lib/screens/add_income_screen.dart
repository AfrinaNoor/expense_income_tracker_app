import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class AddIncomeScreen extends StatefulWidget {
  @override
  _AddIncomeScreenState createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  // List of categories
  final List<String> _categories = ['Salary', 'Business', 'Trade', 'Freelancing', 'Tuition', 'Rent', 'Investments', 'Others'];

  // Method to pick date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addIncome() async {
    // Get input values
    final amount = double.tryParse(_amountController.text);
    final note = _noteController.text.trim();

    // Validate input
    if (amount == null || _selectedCategory == null) {
      // Show error if invalid input
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please provide valid income details')));
      return;
    }

    // Get current date
    DateTime now = DateTime.now();

    // Add income details to Firestore
    await FirebaseFirestore.instance.collection('users')
        .doc(currentUser?.uid)
        .collection('transactions')
        .add({
      'amount': amount,
      'category': _selectedCategory,
      'note': note,
      'title': note, // Save the note as title
      'type': 'income', // Type of transaction
      'date': Timestamp.fromDate(_selectedDate), // Selected date
      'createdAt': Timestamp.fromDate(now), // Current date and time for record creation
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Income added successfully')));

    // Clear text fields after saving
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedDate = DateTime.now();
    });

    // Optionally navigate back to previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Income'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            // Income Amount
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Income Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money), // Updated icon for amount
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              onChanged: (String? newCategory) {
                setState(() {
                  _selectedCategory = newCategory;
                });
              },
              items: _categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            // Note Field
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
            ),
            SizedBox(height: 16),
            // Date Picker
            Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 8),
                Text(
                  'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}', // Display selected date in 'yyyy-MM-dd' format
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Pick Date'),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: _addIncome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade400,
                ),
                child: Text('Save Income', style: TextStyle(color: Colors.white)), // Text color set to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
