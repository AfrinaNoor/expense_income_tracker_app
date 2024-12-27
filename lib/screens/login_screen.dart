import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Variable to toggle password visibility

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String input = _emailOrPhoneController.text.trim();
      UserCredential userCredential;

      if (input.contains('@')) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: input,
          password: _passwordController.text.trim(),
        );
      } else {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: input + '@example.com',
          password: _passwordController.text.trim(),
        );
      }

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email or phone number';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to login: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    String username = await showDialog(
      context: context,
      builder: (context) {
        TextEditingController usernameController = TextEditingController();
        return AlertDialog(
          title: Text('Enter your username'),
          content: TextField(
            controller: usernameController,
            decoration: InputDecoration(hintText: 'Username'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, usernameController.text);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );

    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String email = querySnapshot.docs[0]['email'];
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to $email')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user found with this username')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset password: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purpleAccent, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.track_changes_outlined,
                      size: 60,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Title
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Email or Phone
                  TextFormField(
                    controller: _emailOrPhoneController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Email or Phone',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.black),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email or phone';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: Colors.black),
                    obscureText: !_isPasswordVisible, // Toggle password visibility
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.black),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _loginUser,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.purpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  // Sign Up Link
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Forgot Password Link
                  TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
