import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/screens/screen_reciept.dart';
import 'package:reciepts/screens/settings_screen.dart';
import 'package:signature/signature.dart';

class ScreenInput extends StatefulWidget {
  const ScreenInput({super.key});

  @override
  State<ScreenInput> createState() => _ScreenInputState();
}

class _ScreenInputState extends State<ScreenInput> {
  final _formKey = GlobalKey<FormState>();
  final ScreenInputController _controller = Get.find();
  final UnterschriftController _unterschriftController = Get.find();
  final ScrollController _scrollController = ScrollController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReceiptScreen(receiptData: _controller.rechnungTextFielde),
        ),
      );
    }
  }

  bool get editingEnabled {
    final enable = _controller.enableEditing.value;
    final hasSignature =
        (_unterschriftController.kundePngBytes.value ?? []).isNotEmpty ||
            (_unterschriftController.monteurPngBytes.value ?? []).isNotEmpty;
    return enable || !hasSignature;
  }

  void scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.position.maxScrollExtent;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 222),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Receipt Data'),
        actions: [
          Obx(
            () => editingEnabled
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _controller.rechnungTextFielde.clear,
                  )
                : const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SettingsScreen()));
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Obx(() => editingEnabled
                    ? ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: _controller.rechnungTextFielde.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 12.h),
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header mit Position und Löschen
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Position ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _controller.rechnungTextFielde
                                              .removeAt(index);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        iconSize: 24.sp,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),

                                  // Menge und Einheit in einer Zeile
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          decoration: InputDecoration(
                                            labelText: 'Menge',
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 16.h,
                                            ),
                                          ),
                                          style: TextStyle(fontSize: 14.sp),
                                          onChanged: (value) {
                                            _controller
                                                    .rechnungTextFielde[index]
                                                    .menge =
                                                double.tryParse(value) ?? 0.0;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        flex: 1,
                                        child: TextFormField(
                                          decoration: InputDecoration(
                                            labelText: 'Einheit',
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 16.h,
                                            ),
                                          ),
                                          style: TextStyle(fontSize: 14.sp),
                                          onChanged: (value) {
                                            _controller
                                                .rechnungTextFielde[index]
                                                .einh = value;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        flex: 1,
                                        child: // Einzelpreis
                                            TextFormField(
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          decoration: InputDecoration(
                                            labelText: 'Einzelpreis',
                                            border: const OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                              horizontal: 12.w,
                                              vertical: 16.h,
                                            ),
                                          ),
                                          style: TextStyle(fontSize: 14.sp),
                                          onChanged: (value) {
                                            _controller
                                                    .rechnungTextFielde[index]
                                                    .einzelPreis =
                                                double.tryParse(value) ?? 0.0;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 12.h),

                                  // Bezeichnung in voller Breite
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Bezeichnung',
                                      border: const OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 16.h,
                                      ),
                                    ),
                                    style: TextStyle(fontSize: 14.sp),
                                    onChanged: (value) {
                                      _controller.rechnungTextFielde[index]
                                          .bezeichnung = value;
                                    },
                                  ),
                                  SizedBox(height: 12.h),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Text(
                            "Du kannst die Rechnung nach der Unterschrift nicht bearbeiten. Gehe in die Einstellungen und aktiviere dort Rechnung bearbeiten",
                            style: TextStyle(fontSize: 16.sp),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )),
              ),
              SizedBox(height: 16.h),
              Obx(
                () => editingEnabled
                    ? SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _controller.addNewTextFields();
                            scrollToEnd();
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 32.w, vertical: 16.h),
                            textStyle: TextStyle(fontSize: 16.sp),
                          ),
                          child: const Text('Neue Zeile'),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _unterschriftController.kundePngBytes.value = null;
                    _unterschriftController.monteurPngBytes.value = null;
                    _controller.rechnungTextFielde.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    textStyle: TextStyle(fontSize: 16.sp),
                  ),
                  child: const Text('Neue Rechnung'),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    textStyle: TextStyle(fontSize: 16.sp),
                  ),
                  child: const Text('Weiter'),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
