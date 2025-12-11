import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/widgets/reciept_row.dart';
import 'package:reciepts/screens/unterschrft_screen.dart';

import '../model/reciept_model.dart';
import 'package:signature/signature.dart';

class ReceiptContent extends StatefulWidget {
  final List<ReceiptData> receiptData;

  const ReceiptContent({super.key, required this.receiptData});

  @override
  State<ReceiptContent> createState() => _ReceiptContentState();
}

class _ReceiptContentState extends State<ReceiptContent> {
  final UnterschriftController _unterschriftController = Get.find();
  final ScreenInputController _screenInputController = Get.find();
  double gesamtBetrag = 0;

  void calcGesamtBetrag() {
    gesamtBetrag = 0;
    for (var element in widget.receiptData) {
      gesamtBetrag += element.gesamtPreis;
    }
  }

  @override
  void initState() {
    calcGesamtBetrag();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo Section
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Obx(
                () => _screenInputController.logo.value != null
                    ? Image.file(
                        File(_screenInputController.logo.value!.path),
                        fit: BoxFit.fitWidth,
                        height: 100,
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Firma Section
          _buildSectionTitle("Firma"),
          const SizedBox(height: 10),
          _buildCenteredText(
            _screenInputController.firmaNameController.text,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          _buildCenteredText(
            _screenInputController.firmaStrasseController.text,
            fontSize: 15,
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                _buildInfoText(
                  "E-Mail: ${_screenInputController.firmaEmailController.text}",
                ),
                _buildInfoText(
                  "Tel: ${_screenInputController.firmaTelefonController.text}",
                ),
                _buildInfoText(
                  _screenInputController.firmaWebsiteController.text,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Baustelle Section
          _buildSectionTitle("Baustelle Infos"),
          const SizedBox(height: 10),
          Center(
            child: Column(
              children: [
                _buildInfoText(
                  _screenInputController.baustelleOrtController.text,
                ),
                _buildInfoText(
                  _screenInputController.baustellePlzController.text,
                ),
                _buildInfoText(
                  _screenInputController.baustelleOrtController.text,
                ),
              ],
            ),
          ),
          const SizedBox(height: 33),

          // Receipt Items Header
          ReceiptRow(
            'POS',
            'MENGE',
            'EINHEIT',
            'BEZEICHNUNG',
            'EP',
            'GP',
          ),
          const SizedBox(height: 12),
          const Divider(),

          // Receipt Items List
          ListView.builder(
            itemBuilder: (context, index) {
              final data = widget.receiptData[index];
              return Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: ReceiptRow(
                  (index + 1).toString().padLeft(2, '0'),
                  data.menge.toStringAsFixed(2),
                  data.einh.isNotEmpty ? data.einh : '-',
                  data.bezeichnung.isNotEmpty ? data.bezeichnung : '-',
                  data.einzelPreis.toStringAsFixed(2),
                  data.gesamtPreis.toStringAsFixed(2),
                ),
              );
            },
            itemCount: widget.receiptData.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
          const SizedBox(height: 10),
          const Divider(),

          // Total Amount
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                const Text(
                  "Gesamtbetrag:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "€ ${gesamtBetrag.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Signatures Section
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildSignatureContainer(
                    "Kunde",
                    _unterschriftController.kundeSignatureController,
                    _unterschriftController.kundePngBytes,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSignatureContainer(
                    "Monteur",
                    _unterschriftController.monteurSignatureController,
                    _unterschriftController.monteurPngBytes,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Date & Time
          Center(
            child: Text(
              _formatDateTime(DateTime.now()),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCenteredText(
    String text, {
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _buildSignatureContainer(
    String title,
    SignatureController signatureController,
    pngBytes,
  ) {
    return InkWell(
      onTap: () async {
        _unterschriftController.clearSignature(signatureController);
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UnterschrftScreen(title: title),
          ),
        );
      },
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: pngBytes.value == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 32, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          "Zum Unterschreiben\ntippen",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Image.memory(
                              pngBytes.value!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "✓ Unterschrift bestätigt",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} Uhr";
  }
}
