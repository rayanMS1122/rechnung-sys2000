import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';

class UnterschrftScreen extends StatefulWidget {
  final title;
  UnterschrftScreen({required this.title, super.key});

  @override
  State<UnterschrftScreen> createState() => _UnterschrftScreenState();
}

class _UnterschrftScreenState extends State<UnterschrftScreen> {
  UnterschriftController _controller = Get.find();
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Zurück auf Hochformat, wenn du willst
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unterschriften"),
        actions: [
          IconButton(
            onPressed: _controller.clearSignature(widget.title == "Kunde"
                ? _controller.kundeSignatureController
                : _controller.monteurSignatureController),
            icon: Icon(Icons.clear),
          ),
          IconButton(
            onPressed: () {
              widget.title == "Kunde"
                  ? _controller.saveKundeBytesToImage(context)
                  : _controller.saveMonteurBytesToImage(context);

              // _controller.update();
            },
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: widget.title == "Kunde"
          ? _controller.kundeSignatureCanvas
          : _controller.monteurSignatureCanvas,
    );
  }
}
