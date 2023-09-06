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
      body: Center(
        child: SingleChildScrollView( // Utilisez un SingleChildScrollView
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, size: 50),
                const SizedBox(height: 32),
                const Text('Connexion Administrateur', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                  ),
                  child: const Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 16)
                  ),
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
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                        'Retour',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}