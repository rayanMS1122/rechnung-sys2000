import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import '../content.dart';
import '../model/reciept_model.dart';

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

  Future<void> _generateAndSharePdf() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final ocrFont =
          pw.Font.ttf(await rootBundle.load("assets/fonts/cour.ttf"));
      final Uint8List logoBytes =
          await _screenInputController.logo.value.readAsBytes();
      final logoImage = pw.MemoryImage(logoBytes);

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
              marginBottom: 60,
            ),
            build: (pw.Context context) => [
              if (pageIndex == 0)
                pw.Center(
                  child:
                      pw.Image(logoImage, width: 200, fit: pw.BoxFit.contain),
                ),
              if (pageIndex == 0) pw.SizedBox(height: 30),
              // ──────── HIER DER NEUE BLOCK ────────
              if (pageIndex == 0) ...[
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(children: [
                        pw.SizedBox(height: 20),
                        pw.Center(
                            child: pw.Text("Firma",
                                style: pw.TextStyle(fontSize: 22))),
                        pw.SizedBox(height: 10),
                        pw.Center(
                            child: pw.Text(
                          _screenInputController.firmaNameController.text,
                          style: pw.TextStyle(fontSize: 20),
                        )),
                        pw.SizedBox(height: 8),
                        pw.Center(
                          child: pw.Text(
                            _screenInputController.firmaStrasseController.text,
                            style: pw.TextStyle(fontSize: 15),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Column(children: [
                          pw.SizedBox(height: 12),
                          pw.Center(
                            child: pw.Column(children: [
                              pw.Text(
                                  "E-Mail: ${_screenInputController.firmaEmailController.text}",
                                  style: pw.TextStyle(fontSize: 15)),
                              pw.Text(
                                  "Tel: ${_screenInputController.firmaTelefonController.text}",
                                  style: pw.TextStyle(fontSize: 15)),
                              pw.Text(
                                  _screenInputController
                                      .firmaWebsiteController.text,
                                  style: pw.TextStyle(fontSize: 15)),
                            ]),
                          ),
                        ])
                      ]),
                      pw.Column(
                        children: [
                          pw.SizedBox(height: 10),
                          pw.Center(
                              child: pw.Text("Baustelle Infos",
                                  style: pw.TextStyle(fontSize: 22))),
                          pw.SizedBox(height: 10),
                          pw.Center(
                            child: pw.Column(children: [
                              pw.Text(
                                  "${_screenInputController.baustelleStrasseController.text}",
                                  style: pw.TextStyle(fontSize: 15)),
                              pw.Text(
                                  "${_screenInputController.baustellePlzController.text}",
                                  style: pw.TextStyle(fontSize: 15)),
                              pw.Text(
                                  _screenInputController
                                      .baustelleOrtController.text,
                                  style: pw.TextStyle(fontSize: 15)),
                            ]),
                          ),
                        ],
                      )
                    ]),
                pw.SizedBox(height: 33),
              ],
              // ─────────────────────────────────────

              if (pages.length > 1)
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text(
                    'Seite ${pageIndex + 1} von ${pages.length}',
                    style: pw.TextStyle(
                        font: ocrFont, fontSize: 9, color: PdfColors.grey600),
                  ),
                ),
              if (pages.length > 1)
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Text(
                    'Seite ${pageIndex + 1} von ${pages.length}',
                    style: pw.TextStyle(
                        font: ocrFont, fontSize: 9, color: PdfColors.grey600),
                  ),
                ),
              if (pages.length > 1) pw.SizedBox(height: 10),
              _buildRow([
                'POS',
                'MENGE     ',
                'EINH',
                'BEZEICHNUNG',
                'EINZELPREIS',
                'GESAMTPREIS'
              ], ocrFont, isHeader: true),
              pw.Divider(height: 10, thickness: 1.5),
              ...pageData.asMap().entries.map((e) {
                final int globalIndex = pageIndex * linesPerPage + e.key + 1;
                final item = e.value;
                return _buildRow([
                  globalIndex.toString().padLeft(3),
                  item.menge.toStringAsFixed(2).padLeft(9),
                  item.einh.isNotEmpty ? item.einh : '-',
                  item.bezeichnung.isNotEmpty ? item.bezeichnung : '-',
                  '${item.einzelPreis.toStringAsFixed(2)} €',
                  '${item.gesamtPreis.toStringAsFixed(2)} €',
                ], ocrFont);
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
                  '${widget.receiptData.fold(0.0, (sum, e) => sum + e.gesamtPreis).toStringAsFixed(2)} €'
                ], ocrFont, isHeader: true),
                pw.SizedBox(height: 40),
                pw.Table(
                    tableWidth: pw.TableWidth.min,
                    border:
                        pw.TableBorder.symmetric(inside: pw.BorderSide.none),
                    children: [
                      pw.TableRow(children: [
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(11),
                                child: pw.Text("Kunde"),
                              )
                            ]),
                        pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Padding(
                                padding: pw.EdgeInsets.all(11),
                                child: pw.Text("Monteur"),
                              )
                            ]),
                      ]),
                      pw.TableRow(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                                top: pw.BorderSide(
                                    color: PdfColors.black, width: 2),
                                bottom: pw.BorderSide.none,
                                left: pw.BorderSide.none,
                                right: pw.BorderSide.none),
                          ),
                          children: [
                            pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Padding(
                                    padding: pw.EdgeInsets.all(11),
                                    child: pw.SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: pw.Image(pw.MemoryImage(
                                          _unterschriftController
                                              .kundePngBytes.value!)),
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
                                      child: pw.Image(pw.MemoryImage(
                                          _unterschriftController
                                              .monteurPngBytes.value!)),
                                    ),
                                  )
                                ])
                          ]),
                    ]),
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
        // Web: direkt download
        // (dein SharePlus-Code funktioniert auf Web nicht immer perfekt – hier besserer Weg falls nötig)
      } else {
        final dir = await getTemporaryDirectory();
        final file = File(
            "${dir.path}/Kassenbon_${DateTime.now().millisecondsSinceEpoch}.pdf");
        await file.writeAsBytes(pdfBytes);
        print(file.path);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Hier ist Ihr Kassenbon',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Erstellen des PDFs: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  pw.Widget _buildRow(List<String> cells, pw.Font font,
      {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: cells.map((text) {
          final bool isRight = text.contains('€') ||
              ['GESAMT', 'EINZELPREIS', 'GESAMTPREIS', 'MENGE     ']
                  .contains(text.trim());
          return pw.Expanded(
            child: pw.Text(
              text,
              style: pw.TextStyle(
                font: font,
                fontSize: isHeader ? 11 : 10,
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
              textAlign: isRight ? pw.TextAlign.right : pw.TextAlign.left,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kassenbon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Einstellungen'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(),
                      Text("firma infos "),
                      TextField(
                        controller: _screenInputController.firmaNameController,
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      TextField(
                        controller:
                            _screenInputController.firmaStrasseController,
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      TextField(
                        controller: _screenInputController.firmaPlzController,
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      TextField(
                        controller: _screenInputController.firmaOrtController,
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      TextField(
                        controller:
                            _screenInputController.firmaTelefonController,
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      TextField(
                        controller: _screenInputController.firmaEmailController,
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      Divider(),
                      Text("Baustelle infos "),
                      TextField(
                        controller:
                            _screenInputController.baustelleStrasseController,
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      TextField(
                        controller:
                            _screenInputController.baustellePlzController,
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      TextField(
                        controller:
                            _screenInputController.baustelleOrtController,
                        decoration: InputDecoration(label: Text("Name")),
                      ),
                      const Text("Logo ändern"),
                      IconButton(
                        onPressed: () =>
                            _screenInputController.changeLogo(context),
                        icon: Icon(Icons.image, size: 48.sp), // responsive Icon
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Speichern'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Abbrechen'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Live-Vorschau des Bons
          Expanded(
            child: Center(
              child: Container(
                width: 600.w, // responsiv
                constraints: BoxConstraints(maxWidth: 900.w),
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
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
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
            child: SizedBox(
              width: double.infinity,
              height: 64.h,
              child: ElevatedButton.icon(
                icon: _isProcessing
                    ? SizedBox(
                        width: 24.w,
                        height: 24.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(Icons.picture_as_pdf, size: 32.sp),
                label: Text(
                  _isProcessing
                      ? 'PDF wird erstellt...'
                      : 'Als PDF speichern & teilen',
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 4,
                ),
                onPressed: _isProcessing ? null : _generateAndSharePdf,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
