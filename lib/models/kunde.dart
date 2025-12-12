class Kunde {
  final int? id;
  final String name;
  final String strasse;
  final String plz;
  final String ort;
  final String telefon;
  final String email;

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

  Kunde copyWith({
    int? id,
    String? name,
    String? strasse,
    String? plz,
    String? ort,
    String? telefon,
    String? email,
  }) {
    return Kunde(
      id: id ?? this.id,
      name: name ?? this.name,
      strasse: strasse ?? this.strasse,
      plz: plz ?? this.plz,
      ort: ort ?? this.ort,
      telefon: telefon ?? this.telefon,
      email: email ?? this.email,
    );
  }
}
