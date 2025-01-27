class User {
  final String? nom; // Champ facultatif pour le sign in
  final String email;
  final String password;
  final String? userId; // Champ facultatif

  // Constructeur principal
  User({
    required this.email,
    this.nom, // Facultatif pour les cas où "nom" n'est pas nécessaire
    required this.password,
    this.userId,
  });

  // Constructeur nommé pour le sign in
  User.signIn({
    required this.email,
    required this.password,
  })  : nom = null, // Le "nom" n'est pas utilisé ici
        userId = null;
  Map<String, dynamic> toJsonForSignIn() {
    return {
      'email': email,
      'password': password,
    };
  }
  // Méthode pour convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'email': email,
      'password': password,
    };
  }

  // Constructeur à partir d'un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nom: json['nom'],
      email: json['email'],
      password: '', // Le mot de passe ne devrait pas être exposé
      userId: json['userId'],
    );
  }
}
