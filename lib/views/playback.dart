import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/AudioFile.dart';
import '../services/audio_service.dart';

class PlaybackScreen extends StatefulWidget {
  final String audioFilePath;

  const PlaybackScreen({required this.audioFilePath, Key? key}) : super(key: key);

  @override
  _PlaybackScreenState createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioService _audioService = AudioService();
  bool _isPlaying = false;
  bool _isPaused = false;
  double _currentPosition = 0;
  double _totalDuration = 1;

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
        _isPaused = state == PlayerState.paused;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration.inMilliseconds.toDouble();
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position.inMilliseconds.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio() async {
    await _audioPlayer.play(DeviceFileSource(widget.audioFilePath));
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
  }

  void _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _currentPosition = 0;
    });
  }

  void _uploadAudio() async {
    final audioFile = AudioFile(filePath: widget.audioFilePath);

    if (await File(audioFile.filePath).exists()) {
      try {
        final transcription = await _audioService.uploadAudio(audioFile);


      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de l'upload : $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le fichier n'existe pas.")),
      );
    }
  }

  void _uploadAudioIdent() async {
    final audioFile = AudioFile(filePath: widget.audioFilePath);

    if (await File(audioFile.filePath).exists()) {
      try {
        final transcription = await _audioService.transcribeident(audioFile);

        // Navigation vers un nouvel écran avec la transcription

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec de l'upload : $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le fichier n'existe pas.")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Playback")),

      body: Column(
        children: [
          // Card for the audio file
          Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Cet enregistrement est stocké sur cet appareil uniquement",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Text("File: ${widget.audioFilePath}"),
                ],
              ),
            ),
          ),
          // Audio controls
          Slider(
            value: _currentPosition,
            max: _totalDuration,
            onChanged: (value) async {
              setState(() {
                _currentPosition = value;
              });
              await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _isPlaying ? _pauseAudio : _playAudio,
                iconSize: 40,
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: _stopAudio,
                iconSize: 40,
              ),
            ],
          ),
          const SizedBox(height: 120),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [


            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
