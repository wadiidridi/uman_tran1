import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meeting/views/signup.dart';

import '../../services/auth_service.dart';
import '../../services/reset_password.dart';
import '../login.dart';
import '../meeting_List.dart';
import 'add_code.dart';


class NewPassword extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();
  final ResetPasswordService _sendemailService = ResetPasswordService();

  final String email;
  NewPassword({required this.email});

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'crer un nouveau mot de pass',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'entrez votre adresse e-mail',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'crer un nouveau mot de passe',
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'confirmer votre mot de passe',
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                print("pressed");
                String password = _passwordController.text.trim();
                print(email);

                if (email.isEmpty) {
                  _showErrorDialog(context, 'Please fill in all fields..');


                  return;
                }

                try {
                  // Appel du service d'authentification
                  await _sendemailService.changePass(email,password);

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  LoginPage()),
                  );
                }  catch (e) {
                  _showErrorDialog(context, e.toString());

                }

              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.black,
              ),
              child: Text(
                'Continuer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
