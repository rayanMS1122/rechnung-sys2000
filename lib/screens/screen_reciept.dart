import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:reciepts/constants.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/screens/settings_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/content.dart';
import '../models/reciept_model.dart';

class ReceiptScreen extends StatefulWidget {
  final List<ReceiptData> receiptData;
  const ReceiptScreen({super.key, required this.receiptData});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final UnterschriftController _unterschriftController = Get.find();
  final ScreenInputController _screenInputController = Get.find();
  bool _isProcessing = false;

  // Deutsche Zahlenformatierung (Komma statt Punkt, immer 2 Dezimalstellen)
  final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'de_DE');

  // Hilfsfunktion für deutsche Zahlenformatierung
  String _formatNumber(double value) {
    return _numberFormat.format(value);
  }

  Future<void> _generateAndSharePdf() async {
    if (_isProcessing) return;

    final firmaName = _screenInputController.firmaNameController.text.trim();
    if (firmaName.isEmpty) {
      Get.snackbar(
        "Hinweis",
        "Bitte geben Sie die Firmendaten ein (mindestens Firmenname).\nGehen Sie zu den Einstellungen, um die Daten einzugeben.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 15,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        isDismissible: true,
        mainButton: TextButton(
          onPressed: () {
            Get.back();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            );
          },
          child: const Text(
            "Einstellungen",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }

    final baustelleStrasse =
        _screenInputController.baustelleStrasseController.text.trim();
    final baustellePlz =
        _screenInputController.baustellePlzController.text.trim();
    final baustelleOrt =
        _screenInputController.baustelleOrtController.text.trim();

    if (baustelleStrasse.isEmpty &&
        baustellePlz.isEmpty &&
        baustelleOrt.isEmpty) {
      Get.snackbar(
        "Hinweis",
        "Bitte geben Sie die Baustelle-Daten ein (mindestens Straße oder PLZ/Ort).\nGehen Sie zu den Einstellungen, um die Daten einzugeben.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 15,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        isDismissible: true,
        mainButton: TextButton(
          onPressed: () {
            Get.back();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            );
          },
          child: const Text(
            "Einstellungen",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
      return;
    }

    if (_unterschriftController.kundePngBytes.value == null) {
      Get.snackbar(
        "Hinweis",
        "Bitte geben Sie die Kunden-Unterschrift ein.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 15,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
      return;
    }

    if (_unterschriftController.monteurPngBytes.value == null) {
      Get.snackbar(
        "Hinweis",
        "Bitte geben Sie die Monteur-Unterschrift ein.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 15,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final ocrFont =
          pw.Font.ttf(await rootBundle.load("assets/fonts/cour.ttf"));

      Uint8List? logoBytes;
      pw.MemoryImage? logoImage;
      if (_screenInputController.logo.value.path.isNotEmpty) {
        try {
          final logoPath = _screenInputController.logo.value.path;
          if (logoPath.startsWith('assets/')) {
            final byteData = await rootBundle.load(logoPath);
            logoBytes = byteData.buffer.asUint8List();
            logoImage = pw.MemoryImage(logoBytes);
          } else {
            final file = File(logoPath);
            if (await file.exists()) {
              logoBytes = await file.readAsBytes();
              logoImage = pw.MemoryImage(logoBytes);
            }
          }
        } catch (e) {
          debugPrint("Fehler beim Laden des Logos: $e");
        }
      }

      final pdf = pw.Document();
      const int linesPerPage = 60;

      final List<List<ReceiptData>> pages = [];
      for (int i = 0; i < widget.receiptData.length; i += linesPerPage) {
        final end = (i + linesPerPage < widget.receiptData.length)
            ? i + linesPerPage
            : widget.receiptData.length;
        pages.add(widget.receiptData.sublist(i, end));
      }

      for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
        final pageData = pages[pageIndex];
        final bool isLastPage = pageIndex == pages.length - 1;

        pdf.addPage(
          pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(45),
            build: (pw.Context context) => [
              // HEADER SECTION
              if (pageIndex == 0) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Logo
                    if (logoImage != null)
                      pw.Container(
                        width: 80,
                        height: 80,
                        child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                      )
                    else
                      pw.SizedBox(width: 80),

                    // Rechnung Title
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "RECHNUNG",
                          style: pw.TextStyle(
                            font: ocrFont,
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey300,
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            DateFormat('dd.MM.yyyy - HH:mm')
                                .format(DateTime.now()),
                            style: pw.TextStyle(
                              font: ocrFont,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 35),

                // FIRMA & BAUSTELLE INFO
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Firma
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 8),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.grey700,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: pw.Text(
                                "FIRMA",
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            if (_screenInputController
                                .firmaNameController.text.isNotEmpty)
                              pw.Text(
                                _screenInputController.firmaNameController.text,
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            if (_screenInputController
                                .firmaStrasseController.text.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                _screenInputController
                                    .firmaStrasseController.text,
                                style: pw.TextStyle(font: ocrFont, fontSize: 9),
                              ),
                            ],
                            if (_screenInputController
                                    .firmaPlzController.text.isNotEmpty ||
                                _screenInputController
                                    .firmaOrtController.text.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                "${_screenInputController.firmaPlzController.text} ${_screenInputController.firmaOrtController.text}"
                                    .trim(),
                                style: pw.TextStyle(font: ocrFont, fontSize: 9),
                              ),
                            ],
                            if (_screenInputController
                                .firmaTelefonController.text.isNotEmpty) ...[
                              pw.SizedBox(height: 6),
                              pw.Text(
                                "Tel: ${_screenInputController.firmaTelefonController.text}",
                                style: pw.TextStyle(font: ocrFont, fontSize: 9),
                              ),
                            ],
                            if (_screenInputController
                                .firmaEmailController.text.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                _screenInputController
                                    .firmaEmailController.text,
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 9,
                                  color: PdfColors.blue800,
                                ),
                              ),
                            ],
                            if (_screenInputController
                                .firmaWebsiteController.text.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                _screenInputController
                                    .firmaWebsiteController.text,
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 9,
                                  color: PdfColors.blue800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 25),

                      // Vertikale Trennlinie
                      pw.Container(
                        width: 1,
                        height: 100,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(width: 25),

                      // Baustelle
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 8),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.grey700,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: pw.Text(
                                "BAUSTELLE",
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            if (_screenInputController
                                .baustelleStrasseController.text.isNotEmpty)
                              pw.Text(
                                _screenInputController
                                    .baustelleStrasseController.text,
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            if (_screenInputController
                                    .baustellePlzController.text.isNotEmpty ||
                                _screenInputController.baustelleOrtController
                                    .text.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                "${_screenInputController.baustellePlzController.text} ${_screenInputController.baustelleOrtController.text}"
                                    .trim(),
                                style: pw.TextStyle(font: ocrFont, fontSize: 9),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
              ],

              // Seitenzahl bei mehrseitigen Dokumenten
              if (pages.length > 1)
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text(
                    'Seite ${pageIndex + 1} von ${pages.length}',
                    style: pw.TextStyle(
                      font: ocrFont,
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              if (pages.length > 1) pw.SizedBox(height: 15),

              // POSITIONS TABELLE
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey800, width: 1.5),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    // Tabellen Header
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey800,
                        borderRadius: pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(5),
                          topRight: pw.Radius.circular(5),
                        ),
                      ),
                      padding:
                          pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: pw.Row(
                        children: [
                          pw.SizedBox(
                            width: 35,
                            child: pw.Text(
                              'POS',
                              style: pw.TextStyle(
                                font: ocrFont,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                          pw.SizedBox(
                            width: 55,
                            child: pw.Text(
                              'MENGE',
                              style: pw.TextStyle(
                                font: ocrFont,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.SizedBox(
                            width: 45,
                            child: pw.Text(
                              'EINH',
                              style: pw.TextStyle(
                                font: ocrFont,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              'BEZEICHNUNG',
                              style: pw.TextStyle(
                                font: ocrFont,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                          pw.SizedBox(
                            width: 75,
                            child: pw.Text(
                              'EINZELPREIS',
                              style: pw.TextStyle(
                                font: ocrFont,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text(
                              'GESAMT',
                              style: pw.TextStyle(
                                font: ocrFont,
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tabellen Inhalt
                    ...pageData.asMap().entries.expand((e) {
                      final int globalIndex =
                          pageIndex * linesPerPage + e.key + 1;
                      final item = e.value;
                      final bool isEven = e.key % 2 == 0;

                      final List<pw.Widget> widgets = [
                        pw.Container(
                          color: isEven ? PdfColors.grey100 : PdfColors.white,
                          padding: pw.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.SizedBox(
                                width: 35,
                                child: pw.Text(
                                  globalIndex.toString().padLeft(2, '0'),
                                  style: pw.TextStyle(
                                    font: ocrFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                              pw.SizedBox(
                                width: 55,
                                child: pw.Text(
                                  _formatNumber(item.menge),
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.SizedBox(width: 8),
                              pw.SizedBox(
                                width: 45,
                                child: pw.Text(
                                  item.einh.isNotEmpty ? item.einh : '-',
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9),
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Text(
                                  item.bezeichnung.isNotEmpty
                                      ? item.bezeichnung
                                      : '-',
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9),
                                  maxLines: 3,
                                ),
                              ),
                              pw.SizedBox(
                                width: 75,
                                child: pw.Text(
                                  '${_formatNumber(item.einzelPreis)} €',
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                              pw.SizedBox(width: 8),
                              pw.SizedBox(
                                width: 80,
                                child: pw.Text(
                                  '${_formatNumber(item.gesamtPreis)} €',
                                  style: pw.TextStyle(
                                    font: ocrFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];

                      // Bilder für diese Position
                      if (item.img != null && item.img!.isNotEmpty) {
                        final List<pw.Widget> imageWidgets = [];
                        for (var imagePath in item.img!) {
                          try {
                            final file = File(imagePath);
                            if (file.existsSync()) {
                              final imageBytes = file.readAsBytesSync();
                              imageWidgets.add(
                                pw.Container(
                                  width: 70,
                                  height: 70,
                                  decoration: pw.BoxDecoration(
                                    border: pw.Border.all(
                                      color: PdfColors.grey400,
                                      width: 1,
                                    ),
                                    borderRadius: pw.BorderRadius.circular(4),
                                  ),
                                  child: pw.ClipRRect(
                                    horizontalRadius: 3,
                                    verticalRadius: 3,
                                    child: pw.Image(
                                      pw.MemoryImage(imageBytes),
                                      fit: pw.BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint(
                                "Fehler beim Laden des Bildes für PDF: $e");
                          }
                        }
                        if (imageWidgets.isNotEmpty) {
                          widgets.add(
                            pw.Container(
                              color:
                                  isEven ? PdfColors.grey100 : PdfColors.white,
                              padding: pw.EdgeInsets.only(
                                  left: 12, right: 12, bottom: 10),
                              child: pw.Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: imageWidgets,
                              ),
                            ),
                          );
                        }
                      }

                      return widgets;
                    }),
                  ],
                ),
              ),

              if (!isLastPage) ...[
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Container(
                    padding:
                        pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey300,
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      'FORTSETZUNG FOLGT →',
                      style: pw.TextStyle(
                        font: ocrFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],

              if (isLastPage) ...[
                pw.SizedBox(height: 20),

                // GESAMTSUMME
                pw.Container(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey800,
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  padding:
                      pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'GESAMTBETRAG',
                        style: pw.TextStyle(
                          font: ocrFont,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.Text(
                        '${_formatNumber(widget.receiptData.fold(0.0, (sum, e) => sum + e.gesamtPreis))} €',
                        style: pw.TextStyle(
                          font: ocrFont,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // KUNDE & MONTEUR
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Kunde
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 8),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.grey700,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: pw.Text(
                                "KUNDE",
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            if (_screenInputController
                                .kunde.value.name.isNotEmpty)
                              pw.Text(
                                _screenInputController.kunde.value.name,
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            if (_screenInputController
                                .kunde.value.strasse.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                _screenInputController.kunde.value.strasse,
                                style: pw.TextStyle(font: ocrFont, fontSize: 9),
                              ),
                            ],
                            if (_screenInputController
                                    .kunde.value.plz.isNotEmpty ||
                                _screenInputController
                                    .kunde.value.ort.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                "${_screenInputController.kunde.value.plz} ${_screenInputController.kunde.value.ort}"
                                    .trim(),
                                style: pw.TextStyle(font: ocrFont, fontSize: 9),
                              ),
                            ],
                            if (_screenInputController
                                .kunde.value.telefon.isNotEmpty) ...[
                              pw.SizedBox(height: 6),
                              pw.Text(
                                "Tel: ${_screenInputController.kunde.value.telefon}",
                                style: pw.TextStyle(font: ocrFont, fontSize: 9),
                              ),
                            ],
                            if (_screenInputController
                                .kunde.value.email.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                _screenInputController.kunde.value.email,
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 9,
                                  color: PdfColors.blue800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 25),

                      // Vertikale Trennlinie
                      pw.Container(
                        width: 1,
                        height: 100,
                        color: PdfColors.grey400,
                      ),
                      pw.SizedBox(width: 25),

                      // Monteur
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 8),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.grey700,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: pw.Text(
                                "MONTEUR",
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 10),
                            if (_screenInputController
                                .monteur.value.vollerName.isNotEmpty)
                              pw.Text(
                                _screenInputController.monteur.value.vollerName,
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            if (_screenInputController
                                .monteur.value.telefon.isNotEmpty) ...[
                              pw.SizedBox(height: 6),
                              pw.Text(
                                "Tel: ${_screenInputController.monteur.value.telefon}",
                                style: pw.TextStyle(font: ocrFont, fontSize: 9),
                              ),
                            ],
                            if (_screenInputController
                                .monteur.value.email.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                _screenInputController.monteur.value.email,
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 9,
                                  color: PdfColors.blue800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // UNTERSCHRIFTEN
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "UNTERSCHRIFTEN",
                        style: pw.TextStyle(
                          font: ocrFont,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      pw.SizedBox(height: 20),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          // Kunde Unterschrift
                          pw.Column(
                            children: [
                              pw.Text(
                                "Kunde",
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Container(
                                width: 120,
                                height: 80,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    color: PdfColors.grey600,
                                    width: 1,
                                  ),
                                ),
                                child: _unterschriftController
                                            .kundePngBytes.value !=
                                        null
                                    ? pw.Image(
                                        pw.MemoryImage(
                                          _unterschriftController
                                              .kundePngBytes.value!,
                                        ),
                                        fit: pw.BoxFit.contain,
                                      )
                                    : pw.SizedBox(),
                              ),
                            ],
                          ),
                          // Monteur Unterschrift
                          pw.Column(
                            children: [
                              pw.Text(
                                "Monteur",
                                style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 9,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 10),
                              pw.Container(
                                width: 120,
                                height: 80,
                                decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                    color: PdfColors.grey600,
                                    width: 1,
                                  ),
                                ),
                                child: _unterschriftController
                                            .monteurPngBytes.value !=
                                        null
                                    ? pw.Image(
                                        pw.MemoryImage(
                                          _unterschriftController
                                              .monteurPngBytes.value!,
                                        ),
                                        fit: pw.BoxFit.contain,
                                      )
                                    : pw.SizedBox(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 30),

                // DATUM & UHRZEIT
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                    DateFormat('dd.MM.yyyy - HH:mm').format(DateTime.now()) +
                        ' Uhr',
                    style: pw.TextStyle(
                      font: ocrFont,
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }

      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        // Web: später ggf. Download-Logik
      } else {
        final dir = await getTemporaryDirectory();
        final file = File(
            "${dir.path}/Rechnung_${_screenInputController.kunde.value?.name}.pdf");
        await file.writeAsBytes(pdfBytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Hier ist Ihre Rechnung');
      }
    } catch (e) {
      Get.snackbar(
        "Fehler",
        "Fehler beim Erstellen des PDFs: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 15,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        isDismissible: true,
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // Verbesserter Custom Header mit SafeArea
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "Kassenbon Vorschau (Neues Design)",
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen()),
              ),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.settings,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom Header mit SafeArea für Android
          _buildHeader(context),

          // Live-Vorschau
          Expanded(
            child: Center(
              child: Container(
                width: 600.w,
                constraints: BoxConstraints(maxWidth: 900.w),
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 20.r,
                      offset: Offset(0, 8.h),
                    ),
                  ],
                ),
                child: ReceiptContent(receiptData: widget.receiptData),
              ),
            ),
          ),

          // PDF-Button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
              child: SizedBox(
                width: double.infinity,
                height: 64.h,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _generateAndSharePdf,
                  icon: _isProcessing
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : Icon(Icons.picture_as_pdf, size: 32.sp),
                  label: Text(
                    _isProcessing
                        ? 'PDF wird erstellt...'
                        : 'Als PDF speichern & teilen',
                    style: AppText.button.copyWith(fontSize: 18.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r)),
                    elevation: 6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
