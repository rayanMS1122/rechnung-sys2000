import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reciepts/database/database_helper.dart';
import 'package:reciepts/models/baustelle.dart';
import 'package:reciepts/models/kunde.dart';
import 'package:reciepts/constants.dart';

class BaustelleController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;

  // Reactive Objekt
  late Rx<Baustelle> baustelle;

  // TextControllers
  late TextEditingController baustelleStrasseController;
  late TextEditingController baustellePlzController;
  late TextEditingController baustelleOrtController;

  // Liste für Dropdown
  final RxList<Map<String, dynamic>> baustellenListe = <Map<String, dynamic>>[].obs;

  void initialize(Rx<Kunde> kunde) {
    baustelle = Baustelle(
      strasse: "",
      plz: "",
      ort: "",
      kundeId: kunde.value.id ?? 0,
    ).obs;
    _initControllers();
    _setupListeners();
  }

  void _initControllers() {
    baustelleStrasseController = TextEditingController(text: baustelle.value.strasse ?? '');
    baustellePlzController = TextEditingController(text: baustelle.value.plz ?? '');
    baustelleOrtController = TextEditingController(text: baustelle.value.ort ?? '');
  }

  void _setupListeners() {
    baustelleStrasseController.addListener(() {
      baustelle.value.strasse = baustelleStrasseController.text;
    });
    baustellePlzController.addListener(() {
      baustelle.value.plz = baustellePlzController.text;
    });
    baustelleOrtController.addListener(() {
      baustelle.value.ort = baustelleOrtController.text;
    });
  }

  Future<void> loadBaustellenFromDatabase() async {
    baustellenListe.value = await _dbHelper.queryAllBaustellen();
  }

  Future<void> addBaustelleToDatabase() async {
    try {
      await _dbHelper.insertBaustelle({
        'strasse': baustelle.value.strasse ?? '',
        'plz': baustelle.value.plz ?? '',
        'ort': baustelle.value.ort ?? '',
      });
      await loadBaustellenFromDatabase();
      _showSnackBar("Erfolg", "Baustelle wurde gespeichert!");
    } catch (e) {
      _showSnackBar("Fehler", "Baustelle konnte nicht gespeichert werden: ${e.toString()}", isError: true);
    }
  }

  Future<void> selectBaustelleFromDatabase(int id, Rx<Kunde> kunde) async {
    final baustelleData = await _dbHelper.queryBaustelleById(id);
    if (baustelleData != null) {
      baustelle.value = Baustelle(
        id: baustelleData['id'],
        strasse: baustelleData['strasse'],
        plz: baustelleData['plz'],
        ort: baustelleData['ort'],
        kundeId: kunde.value.id ?? 0,
      );
      _initControllers();
      _showSnackBar("Erfolg", "Baustelle wurde geladen!");
    }
  }

  void loadFromEinstellungen(Map<String, dynamic> einstellungen, Rx<Kunde> kunde) {
    baustelle.value = Baustelle(
      strasse: einstellungen['baustelle_strasse'] ?? '',
      plz: einstellungen['baustelle_plz'] ?? '',
      ort: einstellungen['baustelle_ort'] ?? '',
      kundeId: kunde.value.id ?? 0,
    );
    _initControllers();
  }

  Map<String, dynamic> getEinstellungenData() {
    return {
      'baustelle_strasse': baustelleStrasseController.text,
      'baustelle_plz': baustellePlzController.text,
      'baustelle_ort': baustelleOrtController.text,
    };
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

  @override
  void onClose() {
    baustelleStrasseController.dispose();
    baustellePlzController.dispose();
    baustelleOrtController.dispose();
    super.onClose();
  }
}

