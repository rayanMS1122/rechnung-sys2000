import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class UnterschriftController extends GetxController {
  SignatureController kundeSignatureController = SignatureController(
    penColor: Colors.black,
  );
  SignatureController monteurSignatureController = SignatureController(
    penColor: Colors.black,
  );

  var kundePngBytes = Rx<Uint8List?>(null);
  var monteurPngBytes = Rx<Uint8List?>(null);

  late var kundeSignatureCanvas = Signature(
    backgroundColor: Colors.white,
    controller: kundeSignatureController,
  );
  late var monteurSignatureCanvas = Signature(
    backgroundColor: Colors.white,
    controller: monteurSignatureController,
  );

  clearSignature(SignatureController signatureController) {
    signatureController.clear();
  }

  Future<void> saveKundeBytesToImage(BuildContext context) async {
    try {
      kundePngBytes.value = await kundeSignatureController.toPngBytes();
      Navigator.pop(context);
      debugPrint(kundePngBytes.value!.length.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> saveMonteurBytesToImage(BuildContext context) async {
    try {
      monteurPngBytes.value = await monteurSignatureController.toPngBytes();
      Navigator.pop(context);
      debugPrint(monteurPngBytes.value!.length.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
