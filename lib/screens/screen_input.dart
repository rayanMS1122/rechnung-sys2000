import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:reciepts/constants.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/models/reciept_model.dart';
import 'package:reciepts/screens/bank_qr_generator_screen.dart';
import 'package:reciepts/screens/screen_reciept.dart';
import 'package:reciepts/screens/settings_screen.dart';

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
  final BankQrGeneratorScreen bankQr = BankQrGeneratorScreen();
  // Deutsche Zahlenformatierung (Komma statt Punkt, immer 2 Dezimalstellen)
  final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'de_DE');

  // Hilfsfunktion für deutsche Zahlenformatierung
  String _formatNumber(double value) {
    // NumberFormat mit 'de_DE' verwendet bereits Komma als Dezimaltrennzeichen
    return _numberFormat.format(value);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validierung: Prüfe ob mindestens eine Position vorhanden ist
    if (_controller.rechnungTextFielde.isEmpty) {
      Get.snackbar(
        "Fehler",
        "Bitte fügen Sie mindestens eine Position hinzu",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }

    // Validierung: Prüfe alle Positionen
    for (int i = 0; i < _controller.rechnungTextFielde.length; i++) {
      final item = _controller.rechnungTextFielde[i];

      if (item.menge == null || item.menge! <= 0) {
        Get.snackbar(
          "Fehler",
          "Position ${i + 1}: Menge muss größer als 0 sein",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }

      if (item.einzelPreis == null || item.einzelPreis! < 0) {
        Get.snackbar(
          "Fehler",
          "Position ${i + 1}: Einzelpreis ist erforderlich",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (_formKey.currentState!.validate()) {
      await _controller.generateQR();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            receiptData: _controller.rechnungTextFielde,
            dokumentTitel: _controller.dokumentTitel.value,
          ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset:
          true, // WICHTIG: Damit Tastatur berücksichtigt wird

      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                onVerticalDragUpdate: (_) => FocusScope.of(context).unfocus(),
                child: Obx(() {
                  if (!editingEnabled) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.w),
                        child: Text(
                          "Du kannst die Rechnung nach der Unterschrift nicht bearbeiten.\nGehe in die Einstellungen und aktiviere dort 'Rechnung bearbeiten'",
                          style:
                              AppText.body.copyWith(color: AppColors.textLight),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (_controller.rechnungTextFielde.isEmpty) {
                    return Center(
                      child: Text(
                        "Noch keine Positionen hinzugefügt",
                        style:
                            AppText.body.copyWith(color: AppColors.textLight),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 8.h,
                      bottom: 8.h,
                    ),
                    itemCount: _controller.rechnungTextFielde.length,
                    itemBuilder: (context, index) {
                      final item = _controller.rechnungTextFielde[index];

                      return customPositionCard(
                        index: index,
                        item: item,
                        onDelete: () {
                          _controller.rechnungTextFielde.removeAt(index);
                          _controller.rechnungTextFielde.refresh();
                        },
                      );
                    },
                  );
                }),
              ),
            ),

            // Buttons mit SafeArea damit sie über Tastatur bleiben
            SafeArea(
              child: Container(
                color: AppColors.background,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => editingEnabled
                        ? SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.add, size: 24.sp),
                              label: Text('Neue Position',
                                  style:
                                      AppText.button.copyWith(fontSize: 16.sp)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.r)),
                              ),
                              onPressed: () {
                                _controller.addNewTextFields();
                                Future.delayed(
                                    Duration(milliseconds: 100), scrollToEnd);
                              },
                            ),
                          )
                        : const SizedBox.shrink()),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r)),
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text('Neue Rechnung'),
                                    content: Text(
                                        'Sind Sie sicher, dass Sie eine neue Rechnung erstellen möchten?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('Abbrechen')),
                                      TextButton(
                                          onPressed: () {
                                            _unterschriftController
                                                .kundePngBytes.value = null;
                                            _unterschriftController
                                                .monteurPngBytes.value = null;
                                            _controller.rechnungTextFielde
                                                .clear();
                                            Navigator.pop(context);
                                          },
                                          child: Text('Ja')),
                                    ],
                                  ));
                        },
                        child: Text('Neue Rechnung',
                            style: AppText.button.copyWith(fontSize: 16.sp)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r)),
                        ),
                        onPressed: _submitForm,
                        child: Text('Weiter zur Unterschrift',
                            style: AppText.button),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  "Rechnungenseingabe",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Rechte Seite: Clear-Button (nur wenn bearbeitbar) + Settings
            Row(
              children: [
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SettingsScreen()),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.settings,
                      color: AppColors.primary,
                      size: 24.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget customPositionCard({
    required int index,
    required ReceiptData item,
    required VoidCallback onDelete,
  }) {
    final controller = Get.find<ScreenInputController>();

    InputDecoration _inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Position + Delete
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Position ${index + 1}",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.delete_rounded,
                      color: Colors.red.shade600, size: 20.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Menge | Einheit | Preis
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue:
                      item.menge != null ? _formatNumber(item.menge!) : "1,00",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration("Menge *"),
                  style: TextStyle(fontSize: 14.sp),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Pflicht";
                    final parsed = double.tryParse(value.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) return "> 0";
                    return null;
                  },
                  onChanged: (value) {
                    final parsed =
                        double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                    controller.rechnungTextFielde[index] =
                        item.copyWith(menge: parsed);
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                  width: 1,
                  height: 40.h,
                  color: AppColors.primary.withOpacity(0.25)),
              SizedBox(width: 10.w),
              Expanded(
                child: TextFormField(
                  initialValue: item.einh ?? "Stk",
                  decoration: _inputDecoration("Einheit"),
                  style: TextStyle(fontSize: 14.sp),
                  onChanged: (value) {
                    controller.rechnungTextFielde[index] =
                        item.copyWith(einh: value);
                  },
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                  width: 1,
                  height: 40.h,
                  color: AppColors.primary.withOpacity(0.25)),
              SizedBox(width: 10.w),
              Expanded(
                child: TextFormField(
                  initialValue: item.einzelPreis != null
                      ? _formatNumber(item.einzelPreis!)
                      : "0,00",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration("Preis € *"),
                  style: TextStyle(fontSize: 14.sp),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return "Pflicht";
                    final parsed = double.tryParse(value.replaceAll(',', '.'));
                    if (parsed == null || parsed < 0) return "≥ 0";
                    return null;
                  },
                  onChanged: (value) {
                    final parsed =
                        double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                    controller.rechnungTextFielde[index] =
                        item.copyWith(einzelPreis: parsed);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Bezeichnung
          TextFormField(
            initialValue: item.bezeichnung ?? "",
            decoration: _inputDecoration("Bezeichnung"),
            maxLines: 3,
            minLines: 1,
            style: TextStyle(fontSize: 14.sp),
            onChanged: (value) {
              controller.rechnungTextFielde[index] =
                  item.copyWith(bezeichnung: value);
            },
          ),
          SizedBox(height: 14.h),

          // Bilder (falls vorhanden)
          if (item.img != null && item.img!.isNotEmpty) ...[
            SizedBox(
              height: 100.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: item.img!.length,
                itemBuilder: (context, imgIndex) {
                  return Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.file(
                            File(item.img![imgIndex]),
                            width: 100.w,
                            height: 100.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4.h,
                          right: 4.w,
                          child: GestureDetector(
                            onTap: () => controller.removeImageFromPosition(
                                index, imgIndex),
                            child: Container(
                              padding: EdgeInsets.all(5.w),
                              decoration: const BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                              child: Icon(Icons.close,
                                  color: Colors.white, size: 14.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 14.h),
          ],

          // Action Buttons – kompakt nebeneinander
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCompactActionButton(
                icon: Icons.photo_library_rounded,
                label: "Hinzufügen",
                onTap: () => _showImageSourceDialog(context, index),
              ),
              _buildCompactActionButton(
                icon: Icons.image_search_rounded,
                label: item.img?.isNotEmpty == true
                    ? "${item.img!.length} Anzeigen"
                    : "Anzeigen",
                onTap: () {
                  if (item.img?.isNotEmpty == true) {
                    _showImageGallery(context, index);
                  } else {
                    Get.snackbar("Info", "Keine Bilder vorhanden",
                        backgroundColor: Colors.grey.shade700,
                        colorText: Colors.white);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

// Kompakter Action-Button für wenig Platz
  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)]),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(0.25),
                blurRadius: 8.r,
                offset: Offset(0, 4.h)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18.sp),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16.sp),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                style: AppText.button.copyWith(fontSize: 11.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog zum Auswählen der Bildquelle
  void _showImageSourceDialog(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Bildquelle auswählen",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: Text("Aus Galerie auswählen"),
              onTap: () {
                Navigator.pop(context);
                _controller.addImagesToPosition(index,
                    source: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text("Foto aufnehmen"),
              onTap: () {
                Navigator.pop(context);
                _controller.addImageFromCamera(index);
              },
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // Bildergalerie-Dialog zum Anzeigen aller Bilder
  void _showImageGallery(BuildContext context, int index) {
    final images = _controller.getImagesForPosition(index);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Bilder (${images.length})",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Bilder-Grid
              Expanded(
                child: Container(
                  color: Colors.black87,
                  child: GridView.builder(
                    padding: EdgeInsets.all(16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, imgIndex) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              File(images[imgIndex]),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade800,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 40.sp,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: GestureDetector(
                              onTap: () {
                                _controller.removeImageFromPosition(
                                    index, imgIndex);
                                Navigator.pop(context);
                                if (_controller
                                    .getImagesForPosition(index)
                                    .isNotEmpty) {
                                  _showImageGallery(context, index);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
