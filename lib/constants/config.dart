class ApiEndpoints {

  static const String baseUrl = "http://91.134.19.144:5222/api";

  // Auth endpoints
  static const String signUp = "$baseUrl/auth/register/client";
  static const String signIn = "$baseUrl/auth/login";

  // Meeting-related endpoints
  static const String summarize = "$baseUrl/auth/summarize";
  static const String createMeeting = "$baseUrl/meeting/meeting";
  static const String getmmeting = "$baseUrl/meeting/meetings";
  static const String deleteMeeting = "$baseUrl/auth/delete-meeting";
  static const String KeyApi = "$baseUrl/auth/add-api-key";
  static const String ResetPassword = "$baseUrl/auth/request-password-reset";
  static const String VerifResetPassword = "$baseUrl/auth/verify-reset-code";
  static const String changPass = "$baseUrl/auth/update-password";



  // Autres endpoints
  static const String transcription = "$baseUrl/meeting/transcribe";
  static const String transcribeidentif = "$baseUrl/auth/transcribeidentif";


}


