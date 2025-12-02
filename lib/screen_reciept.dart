import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'content.dart';
import 'model/reciept_model.dart';

class ReceiptScreen extends StatefulWidget {
  final List<ReceiptData> receiptData;

  const ReceiptScreen({super.key, required this.receiptData});

  @override
  _ReceiptScreenState createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isProcessing = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Uint8List> _capturePng() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
        actions: [],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Center(
            child: RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: 600,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ReceiptContent(receiptData: widget.receiptData),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isProcessing
                ? null
                : () async {
                    setState(() {
                      _isProcessing = true;
                    });
                    try {
                      Uint8List pngBytes = await _capturePng();

                      final directory = await Directory.systemTemp.createTemp();

                      final filePath = '${directory.path}/receipt.png';
                      final file = File(filePath);
                      await file.writeAsBytes(pngBytes);
                      print('PNG gespeichert unter: $filePath');
                      await SharePlus.instance.share(ShareParams(
                        files: [XFile(filePath)],
                      ));
                    } catch (e) {
                      print('Fehler: $e');
                    } finally {
                      setState(() {
                        _isProcessing = false;
                      });
                    }
                  },
            child: _isProcessing
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : const Text('Export as PNG'),
          ),
        ],
      ),
    );
  }
}
