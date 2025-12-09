import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/screens/screen_reciept.dart';
import '../model/reciept_model.dart';

class ScreenInput extends StatefulWidget {
  const ScreenInput({super.key});

  @override
  State<ScreenInput> createState() => _ScreenInputState();
}

class _ScreenInputState extends State<ScreenInput> {
  final _formKey = GlobalKey<FormState>();
  final ScreenInputController controller = Get.put(ScreenInputController());

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReceiptScreen(receiptData: controller.rechnungTextFielde),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wichtig: ScreenUtilInit sollte eigentlich im main.dart / MaterialApp sein
    // Falls du es noch nicht hast, hier ein kurzer Hinweis am Ende

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Receipt Data'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: controller.rechnungTextFielde.clear,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w), // responsiv
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 0.6
                      .sh, // 60% der Bildschirmhöhe – viel sauberer als MediaQuery
                  child: Obx(
                    () => ListView.builder(
                      itemCount: controller.rechnungTextFielde.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: 12.0.h), // schöner Zeilenabstand
                          child: Row(
                            children: [
                              // Positionsnummer (deaktiviert)
                              Expanded(
                                child: TextFormField(
                                  enabled: false,
                                  decoration: InputDecoration(
                                    labelText: (index + 1).toString(),
                                    border: const OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 16.h,
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                              SizedBox(width: 8.w),

                              // Menge
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Menge',
                                    border: const OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 16.h,
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14.sp),
                                  onChanged: (value) {
                                    controller.rechnungTextFielde[index].menge =
                                        double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),

                              // Einheit
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Einh',
                                    border: const OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 16.h,
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14.sp),
                                  onChanged: (value) {
                                    controller.rechnungTextFielde[index].einh =
                                        value;
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),

                              // Bezeichnung
                              Expanded(
                                flex: 2, // etwas mehr Platz für langen Text
                                child: TextFormField(
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
                                    controller.rechnungTextFielde[index]
                                        .bezeichnung = value;
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),

                              // Einzelpreis
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Einzelpreis',
                                    border: const OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 16.h,
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14.sp),
                                  onChanged: (value) {
                                    controller.rechnungTextFielde[index]
                                            .einzelPreis =
                                        double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),

                              // Löschen-Button
                              IconButton(
                                onPressed: () {
                                  controller.rechnungTextFielde.removeAt(index);
                                },
                                icon: Icon(Icons.delete,
                                    color: Colors.redAccent, size: 28.sp),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: controller.addNewTextFields,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    textStyle: TextStyle(fontSize: 16.sp),
                  ),
                  child: const Text('Neue Zeile'),
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                    textStyle: TextStyle(fontSize: 16.sp),
                  ),
                  child: const Text('Generate Receipt'),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
