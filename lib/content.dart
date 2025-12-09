import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/screens/reciept_row.dart';
import 'package:reciepts/screens/unterschrft_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'model/reciept_model.dart';
import "package:intl/intl.dart";
import 'package:signature/signature.dart';

class ReceiptContent extends StatefulWidget {
  final List<ReceiptData> receiptData;

  ReceiptContent({super.key, required this.receiptData});

  @override
  State<ReceiptContent> createState() => _ReceiptContentState();
}

class _ReceiptContentState extends State<ReceiptContent> {
  final UnterschriftController _unterschriftController = Get.find();
  final ScreenInputController _screenInputController = Get.find();
  double gesamtBetrag = 0;

  void calcGesamtBetrag() {
    widget.receiptData.forEach(
      (element) {
        gesamtBetrag = element.gesamtPreis + gesamtBetrag;
      },
    );
  }

  @override
  void initState() {
    calcGesamtBetrag();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 20, right: 20, bottom: 10),
                child: Obx(
                  () => Image.file(
                    File(_screenInputController.logo.value.path),
                    fit: BoxFit.fitWidth,
                  ),
                )),
          ),
          SizedBox(height: 30),
          Center(child: Text("Firma", style: TextStyle(fontSize: 22))),
          SizedBox(height: 10),
          Center(
              child: Text(
            _screenInputController.firmaNameController.text,
            style: TextStyle(fontSize: 20),
          )),
          SizedBox(height: 8),
          Center(
            child: Text(
              _screenInputController.firmaStrasseController.text,
              style: TextStyle(fontSize: 15),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 12),
          Center(
            child: Column(children: [
              Text(
                  "E-Mail: ${_screenInputController.firmaEmailController.text}",
                  style: TextStyle(fontSize: 15)),
              Text("Tel: ${_screenInputController.firmaTelefonController.text}",
                  style: TextStyle(fontSize: 15)),
              Text(_screenInputController.firmaWebsiteController.text,
                  style: TextStyle(fontSize: 15)),
            ]),
          ),
          SizedBox(height: 10),
          Center(
              child: Text("Baustelle Infos", style: TextStyle(fontSize: 22))),
          SizedBox(height: 10),
          Center(
            child: Column(children: [
              Text(
                  "E-Mail: ${_screenInputController.baustelleStrasseController.text}",
                  style: TextStyle(fontSize: 15)),
              Text("Tel: ${_screenInputController.baustellePlzController.text}",
                  style: TextStyle(fontSize: 15)),
              Text(_screenInputController.baustelleOrtController.text,
                  style: TextStyle(fontSize: 15)),
            ]),
          ),
          const SizedBox(height: 33),
          ReceiptRow(
            'POS',
            'MENGE',
            'EINHEIT',
            'BEZEICHNUNG',
            'EP',
            'GP',
          ),
          const SizedBox(height: 12),
          const Divider(),
          ListView.builder(
              itemBuilder: (context, index) {
                final data = widget.receiptData[index];

                return Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: ReceiptRow(
                    (index + 1).toString(),
                    data.menge.toStringAsFixed(2),
                    data.einh.isNotEmpty ? data.einh : '-',
                    data.bezeichnung.isNotEmpty ? data.bezeichnung : '-',
                    data.einzelPreis.toStringAsFixed(2),
                    data.gesamtPreis.toStringAsFixed(2),
                  ),
                );
              },
              itemCount: widget.receiptData.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics()),
          SizedBox(
            height: 10,
          ),
          Divider(),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(""),
                Text(
                  "Gesamtbetrag:",
                  style: const TextStyle(
                      fontSize: 9,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  gesamtBetrag.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SignatureContainer(
                    "Kunde",
                    _unterschriftController.kundeSignatureController,
                    _unterschriftController.kundePngBytes,
                  ),
                  SignatureContainer(
                    "Monteur",
                    _unterschriftController.monteurSignatureController,
                    _unterschriftController.monteurPngBytes,
                  ),
                ],
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Divider(
                  indent: 22,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Text(
              "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}  ${DateTime.now().hour}:${DateTime.now().minute} Uhr")
        ],
      ),
    );
  }

  Widget SignatureContainer(
      String title, SignatureController signatureController, pngBytes) {
    return MaterialButton(
      onPressed: () async {
        _unterschriftController.clearSignature(signatureController);
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UnterschrftScreen(
                    title: title,
                  )),
        );
      },
      child: Column(
        children: [
          Text(title),
          Container(
            width: MediaQuery.sizeOf(context).width * .3,
            height: MediaQuery.sizeOf(context).height * .2,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: pngBytes.value == null
                  ? Text(
                      "Zum Unterschreiben\ntippen",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.memory(
                          pngBytes.value!,
                          width: 200,
                          height: 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Unterschrift bestätigt",
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[700]),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
