class ReceiptData {
  int pos;
  List<String>? img;
  double menge;
  String einh;
  String bezeichnung;
  double einzelPreis;

  ReceiptData({
    required this.pos,
    required this.menge,
    required this.einh,
    required this.bezeichnung,
    required this.einzelPreis,
    this.img,
  });
  double get gesamtPreis => menge * einzelPreis;

  ReceiptData copyWith({
    int? pos,
    List<String>? img,
    double? menge,
    String? einh,
    String? bezeichnung,
    double? einzelPreis,
  }) {
    return ReceiptData(
      pos: pos ?? this.pos,
      img: img ?? this.img,
      menge: menge ?? this.menge,
      einh: einh ?? this.einh,
      bezeichnung: bezeichnung ?? this.bezeichnung,
      einzelPreis: einzelPreis ?? this.einzelPreis,
    );
  }
}
