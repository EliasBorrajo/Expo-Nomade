import 'package:expo_nomade/quiz_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expo_nomade/admin_forms/forms.dart';
import 'firebase/firebase_auth.dart';

class SignInPage extends StatelessWidget {
  final AuthService authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              child: Text('Sign in with Email & Password'),
              onPressed: () async {
                User? user = await authService.signInWithEmailPassword(
                  emailController.text,
                  passwordController.text,
                );
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminForms(),
                    ),
                  );
                } else {
                  print('Failed to sign in with Email & Password');
                }
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              child: Text('Return to Map'),
              onPressed: () {
                // Navigate back to the map
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
