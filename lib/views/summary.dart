import 'package:flutter/material.dart';
import '../pdf_helper.dart';
import '../word_helper.dart';

class SummaryScreen extends StatelessWidget {
  final String summary;

  const SummaryScreen({required this.summary, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Résumé"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Résumé :",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  summary,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (await requestPermissions()) {
                        await saveAsPdf(summary, "resume");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Résumé exporté en PDF dans Téléchargements.")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Permission refusée, veuillez vérifier les paramètres.")),
                        );
                      }
                    },
                    child: const Text("Exporter en PDF", style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final summaryContent = "Voici le contenu du résumé à exporter en Word.";
                      await saveAsWord(summary, "resume_reunion");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Résumé exporté en Word dans Téléchargements.")),
                      );
                    },
                    child: const Text("Exporter en Word" , style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),

                  ),


                ],
              ),
            ),

          ],
            ),


        ),
    );

  }
}
