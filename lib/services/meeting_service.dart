import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constants/config.dart';
import '../models/meeting_model.dart';

class MeetingService {
  Future<void> saveMeetData(String meetId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('meetId', meetId);  // Modification ici pour stocker sous 'meetId'
    print("Meet ID saved: $meetId");
  }

  Future<String?> getMeetId() async {
    final prefs = await SharedPreferences.getInstance();
    final meetId = prefs.getString('meetId');  // Utilisation de 'meetId' pour la récupération
    print("Retrieved Meet ID: $meetId");
    return meetId;
  }

  Future<void> createMeeting(Meeting meeting) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      print("User ID is null. Please log in again.");
      throw Exception("User ID not found in SharedPreferences.");
    }

    final Uri url = Uri.parse("${ApiEndpoints.createMeeting}/$userId");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(meeting.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        // Correction : accéder à '_id' à l'intérieur de 'meeting'
        if (!data.containsKey('meeting') || data['meeting']['_id'] == null) {
          print("Response does not contain '_id' or it is null: $data");
          throw Exception("Missing '_id' in the API response.");
        }

        final meetId = data['meeting']['_id'];
        await saveMeetData(meetId);  // Enregistrement du meetId sous 'meetId'

        print("Meeting created successfully! ID: $meetId");
      } else {
        print("API Error: ${response.body}");
        throw Exception("Failed to create meeting: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error while creating meeting: $e");
    }
  }
  Future<List<Meeting>> fetchMeetings() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');  // Récupère l'ID utilisateur à partir des SharedPreferences

    if (userId == null) {
      print("User ID is null. Please log in again.");
      throw Exception("User ID not found in SharedPreferences.");
    }

    final Uri url = Uri.parse("${ApiEndpoints.getmmeting}/$userId");  // Utilise l'ID utilisateur dans l'URL

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((json) => Meeting.fromJson(json)).toList();  // Conversion de la réponse en liste de réunions

      } else {
        throw Exception("Failed to load meetings");
      }
    } catch (e) {
      print("Error: $e");
      throw Exception("Error fetching meetings: $e");
    }
  }


  static Future<Map<String, dynamic>> deleteMeeting(String meetingId) async {
    final Uri url = Uri.parse("${ApiEndpoints.deleteMeeting}/$meetingId");

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": "Meeting deleted successfully.",
        };

      } else {
        // Erreur inconnue
        return {
          "success": false,
          "message": "Unexpected error occurred.",
          "error": response.body,


      };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error while deleting meeting.",
        "error": e.toString(),
      };
    }
  }
}

