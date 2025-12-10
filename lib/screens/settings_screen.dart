// settings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reciepts/controller/screen_input_controller.dart';

class SettingsScreen extends StatelessWidget {
  final ScreenInputController controller = Get.find();

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
            // ==================== FIRMA ====================
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
                        controller.firmaNameController, "Firmenname"),
                    _buildTextField(
                        controller.firmaStrasseController, "Straße & Hausnr."),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                controller.firmaPlzController, "PLZ")),
                        SizedBox(width: 12.w),
                        Expanded(
                            flex: 2,
                            child: _buildTextField(
                                controller.firmaOrtController, "Ort")),
                      ],
                    ),
                    _buildTextField(
                        controller.firmaTelefonController, "Telefon"),
                    _buildTextField(controller.firmaEmailController, "E-Mail"),
                    _buildTextField(
                        controller.firmaWebsiteController, "Website"),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ==================== BAUSTELLE ====================
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
                    _buildTextField(controller.baustelleStrasseController,
                        "Straße & Hausnr."),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                controller.baustellePlzController, "PLZ")),
                        SizedBox(width: 12.w),
                        Expanded(
                            flex: 2,
                            child: _buildTextField(
                                controller.baustelleOrtController, "Ort")),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ==================== LOGO ====================
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
                              File(controller.logo.value.path),
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
                            onPressed: () => controller.changeLogo(context),
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
                            onPressed: controller.resetLogo,
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
