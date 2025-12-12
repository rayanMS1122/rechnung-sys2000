import 'package:flutter/material.dart';

class ReceiptRow extends StatelessWidget {
  final String pos;
  final String menge;
  final String einh;
  final String bezeichnung;
  final String einzelPreis;
  final String gesamtPreis;
  final bool isHeader;

  const ReceiptRow(
    this.pos,
    this.menge,
    this.einh,
    this.bezeichnung,
    this.einzelPreis,
    this.gesamtPreis, {
    super.key,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(40), // POS
        1: FixedColumnWidth(55), // MENGE
        2: FixedColumnWidth(50), // EINHEIT
        3: FlexColumnWidth(3), // BEZEICHNUNG (flexibel)
        4: FixedColumnWidth(60), // EP
        5: FixedColumnWidth(65), // GP
      },
      children: [
        TableRow(
          children: [
            _buildCell(pos, TextAlign.left),
            _buildCell(menge, TextAlign.right),
            _buildCell(einh, TextAlign.center),
            _buildCell(bezeichnung, TextAlign.left),
            _buildCell(einzelPreis, TextAlign.right),
            _buildCell(gesamtPreis, TextAlign.right),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(String text, TextAlign alignment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 12 : 13,
          color: isHeader ? Colors.black87 : Colors.black54,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w600,
        ),
        textAlign: alignment,
        maxLines: isHeader ? 1 : 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
