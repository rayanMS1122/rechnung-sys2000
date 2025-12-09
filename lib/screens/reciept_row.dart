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
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                menge,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.end,
              ),
            ),
          ),
          Expanded(
            child: Text(
              einh,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              bezeichnung,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              einzelPreis,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.end,
            ),
          ),
          Expanded(
            child: Text(
              gesamtPreis,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
