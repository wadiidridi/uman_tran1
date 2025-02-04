import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

Future<bool> requestPermissions() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.isGranted) {
      return true;
    }

    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    }

    var manageStatus = await Permission.manageExternalStorage.request();
    if (manageStatus.isGranted) {
      return true;
    } else if (manageStatus.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
  return false;
}

Future<void> saveAsPdf(String content, String fileName) async {
  final pdf = pw.Document();

  try {
    // Vérifie si la permission est accordée
    if (!await requestPermissions()) {
      print("Permission refusée.");
      return;
    }

    // Charger le logo depuis les assets
    final ByteData data = await rootBundle.load('assets/logo.png');
    final Uint8List bytes = data.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Ajouter le logo
              pw.Image(pw.MemoryImage(bytes), width: 100, height: 100),
              // Ajouter un espace après le logo
              pw.SizedBox(height: 40),
              // Ajouter un titre avec une nouvelle couleur et poids
              pw.Text(
                'Résumé de la réunion',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 30),
              // Ajouter le contenu principal avec une couleur et taille personnalisée
              pw.Text(
                content,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.normal, // Font weight normal for body text
                ),
                textAlign: pw.TextAlign.left,
              ),
            ],
          );
        },
      ),
    );

    // Récupère le chemin des téléchargements
    final directory = Directory('/storage/emulated/0/Download');
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }

    // Sauvegarde le fichier PDF
    final file = File("${directory.path}/$fileName.pdf");
    await file.writeAsBytes(await pdf.save());
    print("Fichier sauvegardé : ${file.path}");
  } catch (e) {
    print("Erreur lors de l'enregistrement du fichier : $e");
  }
}