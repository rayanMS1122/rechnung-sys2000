import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/models/firma_model.dart';
import 'package:reciepts/models/kunde.dart';
import 'package:reciepts/models/monteur.dart';
import 'package:reciepts/screens/screen_input.dart';

class NameEingebenScreen extends StatefulWidget {
  NameEingebenScreen({super.key});

  @override
  State<NameEingebenScreen> createState() => _NameEingebenScreenState();
}

class _NameEingebenScreenState extends State<NameEingebenScreen> {
  final ScreenInputController controller = Get.find<ScreenInputController>();

  @override
  Widget build(BuildContext context) {
    // Live-Update: Sobald ein TextField ändert → Model aktualisieren
    void updateMonteur() {
      controller.monteur.value = Monteur(
        vorname: controller.monteurVornameController.text.trim(),
        nachname: controller.monteurNachnameController.text.trim(),
        email: controller.monteurEmailController.text,
        telefon: controller.monteurTeleController.text.trim(),
      );
    }

    void updateKunde() {
      controller.kunde.value = Kunde(
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
        actions: [
          // Button zum Öffnen der Datenverwaltung
          // IconButton(
          //   icon: const Icon(Icons.storage),
          //   tooltip: "Datenverwaltung",
          //   onPressed: () => _showDatenVerwaltung(context),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==================== MONTEUR ====================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Monteur Informationen",
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.search, color: Colors.blue),
                          tooltip: "Monteur laden",
                          onPressed: () {
                            _selectMonteur(context);
                          }),
                      IconButton(
                        icon: const Icon(Icons.save, color: Colors.green),
                        tooltip: "Monteur speichern",
                        onPressed: () async {
                          updateMonteur();
                          await controller.addMonteurToDatabase();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Kunden Informationen",
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.blue),
                        tooltip: "Kunde laden",
                        onPressed: () => _selectKunde(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.save, color: Colors.green),
                        tooltip: "Kunde speichern",
                        onPressed: () async {
                          updateKunde();
                          await controller.addKundeToDatabase();
                        },
                      ),
                    ],
                  ),
                ],
              ),
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

  // ==================== MONTEUR AUSWÄHLEN ====================
  void _selectMonteur(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Monteur auswählen",
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.monteureListe.isEmpty) {
                  return const Center(child: Text("Keine Monteure vorhanden"));
                }
                return ListView.builder(
                  controller: scrollController,
                  itemCount: controller.monteureListe.length,
                  itemBuilder: (context, index) {
                    final monteur = controller.monteureListe[index];
                    return ListTile(
                      title:
                          Text("${monteur['vorname']} ${monteur['nachname']}"),
                      subtitle: Text(monteur['telefon'] ?? ''),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        await controller
                            .selectMonteurFromDatabase(monteur['id']);
                        Navigator.pop(context);
                        setState(() {});
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _selectKunde(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Kunde auswählen",
                      style: TextStyle(
                          fontSize: 20.sp, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
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
                          "${kunde['strasse']}, ${kunde['plz']} ${kunde['ort']}"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () async {
                        await controller.selectKundeFromDatabase(kunde['id']);
                        Navigator.pop(context); // Modal schließen

                        // WICHTIG: UI aktualisieren!
                        setState(() {});
                      },
                    );
                  },
                );
              }),
            ),
          ],
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
