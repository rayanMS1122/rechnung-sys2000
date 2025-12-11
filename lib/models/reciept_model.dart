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
}
