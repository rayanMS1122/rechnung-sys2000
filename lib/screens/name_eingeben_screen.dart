import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
        title: Text("Personen & Kunde eingeben",
            style: GoogleFonts.poppins(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.indigo.shade700,
        elevation: 4,
        shadowColor: Colors.black26,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.storage),
          //   tooltip: "Datenverwaltung",
          //   onPressed: () => _showDatenVerwaltung(context),
          // ),
        ],
      ),
      body: Container(
        color: Colors.grey[50], // Heller, sauberer Hintergrund – kein Gradient
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // ==================== MONTEUR SECTION ====================
                _buildSectionCard(
                  title: "Monteur Informationen",
                  accentColor: Colors.indigo,
                  onSearch: () => _selectMonteur(context),
                  onSave: () async {
                    updateMonteur();
                    await controller.addMonteurToDatabase();
                    setState(() {});
                  },
                  children: [
                    _buildModernTextField(controller.monteurVornameController,
                        "Vorname", "Max", updateMonteur),
                    _buildModernTextField(controller.monteurNachnameController,
                        "Nachname", "Mustermann", updateMonteur),
                    _buildModernTextField(controller.monteurEmailController,
                        "E-Mail", "max@beispiel.de", updateMonteur,
                        keyboardType: TextInputType.emailAddress),
                    _buildModernTextField(controller.monteurTeleController,
                        "Telefon", "0176 12345678", updateMonteur,
                        keyboardType: TextInputType.phone),
                  ],
                ),

                SizedBox(height: 40.h),

                // ==================== KUNDE SECTION ====================
                _buildSectionCard(
                  title: "Kunden Informationen",
                  accentColor: Colors.green,
                  onSearch: () => _selectKunde(context),
                  onSave: () async {
                    updateKunde();
                    await controller.addKundeToDatabase();
                  },
                  children: [
                    _buildModernTextField(controller.kundeNameController,
                        "Firmenname / Name", "Muster GmbH", updateKunde),
                    _buildModernTextField(controller.kundeStrasseController,
                        "Straße & Hausnr.", "Musterstraße 12", updateKunde),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                              controller.kundePlzController,
                              "PLZ",
                              "12345",
                              updateKunde,
                              keyboardType: TextInputType.number),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          flex: 2,
                          child: _buildModernTextField(
                              controller.kundeOrtController,
                              "Ort",
                              "Musterstadt",
                              updateKunde),
                        ),
                      ],
                    ),
                    _buildModernTextField(controller.kundeTeleController,
                        "Telefon", "0231 123456", updateKunde,
                        keyboardType: TextInputType.phone),
                    _buildModernTextField(controller.kundeEmailController,
                        "E-Mail", "info@musterfirma.de", updateKunde,
                        keyboardType: TextInputType.emailAddress),
                  ],
                ),

                SizedBox(height: 60.h),

                // ==================== WEITER BUTTON ====================
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.monteurVornameController.text
                              .trim()
                              .isEmpty ||
                          controller.kundeNameController.text.trim().isEmpty) {
                        Get.snackbar(
                            "Fehler", "Bitte Vorname und Kundenname eingeben",
                            backgroundColor: Colors.red.shade600,
                            colorText: Colors.white);
                        return;
                      }
                      Get.to(() => const ScreenInput());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade700,
                      elevation: 8,
                      shadowColor: Colors.indigo.shade300,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r)),
                    ),
                    child: Text("Weiter zur Rechnung",
                        style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                  )
                      .animate()
                      .scale(duration: 400.ms)
                      .shimmer(duration: 1800.ms),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Color accentColor,
    required VoidCallback onSearch,
    required VoidCallback onSave,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 12,
      shadowColor: accentColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      title,
                      textStyle: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: accentColor),
                      speed: const Duration(milliseconds: 80),
                    ),
                  ],
                  totalRepeatCount: 1,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.search, color: accentColor),
                      tooltip: "Laden",
                      onPressed: onSearch,
                    ).animate().fadeIn(duration: 600.ms),
                    IconButton(
                      icon: Icon(Icons.save, color: accentColor),
                      tooltip: "Speichern",
                      onPressed: onSave,
                    ).animate().fadeIn(duration: 600.ms),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            ...children.map((child) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: child,
                )),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0.0);
  }

  Widget _buildModernTextField(
    TextEditingController ctrl,
    String label,
    String hint,
    VoidCallback onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      style: GoogleFonts.poppins(fontSize: 16.sp),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: Colors.indigo.shade500, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      ),
      onChanged: (_) => onChanged(),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1);
  }

  // ==================== MONTEUR AUSWÄHLEN ====================
  void _selectMonteur(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30.r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Monteur auswählen",
                        style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade800)),
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
                    return Center(
                        child: Text("Keine Monteure vorhanden",
                            style: GoogleFonts.poppins(color: Colors.grey)));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.monteureListe.length,
                    itemBuilder: (context, index) {
                      final monteur = controller.monteureListe[index];
                      return ListTile(
                        title: Text(
                            "${monteur['vorname']} ${monteur['nachname']}",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(monteur['telefon'] ?? '',
                            style: GoogleFonts.poppins()),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          await controller
                              .selectMonteurFromDatabase(monteur['id']);
                          Navigator.pop(context);
                          setState(() {});
                        },
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (index * 50).ms);
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

  void _selectKunde(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30.r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Kunde auswählen",
                        style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800)),
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
                    return Center(
                        child: Text("Keine Kunden vorhanden",
                            style: GoogleFonts.poppins(color: Colors.grey)));
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.kundenListe.length,
                    itemBuilder: (context, index) {
                      final kunde = controller.kundenListe[index];
                      return ListTile(
                        title: Text(kunde['name'] ?? '',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            "${kunde['strasse']}, ${kunde['plz']} ${kunde['ort']}",
                            style: GoogleFonts.poppins()),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          await controller.selectKundeFromDatabase(kunde['id']);
                          Navigator.pop(context);
                          setState(() {});
                        },
                      )
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (index * 50).ms);
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
