// models/monteur.dart
class Monteur {
  int? id;
  String vorname;
  String nachname;
  String telefon;
  String email;

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
}
