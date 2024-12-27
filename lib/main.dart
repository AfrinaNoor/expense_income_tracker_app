import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/budgeting_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'model/expense_model.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // Theme Management
        ChangeNotifierProvider(create: (context) => ExpenseIncomeModel()),  // Expense Tracking Model
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Expense Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode, // Light or Dark Theme
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/', // SplashScreen as the first route
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/addExpense': (context) => AddExpenseScreen(), // Add Expense Screen
        '/history': (context) => TransactionHistoryScreen(), // Transaction History
        '/categories': (context) => CategoriesScreen(),
        '/budgeting': (context) => BudgetingScreen(),
        '/reports': (context) => ReportsScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
