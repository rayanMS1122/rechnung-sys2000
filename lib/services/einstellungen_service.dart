import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reciepts/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:reciepts/constants.dart';

class EinstellungenService extends GetxService {
  final _dbHelper = DatabaseHelper.instance;

  final Rx<XFile> logo = XFile('').obs;
  final RxString logoPath = ''.obs;
  final RxBool enableEditing = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> loadEinstellungen() async {
    final einstellungen = await _dbHelper.getEinstellungen();
    if (einstellungen != null) {
      // Logo laden
      final savedLogoPath = einstellungen['logo_path'] as String?;
      if (savedLogoPath != null && savedLogoPath.isNotEmpty) {
        final file = File(savedLogoPath);
        if (await file.exists()) {
          logo.value = XFile(savedLogoPath);
        } else {
          resetLogo();
        }
      } else {
        resetLogo();
      }

      // Bearbeitung erlauben
      enableEditing.value = (einstellungen['enable_editing'] as int? ?? 0) == 1;
    } else {
      resetLogo();
    }
  }

  Future<void> saveEinstellungen({
    required Map<String, dynamic> firmaData,
    required Map<String, dynamic> baustelleData,
    required int? lastMonteurId,
    required int? lastKundeId,
  }) async {
    final data = {
      ...firmaData,
      ...baustelleData,
      'logo_path': logo.value.path == 'assets/senat.png' ? '' : logo.value.path,
      'enable_editing': enableEditing.value ? 1 : 0,
      'last_monteur_id': lastMonteurId,
      'last_kunde_id': lastKundeId,
    };

    await _dbHelper.saveEinstellungen(data);
  }

  Future<void> changeLogo() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String newPath =
            "${directory.path}/logo_${DateTime.now().millisecondsSinceEpoch}.png";
        final File newFile = await File(pickedFile.path).copy(newPath);

        logo.value = XFile(newFile.path);
      }
    } catch (e) {
      debugPrint("Fehler beim Speichern des Logos: $e");
    }
  }

  void resetLogo() {
    logo.value = XFile('assets/senat.png');
  }

  void _showSnackBar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.redAccent.withOpacity(0.9) : AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 15,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}

