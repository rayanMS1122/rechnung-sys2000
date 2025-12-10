import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/model/firma_model.dart'; // <- WICHTIG: importiere deine Modelle!
import 'package:reciepts/screens/screen_input.dart';

class NameEingebenScreen extends StatelessWidget {
  NameEingebenScreen({super.key});

  final ScreenInputController controller = Get.find<ScreenInputController>();

  @override
  Widget build(BuildContext context) {
    // Live-Update: Sobald ein TextField ändert → Model aktualisieren
    void updateMonteur() {
      controller.data.monteur = Monteur(
        vorname: controller.monteurVornameController.text.trim(),
        nachname: controller.monteurNachnameController.text.trim(),
        email: controller.monteurEmailController.text.trim(),
        telefon: controller.monteurTeleController.text.trim(),
      );
    }

    void updateKunde() {
      controller.data.kunde = Kunde(
        name: controller.kundeNameController.text.trim(),
        strasse: controller.kundeStrasseController.text.trim(),
        plz: controller.kundePlzController.text.trim(),
        ort: controller.kundeOrtController.text.trim(),
        telefon: controller.kundeTeleController.text.trim(),
        email: controller.kundeEmailController.text.trim(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personen & Kunde eingeben"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== MONTEUR ====================
              Text("Monteur Informationen",
                  style:
                      TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),

              TextField(
                controller: controller.monteurVornameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration("Vorname", "Max"),
                onChanged: (_) => updateMonteur(),
              ),
              SizedBox(height: 16.h),

              TextField(
                controller: controller.monteurNachnameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration("Nachname", "Mustermann"),
                onChanged: (_) => updateMonteur(),
              ),
              SizedBox(height: 16.h),

              TextField(
                controller: controller.monteurEmailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration("E-Mail", "max@beispiel.de"),
                onChanged: (_) => updateMonteur(),
              ),
              SizedBox(height: 16.h),

              TextField(
                controller: controller.monteurTeleController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration("Telefon", "0176 12345678"),
                onChanged: (_) => updateMonteur(),
              ),

              SizedBox(height: 40.h),

              // ==================== KUNDE ====================
              Text("Kunden Informationen",
                  style:
                      TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 20.h),

              TextField(
                controller: controller.kundeNameController,
                textInputAction: TextInputAction.next,
                decoration:
                    _inputDecoration("Firmenname / Name", "Muster GmbH"),
                onChanged: (_) => updateKunde(),
              ),
              SizedBox(height: 16.h),

              TextField(
                controller: controller.kundeStrasseController,
                textInputAction: TextInputAction.next,
                decoration:
                    _inputDecoration("Straße & Hausnr.", "Musterstraße 12"),
                onChanged: (_) => updateKunde(),
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: controller.kundePlzController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration("PLZ", "12345"),
                      onChanged: (_) => updateKunde(),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: controller.kundeOrtController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration("Ort", "Musterstadt"),
                      onChanged: (_) => updateKunde(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              TextField(
                controller: controller.kundeTeleController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration("Telefon", "0231 123456"),
                // TODO
                onChanged: (_) => updateKunde(),
              ),
              SizedBox(height: 16.h),

              TextField(
                controller: controller.kundeEmailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: _inputDecoration("E-Mail", "info@musterfirma.de"),
                onChanged: (_) => updateKunde(),
              ),

              SizedBox(height: 50.h),

              // ==================== WEITER BUTTON ====================
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    // Optional: Prüfen ob Pflichtfelder gefüllt
                    if (controller.monteurVornameController.text
                            .trim()
                            .isEmpty ||
                        controller.kundeNameController.text.trim().isEmpty) {
                      Get.snackbar(
                          "Fehler", "Bitte Vorname und Kundenname eingeben");
                      return;
                    }

                    Get.to(() => const ScreenInput());
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                  ),
                  child: Text("Weiter zur Rechnung",
                      style: TextStyle(
                          fontSize: 18.sp, fontWeight: FontWeight.w600)),
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration(String label, String hint) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
    filled: true,
    fillColor: Colors.grey[50],
  );
}
