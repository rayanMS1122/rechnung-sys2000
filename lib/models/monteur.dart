class Monteur {
  final int? id;
  final String vorname;
  final String nachname;
  final String telefon;
  final String email;

  Monteur({
    this.id,
    required this.vorname,
    required this.nachname,
    required this.telefon,
    this.email = '',
  });

  String get vollerName => '$vorname $nachname'.trim();

  factory Monteur.fromMap(Map<String, dynamic> json) => Monteur(
        id: json['id'] as int?,
        vorname: json['vorname'] ?? '',
        nachname: json['nachname'] ?? '',
        telefon: json['telefon'] ?? '',
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'vorname': vorname,
        'nachname': nachname,
        'telefon': telefon,
        'email': email,
      };

  Monteur copyWith({
    int? id,
    String? vorname,
    String? nachname,
    String? telefon,
    String? email,
  }) {
    return Monteur(
      id: id ?? this.id,
      vorname: vorname ?? this.vorname,
      nachname: nachname ?? this.nachname,
      telefon: telefon ?? this.telefon,
      email: email ?? this.email,
    );
  }
}
