import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';
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
  final String dokumentTitel;
  // final String dokumentTitel = "RECHNUNG";
  const ReceiptScreen(
      {super.key, required this.receiptData, required this.dokumentTitel});

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final UnterschriftController _unterschriftController = Get.find();
  final ScreenInputController _screenInputController = Get.find();
  bool _isProcessing = false;

  // Deutsche Zahlenformatierung
  final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'de_DE');
  String _formatNumber(double value) => _numberFormat.format(value);
// Entferne diese Imports, falls du sie nur für SVG brauchst:
// import 'dart:ui' as ui;
// import 'package:flutter_svg/flutter_svg.dart';

// Füge diesen Import hinzu (falls noch nicht vorhanden):

// Ersetze deine komplette _generateQrImage()-Methode durch diese:
  Future<pw.MemoryImage?> _generateQrImage() async {
    final qrData = _screenInputController.qrData.value;
    if (qrData.isEmpty) {
      debugPrint("Kein QR-Data vorhanden – QR-Code wird übersprungen");
      return null;
    }

    try {
      // Verwende QrPainter aus qr_flutter, um ein Bild zu malen
      final painter = QrPainter(
        data: qrData,
        version: QrVersions.auto,
        // errorCorrectionLevel: QrErrorCorrectionLevel.L,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );

      // Erstelle ein Bild mit gewünschter Größe
      final picData =
          await painter.toImageData(300, format: ui.ImageByteFormat.png);

      if (picData != null) {
        return pw.MemoryImage(picData.buffer.asUint8List());
      }
    } catch (e) {
      debugPrint("Fehler beim Generieren des QR-Codes: $e");
    }
    return null;
  }

  Future<void> _generateAndSharePdf() async {
    if (_isProcessing) return;

    // Validierungen
    final firmaName = _screenInputController.firmaNameController.text.trim();
    if (firmaName.isEmpty) {
      Get.snackbar(
        "Hinweis",
        "Bitte geben Sie die Firmendaten ein (mindestens Firmenname).\nGehen Sie zu den Einstellungen.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 15,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            Get.back();
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => SettingsScreen()));
          },
          child: const Text("Einstellungen",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        "Bitte geben Sie die Baustelle-Daten ein (mindestens Straße oder PLZ/Ort).",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        borderRadius: 15,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            Get.back();
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => SettingsScreen()));
          },
          child: const Text("Einstellungen",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      );
      return;
    }

    if (_unterschriftController.kundePngBytes.value == null ||
        _unterschriftController.monteurPngBytes.value == null) {
      Get.snackbar(
        "Hinweis",
        "Bitte geben Sie beide Unterschriften ein (Kunde & Monteur).",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final ocrFont =
          pw.Font.ttf(await rootBundle.load("assets/fonts/cour.ttf"));

      // Logo laden
      pw.MemoryImage? logoImage;
      if (_screenInputController.logo.value.path.isNotEmpty) {
        try {
          final logoPath = _screenInputController.logo.value.path;
          Uint8List logoBytes;
          if (logoPath.startsWith('assets/')) {
            final byteData = await rootBundle.load(logoPath);
            logoBytes = byteData.buffer.asUint8List();
          } else {
            final file = File(logoPath);
            if (await file.exists()) {
              logoBytes = await file.readAsBytes();
            } else {
              logoBytes = Uint8List(0);
            }
          }
          if (logoBytes.isNotEmpty) {
            logoImage = pw.MemoryImage(logoBytes);
          }
        } catch (e) {
          debugPrint("Logo-Fehler: $e");
        }
      }

      // QR-Code generieren
      final pw.MemoryImage? qrImage = await _generateQrImage();

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
              // HEADER (nur erste Seite)
              if (pageIndex == 0) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Logo links
                    if (logoImage != null)
                      pw.Container(
                        width: 80,
                        height: 80,
                        child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                      )
                    else
                      pw.SizedBox(width: 80),

                    pw.SizedBox(width: 30), // Abstand zum QR-Block

                    // QR-RECHNUNG mittig (nur wenn vorhanden)
                    if (qrImage != null)
                      pw.Expanded(
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.SizedBox(width: 20),
                            pw.Container(
                              width:
                                  80, // Etwas kleiner für Header (original 140)
                              height: 80,
                              padding: pw.EdgeInsets.all(8),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey600),
                                borderRadius: pw.BorderRadius.circular(6),
                              ),
                              child: pw.Image(qrImage, fit: pw.BoxFit.contain),
                            ),
                          ],
                        ),
                      )
                    else
                      pw.Expanded(
                          child: pw.SizedBox()), // Platzhalter, falls kein QR

                    pw.SizedBox(width: 30), // Abstand zum Titel

                    // Rechnungstitel rechts
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(widget.dokumentTitel,
                            style: pw.TextStyle(
                                font: ocrFont,
                                fontSize: 24,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 2)),
                        pw.SizedBox(height: 8),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: pw.BoxDecoration(
                              color: PdfColors.grey300,
                              borderRadius: pw.BorderRadius.circular(4)),
                          child: pw.Text(
                              DateFormat('dd.MM.yyyy - HH:mm')
                                  .format(DateTime.now()),
                              style: pw.TextStyle(
                                  font: ocrFont,
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(
                    height:
                        35), // Abstand zum nächsten Block (Firma/Baustelle)                pw.SizedBox(height: 35),

                // FIRMA & BAUSTELLE
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 8),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                                        color: PdfColors.grey700, width: 2)),
                              ),
                              child: pw.Text("FIRMA",
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                      letterSpacing: 1)),
                            ),
                            pw.SizedBox(height: 10),
                            if (_screenInputController
                                .firmaNameController.text.isNotEmpty)
                              pw.Text(
                                  _screenInputController
                                      .firmaNameController.text,
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold)),
                            if (_screenInputController
                                .firmaStrasseController.text.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                  _screenInputController
                                      .firmaStrasseController.text,
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9)),
                            ],
                            if (_screenInputController
                                    .firmaPlzController.text.isNotEmpty ||
                                _screenInputController
                                    .firmaOrtController.text.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                  "${_screenInputController.firmaPlzController.text} ${_screenInputController.firmaOrtController.text}"
                                      .trim(),
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9)),
                            ],
                            if (_screenInputController
                                .firmaTelefonController.text.isNotEmpty) ...[
                              pw.SizedBox(height: 6),
                              pw.Text(
                                  "Tel: ${_screenInputController.firmaTelefonController.text}",
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9)),
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
                                      color: PdfColors.blue800)),
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
                                      color: PdfColors.blue800)),
                            ],
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 25),
                      pw.Container(
                          width: 1, height: 100, color: PdfColors.grey400),
                      pw.SizedBox(width: 25),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              padding: pw.EdgeInsets.only(bottom: 8),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                    bottom: pw.BorderSide(
                                        color: PdfColors.grey700, width: 2)),
                              ),
                              child: pw.Text("BAUSTELLE",
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                      letterSpacing: 1)),
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
                                      fontWeight: pw.FontWeight.bold)),
                            if (_screenInputController
                                    .baustellePlzController.text.isNotEmpty ||
                                _screenInputController.baustelleOrtController
                                    .text.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                  "${_screenInputController.baustellePlzController.text} ${_screenInputController.baustelleOrtController.text}"
                                      .trim(),
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
              ],

              // Seitenzahl (bei mehreren Seiten)
              if (pages.length > 1)
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text('Seite ${pageIndex + 1} von ${pages.length}',
                      style: pw.TextStyle(
                          font: ocrFont,
                          fontSize: 9,
                          color: PdfColors.grey600)),
                ),
              if (pages.length > 1) pw.SizedBox(height: 15),

              // POSITIONSTABELLE
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey800, width: 1.5),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  children: [
                    // Header
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey800,
                        borderRadius: const pw.BorderRadius.only(
                            topLeft: pw.Radius.circular(5),
                            topRight: pw.Radius.circular(5)),
                      ),
                      padding:
                          pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: pw.Row(
                        children: [
                          pw.SizedBox(
                              width: 35,
                              child: pw.Text('POS',
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white))),
                          pw.SizedBox(
                              width: 55,
                              child: pw.Text('MENGE',
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white),
                                  textAlign: pw.TextAlign.right)),
                          pw.SizedBox(width: 8),
                          pw.SizedBox(
                              width: 45,
                              child: pw.Text('EINH',
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white))),
                          pw.Expanded(
                              child: pw.Text('BEZEICHNUNG',
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white))),
                          pw.SizedBox(
                              width: 75,
                              child: pw.Text('EINZELPREIS',
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white),
                                  textAlign: pw.TextAlign.right)),
                          pw.SizedBox(width: 8),
                          pw.SizedBox(
                              width: 80,
                              child: pw.Text('GESAMT',
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.white),
                                  textAlign: pw.TextAlign.right)),
                        ],
                      ),
                    ),

                    // Zeilen + Bilder
                    ...pageData.asMap().entries.expand((e) {
                      final int globalIndex =
                          pageIndex * linesPerPage + e.key + 1;
                      final item = e.value;
                      final bool isEven = e.key % 2 == 0;

                      final List<pw.Widget> row = [
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
                                          fontWeight: pw.FontWeight.bold))),
                              pw.SizedBox(
                                  width: 55,
                                  child: pw.Text(_formatNumber(item.menge),
                                      style: pw.TextStyle(
                                          font: ocrFont, fontSize: 9),
                                      textAlign: pw.TextAlign.right)),
                              pw.SizedBox(width: 8),
                              pw.SizedBox(
                                  width: 45,
                                  child: pw.Text(
                                      item.einh.isNotEmpty ? item.einh : '-',
                                      style: pw.TextStyle(
                                          font: ocrFont, fontSize: 9))),
                              pw.Expanded(
                                  child: pw.Text(
                                      item.bezeichnung.isNotEmpty
                                          ? item.bezeichnung
                                          : '-',
                                      style: pw.TextStyle(
                                          font: ocrFont, fontSize: 9),
                                      maxLines: 3)),
                              pw.SizedBox(
                                  width: 75,
                                  child: pw.Text(
                                      '${_formatNumber(item.einzelPreis)} €',
                                      style: pw.TextStyle(
                                          font: ocrFont, fontSize: 9),
                                      textAlign: pw.TextAlign.right)),
                              pw.SizedBox(width: 8),
                              pw.SizedBox(
                                  width: 80,
                                  child: pw.Text(
                                      '${_formatNumber(item.gesamtPreis)} €',
                                      style: pw.TextStyle(
                                          font: ocrFont,
                                          fontSize: 9,
                                          fontWeight: pw.FontWeight.bold),
                                      textAlign: pw.TextAlign.right)),
                            ],
                          ),
                        ),
                      ];

                      // Bilder der Position
                      if (item.img != null && item.img!.isNotEmpty) {
                        final List<pw.Widget> imageWidgets = [];
                        for (var path in item.img!) {
                          try {
                            final file = File(path);
                            if (file.existsSync()) {
                              final bytes = file.readAsBytesSync();
                              imageWidgets.add(
                                pw.Container(
                                  width: 70,
                                  height: 70,
                                  decoration: pw.BoxDecoration(
                                      border: pw.Border.all(
                                          color: PdfColors.grey400),
                                      borderRadius:
                                          pw.BorderRadius.circular(4)),
                                  child: pw.ClipRRect(
                                    horizontalRadius: 3,
                                    verticalRadius: 3,
                                    child: pw.Image(pw.MemoryImage(bytes),
                                        fit: pw.BoxFit.cover),
                                  ),
                                ),
                              );
                            }
                          } catch (_) {}
                        }
                        if (imageWidgets.isNotEmpty) {
                          row.add(
                            pw.Container(
                              color:
                                  isEven ? PdfColors.grey100 : PdfColors.white,
                              padding: pw.EdgeInsets.only(
                                  left: 12, right: 12, bottom: 10),
                              child: pw.Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: imageWidgets),
                            ),
                          );
                        }
                      }

                      return row;
                    }),
                  ],
                ),
              ),

              // Fortsetzungshinweis
              if (!isLastPage) ...[
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Container(
                    padding:
                        pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                        borderRadius: pw.BorderRadius.circular(4)),
                    child: pw.Text('FORTSETZUNG FOLGT →',
                        style: pw.TextStyle(
                            font: ocrFont,
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                ),
              ],

              // Nur auf letzter Seite
              if (isLastPage) ...[
                pw.SizedBox(height: 20),
                // Gesamtbetrag
                pw.Container(
                  decoration: pw.BoxDecoration(
                      color: PdfColors.grey800,
                      borderRadius: pw.BorderRadius.circular(6)),
                  padding:
                      pw.EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('GESAMTBETRAG',
                          style: pw.TextStyle(
                              font: ocrFont,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                              letterSpacing: 1)),
                      pw.Text(
                          '${_formatNumber(widget.receiptData.fold(0.0, (sum, e) => sum + e.gesamtPreis))} €',
                          style: pw.TextStyle(
                              font: ocrFont,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // KUNDE & MONTEUR
                pw.Container(
                  decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400, width: 1),
                      borderRadius: pw.BorderRadius.circular(8)),
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
                                          color: PdfColors.grey700, width: 2))),
                              child: pw.Text("KUNDE",
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                      letterSpacing: 1)),
                            ),
                            pw.SizedBox(height: 10),
                            if (_screenInputController
                                .kunde.value.name.isNotEmpty)
                              pw.Text(_screenInputController.kunde.value.name,
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold)),
                            if (_screenInputController
                                .kunde.value.strasse.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                  _screenInputController.kunde.value.strasse,
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9)),
                            ],
                            if (_screenInputController
                                    .kunde.value.plz.isNotEmpty ||
                                _screenInputController
                                    .kunde.value.ort.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                  "${_screenInputController.kunde.value.plz} ${_screenInputController.kunde.value.ort}"
                                      .trim(),
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9)),
                            ],
                            if (_screenInputController
                                .kunde.value.telefon.isNotEmpty) ...[
                              pw.SizedBox(height: 6),
                              pw.Text(
                                  "Tel: ${_screenInputController.kunde.value.telefon}",
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9)),
                            ],
                            if (_screenInputController
                                .kunde.value.email.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(_screenInputController.kunde.value.email,
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 9,
                                      color: PdfColors.blue800)),
                            ],
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 25),
                      pw.Container(
                          width: 1, height: 100, color: PdfColors.grey400),
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
                                          color: PdfColors.grey700, width: 2))),
                              child: pw.Text("MONTEUR",
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                      letterSpacing: 1)),
                            ),
                            pw.SizedBox(height: 10),
                            if (_screenInputController
                                .monteur.value.vollerName.isNotEmpty)
                              pw.Text(
                                  _screenInputController
                                      .monteur.value.vollerName,
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold)),
                            if (_screenInputController
                                .monteur.value.telefon.isNotEmpty) ...[
                              pw.SizedBox(height: 6),
                              pw.Text(
                                  "Tel: ${_screenInputController.monteur.value.telefon}",
                                  style:
                                      pw.TextStyle(font: ocrFont, fontSize: 9)),
                            ],
                            if (_screenInputController
                                .monteur.value.email.isNotEmpty) ...[
                              pw.SizedBox(height: 3),
                              pw.Text(
                                  _screenInputController.monteur.value.email,
                                  style: pw.TextStyle(
                                      font: ocrFont,
                                      fontSize: 9,
                                      color: PdfColors.blue800)),
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
                      borderRadius: pw.BorderRadius.circular(8)),
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Column(
                    children: [
                      pw.Text("UNTERSCHRIFTEN",
                          style: pw.TextStyle(
                              font: ocrFont,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 1)),
                      pw.SizedBox(height: 20),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                        children: [
                          pw.Column(children: [
                            pw.Text("Kunde",
                                style: pw.TextStyle(
                                    font: ocrFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 10),
                            pw.Container(
                              width: 120,
                              height: 80,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.grey600, width: 1)),
                              child:
                                  _unterschriftController.kundePngBytes.value !=
                                          null
                                      ? pw.Image(
                                          pw.MemoryImage(_unterschriftController
                                              .kundePngBytes.value!),
                                          fit: pw.BoxFit.contain)
                                      : pw.SizedBox(),
                            ),
                          ]),
                          pw.Column(children: [
                            pw.Text("Monteur",
                                style: pw.TextStyle(
                                    font: ocrFont,
                                    fontSize: 9,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 10),
                            pw.Container(
                              width: 120,
                              height: 80,
                              decoration: pw.BoxDecoration(
                                  border: pw.Border.all(
                                      color: PdfColors.grey600, width: 1)),
                              child: _unterschriftController
                                          .monteurPngBytes.value !=
                                      null
                                  ? pw.Image(
                                      pw.MemoryImage(_unterschriftController
                                          .monteurPngBytes.value!),
                                      fit: pw.BoxFit.contain)
                                  : pw.SizedBox(),
                            ),
                          ]),
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
                      '${DateFormat('dd.MM.yyyy - HH:mm').format(DateTime.now())} Uhr',
                      style: pw.TextStyle(
                          font: ocrFont,
                          fontSize: 9,
                          color: PdfColors.grey600)),
                ),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Zahlungsinformationen",
                      style: pw.TextStyle(
                          font: ocrFont,
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text("Empfänger:",
                      style: pw.TextStyle(font: ocrFont, fontSize: 9)),
                  pw.Text(
                      _screenInputController.nameBankQrController.text.trim(),
                      style: pw.TextStyle(
                          font: ocrFont,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      "IBAN: ${_screenInputController.ibanBankQrController.text.trim()}",
                      style: pw.TextStyle(font: ocrFont, fontSize: 9)),
                  if (_screenInputController.bicBankQrController.text
                      .trim()
                      .isNotEmpty)
                    pw.Text(
                        "BIC: ${_screenInputController.bicBankQrController.text.trim()}",
                        style: pw.TextStyle(font: ocrFont, fontSize: 9)),
                  pw.Text(
                      "Betrag: ${_formatNumber(widget.receiptData.fold(0.0, (sum, e) => sum + e.gesamtPreis))} €",
                      style: pw.TextStyle(
                          font: ocrFont,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold)),
                  if (_screenInputController.purposeBankQrController.text
                      .trim()
                      .isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Text("Verwendungszweck:",
                        style: pw.TextStyle(font: ocrFont, fontSize: 9)),
                    pw.Text(
                        _screenInputController.purposeBankQrController.text
                            .trim(),
                        style: pw.TextStyle(font: ocrFont, fontSize: 9)),
                  ],
                ],
              ),
            ],
          ),
        );
      }

      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        // Web-Handling später ergänzen
      } else {
        final dir = await getTemporaryDirectory();
        final fileName =
            "Rechnung_${_screenInputController.kunde.value.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf";
        final file = File("${dir.path}/$fileName");
        await file.writeAsBytes(pdfBytes);
        await Share.shareXFiles([XFile(file.path)],
            text: 'Hier ist Ihre Rechnung');
      }
    } catch (e) {
      Get.snackbar("Fehler", "PDF konnte nicht erstellt werden: $e",
          backgroundColor: Colors.redAccent.withOpacity(0.9),
          colorText: Colors.white);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

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
                    borderRadius: BorderRadius.circular(12.r)),
                child: Icon(Icons.arrow_back,
                    color: AppColors.primary, size: 24.sp),
              ),
            ),
            Expanded(
              child: Center(
                child: Obx(
                  () => Text(
                      "${_screenInputController.dokumentTitel.value} Vorschau",
                      style: TextStyle(
                          fontSize: 20.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SettingsScreen())),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r)),
                child:
                    Icon(Icons.settings, color: AppColors.primary, size: 24.sp),
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
          _buildHeader(context),
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
                        offset: Offset(0, 8.h))
                  ],
                ),
                child: ReceiptContent(receiptData: widget.receiptData),
              ),
            ),
          ),
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
                      style: AppText.button.copyWith(fontSize: 18.sp)),
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
