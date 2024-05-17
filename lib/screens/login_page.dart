import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:savorease_app/screens/admin_page.dart'; // Import your AdminPage widget
import 'package:savorease_app/screens/branch_admin.dart';
import 'package:savorease_app/screens/map_page.dart';
import 'package:savorease_app/screens/signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to Savor Ease",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 30.0),
              TextField(
                controller: emailController,
                style: TextStyle(fontSize: 18.0),
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: passwordController,
                style: TextStyle(fontSize: 18.0),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // Authenticate user with email and password
                    UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );

                    // Check if the user exists in Firebase user table
                    if (userCredential.user != null) {
                      // Check if the user is admin
                      if (emailController.text.trim() == 'admin@gmail.com' &&
                          passwordController.text == 'admin123') {
                        // Navigate to admin page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AdminHomePage(), // Replace AdminPage with your admin page widget
                          ),
                        );
                      } else {
                        // Check if the user is branch admin
                        bool isBranchAdmin = await checkBranchAdmin(
                            emailController.text.trim(),
                            passwordController.text,
                            'Colombo'); // Replace 'Colombo' with the city name based on user selection

                        if (isBranchAdmin) {
                          // Navigate to branch admin dashboard page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BranchAdminDashboardPage(
                                city: 'colombo',
                              ),
                            ),
                          );
                        } else {
                          // Navigate to map page for regular users
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapPage(),
                            ),
                          );
                        }
                      }
                    } else {
                      // User does not exist
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("User not found"),
                            content: Text("Please sign up first."),
                            actions: <Widget>[
                              TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } catch (e) {
                    print('Error: $e');
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Invalid Login"),
                          content: Text(" Please try again later."),
                          actions: <Widget>[
                            TextButton(
                              child: Text("OK"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 20.0),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to sign-up page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to check if the user is a branch admin
  Future<bool> checkBranchAdmin(
      String email, String password, String city) async {
    try {
      // Query the branchAdmin collection based on the provided email, password, and city
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('branchAdmin')
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .where('city', isEqualTo: city)
          .get();

      // Check if there is a document returned
      if (querySnapshot.docs.isNotEmpty) {
        return true; // User is a branch admin
      } else {
        return false; // User is not a branch admin
      }
    } catch (error) {
      print('Error checking branch admin: $error');
      return false; // Assume user is not a branch admin in case of error
    }
  }
}
