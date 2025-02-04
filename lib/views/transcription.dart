import 'package:flutter/material.dart';
import 'package:meeting/views/summary.dart';
import '../constants/config.dart';
import '../services/summarize_service.dart'; // Assurez-vous que le chemin est correct

class TranscriptionScreen extends StatefulWidget {
  final String transcription;

  const TranscriptionScreen({required this.transcription, Key? key})
      : super(key: key);

  @override
  _TranscriptionScreenState createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  late TextEditingController _transcriptionController;

  @override
  void initState() {
    super.initState();
    // Initialisation du contrôleur avec la transcription existante
    _transcriptionController =
        TextEditingController(text: widget.transcription);
  }

  @override
  void dispose() {
    _transcriptionController.dispose(); // Libération du contrôleur
    super.dispose();
  }

  void _generateSummary() async {
    // Récupérer le texte de la transcription
    String transcriptionText = _transcriptionController.text;

    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Générer le résumé
    SummarizeService summarizeService = SummarizeService();
    String? summary = await summarizeService.summarizeText(transcriptionText);

    // Fermer l'indicateur de chargement
    Navigator.pop(context);

    if (summary != null) {
      // Naviguer vers l'écran du résumé avec les données
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(summary: summary),
        ),
      );
    } else {
      // Afficher une erreur si le résumé n'a pas pu être généré
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la génération du résumé")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transcription"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Transcription :",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _generateSummary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Ajuste la largeur au contenu
                    children: [
                      Text(
                        "Résumé",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(width: 8), // Espacement entre le texte et l'icône
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),

              ],
            ),
            const SizedBox(height: 24.0),
            TextField(
              controller: _transcriptionController,
              maxLines: 25,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Modifier la transcription",
              ),
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
