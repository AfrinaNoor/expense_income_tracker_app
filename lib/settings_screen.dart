import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker_app/welcome_screen.dart'; // Replace with the actual path to your Welcome screen
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCurrency = 'BDT'; // Default currency
  final List<String> _currencies = ['BDT', 'USD', 'EUR', 'INR', 'GBP']; // Supported currencies

  @override
  void initState() {
    super.initState();
    _loadCurrency(); // Load the saved currency on initialization
  }

  // Load the saved currency from SharedPreferences
  Future<void> _loadCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('currency') ?? 'BDT';
    });
  }

  // Save the selected currency to SharedPreferences
  Future<void> _saveCurrency(String currency) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  @override
  Widget build(BuildContext context) {
    // Determine the AppBar text color based on the theme
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final appBarTextColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 22.0,
            color: appBarTextColor, // Dynamically set text color
          ),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Currency'),
              trailing: DropdownButton<String>(
                value: _selectedCurrency,
                items: _currencies.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (String? newCurrency) {
                  if (newCurrency != null) {
                    setState(() {
                      _selectedCurrency = newCurrency;
                    });
                    _saveCurrency(newCurrency); // Save the new currency
                  }
                },
              ),
            ),
            ListTile(
              title: Text('Backup Data'),
              trailing: Icon(Icons.cloud_upload),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle settings actions
              },
              child: Text('Save Settings'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Logout functionality
                try {
                  await FirebaseAuth.instance.signOut(); // Log out the user
                  // After logout, redirect to the Welcome page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()), // Replace with your Welcome page
                  );
                } catch (e) {
                  print("Error logging out: $e");
                }
              },
              child: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red color for the logout button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
