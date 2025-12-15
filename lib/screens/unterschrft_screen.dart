import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';

class UnterschrftScreen extends StatefulWidget {
  final title;
  UnterschrftScreen({required this.title, super.key});

  @override
  State<UnterschrftScreen> createState() => _UnterschrftScreenState();
}

class _UnterschrftScreenState extends State<UnterschrftScreen> {
  UnterschriftController _controller = Get.find();
  Timer? _checkTimer;
  int _lastPointCount = 0;
  DateTime? _lastDrawingTime;
  bool _hasDrawn = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Periodischer Timer, der prüft, ob der User aufgehört hat zu zeichnen
    _checkTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final signatureController = widget.title == "Kunde"
          ? _controller.kundeSignatureController
          : _controller.monteurSignatureController;

      // Aktuelle Anzahl der Punkte prüfen
      final currentPointCount = signatureController.points.length;

      // Wenn sich die Punkte geändert haben, hat der User gezeichnet
      if (currentPointCount > _lastPointCount) {
        _hasDrawn = true;
        _lastDrawingTime = DateTime.now();
        _lastPointCount = currentPointCount;
      }

      // Wenn der User gezeichnet hat und seit 1 Sekunde nicht mehr gezeichnet hat
      if (_hasDrawn &&
          _lastDrawingTime != null &&
          currentPointCount > 0 &&
          DateTime.now().difference(_lastDrawingTime!).inMilliseconds >= 1000) {
        timer.cancel();
        _saveAndClose();
      }
    });
  }

  Future<void> _saveAndClose() async {
    if (!mounted) return;

    try {
      if (widget.title == "Kunde") {
        await _controller.saveKundeBytesToImage(context);
      } else {
        await _controller.saveMonteurBytesToImage(context);
      }
    } catch (e) {
      debugPrint("Fehler beim Speichern der Unterschrift: $e");
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _checkTimer?.cancel();

    // Zurück auf Hochformat
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Wichtig im Landscape, wegen Notch/Statusbar
        child: Stack(
          children: [
            // Haupt-Zeichenbereich – füllt fast alles aus
            Padding(
              padding: const EdgeInsets.all(16.0), // Abstand zum Rand
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: widget.title == "Kunde"
                    ? _controller.kundeSignatureCanvas
                    : _controller.monteurSignatureCanvas,
              ),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: Text(
                widget.title + " Unterschrift",
                style: TextStyle(fontSize: 24, color: Colors.black54),
              ),
            ),

            // Optional: "Löschen"-Button oben rechts
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.clear, size: 32),
                onPressed: () {
                  if (widget.title == "Kunde") {
                    _controller.kundeSignatureController.clear();
                  } else {
                    _controller.monteurSignatureController.clear();
                  }
                  setState(() {
                    _hasDrawn = false;
                    _lastPointCount = 0;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
