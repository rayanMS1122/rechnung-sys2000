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

class _NameEingebenScreenState extends State<NameEingebenScreen>
    with TickerProviderStateMixin {
  final ScreenInputController controller = Get.find<ScreenInputController>();
  late AnimationController _pulseController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

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
      extendBodyBehindAppBar: true,
      appBar: _buildAdvancedAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // Header mit Animation
                _buildAnimatedHeader()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, end: 0, curve: Curves.easeOut),

                SizedBox(height: 32.h),

                // ==================== MONTEUR SECTION ====================
                _buildAdvancedSectionCard(
                  title: "Monteur Informationen",
                  icon: Icons.person_outline,
                  accentColor: Colors.indigo,
                  gradientColors: [
                    Colors.indigo.shade400,
                    Colors.indigo.shade600,
                  ],
                  onSearch: () => _selectMonteur(context),
                  onSave: () async {
                    updateMonteur();
                    await controller.addMonteurToDatabase();
                    setState(() {});
                    _showSuccessSnackbar("Monteur gespeichert!", Colors.indigo);
                  },
                  children: [
                    _buildAdvancedTextField(
                      controller.monteurVornameController,
                      "Vorname",
                      Icons.badge_outlined,
                      "Max",
                      updateMonteur,
                    ),
                    SizedBox(height: 16.h),
                    _buildAdvancedTextField(
                      controller.monteurNachnameController,
                      "Nachname",
                      Icons.person,
                      "Mustermann",
                      updateMonteur,
                    ),
                    SizedBox(height: 16.h),
                    _buildAdvancedTextField(
                      controller.monteurEmailController,
                      "E-Mail",
                      Icons.email_outlined,
                      "max@beispiel.de",
                      updateMonteur,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.h),
                    _buildAdvancedTextField(
                      controller.monteurTeleController,
                      "Telefon",
                      Icons.phone_outlined,
                      "0176 12345678",
                      updateMonteur,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 200.ms)
                    .slideX(begin: -0.2, end: 0, curve: Curves.easeOut),

                SizedBox(height: 32.h),

                // ==================== KUNDE SECTION ====================
                _buildAdvancedSectionCard(
                  title: "Kunden Informationen",
                  icon: Icons.business_outlined,
                  accentColor: Colors.green,
                  gradientColors: [
                    Colors.green.shade400,
                    Colors.green.shade600,
                  ],
                  onSearch: () => _selectKunde(context),
                  onSave: () async {
                    updateKunde();
                    await controller.addKundeToDatabase();
                    _showSuccessSnackbar("Kunde gespeichert!", Colors.green);
                  },
                  children: [
                    _buildAdvancedTextField(
                      controller.kundeNameController,
                      "Firmenname / Name",
                      Icons.business,
                      "Muster GmbH",
                      updateKunde,
                    ),
                    SizedBox(height: 16.h),
                    _buildAdvancedTextField(
                      controller.kundeStrasseController,
                      "Straße & Hausnr.",
                      Icons.location_on_outlined,
                      "Musterstraße 12",
                      updateKunde,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAdvancedTextField(
                            controller.kundePlzController,
                            "PLZ",
                            Icons.pin,
                            "12345",
                            updateKunde,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          flex: 2,
                          child: _buildAdvancedTextField(
                            controller.kundeOrtController,
                            "Ort",
                            Icons.location_city_outlined,
                            "Musterstadt",
                            updateKunde,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildAdvancedTextField(
                      controller.kundeTeleController,
                      "Telefon",
                      Icons.phone_outlined,
                      "0231 123456",
                      updateKunde,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16.h),
                    _buildAdvancedTextField(
                      controller.kundeEmailController,
                      "E-Mail",
                      Icons.email_outlined,
                      "info@musterfirma.de",
                      updateKunde,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 800.ms, delay: 400.ms)
                    .slideX(begin: 0.2, end: 0, curve: Curves.easeOut),

                SizedBox(height: 40.h),

                // ==================== WEITER BUTTON ====================
                _buildAdvancedContinueButton(
                  onPressed: () {
                    if (controller.monteurVornameController.text
                            .trim()
                            .isEmpty ||
                        controller.kundeNameController.text.trim().isEmpty) {
                      _showErrorSnackbar(
                          "Bitte Vorname und Kundenname eingeben");
                      return;
                    }
                    Get.to(() => const ScreenInput());
                  },
                ).animate().fadeIn(duration: 1000.ms, delay: 600.ms).scale(
                    begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAdvancedAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade700,
              Colors.indigo.shade900,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_document, color: Colors.white, size: 24.sp),
          SizedBox(width: 12.w),
          Text(
            "Personen & Kunde",
            style: GoogleFonts.poppins(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildAnimatedHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade600.withOpacity(0.1),
            Colors.blue.shade400.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: Colors.indigo.shade200.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Rechnungsdaten",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Bitte füllen Sie alle Felder aus",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Color> gradientColors,
    required VoidCallback onSearch,
    required VoidCallback onSave,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            children: [
              // Header mit Gradient
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(icon, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    _buildActionButton(
                      icon: Icons.search_rounded,
                      onPressed: onSearch,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8.w),
                    _buildActionButton(
                      icon: Icons.save_rounded,
                      onPressed: onSave,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(children: children),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3));
  }

  Widget _buildAdvancedTextField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String hint,
    VoidCallback onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Container(
            margin: EdgeInsets.all(8.w),
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: Colors.indigo.shade600, size: 20.sp),
          ),
          labelStyle: GoogleFonts.poppins(
            color: Colors.grey.shade600,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade400,
            fontSize: 15.sp,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(
              color: Colors.indigo.shade400,
              width: 2.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 20.h,
          ),
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }

  Widget _buildAdvancedContinueButton({required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo.shade600,
                  Colors.indigo.shade800,
                  Colors.indigo.shade900,
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Weiter zur Rechnung",
                  style: GoogleFonts.poppins(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message, Color color) {
    Get.snackbar(
      "✓ Erfolg",
      message,
      backgroundColor: color,
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16.w),
      borderRadius: 16.r,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      "⚠ Fehler",
      message,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      icon: Icon(Icons.error_outline, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.all(16.w),
      borderRadius: 16.r,
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  // ==================== MONTEUR AUSWÄHLEN ====================
  void _selectMonteur(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo.shade50,
                      Colors.indigo.shade100,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade600,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.person_search,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          "Monteur auswählen",
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.indigo.shade900,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.close, size: 20.sp),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: Obx(() {
                  if (controller.monteureListe.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_off_outlined,
                            size: 64.sp,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "Keine Monteure vorhanden",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16.w),
                    itemCount: controller.monteureListe.length,
                    itemBuilder: (context, index) {
                      final monteur = controller.monteureListe[index];
                      return _buildListItem(
                        title: "${monteur['vorname']} ${monteur['nachname']}",
                        subtitle: monteur['telefon'] ?? '',
                        icon: Icons.person,
                        color: Colors.indigo,
                        onTap: () async {
                          await controller
                              .selectMonteurFromDatabase(monteur['id']);
                          Navigator.pop(context);
                          setState(() {});
                          _showSuccessSnackbar(
                              "Monteur geladen!", Colors.indigo);
                        },
                        index: index,
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

  void _selectKunde(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Header
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade50,
                      Colors.green.shade100,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.business_center,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          "Kunde auswählen",
                          style: GoogleFonts.poppins(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.close, size: 20.sp),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: Obx(() {
                  if (controller.kundenListe.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.business_outlined,
                            size: 64.sp,
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            "Keine Kunden vorhanden",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(16.w),
                    itemCount: controller.kundenListe.length,
                    itemBuilder: (context, index) {
                      final kunde = controller.kundenListe[index];
                      return _buildListItem(
                        title: kunde['name'] ?? '',
                        subtitle:
                            "${kunde['strasse']}, ${kunde['plz']} ${kunde['ort']}",
                        icon: Icons.business,
                        color: Colors.green,
                        onTap: () async {
                          await controller.selectKundeFromDatabase(kunde['id']);
                          Navigator.pop(context);
                          setState(() {});
                          _showSuccessSnackbar("Kunde geladen!", Colors.green);
                        },
                        index: index,
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

  Widget _buildListItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.grey],
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18.sp,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 50).ms)
        .slideX(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}
