import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:meeting/views/playback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AddRecord extends StatefulWidget {
  const AddRecord({super.key});

  @override
  _AudioRecorderScreenState createState() => _AudioRecorderScreenState();
}

class _AudioRecorderScreenState extends State<AddRecord>
    with SingleTickerProviderStateMixin {
  FlutterSoundRecorder? _recorder;
  String? _audioFilePath;
  bool _isRecording = false;
  bool _isPaused = false;
  double _soundLevel = 0.0;
  int _recordDuration = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _startRecording();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 1.0,
      upperBound: 1.2,
    )..repeat(reverse: true);
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


  Timer? _timer; // Ajoute un Timer global

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    _audioFilePath = '${tempDir.path}/recording.aac';
    await _recorder!.startRecorder(toFile: _audioFilePath);

    setState(() {
      _isRecording = true;
      _isPaused = false;
      _recordDuration = 0; // Réinitialise le minuteur à 0
    });

    // Démarre un Timer qui incrémente _recordDuration chaque seconde
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording) {
        setState(() {
          _recordDuration++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isRecording) {
        setState(() {
          _recordDuration++;
        });
        _startTimer();
      }
    });
  }

  Future<void> _pauseRecording() async {
    await _recorder!.pauseRecorder();
    setState(() {
      _isPaused = true;
    });
    _animationController.stop();
  }

  Future<void> _resumeRecording() async {
    await _recorder!.resumeRecorder();
    setState(() {
      _isPaused = false;
    });
    _animationController.repeat(reverse: true);
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

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Barre du haut avec les icônes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.close, color: Colors.black),
                  Row(
                    children: const [
                      Icon(Icons.delete, color: Colors.black),
                      SizedBox(width: 10),
                      Icon(Icons.share, color: Colors.black),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Texte "Add a Title"
            const Text(
              "Add a Title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Microphone animé
            ScaleTransition(
              scale: _animationController,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.2),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(Icons.mic, size: 40, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Texte "Listening"
            const Text(
              "Listening",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),

            // Barre de contrôle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bouton Pause/Reprendre
                  IconButton(
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause,
                        color: Colors.white),
                    iconSize: 40,
                    onPressed: () {
                      setState(() {
                        _isPaused ? _resumeRecording() : _pauseRecording();
                      });
                    },
                  ),

                  // Bouton Stop
                  IconButton(
                    icon: const Icon(Icons.stop, color: Colors.white),
                    iconSize: 40,
                    onPressed: _stopRecording,
                  ),

                  // Timer
                  Text(
                    "${_recordDuration ~/ 60}:${(_recordDuration % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
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
