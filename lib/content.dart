import 'package:flutter/material.dart';
import 'package:reciepts/reciept_row.dart';

import 'model/reciept_model.dart';

class ReceiptContent extends StatelessWidget {
  final List<ReceiptData> receiptData;

  const ReceiptContent({super.key, required this.receiptData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
              child: Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Image.asset(
              'assets/system2000_logo.png',
              fit: BoxFit.fitWidth,
            ),
          )),
          // const SizedBox(height: 4),
          const SizedBox(height: 12),
          ReceiptRow(
            'POS',
            'MENGE',
            'EINH',
            'BEZEICHNUNG',
            'EINZELPREIS',
            'GESAMTPREIS',
          ),
          const SizedBox(height: 12),
          const Divider(),
          ListView.builder(
              itemBuilder: (context, index) {
                final data = receiptData[index];
                return ReceiptRow(
                  (index + 1).toString(),
                  data.menge.toString(),
                  data.einh.isNotEmpty ? data.einh : '-',
                  data.bezeichnung.isNotEmpty ? data.bezeichnung : '-',
                  data.einzelPreis.toStringAsFixed(2),
                  data.gesamtPreis.toStringAsFixed(2),
                );
              },
              itemCount: receiptData.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics()),
        ],
      ),
    );
  }
}
