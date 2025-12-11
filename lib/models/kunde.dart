// models/kunde.dart
class Kunde {
  int? id;
  String name;
  String strasse;
  String plz;
  String ort;
  String telefon;
  String email;

  Kunde({
    this.id,
    required this.name,
    required this.strasse,
    required this.plz,
    required this.ort,
    required this.telefon,
    required this.email,
  });

  factory Kunde.fromMap(Map<String, dynamic> json) => Kunde(
        id: json['id'] as int?,
        name: json['name'] ?? '',
        strasse: json['strasse'] ?? '',
        plz: json['plz'] ?? '',
        ort: json['ort'] ?? '',
        telefon: json['telefon'] ?? '',
        email: json['email'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'strasse': strasse,
        'plz': plz,
        'ort': ort,
        'telefon': telefon,
        'email': email,
      };
}
