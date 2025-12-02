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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              pos,
              style: const TextStyle(
                  fontFamily: 'OCR-B',
                  fontSize: 9,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              menge,
              style: const TextStyle(
                  fontFamily: 'OCR-B',
                  fontSize: 9,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              einh,
              style: const TextStyle(
                  fontFamily: 'OCR-B',
                  fontSize: 9,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              bezeichnung,
              style: const TextStyle(
                  fontFamily: 'OCR-B',
                  fontSize: 9,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              einzelPreis,
              style: const TextStyle(
                  fontFamily: 'OCR-B',
                  fontSize: 9,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              gesamtPreis,
              style: const TextStyle(
                  fontFamily: 'OCR-B',
                  fontSize: 9,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
