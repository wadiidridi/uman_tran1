import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/config.dart'; // Assure-toi que le chemin est correct
class SummarizeService {

  Future<String?> summarizeText(String text) async {
    final prefs = await SharedPreferences.getInstance();
    final meetId = prefs.getString('meetId');

    // final Uri url = Uri.parse("${ApiEndpoints.summarize}/$meetId");

    final String url = "${ApiEndpoints.summarize}/$meetId";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('resume generé : ${response.body}');

        return data['summary'];
      } else {
        print('Erreur API : ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erreur : $e');
      return null;
    }
  }
}
