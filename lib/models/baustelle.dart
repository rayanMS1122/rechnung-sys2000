// models/baustelle.dart
class Baustelle {
  int? id;
  String strasse;
  String plz;
  String ort;
  int kundeId; // WICHTIG: Referenz auf Kunde

  Baustelle({
    this.id,
    required this.strasse,
    required this.plz,
    required this.ort,
    required this.kundeId,
  });

  factory Baustelle.fromMap(Map<String, dynamic> json) => Baustelle(
        id: json['id'] as int?,
        strasse: json['strasse'] ?? '',
        plz: json['plz'] ?? '',
        ort: json['ort'] ?? '',
        kundeId: json['kundeId'] as int,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'strasse': strasse,
        'plz': plz,
        'ort': ort,
        'kundeId': kundeId,
      };
}
