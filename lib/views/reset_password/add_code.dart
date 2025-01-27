import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meeting/views/signup.dart';

import '../../services/auth_service.dart';
import '../../services/reset_password.dart';
import '../meeting_List.dart';
import 'neww_Password.dart';


class AddCode extends StatelessWidget {
  final TextEditingController _codeController = TextEditingController();
  final ResetPasswordService _sendemailService = ResetPasswordService();
  final String email;
  AddCode({required this.email});

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
              'Confirmez votre code',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'nous vous avons envoyé un code  par texto'
                  '\n Saissez ce code pour confirmer votre compte',
              style: TextStyle(
                fontSize: 17,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Entrer votre code',
                border: UnderlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),


            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                String code = _codeController.text.trim();
                print("email: $email");

                print("Code saisi : $code"); // Affiche le code saisi

                if (code.isEmpty) {
                  _showErrorDialog(context, 'Veuillez saisir un code.');
                  return;
                }

                try {
                  // Appel au service pour vérifier le code
                await _sendemailService.SendCode(email, code);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewPassword(email: email)));

                } catch (e) {
                  // Affichez un message d'erreur en cas de code invalide
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
