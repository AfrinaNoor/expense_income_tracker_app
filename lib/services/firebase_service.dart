import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker_app/model/expense_model.dart'; // Ensure this import is correct

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to get the current user's ID
  String? get userId {
    return _auth.currentUser?.uid;
  }

  // Helper function to check if the user is authenticated
  bool get _isUserAuthenticated => userId != null;

  // Save transaction with amount, date, category, note, and type (expense/income)
  Future<void> saveTransaction(double amount, DateTime date, String category, String note, String type) async {
    try {
      if (_isUserAuthenticated) {
        // Create a new ExpenseTransaction object
        ExpenseTransaction newTransaction = ExpenseTransaction(
          id: '', // Firestore will auto-generate this
          title: note,
          category: category,
          amount: amount,
          date: date,
          type: type, // Specify whether it's income or expense
        );

        // Save transaction to Firestore
        await _firestore
            .collection('users')
            .doc(userId) // Save data under the current user's ID
            .collection('transactions')
            .add(newTransaction.toFirestore()..['timestamp'] = FieldValue.serverTimestamp());

        print("Transaction saved successfully.");
      } else {
        throw FirebaseAuthException(
          code: 'USER_NOT_AUTHENTICATED',
          message: 'User is not authenticated. Please log in.',
        );
      }
    } catch (e) {
      print("Error saving transaction: $e");
      rethrow; // Re-throw the error for handling in the UI
    }
  }

  // Save report data
  Future<void> saveReport(String title, String content) async {
    try {
      if (_isUserAuthenticated) {
        await _firestore
            .collection('users')
            .doc(userId) // Save report data under the current user's ID
            .collection('reports')
            .add({
          'title': title,
          'content': content,
          'date': DateTime.now().toIso8601String(),
          'timestamp': FieldValue.serverTimestamp(), // Add timestamp for ordering
        });
        print("Report saved successfully.");
      } else {
        throw FirebaseAuthException(
          code: 'USER_NOT_AUTHENTICATED',
          message: 'User is not authenticated. Please log in.',
        );
      }
    } catch (e) {
      print("Error saving report: $e");
      rethrow; // Re-throw the error for handling in the UI
    }
  }

  // Retrieve transaction history (Stream for real-time updates)
  Stream<List<ExpenseTransaction>> getTransactionHistory() {
    if (_isUserAuthenticated) {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data();
          return ExpenseTransaction(
            id: doc.id, // Firestore Document ID
            title: data['title'] ?? 'No Title',
            category: data['category'] ?? 'Uncategorized',
            amount: data['amount'] ?? 0.0,
            date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
            type: data['type'] ?? 'expense', // Default to expense if type is missing
          );
        }).toList();
      });
    } else {
      print("User is not authenticated. Returning empty list.");
      return Stream.value([]); // Return an empty list
    }
  }

  // Retrieve transactions filtered by type (income or expense)
  Stream<List<ExpenseTransaction>> getTransactionsByType(String type) {
    if (_isUserAuthenticated) {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('type', isEqualTo: type)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data();
          return ExpenseTransaction(
            id: doc.id,
            title: data['title'] ?? 'No Title',
            category: data['category'] ?? 'Uncategorized',
            amount: data['amount'] ?? 0.0,
            date: DateTime.parse(data['date'] ?? DateTime.now().toIso8601String()),
            type: data['type'] ?? 'expense',
          );
        }).toList();
      });
    } else {
      print("User is not authenticated. Returning empty list.");
      return Stream.value([]);
    }
  }

  // Retrieve report data (Stream for real-time updates)
  Stream<List<Map<String, dynamic>>> getReportData() {
    if (_isUserAuthenticated) {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('reports')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return doc.data(); // Directly return the report data
        }).toList();
      });
    } else {
      print("User is not authenticated. Returning empty list.");
      return Stream.value([]); // Return an empty list
    }
  }
}
