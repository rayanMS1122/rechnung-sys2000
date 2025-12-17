// name_eingeben_screen.dart - Ultra Advanced UI Version
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        controller.updateMonteurControllers();
        controller.updateKundeControllers();
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
            error ? const Color(0xFFE53935) : const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.95),
              const Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildAdvancedHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress Indicator
                    _buildProgressIndicator(),
                    SizedBox(height: 32.h),
                    // ==================== MONTEUR SECTION ====================
                    _buildGlassmorphicCard(
                      child: Column(
                        children: [
                          Obx(() {
                            final monteurId = controller.monteur.value?.id ?? 0;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.updateMonteurControllers();
                            });
                            return _buildAdvancedSectionHeader(
                              title: "Monteur Informationen",
                              subtitle: "Techniker-Details eingeben",
                              icon: Icons.engineering_rounded,
                              onSearch: () => _selectMonteur(context),
                              showSave: controller.canSaveMonteur.value,
                              onSave: () async {
                                final vorname = controller
                                    .monteurVornameController.text
                                    .trim();
                                final nachname = controller
                                    .monteurNachnameController.text
                                    .trim();
                                final telefon = controller
                                    .monteurTeleController.text
                                    .trim();
                                final email = controller
                                    .monteurEmailController.text
                                    .trim();
                                if (vorname.isEmpty) {
                                  _showSnackBar("Vorname ist erforderlich",
                                      error: true);
                                  return;
                                }
                                if (nachname.isEmpty) {
                                  _showSnackBar("Nachname ist erforderlich",
                                      error: true);
                                  return;
                                }
                                if (telefon.isEmpty) {
                                  _showSnackBar("Telefon ist erforderlich",
                                      error: true);
                                  return;
                                }
                                controller.monteur.value = Monteur(
                                  id: controller.monteur.value.id,
                                  vorname: vorname,
                                  nachname: nachname,
                                  email: email,
                                  telefon: telefon,
                                );
                                final success =
                                    await controller.addMonteurToDatabase();
                                if (success) {
                                  _showSnackBar("Monteur gespeichert!");
                                  await controller.saveEinstellungen();
                                } else {
                                  _showSnackBar(
                                    "Ein identischer Monteur existiert bereits. Daten wurden geladen.",
                                    error: false,
                                  );
                                }
                              },
                            );
                          }),
                          SizedBox(height: 24.h),
                          _buildAdvancedTextField(
                            ctrl: controller.monteurVornameController,
                            label: "Vorname",
                            icon: Icons.badge_outlined,
                            hint: "Max",
                            keyValue:
                                'monteur_vorname_${controller.monteur.value?.id ?? 0}',
                          ),
                          SizedBox(height: 16.h),
                          _buildAdvancedTextField(
                            ctrl: controller.monteurNachnameController,
                            label: "Nachname",
                            icon: Icons.person_outline_rounded,
                            hint: "Mustermann",
                            keyValue:
                                'monteur_nachname_${controller.monteur.value?.id ?? 0}',
                          ),
                          SizedBox(height: 16.h),
                          _buildAdvancedTextField(
                            ctrl: controller.monteurEmailController,
                            label: "E-Mail",
                            icon: Icons.email_outlined,
                            hint: "max@beispiel.de",
                            keyboardType: TextInputType.emailAddress,
                            keyValue:
                                'monteur_email_${controller.monteur.value?.id ?? 0}',
                          ),
                          SizedBox(height: 16.h),
                          _buildAdvancedTextField(
                            ctrl: controller.monteurTeleController,
                            label: "Telefon",
                            icon: Icons.phone_outlined,
                            hint: "0176 12345678",
                            keyboardType: TextInputType.phone,
                            keyValue:
                                'monteur_tele_${controller.monteur.value?.id ?? 0}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    // ==================== KUNDE SECTION ====================
                    _buildGlassmorphicCard(
                      child: Column(
                        children: [
                          Obx(() {
                            final kundeId = controller.kunde.value?.id ?? 0;
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.updateKundeControllers();
                            });
                            return _buildAdvancedSectionHeader(
                              title: "Kunden Informationen",
                              subtitle: "Auftraggeber-Details eingeben",
                              icon: Icons.business_center_rounded,
                              onSearch: () => _selectKunde(context),
                              showSave: controller.canSaveKunde.value,
                              onSave: () async {
                                final name =
                                    controller.kundeNameController.text.trim();
                                final strasse = controller
                                    .kundeStrasseController.text
                                    .trim();
                                final plz =
                                    controller.kundePlzController.text.trim();
                                final ort =
                                    controller.kundeOrtController.text.trim();
                                final telefon =
                                    controller.kundeTeleController.text.trim();
                                final email =
                                    controller.kundeEmailController.text.trim();
                                if (name.isEmpty) {
                                  _showSnackBar("Name ist erforderlich",
                                      error: true);
                                  return;
                                }
                                if (strasse.isEmpty) {
                                  _showSnackBar("Straße ist erforderlich",
                                      error: true);
                                  return;
                                }
                                if (plz.isEmpty) {
                                  _showSnackBar("PLZ ist erforderlich",
                                      error: true);
                                  return;
                                }
                                if (ort.isEmpty) {
                                  _showSnackBar("Ort ist erforderlich",
                                      error: true);
                                  return;
                                }
                                controller.kunde.value = Kunde(
                                  id: controller.kunde.value.id,
                                  name: name,
                                  strasse: strasse,
                                  plz: plz,
                                  ort: ort,
                                  telefon: telefon,
                                  email: email,
                                );
                                final success =
                                    await controller.addKundeToDatabase();
                                if (success) {
                                  _showSnackBar("Kunde gespeichert!");
                                  await controller.saveEinstellungen();
                                } else {
                                  _showSnackBar(
                                    "Ein identischer Kunde existiert bereits. Daten wurden geladen.",
                                    error: false,
                                  );
                                }
                              },
                            );
                          }),
                          SizedBox(height: 24.h),
                          _buildAdvancedTextField(
                            ctrl: controller.kundeNameController,
                            label: "Firmenname / Name",
                            icon: Icons.business_rounded,
                            hint: "Muster GmbH",
                            keyValue:
                                'kunde_name_${controller.kunde.value?.id ?? 0}',
                          ),
                          SizedBox(height: 16.h),
                          _buildAdvancedTextField(
                            ctrl: controller.kundeStrasseController,
                            label: "Straße & Hausnr.",
                            icon: Icons.location_on_outlined,
                            hint: "Musterstraße 12",
                            keyValue:
                                'kunde_strasse_${controller.kunde.value?.id ?? 0}',
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildAdvancedTextField(
                                  ctrl: controller.kundePlzController,
                                  label: "PLZ",
                                  icon: Icons.pin_drop_outlined,
                                  hint: "12345",
                                  keyboardType: TextInputType.number,
                                  keyValue:
                                      'kunde_plz_${controller.kunde.value?.id ?? 0}',
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                flex: 3,
                                child: _buildAdvancedTextField(
                                  ctrl: controller.kundeOrtController,
                                  label: "Ort",
                                  icon: Icons.location_city_outlined,
                                  hint: "Musterstadt",
                                  keyValue:
                                      'kunde_ort_${controller.kunde.value?.id ?? 0}',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _buildAdvancedTextField(
                            ctrl: controller.kundeTeleController,
                            label: "Telefon",
                            icon: Icons.phone_outlined,
                            hint: "0231 123456",
                            keyboardType: TextInputType.phone,
                            keyValue:
                                'kunde_tele_${controller.kunde.value?.id ?? 0}',
                          ),
                          SizedBox(height: 16.h),
                          _buildAdvancedTextField(
                            ctrl: controller.kundeEmailController,
                            label: "E-Mail",
                            icon: Icons.email_outlined,
                            hint: "info@musterfirma.de",
                            keyboardType: TextInputType.emailAddress,
                            keyValue:
                                'kunde_email_${controller.kunde.value?.id ?? 0}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40.h),
                    // ==================== ADVANCED WEITER BUTTON ====================
                    _buildAdvancedContinueButton(),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HILFSWIDGETS (wie zuvor) ====================
  // (Alle _build... Methoden bleiben exakt wie in deinem Original – sie sind bereits vollständig)
  // Ich lasse sie hier der Übersichtlichkeit halber unverändert stehen.

  Widget _buildAdvancedHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.description_rounded,
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
                      "Auftrag starten",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Schritt 1 von 2",
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _buildProgressStep(
            number: "1",
            label: "Details",
            isActive: true,
            isCompleted: false,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    Colors.grey.shade300,
                  ],
                ),
              ),
            ),
          ),
          _buildProgressStep(
            number: "2",
            label: "Rechnung",
            isActive: false,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required String number,
    required String label,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8)
                    ],
                  )
                : null,
            color: isActive ? null : Colors.grey.shade200,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphicCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAdvancedSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onSearch,
    required VoidCallback onSave,
    required bool showSave,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _buildIconButton(
              icon: Icons.search_rounded,
              onPressed: onSearch,
              tooltip: "Suchen",
            ),
            if (showSave) ...[
              SizedBox(width: 8.w),
              _buildIconButton(
                icon: Icons.save_rounded,
                onPressed: onSave,
                tooltip: "Speichern",
                isPrimary: true,
              ),
            ],
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          height: 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    bool isPrimary = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8)
                  ],
                )
              : null,
          color: isPrimary ? null : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(10.w),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.primary,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedTextField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? keyValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2C3E50),
              letterSpacing: 0.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            key: keyValue != null ? ValueKey(keyValue) : null,
            controller: ctrl,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.next,
            style: TextStyle(
              fontSize: 15.sp,
              color: const Color(0xFF1A1A1A),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Container(
                margin: EdgeInsets.only(right: 12.w, left: 12.w),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22.sp,
                ),
              ),
              prefixIconConstraints: BoxConstraints(
                minWidth: 48.w,
              ),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 18.h,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedContinueButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.85),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final monteurVorname =
                controller.monteurVornameController.text.trim();
            final monteurNachname =
                controller.monteurNachnameController.text.trim();
            final monteurTele = controller.monteurTeleController.text.trim();
            final monteurEmail = controller.monteurEmailController.text.trim();
            final kundeName = controller.kundeNameController.text.trim();
            final kundeStrasse = controller.kundeStrasseController.text.trim();
            final kundePlz = controller.kundePlzController.text.trim();
            final kundeOrt = controller.kundeOrtController.text.trim();
            final kundeTele = controller.kundeTeleController.text.trim();
            final kundeEmail = controller.kundeEmailController.text.trim();

            if (monteurVorname.isEmpty) {
              _showSnackBar("Monteur Vorname ist erforderlich", error: true);
              return;
            }
            if (monteurNachname.isEmpty) {
              _showSnackBar("Monteur Nachname ist erforderlich", error: true);
              return;
            }
            if (monteurTele.isEmpty) {
              _showSnackBar("Monteur Telefon ist erforderlich", error: true);
              return;
            }
            if (kundeName.isEmpty) {
              _showSnackBar("Kundenname ist erforderlich", error: true);
              return;
            }
            if (kundeStrasse.isEmpty) {
              _showSnackBar("Kunde Straße ist erforderlich", error: true);
              return;
            }
            if (kundePlz.isEmpty) {
              _showSnackBar("Kunde PLZ ist erforderlich", error: true);
              return;
            }
            if (kundeOrt.isEmpty) {
              _showSnackBar("Kunde Ort ist erforderlich", error: true);
              return;
            }

            controller.monteur.value = Monteur(
              id: controller.monteur.value.id,
              vorname: monteurVorname,
              nachname: monteurNachname,
              email: monteurEmail,
              telefon: monteurTele,
            );
            controller.kunde.value = Kunde(
              id: controller.kunde.value.id,
              name: kundeName,
              strasse: kundeStrasse,
              plz: kundePlz,
              ort: kundeOrt,
              telefon: kundeTele,
              email: kundeEmail,
            );
            controller.saveEinstellungen();
            Get.to(() => const ScreenInput());
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Weiter zur Rechnung",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
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

  // ==================== MONTEUR AUSWÄHLEN ====================
  void _selectMonteur(BuildContext context) async {
    await controller.reloadAllData();

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  "Monteur auswählen",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.monteureListe.isEmpty) {
                    return Center(
                      child: Text(
                        "Keine Monteure vorhanden",
                        style: TextStyle(
                            fontSize: 16.sp, color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.monteureListe.length,
                    itemBuilder: (context, index) {
                      final monteur = controller.monteureListe[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child:
                              Icon(Icons.engineering, color: AppColors.primary),
                        ),
                        title: Text(
                          "${monteur['vorname'] ?? ''} ${monteur['nachname'] ?? ''}",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(monteur['telefon'] ?? ''),
                        onTap: () async {
                          await controller
                              .selectMonteurFromDatabase(monteur['id']);
                          Navigator.pop(context);
                          controller.updateMonteurControllers();
                          setState(() {});
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

  // ==================== KUNDE AUSWÄHLEN ====================
  void _selectKunde(BuildContext context) async {
    await controller.reloadAllData();

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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  "Kunde auswählen",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.kundenListe.isEmpty) {
                    return Center(
                      child: Text(
                        "Keine Kunden vorhanden",
                        style: TextStyle(
                            fontSize: 16.sp, color: Colors.grey.shade600),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: controller.kundenListe.length,
                    itemBuilder: (context, index) {
                      final kunde = controller.kundenListe[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(Icons.business, color: AppColors.primary),
                        ),
                        title: Text(
                          kunde['name'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          "${kunde['strasse'] ?? ''}, ${kunde['plz'] ?? ''} ${kunde['ort'] ?? ''}",
                        ),
                        onTap: () async {
                          await controller.selectKundeFromDatabase(kunde['id']);
                          Navigator.pop(context);
                          controller.updateKundeControllers();
                          setState(() {});
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
