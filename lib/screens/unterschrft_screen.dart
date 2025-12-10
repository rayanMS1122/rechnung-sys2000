import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';

class UnterschrftScreen extends StatelessWidget {
  final title;
  UnterschrftScreen({required this.title, super.key});
  UnterschriftController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Unterschriften"),
        actions: [
          IconButton(
            onPressed: _controller.clearSignature(title == "Kunde"
                ? _controller.kundeSignatureController
                : _controller.monteurSignatureController),
            icon: Icon(Icons.clear),
          ),
          IconButton(
            onPressed: () {
              title == "Kunde"
                  ? _controller.saveKundeBytesToImage(context)
                  : _controller.saveMonteurBytesToImage(context);

              // _controller.update();
            },
            icon: Icon(Icons.save),
          )
        ],
      ),
      body: title == "Kunde"
          ? _controller.kundeSignatureCanvas
          : _controller.monteurSignatureCanvas,
    );
  }
}
