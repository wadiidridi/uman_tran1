import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:meeting/views/playback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

import '../widgets/custom_bottom_nav.dart';


class addRecord extends StatefulWidget {
  const addRecord({super.key});

  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<addRecord> {
  FlutterSoundRecorder? _recorder;
  String? _audioFilePath;

  bool _isRecording = false;
  bool _isPaused = false;

  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();

    if (await Permission.microphone.request().isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission is required.")),
      );
    }

    _recorder!.setSubscriptionDuration(const Duration(milliseconds: 100));
    _recorder!.onProgress!.listen((event) {
      setState(() {
        _soundLevel = event.decibels ?? 0.0;
      });
    });
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    _audioFilePath = '${tempDir.path}/recording.aac';
    await _recorder!.startRecorder(toFile: _audioFilePath);
    setState(() {
      _isRecording = true;
      _isPaused = false;
    });
  }

  Future<void> _pauseRecording() async {
    await _recorder!.pauseRecorder();
    setState(() {
      _isPaused = true;
    });
  }

  Future<void> _resumeRecording() async {
    await _recorder!.resumeRecorder();
    setState(() {
      _isPaused = false;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });

    if (_audioFilePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaybackScreen(audioFilePath: _audioFilePath!),
        ),
      );
    }
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      final selectedFilePath = result.files.single.path!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaybackScreen(audioFilePath: selectedFilePath),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aucun fichier sélectionné.")),
      );
    }
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Audio Recorder"),
      ),

      body: Column(
        children: [
          // Partie supérieure avec l'image en arrière-plan

          // Partie inférieure avec les boutons
          Expanded(
            flex: 1, // Prend l'autre moitié de l'écran
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bouton "Enregistrer un nouvel audio"

// Bouton "Enregistrer un nouvel audio"
                  Flexible(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.mic, color: Colors.white),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          _startRecording();
                          _showRecordingPopup();
                        },
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded( // Ajout pour éviter l'overflow
                              child: Text('Enregistrer un nouvel audio', overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 50), // Espace entre les boutons

// Bouton "Importer un audio"
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6, // 60% of the screen width
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.upload, color: Colors.white),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black,
                      ),
                      onPressed: _pickAudioFile,
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.start, // Aligne le texte à gauche
                        children: [
                          Text('Importer un audio'),
                        ],
                      ),
                    ),
                  )


                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // Onglet actif : History
        context: context,
      ),
    );
  }

  void _showRecordingPopup() {
    int _recordDuration = 0;
    bool _isRecording = true;

    void _startTimer() {
      Future.delayed(Duration(seconds: 1), () {
        if (_isRecording) {
          setState(() {
            _recordDuration++;
          });
          _startTimer();
        }
      });
    }

    _startTimer();

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(16),
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Transcribe",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Add a Title",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                "Listening",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildWaveform(),
              const SizedBox(height: 16),
              Text(
                "${_recordDuration ~/ 60}:${(_recordDuration % 60).toString().padLeft(2, '0')}",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    onPressed: _isPaused ? _resumeRecording : _pauseRecording,
                    iconSize: 40,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () {
                      _isRecording = false;
                      _stopRecording();
                      Navigator.pop(context);
                    },
                    iconSize: 40,
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaveform() {
    final barHeight = max(10, _soundLevel * 2);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        10,
            (index) => Container(
          width: 5,
          height: Random().nextDouble() * barHeight,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          color: Colors.red,
        ),
      ),
    );
  }
}
