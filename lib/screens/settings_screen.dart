// settings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/screens/unterschrft_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ScreenInputController _controller = Get.find();
  final UnterschriftController _unterschriftController = Get.find();

  SettingsScreen({super.key});

  Widget _buildTextField(TextEditingController ctrl, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen", style: TextStyle(fontSize: 20.sp)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Firma",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.h),
                    _buildTextField(
                        _controller.firmaNameController, "Firmenname"),
                    _buildTextField(
                        _controller.firmaStrasseController, "Straße & Hausnr."),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                _controller.firmaPlzController, "PLZ")),
                        SizedBox(width: 12.w),
                        Expanded(
                            flex: 2,
                            child: _buildTextField(
                                _controller.firmaOrtController, "Ort")),
                      ],
                    ),
                    _buildTextField(
                        _controller.firmaTelefonController, "Telefon"),
                    _buildTextField(_controller.firmaEmailController, "E-Mail"),
                    _buildTextField(
                        _controller.firmaWebsiteController, "Website"),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Baustelle",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16.h),
                    _buildTextField(_controller.baustelleStrasseController,
                        "Straße & Hausnr."),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                _controller.baustellePlzController, "PLZ")),
                        SizedBox(width: 12.w),
                        Expanded(
                            flex: 2,
                            child: _buildTextField(
                                _controller.baustelleOrtController, "Ort")),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Text("Logo",
                        style: TextStyle(
                            fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20.h),
                    Obx(() => Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.file(
                              File(_controller.logo.value!.path),
                              height: 120.h,
                              width: 240.w,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Image.asset(
                                'assets/system2000_logo.png',
                                height: 120.h,
                                width: 240.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        )),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _controller.changeLogo(context);
                            },
                            icon: Icon(Icons.image, size: 28.sp),
                            label: Text("Neues Logo wählen",
                                style: TextStyle(fontSize: 16.sp)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _controller.resetLogo,
                            icon: Icon(Icons.restore, size: 28.sp),
                            label: Text("Standard",
                                style: TextStyle(fontSize: 16.sp)),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              side: BorderSide(color: Colors.redAccent),
                              foregroundColor: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40.h),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      Text("Rechnung bearbeiten nach unterschriften",
                          style: TextStyle(
                              fontSize: 20.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20.h),
                      Obx(() => Switch(
                            value: _controller.enableEditing.value,
                            onChanged: (value) {
                              _controller.enableEditing.value = value;
                              _unterschriftController.kundePngBytes.value =
                                  null;
                              _unterschriftController.monteurPngBytes.value =
                                  null;
                            },
                          ))
                    ],
                  )),
            ),
            SizedBox(height: 40.h),

            // Info-Text
            Center(
              child: Text(
                "Änderungen werden automatisch gespeichert",
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
