import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Navigate to the WelcomeScreen after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/welcome'); // Navigate to WelcomeScreen
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.2),
              ),
              child: Icon(
                Icons.track_changes, // Icon representing tracking/finance
                size: 60,
                color: Colors.purpleAccent,
              ),
            ),
            SizedBox(height: 20),

            // App Name
            Text(
              'FinTrack Pro',
              style: TextStyle(
                fontSize: 32,
                color: Colors.purpleAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 10),

            // Tagline
            Text(
              'Your Personal Expense Guide',
              style: TextStyle(
                fontSize: 16,
                color: Colors.purpleAccent.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 40),

            // Loading Indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
            ),
          ],
        ),
      ),
    );
  }
}
