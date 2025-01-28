import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class AudioRecorderScreen extends StatefulWidget {
  const AudioRecorderScreen({super.key});

  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AudioRecorderScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Recorder"),
      ),

      body: Column(
        children: [
          // Partie supérieure avec l'image en arrière-plan
          Expanded(
            flex: 1, // Prend la moitié de l'écran
            child: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5, // 50% de la hauteur de l'écran
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/logo.png'),
                        fit: BoxFit.contain, // Ajuste l'image
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),
          // Partie inférieure avec les boutons
          Expanded(
            flex: 1, // Prend l'autre moitié de l'écran
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bouton "Enregistrer un nouvel audio"

                  const SizedBox(width: 20), // Espace entre les boutons
                  // Bouton "Importer un audio"

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showRecordingPopup() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Recording..."),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () {

                    },
                    iconSize: 40,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}
