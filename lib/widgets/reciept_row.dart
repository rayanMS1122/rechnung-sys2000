import 'package:flutter/material.dart';

class ReceiptRow extends StatelessWidget {
  final String pos;
  final String menge;
  final String einh;
  final String bezeichnung;
  final String einzelPreis;
  final String gesamtPreis;

  const ReceiptRow(this.pos, this.menge, this.einh, this.bezeichnung,
      this.einzelPreis, this.gesamtPreis,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2.5),
      child: Row(
        children: [
          // POS - Feste Breite
          SizedBox(
            width: 35,
            child: Text(
              pos,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // MENGE - Feste Breite
          SizedBox(
            width: 50,
            child: Text(
              menge,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),

          // EINHEIT - Feste Breite
          SizedBox(
            width: 45,
            child: Text(
              einh,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // BEZEICHNUNG - Flexible, nimmt verfügbaren Platz
          Expanded(
            flex: 3,
            child: Text(
              bezeichnung,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),

          // EINZELPREIS - Feste Breite
          SizedBox(
            width: 55,
            child: Text(
              einzelPreis,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),

          // GESAMTPREIS - Feste Breite
          SizedBox(
            width: 60,
            child: Text(
              gesamtPreis,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
