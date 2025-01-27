import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../constants/config.dart';




class ResetPasswordService {

Future<bool> SendEmail(String email) async {
  final Uri url = Uri.parse(ApiEndpoints.ResetPassword);
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("Response body: ${response.body}");
    print(data);
    return true;

  } else {
    // Si le statut est différent de 200, extraire le message d'erreur
    final errorData = jsonDecode(response.body);
    String errorMessage = errorData['message'] ?? 'An error occurred';
    throw Exception(errorMessage);
  }

}
Future<bool> SendCode(String email, String resetCode) async {
  final Uri url = Uri.parse(ApiEndpoints.ResetPassword);
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'resetCode': resetCode, // Envoie le vrai code
    }),
  );

  // Ajoutez ce print pour afficher la réponse brute
  print("Réponse du serveur : ${response.body}");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    print("Response body: ${response.body}");
    print(data);
    return true;
  } else {
    // En cas d'erreur HTTP
    final errorData = jsonDecode(response.body);
    String errorMessage = errorData['message'] ?? 'Une erreur est survenue';
    throw Exception(errorMessage);
  }
}

Future<bool> changePass(String email,String newPassword) async {
  final Uri url = Uri.parse(ApiEndpoints.changPass);
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'newPassword': newPassword,

    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print("Response body: ${response.body}");
    print(data);
    return true;
  } else {
    // Si le statut est différent de 200, extraire le message d'erreur
    final errorData = jsonDecode(response.body);
    String errorMessage = errorData['message'] ?? 'An error occurred';
    throw Exception(errorMessage);
  }

}
}
