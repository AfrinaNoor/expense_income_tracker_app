import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Make the container take the full width
        height: double.infinity, // Make the container take the full height
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade300, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Section
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Icon(
                    Icons.track_changes,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),

                // Title
                Text(
                  '   Welcome to FinTrack   ',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),

                // Buttons Section
                HoverButton(
                  text: 'Login',
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
                SizedBox(height: 20),
                HoverButton(
                  text: 'Sign Up',
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const HoverButton({required this.text, required this.onPressed, Key? key})
      : super(key: key);

  @override
  _HoverButtonState createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isHovered ? Colors.purple.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white, width: 2),
        ),
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isHovered ? Colors.white : Colors.purple.shade400,
            ),
          ),
        ),
      ),
    );
  }
}
