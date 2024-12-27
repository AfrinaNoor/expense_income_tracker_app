import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();  // Added controller for username
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;  // Variable to toggle password visibility

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signupUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Register user in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user details to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'username': _usernameController.text.trim(),  // Save username
        'createdAt': DateTime.now(),
      });

      // Navigate to home screen or show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup successful!")),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email is already in use';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign up: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  // Title
                  Text(
                    'Signup',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),

                  // Username
                  TextFormField(
                    controller: _usernameController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.black),  // Changed to black
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black),  // Changed to black
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.black),  // Changed to black
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.black),  // Changed to black
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black),  // Changed to black
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.black),  // Changed to black
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.black),  // Changed to black
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black),  // Changed to black
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.black),  // Changed to black
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Phone
                  InternationalPhoneNumberInput(
                    initialValue: PhoneNumber(isoCode: 'BD'),  // Default phone code set to Bangladesh
                    onInputChanged: (PhoneNumber number) {
                      _phoneController.text = number.phoneNumber ?? '';
                    },
                    inputDecoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(color: Colors.black),  // Changed to black
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black),  // Changed to black
                      ),
                      prefixIcon: Icon(Icons.phone, color: Colors.black),  // Changed to black
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black),  // Changed to black
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.black),  // Changed to black
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.black),  // Changed to black
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
                    obscureText: !_isPasswordVisible,  // Toggle password visibility
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6 || !RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[A-Za-z\d@$!%*?&]{6,}$').hasMatch(value)) {
                        return 'Password must be at least 6 characters long, including letters and numbers';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30),

                  // Signup Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signupUser,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Signup',
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
                  SizedBox(height: 20),

                  // Already have an account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();  // Dispose username controller
    super.dispose();
  }
}
