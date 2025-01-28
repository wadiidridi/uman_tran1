class Meeting {
  final String sujetReunion;
  final String heure;
  final int nombreParticipants;
  final String date;
  final String userId;  // Champ ajouté pour l'ID de l'utilisateur
  final String audio;
  final String transcriptionLocuteur;  // Champ ajouté pour l'ID de l'utilisateur
  final String resume;
  final String? id;

  Meeting({
    required this.sujetReunion,
    required this.heure,
    required this.nombreParticipants,
    required this.date,
    required this.userId,
    required this.audio,
    required this.transcriptionLocuteur,
    required this.resume,
    required this.id
  });

  Map<String, dynamic> toJson() {
    return {
      'sujetReunion': sujetReunion,
      'heure': heure,
      'nombreParticipants': nombreParticipants,
      'date': date,
      'userId': userId,  // Assurez-vous d'ajouter cet élément à la conversion JSON
      '_id': id,

    };
  }

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      sujetReunion: json['sujetReunion'] ?? '', // Si 'sujetReunion' est null, attribuer une chaîne vide
      heure: json['heure'] ?? '',               // Si 'heure' est null, attribuer une chaîne vide
      nombreParticipants: json['nombreParticipants'] ?? 0,  // Si 'nombreParticipants' est null, attribuer 0
      date: json['date'] ?? '',                 // Si 'date' est null, attribuer une chaîne vide
      userId: json['userId'] ?? '',             // Si 'userId' est null, attribuer une chaîne vide
      audio: json['audio'] ?? '',
      transcriptionLocuteur: json['transcriptionLocuteur']?? '',
      resume: json['resume']?? '',
      id: json['_id'], // Assurez-vous que cela correspond au format de votre API

    );
  }
}
