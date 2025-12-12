import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/constants.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/models/reciept_model.dart';
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            SizedBox(
              height: 33,
            ),
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
                          _unterschriftController.kundePngBytes.value = null;
                          _unterschriftController.monteurPngBytes.value = null;
                          _controller.rechnungTextFielde.clear();
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Icon(
              Icons.arrow_back,
            ),
          ),
        ),
        Text(""),
        Text(
          "Eingabe",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall!.copyWith(
              fontSize: 24.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Obx(() => editingEnabled
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _controller.rechnungTextFielde.clear(),
                  )
                : const SizedBox.shrink()),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SettingsScreen())),
            ),
          ],
        ),
      ],
    );
  }

  Widget customPositionCard({
    required int index,
    required ReceiptData item,
    required VoidCallback onDelete,
  }) {
    final controller = Get.find<ScreenInputController>();

    // Gemeinsame Border-Logik für alle Felder
    InputDecoration _inputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19.r),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19.r),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19.r),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(19.r),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 8.h),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 8.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Position ${index + 1}",
                    style: AppText.heading
                        .copyWith(color: AppColors.primary, fontSize: 15.sp)),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red.shade600, size: 22.sp),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Menge | Einheit | Preis
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: item.menge?.toStringAsFixed(2) ?? "1.00",
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration("Menge"),
                    style: TextStyle(fontSize: 14.sp),
                    onChanged: (value) {
                      final parsed =
                          double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                      controller.rechnungTextFielde[index] =
                          item.copyWith(menge: parsed);
                    },
                  ),
                ),
                _divider(),
                Expanded(
                  flex: 2,
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
                SizedBox(width: 12.w),
                _divider(),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue:
                        item.einzelPreis?.toStringAsFixed(2) ?? "0.00",
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration("Einzelpreis €"),
                    style: TextStyle(fontSize: 14.sp),
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

            SizedBox(height: 16.h),

            // Bezeichnung
            TextFormField(
              initialValue: item.bezeichnung ?? "",
              decoration: InputDecoration(
                labelText: "Bezeichnung",
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19.r),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19.r),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(19.r),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              maxLines: 3,
              style: TextStyle(fontSize: 14.sp),
              onChanged: (value) {
                controller.rechnungTextFielde[index] =
                    item.copyWith(bezeichnung: value);
              },
            ),

            SizedBox(height: 12.h),

            // Action Buttons (noch nicht implementiert)

            Center(
              child: Column(
                children: [
                  Text(
                    "Kommt in zweiten Version",
                    style: TextStyle(color: AppColors.error),
                  ),
                  _actionButton(
                      icon: Icons.image_outlined,
                      label: "Bild anzeigen",
                      onTap: () {}),
                  SizedBox(height: 10.w),
                  _actionButton(
                      icon: Icons.photo_library_outlined,
                      label: "Bilder hinzufügen",
                      onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 32.h,
      color: AppColors.primary.withOpacity(0.2),
      margin: EdgeInsets.symmetric(horizontal: 10.w),
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
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 13.sp),
            SizedBox(width: 4.w),
            Text(label, style: AppText.button.copyWith(fontSize: 11.sp)),
          ],
        ),
      ),
    );
  }
}
