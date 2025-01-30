class AudioFile {
  final String filePath;

  AudioFile({required this.filePath});

  Map<String, dynamic> toJson() {
    return {
      'audio': filePath, // Clé utilisée dans le backend
    };
  }
}
