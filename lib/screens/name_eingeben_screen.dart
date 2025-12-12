// name_eingeben_screen.dart (oder wie deine Datei heißt)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/constants.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/models/kunde.dart';
import 'package:reciepts/models/monteur.dart';
import 'package:reciepts/screens/screen_input.dart';

class NameEingebenScreen extends StatefulWidget {
  const NameEingebenScreen({super.key});

  @override
  State<NameEingebenScreen> createState() => _NameEingebenScreenState();
}

class _NameEingebenScreenState extends State<NameEingebenScreen> {
  final controller = Get.find<ScreenInputController>();

  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.redAccent : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 22.h),
            _buildHeader(context),
            SizedBox(height: 22.h),
            // ==================== MONTEUR ====================
            Obx(() => _sectionHeader(
              title: "Monteur Informationen",
              onSearch: () => _selectMonteur(context),
              showSave: controller.canSaveMonteur.value,
              onSave: () async {
                // Validierung
                if (controller.monteurVornameController.text.trim().isEmpty) {
                  _showSnackBar("Vorname ist erforderlich", error: true);
                  return;
                }
                if (controller.monteurNachnameController.text.trim().isEmpty) {
                  _showSnackBar("Nachname ist erforderlich", error: true);
                  return;
                }
                if (controller.monteurTeleController.text.trim().isEmpty) {
                  _showSnackBar("Telefon ist erforderlich", error: true);
                  return;
                }
                
                // Aktualisiere monteur.value vor der Prüfung
                controller.monteur.value = Monteur(
                  vorname: controller.monteurVornameController.text.trim(),
                  nachname: controller.monteurNachnameController.text.trim(),
                  email: controller.monteurEmailController.text.trim(),
                  telefon: controller.monteurTeleController.text.trim(),
                );
                
                // Speichern
                final success = await controller.addMonteurToDatabase();
                if (success) {
                  _showSnackBar("Monteur gespeichert!");
                } else {
                  // Duplikat gefunden, Daten wurden bereits geladen
                  _showSnackBar("Ein identischer Monteur existiert bereits. Daten wurden geladen.", error: false);
                }
              },
            )),
            SizedBox(height: 20.h),

            customTextField(
              ctrl: controller.monteurVornameController,
              label: "Vorname",
              icon: Icons.badge_outlined,
              hint: "Max",
            ),
            SizedBox(height: 16.h),
            customTextField(
              ctrl: controller.monteurNachnameController,
              label: "Nachname",
              icon: Icons.person,
              hint: "Mustermann",
            ),
            SizedBox(height: 16.h),
            customTextField(
              ctrl: controller.monteurEmailController,
              label: "E-Mail",
              icon: Icons.email_outlined,
              hint: "max@beispiel.de",
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),
            customTextField(
              ctrl: controller.monteurTeleController,
              label: "Telefon",
              icon: Icons.phone_outlined,
              hint: "0176 12345678",
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 40.h),

            // ==================== KUNDE ====================
            Obx(() => _sectionHeader(
              title: "Kunden Informationen",
              onSearch: () => _selectKunde(context),
              showSave: controller.canSaveKunde.value,
              onSave: () async {
                // Validierung
                if (controller.kundeNameController.text.trim().isEmpty) {
                  _showSnackBar("Name ist erforderlich", error: true);
                  return;
                }
                if (controller.kundeStrasseController.text.trim().isEmpty) {
                  _showSnackBar("Straße ist erforderlich", error: true);
                  return;
                }
                if (controller.kundePlzController.text.trim().isEmpty) {
                  _showSnackBar("PLZ ist erforderlich", error: true);
                  return;
                }
                if (controller.kundeOrtController.text.trim().isEmpty) {
                  _showSnackBar("Ort ist erforderlich", error: true);
                  return;
                }
                
                // Aktualisiere kunde.value vor der Prüfung
                controller.kunde.value = Kunde(
                  name: controller.kundeNameController.text.trim(),
                  strasse: controller.kundeStrasseController.text.trim(),
                  plz: controller.kundePlzController.text.trim(),
                  ort: controller.kundeOrtController.text.trim(),
                  telefon: controller.kundeTeleController.text.trim(),
                  email: controller.kundeEmailController.text.trim(),
                );
                
                // Speichern
                final success = await controller.addKundeToDatabase();
                if (success) {
                  _showSnackBar("Kunde gespeichert!");
                } else {
                  // Duplikat gefunden, Daten wurden bereits geladen
                  _showSnackBar("Ein identischer Kunde existiert bereits. Daten wurden geladen.", error: false);
                }
              },
            )),
            SizedBox(height: 20.h),

            customTextField(
              ctrl: controller.kundeNameController,
              label: "Firmenname / Name",
              icon: Icons.business,
              hint: "Muster GmbH",
            ),
            SizedBox(height: 16.h),
            customTextField(
              ctrl: controller.kundeStrasseController,
              label: "Straße & Hausnr.",
              icon: Icons.location_on_outlined,
              hint: "Musterstraße 12",
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: customTextField(
                    ctrl: controller.kundePlzController,
                    label: "PLZ",
                    icon: Icons.pin,
                    hint: "12345",
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: customTextField(
                    ctrl: controller.kundeOrtController,
                    label: "Ort",
                    icon: Icons.location_city_outlined,
                    hint: "Musterstadt",
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            customTextField(
              ctrl: controller.kundeTeleController,
              label: "Telefon",
              icon: Icons.phone_outlined,
              hint: "0231 123456",
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),
            customTextField(
              ctrl: controller.kundeEmailController,
              label: "E-Mail",
              icon: Icons.email_outlined,
              hint: "info@musterfirma.de",
              keyboardType: TextInputType.emailAddress,
            ),

            SizedBox(height: 60.h),

            // ==================== WEITER BUTTON ====================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Validierung für Monteur
                  if (controller.monteurVornameController.text.trim().isEmpty) {
                    _showSnackBar("Monteur Vorname ist erforderlich", error: true);
                    return;
                  }
                  if (controller.monteurNachnameController.text.trim().isEmpty) {
                    _showSnackBar("Monteur Nachname ist erforderlich", error: true);
                    return;
                  }
                  if (controller.monteurTeleController.text.trim().isEmpty) {
                    _showSnackBar("Monteur Telefon ist erforderlich", error: true);
                    return;
                  }
                  
                  // Validierung für Kunde
                  if (controller.kundeNameController.text.trim().isEmpty) {
                    _showSnackBar("Kundenname ist erforderlich", error: true);
                    return;
                  }
                  if (controller.kundeStrasseController.text.trim().isEmpty) {
                    _showSnackBar("Kunde Straße ist erforderlich", error: true);
                    return;
                  }
                  if (controller.kundePlzController.text.trim().isEmpty) {
                    _showSnackBar("Kunde PLZ ist erforderlich", error: true);
                    return;
                  }
                  if (controller.kundeOrtController.text.trim().isEmpty) {
                    _showSnackBar("Kunde Ort ist erforderlich", error: true);
                    return;
                  }
                  
                  // Werte aktualisieren
                  controller.monteur.value = Monteur(
                    vorname: controller.monteurVornameController.text.trim(),
                    nachname: controller.monteurNachnameController.text.trim(),
                    email: controller.monteurEmailController.text.trim(),
                    telefon: controller.monteurTeleController.text.trim(),
                  );
                  
                  controller.kunde.value = Kunde(
                    name: controller.kundeNameController.text.trim(),
                    strasse: controller.kundeStrasseController.text.trim(),
                    plz: controller.kundePlzController.text.trim(),
                    ort: controller.kundeOrtController.text.trim(),
                    telefon: controller.kundeTeleController.text.trim(),
                    email: controller.kundeEmailController.text.trim(),
                  );
                  
                  Get.to(() => const ScreenInput());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Weiter zur Rechnung",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // GestureDetector(
        //   onTap: () => Navigator.maybePop(context),
        //   child: Image.asset(
        //     "assets/images/arrow-back-simple.png",
        //     width: 24.w,
        //     height: 24.h,
        //   ),
        // ),
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
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 12.w),
            //   child: Icon(Icons.search, color: AppColors.primary, size: 24.w),
            // ),
          ],
        ),
      ],
    );
  }

  // Section Header mit Suchen/Speichern Icons
  Widget _sectionHeader({
    required String title,
    required VoidCallback onSearch,
    required VoidCallback onSave,
    required bool showSave,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: onSearch,
              icon: Icon(Icons.search, color: AppColors.primary),
            ),
            if (showSave)
              IconButton(
                onPressed: onSave,
                icon: Icon(Icons.save, color: AppColors.primary),
              ),
          ],
        ),
      ],
    );
  }

  // Dein schönes TextField – jetzt mit zentraler Farbe
  Widget customTextField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            style: TextStyle(fontSize: 16.sp, color: AppColors.text),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 15.sp),
              prefixIcon: Icon(icon, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: AppColors.primary, width: 2.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SUCHE MONTEUR ====================
  void _selectMonteur(BuildContext context) async {
    // Daten neu laden bevor Dialog geöffnet wird
    await controller.reloadAllData();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text("Monteur auswählen",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.monteureListe.isEmpty) {
                    return const Center(
                        child: Text("Keine Monteure vorhanden"));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.monteureListe.length,
                    itemBuilder: (context, index) {
                      final monteur = controller.monteureListe[index];
                      return ListTile(
                        title: Text(
                            "${monteur['vorname'] ?? ''} ${monteur['nachname'] ?? ''}"),
                        subtitle: Text(monteur['telefon'] ?? ''),
                        onTap: () async {
                          await controller
                              .selectMonteurFromDatabase(monteur['id']);
                          Navigator.pop(context);
                          _showSnackBar("Monteur geladen!");
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SUCHE KUNDE ====================
  void _selectKunde(BuildContext context) async {
    // Daten neu laden bevor Dialog geöffnet wird
    await controller.reloadAllData();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text("Kunde auswählen",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.kundenListe.isEmpty) {
                    return const Center(child: Text("Keine Kunden vorhanden"));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.kundenListe.length,
                    itemBuilder: (context, index) {
                      final kunde = controller.kundenListe[index];
                      return ListTile(
                        title: Text(kunde['name'] ?? ''),
                        subtitle: Text(
                            "${kunde['strasse'] ?? ''}, ${kunde['plz'] ?? ''} ${kunde['ort'] ?? ''}"),
                        onTap: () async {
                          await controller.selectKundeFromDatabase(kunde['id']);
                          Navigator.pop(context);
                          _showSnackBar("Kunde geladen!");
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
