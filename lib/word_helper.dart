import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestPermissionsW() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.isGranted || await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    var status = await Permission.storage.request();
    if (status.isGranted) return true;

    var manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) return true;

    if (manageStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
  return false;
}

Future<void> saveAsWord(String content, String fileName) async {
  try {
    // Vérifier les permissions
    if (!await requestPermissionsW()) {
      print("Permission refusée.");
      return;
    }

    // Création du contenu au format Word (texte brut pour ce cas)
    final header = "Résumé de la réunion\n\n";
    final body = content;
    final fullContent = "$header$body";

    // Chemin du fichier de sortie
    final directory = Directory('/storage/emulated/0/Download');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    final filePath = "${directory.path}/$fileName.docx";

    // Écrire le contenu dans le fichier
    final file = File(filePath);
    await file.writeAsString(fullContent, flush: true);

    print("Fichier sauvegardé : $filePath");
  } catch (e) {
    print("Erreur lors de l'enregistrement du fichier Word : $e");
  }
}
