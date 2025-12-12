// models/firma.dart
class Firma {
  final int? id;
  final String name;
  final String strasse;
  final String plz;
  final String ort;
  final String telefon;
  final String email;
  final String website;

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

  Firma copyWith({
    int? id,
    String? name,
    String? strasse,
    String? plz,
    String? ort,
    String? telefon,
    String? email,
    String? website,
  }) {
    return Firma(
      name: name ?? this.name,
      strasse: strasse ?? this.strasse,
      plz: plz ?? this.plz,
      ort: ort ?? this.ort,
      telefon: telefon ?? this.telefon,
      email: email ?? this.email,
      website: website ?? this.website,
    );
  }
}
