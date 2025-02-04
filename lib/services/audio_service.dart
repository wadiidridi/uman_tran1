import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/config.dart';
import 'package:http_parser/http_parser.dart';

import '../models/AudioFile.dart';  // Assurez-vous que cet import est présent

class AudioService {

  Future<String> uploadAudio(AudioFile audioFile) async {
    final prefs = await SharedPreferences.getInstance();
    final meetId = prefs.getString('meetId');

    print('MeetId: $meetId');
    print('Audio file path: ${audioFile.filePath}');

    if (meetId == null) {
      throw Exception('MeetId is null');
    }

    final Uri url = Uri.parse("${ApiEndpoints.transcription}/$meetId");

    try {
      // Vérifier si le fichier audio existe
      if (!File(audioFile.filePath).existsSync()) {
        throw Exception("Fichier audio introuvable : ${audioFile.filePath}");
      }

      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        "Content-Type": "multipart/form-data",
      });

      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.filePath,
      ));

      print("Request URL: $url");
      print("Headers: ${request.headers}");
      print("Files: ${request.files.map((f) => f.filename).toList()}");

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("Audio uploaded successfully!");
        print("Response body: $responseBody");

        // Vérification du contenu de la réponse
        if (responseBody.trim().startsWith('{') &&
            responseBody.trim().endsWith('}')) {
          final responseData = jsonDecode(responseBody);
          // Extraire la transcription à partir de la réponse
          if (responseData.containsKey('transcript')) {
            return responseData['transcript'] ??
                "Aucune transcription disponible.";
          } else {
            throw Exception("Transcription non disponible dans la réponse.");
          }
        } else {
          throw Exception("Réponse inattendue reçue du serveur : $responseBody");
        }
      } else {
        print("API Error: ${response.statusCode} - ${response.reasonPhrase}");
        print("Response body: $responseBody");
        throw Exception("Échec de l'upload : ${response.reasonPhrase}");
      }
    } catch (e, stackTrace) {
      print("Error: $e\nStackTrace: $stackTrace");
      throw Exception("Erreur lors de l'upload de l'audio : $e");
    }
  }


  Future<String> transcribeident(AudioFile audioFile) async {
    final prefs = await SharedPreferences.getInstance();
    final meetId = prefs.getString('meetId');

    print('MeetId: $meetId');
    print('Audio file path: ${audioFile.filePath}');

    if (meetId == null) {
      throw Exception('MeetId is null');
    }

    final Uri url = Uri.parse("${ApiEndpoints.transcribeidentif}/$meetId");

    try {
      // Vérifier si le fichier existe
      if (!File(audioFile.filePath).existsSync()) {
        throw Exception("Fichier audio introuvable : ${audioFile.filePath}");
      }

      // Préparer la requête multipart
      var request = http.MultipartRequest('POST', url);

      // Ajouter les en-têtes nécessaires
      request.headers.addAll({
        "Content-Type": "multipart/form-data",
      });

      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.filePath,
      ));

      print("Request URL: $url");
      print("Headers: ${request.headers}");
      print("Files: ${request.files.map((f) => f.filename).toList()}");

      // Envoyer la requête
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: $responseBody");

      // Vérifier la réponse
      if (response.statusCode == 200) {
        print("Audio uploaded successfully!");
        print("Response body: $responseBody");
        final responseData = jsonDecode(responseBody);
        return responseData['transcriptionLocuteur'] ??
            "Aucune transcription disponible.";
      } else {
        print("Erreur API: ${response.statusCode} - ${response.reasonPhrase}");
        print("Body: $responseBody");
        throw Exception("Échec de l'upload : ${response.reasonPhrase}");
      }
    } catch (e, stackTrace) {
      print("Error: $e\nStackTrace: $stackTrace");
      throw Exception("Erreur lors de l'upload de l'audio : $e");
    }
  }

}
