import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/widgets/reciept_row.dart';
import 'package:reciepts/screens/unterschrft_screen.dart';

import '../models/reciept_model.dart';
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
  
  // Deutsche Zahlenformatierung (Komma statt Punkt, immer 2 Dezimalstellen)
  final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'de_DE');

  void calcGesamtBetrag() {
    gesamtBetrag = 0;
    for (var element in widget.receiptData) {
      gesamtBetrag += element.gesamtPreis;
    }
  }
  
  // Hilfsfunktion für deutsche Zahlenformatierung
  String _formatNumber(double value) {
    // NumberFormat mit 'de_DE' verwendet bereits Komma als Dezimaltrennzeichen
    return _numberFormat.format(value);
  }

  @override
  void initState() {
    calcGesamtBetrag();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Gesamtbetrag bei jedem Build neu berechnen
    calcGesamtBetrag();
    
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
              child: Obx(() {
                final logoFile = _screenInputController.logo.value;
                if (logoFile.path.isNotEmpty) {
                  // Prüfe ob es ein Asset-Pfad ist
                  if (logoFile.path.startsWith('assets/')) {
                    return Image.asset(
                      logoFile.path,
                      fit: BoxFit.fitWidth,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    );
                  } else if (File(logoFile.path).existsSync()) {
                    // Normale Datei
                    return Image.file(
                      File(logoFile.path),
                      fit: BoxFit.fitWidth,
                      height: 100,
                    );
                  }
                }
                return const SizedBox.shrink();
              }),
            ),
          ),
          const SizedBox(height: 30),

          // Firma Section
          _buildSectionTitle("Firma"),
          const SizedBox(height: 10),
          Obx(() => _buildCenteredText(
                _screenInputController.firma.value.name,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          Obx(() =>
              _buildCenteredText(_screenInputController.firma.value.strasse)),
          const SizedBox(height: 12),
          Center(
            child: Obx(() => Column(
                  children: [
                    _buildInfoText(
                        "E-Mail: ${_screenInputController.firma.value.email}"),
                    _buildInfoText(
                        "Tel: ${_screenInputController.firma.value.telefon}"),
                    if (_screenInputController.firma.value.website.isNotEmpty)
                      _buildInfoText(
                          _screenInputController.firma.value.website),
                  ],
                )),
          ),
          const SizedBox(height: 30),

          // Baustelle Section
          _buildSectionTitle("Baustelle Infos"),
          const SizedBox(height: 10),
          Center(
            child: Obx(() => Column(
                  children: [
                    if (_screenInputController
                        .baustelle.value.strasse.isNotEmpty)
                      _buildInfoText(
                          _screenInputController.baustelle.value.strasse),
                    if (_screenInputController.baustelle.value.plz.isNotEmpty ||
                        _screenInputController.baustelle.value.plz != null)
                      _buildInfoText(
                          "${_screenInputController.baustelle.value.plz} ${_screenInputController.baustelle.value.ort ?? ""}"),
                  ],
                )),
          ),
          const SizedBox(height: 33),

          // Receipt Items Header - MIT isHeader: true
          ReceiptRow(
            'POS',
            'MENGE',
            'EINHEIT',
            'BEZEICHNUNG',
            'EP',
            'GP',
            isHeader: true,
          ),
          const SizedBox(height: 12),
          const Divider(),

          // Receipt Items List
          ListView.builder(
            itemBuilder: (context, index) {
              final data = widget.receiptData[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ReceiptRow(
                      (index + 1).toString().padLeft(2, '0'),
                      _formatNumber(data.menge),
                      data.einh.isNotEmpty ? data.einh : '-',
                      data.bezeichnung.isNotEmpty ? data.bezeichnung : '-',
                      _formatNumber(data.einzelPreis),
                      _formatNumber(data.gesamtPreis),
                      isHeader: false,
                    ),
                  ),
                  // Bilder für diese Position anzeigen
                  if (data.img != null && data.img!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.img!.length,
                        itemBuilder: (context, imgIndex) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(data.img![imgIndex]),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.broken_image,
                                        color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${_formatNumber(gesamtBetrag)} €",
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Kunde & Monteur Section
          _buildSectionTitle("Kunde & Monteur"),
          const SizedBox(height: 15),
          Obx(() => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kunde Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kunde:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_screenInputController.kunde.value.name.isNotEmpty)
                          _buildInfoText(
                              _screenInputController.kunde.value.name),
                        if (_screenInputController.kunde.value.strasse.isNotEmpty)
                          _buildInfoText(
                              _screenInputController.kunde.value.strasse),
                        if (_screenInputController.kunde.value.plz.isNotEmpty ||
                            _screenInputController.kunde.value.ort.isNotEmpty)
                          _buildInfoText(
                              "${_screenInputController.kunde.value.plz} ${_screenInputController.kunde.value.ort}".trim()),
                        if (_screenInputController.kunde.value.telefon.isNotEmpty)
                          _buildInfoText(
                              "Tel: ${_screenInputController.kunde.value.telefon}"),
                        if (_screenInputController.kunde.value.email.isNotEmpty)
                          _buildInfoText(
                              "E-Mail: ${_screenInputController.kunde.value.email}"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Monteur Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Monteur:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_screenInputController.monteur.value.vollerName.isNotEmpty)
                          _buildInfoText(
                              _screenInputController.monteur.value.vollerName),
                        if (_screenInputController.monteur.value.telefon.isNotEmpty)
                          _buildInfoText(
                              "Tel: ${_screenInputController.monteur.value.telefon}"),
                        if (_screenInputController.monteur.value.email.isNotEmpty)
                          _buildInfoText(
                              "E-Mail: ${_screenInputController.monteur.value.email}"),
                      ],
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 30),

          // Signatures Section
          _buildSectionTitle("Unterschriften"),
          const SizedBox(height: 15),
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