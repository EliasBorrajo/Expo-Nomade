import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expo_nomade/admin_forms/forms.dart';
import 'firebase/firebase_auth.dart';

class SignInPage extends StatelessWidget {
  final AuthService authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInPage({super.key});

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
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              child: const Text('Sign in'),
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
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Return to Map'),
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
