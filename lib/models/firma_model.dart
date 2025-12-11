// models/firma.dart
class Firma {
  int? id; // Normalerweise immer 1
  String name;
  String strasse;
  String plz;
  String ort;
  String telefon;
  String email;
  String website;

  Firma({
    this.id,
    required this.name,
    required this.strasse,
    required this.plz,
    required this.ort,
    required this.telefon,
    required this.email,
    required this.website,
  });

  factory Firma.fromMap(Map<String, dynamic> json) => Firma(
        id: json['id'] as int?,
        name: json['name'] ?? '',
        strasse: json['strasse'] ?? '',
        plz: json['plz'] ?? '',
        ort: json['ort'] ?? '',
        telefon: json['telefon'] ?? '',
        email: json['email'] ?? '',
        website: json['website'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'strasse': strasse,
        'plz': plz,
        'ort': ort,
        'telefon': telefon,
        'email': email,
        'website': website,
      };
}
