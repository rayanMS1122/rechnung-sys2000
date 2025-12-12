// settings_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/constants.dart'; // WICHTIG: AppColors wird hier verwendet
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';

class SettingsScreen extends StatelessWidget {
  final ScreenInputController _controller = Get.find();
  final UnterschriftController _unterschriftController = Get.find();

  SettingsScreen({super.key});

  // Einheitlicher Custom Header – identisch mit den anderen Screens
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
            ),

            // Titel zentriert
            Expanded(
              child: Center(
                child: Text(
                  "Einstellungen",
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Platzhalter rechts für perfekte Zentrierung
            SizedBox(width: 40.w),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textLight),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
        style: TextStyle(fontSize: 16.sp, color: AppColors.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Custom Header
          _buildHeader(context),

          // Hauptinhalt
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Firma Card
                  Card(
                    color: AppColors.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r)),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Firma",
                              style: AppText.heading.copyWith(
                                  fontSize: 20.sp, color: AppColors.primary)),
                          SizedBox(height: 16.h),
                          _buildTextField(
                              _controller.firmaNameController, "Firmenname"),
                          _buildTextField(_controller.firmaStrasseController,
                              "Straße & Hausnr."),
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
                          _buildTextField(
                              _controller.firmaEmailController, "E-Mail"),
                          _buildTextField(
                              _controller.firmaWebsiteController, "Website"),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Baustelle Card
                  Card(
                    color: AppColors.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r)),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Baustelle",
                              style: AppText.heading.copyWith(
                                  fontSize: 20.sp, color: AppColors.primary)),
                          SizedBox(height: 16.h),
                          _buildTextField(
                              _controller.baustelleStrasseController,
                              "Straße & Hausnr."),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildTextField(
                                      _controller.baustellePlzController,
                                      "PLZ")),
                              SizedBox(width: 12.w),
                              Expanded(
                                  flex: 2,
                                  child: _buildTextField(
                                      _controller.baustelleOrtController,
                                      "Ort")),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Logo Card
                  Card(
                    color: AppColors.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r)),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          Text("Logo",
                              style: AppText.heading.copyWith(
                                  fontSize: 20.sp, color: AppColors.primary)),
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
                                  onPressed: () =>
                                      _controller.changeLogo(context),
                                  icon: Icon(Icons.image, size: 28.sp),
                                  label: Text("Neues Logo wählen",
                                      style: TextStyle(fontSize: 16.sp)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding:
                                        EdgeInsets.symmetric(vertical: 14.h),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.r)),
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
                                    padding:
                                        EdgeInsets.symmetric(vertical: 14.h),
                                    side: BorderSide(color: AppColors.error),
                                    foregroundColor: AppColors.error,
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

                  // Bearbeiten nach Unterschrift Card
                  Card(
                    color: AppColors.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r)),
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          Text("Rechnung bearbeiten nach Unterschriften",
                              style: AppText.heading.copyWith(
                                  fontSize: 20.sp, color: AppColors.primary)),
                          SizedBox(height: 20.h),
                          Obx(() => SwitchListTile(
                                title: Text(
                                  _controller.enableEditing.value
                                      ? "Bearbeiten erlaubt"
                                      : "Bearbeiten gesperrt",
                                  style: TextStyle(
                                      fontSize: 16.sp, color: AppColors.text),
                                ),
                                subtitle: Text(
                                  _controller.enableEditing.value
                                      ? "Du kannst die Rechnung auch nach der Unterschrift ändern"
                                      : "Nach der Unterschrift ist Bearbeiten gesperrt",
                                  style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textLight),
                                ),
                                value: _controller.enableEditing.value,
                                onChanged: (value) {
                                  _controller.enableEditing.value = value;
                                  if (!value) {
                                    _unterschriftController
                                        .kundePngBytes.value = null;
                                    _unterschriftController
                                        .monteurPngBytes.value = null;
                                  }
                                },
                                activeColor: AppColors.primary,
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor:
                                    Colors.grey.withOpacity(0.3),
                              )),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // Info-Text am Ende
                  Center(
                    child: Text(
                      "Änderungen werden automatisch gespeichert",
                      style: TextStyle(
                          color: AppColors.textLight, fontSize: 14.sp),
                    ),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
