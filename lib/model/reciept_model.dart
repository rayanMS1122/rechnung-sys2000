class ReceiptData {
  int pos;
  int menge;
  String einh;
  String bezeichnung;
  double einzelPreis;

  ReceiptData({
    required this.pos,
    required this.menge,
    required this.einh,
    required this.bezeichnung,
    required this.einzelPreis,
  });
  double get gesamtPreis => menge * einzelPreis;
}
