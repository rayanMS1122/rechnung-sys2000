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

  // Dein PDF-Generator bleibt unverändert (funktioniert super!)
  Future<void> _generateAndSharePdf() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final ocrFont =
          pw.Font.ttf(await rootBundle.load("assets/fonts/cour.ttf"));
      
      // Logo mit Null-Check laden
      Uint8List? logoBytes;
      pw.MemoryImage? logoImage;
      if (_screenInputController.logo.value.path.isNotEmpty) {
        try {
          final logoPath = _screenInputController.logo.value.path;
          // Prüfe ob es ein Asset-Pfad ist
          if (logoPath.startsWith('assets/')) {
            // Asset-Logo laden
            final byteData = await rootBundle.load(logoPath);
            logoBytes = byteData.buffer.asUint8List();
            logoImage = pw.MemoryImage(logoBytes);
          } else {
            // Normale Datei
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
      const int linesPerPage = 65;

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
            margin: pw.EdgeInsets.all(40),
            pageFormat: PdfPageFormat.a4.copyWith(
                marginLeft: 30,
                marginRight: 30,
                marginTop: 40,
                marginBottom: 60),
            build: (pw.Context context) => [
              if (pageIndex == 0 && logoImage != null)
                pw.Center(
                    child: pw.Image(logoImage,
                        width: 150, height: 150, fit: pw.BoxFit.contain)),
              if (pageIndex == 0 && logoImage != null) pw.SizedBox(height: 30),
              if (pageIndex == 0) ...[
                // Firma und Baustelle - konsistentes Layout
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Firma
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Firma",
                            style: pw.TextStyle(
                              font: ocrFont,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          if (_screenInputController.firmaNameController.text.isNotEmpty)
                            pw.Text(
                              _screenInputController.firmaNameController.text,
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          if (_screenInputController.firmaStrasseController.text.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              _screenInputController.firmaStrasseController.text,
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                          if (_screenInputController.firmaPlzController.text.isNotEmpty ||
                              _screenInputController.firmaOrtController.text.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "${_screenInputController.firmaPlzController.text} ${_screenInputController.firmaOrtController.text}".trim(),
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                          if (_screenInputController.firmaTelefonController.text.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "Tel: ${_screenInputController.firmaTelefonController.text}",
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                          if (_screenInputController.firmaEmailController.text.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "E-Mail: ${_screenInputController.firmaEmailController.text}",
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                          if (_screenInputController.firmaWebsiteController.text.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              _screenInputController.firmaWebsiteController.text,
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 30),
                    // Baustelle
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Baustelle Infos",
                            style: pw.TextStyle(
                              font: ocrFont,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          if (_screenInputController.baustelleStrasseController.text.isNotEmpty)
                            pw.Text(
                              _screenInputController.baustelleStrasseController.text,
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          if (_screenInputController.baustellePlzController.text.isNotEmpty ||
                              _screenInputController.baustelleOrtController.text.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "${_screenInputController.baustellePlzController.text} ${_screenInputController.baustelleOrtController.text}".trim(),
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 33),
              ],
              if (pages.length > 1)
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text('Seite ${pageIndex + 1} von ${pages.length}',
                      style: pw.TextStyle(
                          font: ocrFont,
                          fontSize: 9,
                          color: PdfColors.grey600)),
                ),
              if (pages.length > 1) pw.SizedBox(height: 10),
              _buildRow([
                'POS',
                'MENGE',
                'EINH',
                'BEZEICHNUNG',
                'EINZELPREIS',
                'GESAMTPREIS'
              ], ocrFont, isHeader: true),
              pw.Divider(height: 10, thickness: 1.5),
              ...pageData.asMap().entries.expand((e) {
                final int globalIndex = pageIndex * linesPerPage + e.key + 1;
                final item = e.value;
                final List<pw.Widget> widgets = [
                  _buildRow([
                    globalIndex.toString().padLeft(2, '0'),
                    _formatNumber(item.menge),
                    item.einh.isNotEmpty ? item.einh : '-',
                    item.bezeichnung.isNotEmpty ? item.bezeichnung : '-',
                    '${_formatNumber(item.einzelPreis)} €',
                    '${_formatNumber(item.gesamtPreis)} €',
                  ], ocrFont),
                ];
                
                // Bilder für diese Position hinzufügen
                if (item.img != null && item.img!.isNotEmpty) {
                  widgets.add(pw.SizedBox(height: 8));
                  
                  // Bilder synchron laden
                  final List<pw.Widget> imageWidgets = [];
                  for (var imagePath in item.img!) {
                    try {
                      final file = File(imagePath);
                      if (file.existsSync()) {
                        final imageBytes = file.readAsBytesSync();
                        imageWidgets.add(
                          pw.Container(
                            width: 80,
                            height: 80,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey300, width: 1),
                            ),
                            child: pw.Image(
                              pw.MemoryImage(imageBytes),
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      debugPrint("Fehler beim Laden des Bildes für PDF: $e");
                    }
                  }
                  
                  if (imageWidgets.isNotEmpty) {
                    widgets.add(
                      pw.Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: imageWidgets,
                      ),
                    );
                    widgets.add(pw.SizedBox(height: 8));
                  }
                }
                
                return widgets;
              }),
              if (!isLastPage) ...[
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 8),
                _buildRow(
                    ['', '', '', 'FORTSETZUNG FOLGT...', '', ''], ocrFont),
              ],
              if (isLastPage) ...[
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 10),
                _buildRow([
                  '',
                  '',
                  '',
                  'GESAMTBETRAG',
                  '',
                  '${_formatNumber(widget.receiptData.fold(0.0, (sum, e) => sum + e.gesamtPreis))} €'
                ], ocrFont, isHeader: true),
                pw.SizedBox(height: 30),
                // Kunde & Monteur Informationen - konsistentes Layout
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Kunde Info
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Kunde",
                            style: pw.TextStyle(
                              font: ocrFont,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          if (_screenInputController.kunde.value.name.isNotEmpty)
                            pw.Text(
                              _screenInputController.kunde.value.name,
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          if (_screenInputController.kunde.value.strasse.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              _screenInputController.kunde.value.strasse,
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                          if (_screenInputController.kunde.value.plz.isNotEmpty ||
                              _screenInputController.kunde.value.ort.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "${_screenInputController.kunde.value.plz} ${_screenInputController.kunde.value.ort}".trim(),
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                          if (_screenInputController.kunde.value.telefon.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "Tel: ${_screenInputController.kunde.value.telefon}",
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                          if (_screenInputController.kunde.value.email.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "E-Mail: ${_screenInputController.kunde.value.email}",
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 30),
                    // Monteur Info
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "Monteur",
                            style: pw.TextStyle(
                              font: ocrFont,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          if (_screenInputController.monteur.value.vollerName.isNotEmpty)
                            pw.Text(
                              _screenInputController.monteur.value.vollerName,
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          if (_screenInputController.monteur.value.telefon.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "Tel: ${_screenInputController.monteur.value.telefon}",
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                          if (_screenInputController.monteur.value.email.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              "E-Mail: ${_screenInputController.monteur.value.email}",
                              style: pw.TextStyle(font: ocrFont, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Text(
                  "Unterschriften:",
                  style: pw.TextStyle(
                    font: ocrFont,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Table(
                  tableWidth: pw.TableWidth.min,
                  border: pw.TableBorder.symmetric(inside: pw.BorderSide.none),
                  children: [
                    pw.TableRow(children: [
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Padding(
                                padding: pw.EdgeInsets.all(11),
                                child: pw.Text("Kunde"))
                          ]),
                      pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          children: [
                            pw.Padding(
                                padding: pw.EdgeInsets.all(11),
                                child: pw.Text("Monteur"))
                          ]),
                    ]),
                    pw.TableRow(
                      decoration: pw.BoxDecoration(
                          border: pw.Border(
                              top: pw.BorderSide(
                                  color: PdfColors.black, width: 2))),
                      children: [
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(11),
                                child: pw.SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: _unterschriftController
                                              .kundePngBytes.value !=
                                          null
                                      ? pw.Image(pw.MemoryImage(
                                          _unterschriftController
                                              .kundePngBytes.value!))
                                      : pw.Text(""),
                                ),
                              )
                            ]),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(11),
                                child: pw.SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: _unterschriftController
                                              .monteurPngBytes.value !=
                                          null
                                      ? pw.Image(pw.MemoryImage(
                                          _unterschriftController
                                              .monteurPngBytes.value!))
                                      : pw.Text(""),
                                ),
                              )
                            ]),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  '${DateTime.now().toString().substring(0, 16).replaceAll('-', '.')} Uhr',
                  style: pw.TextStyle(font: ocrFont, fontSize: 10),
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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Erstellen des PDFs: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  pw.Widget _buildRow(List<String> cells, pw.Font font,
      {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          // POS - 8% der Breite
          pw.SizedBox(
            width: 40,
            child: pw.Text(
              cells[0],
              style: pw.TextStyle(
                font: font,
                fontSize: isHeader ? 10 : 9,
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(width: 8),
          // MENGE - 12% der Breite
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              cells[1],
              style: pw.TextStyle(
                font: font,
                fontSize: isHeader ? 10 : 9,
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.SizedBox(width: 8),
          // EINH - 10% der Breite
          pw.SizedBox(
            width: 50,
            child: pw.Text(
              cells[2],
              style: pw.TextStyle(
                font: font,
                fontSize: isHeader ? 10 : 9,
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.left,
            ),
          ),
          pw.SizedBox(width: 8),
          // BEZEICHNUNG - Nimmt den restlichen Platz
          pw.Expanded(
            child: pw.Text(
              cells[3],
              style: pw.TextStyle(
                font: font,
                fontSize: isHeader ? 10 : 9,
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.left,
              maxLines: 2,
            ),
          ),
          pw.SizedBox(width: 8),
          // EINZELPREIS - 12% der Breite
          pw.SizedBox(
            width: 70,
            child: pw.Text(
              cells[4],
              style: pw.TextStyle(
                font: font,
                fontSize: isHeader ? 10 : 9,
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.SizedBox(width: 8),
          // GESAMTPREIS - 12% der Breite
          pw.SizedBox(
            width: 75,
            child: pw.Text(
              cells[5],
              style: pw.TextStyle(
                font: font,
                fontSize: isHeader ? 10 : 9,
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: PdfColors.black,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
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
                  "Kassenbon Vorschau",
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
