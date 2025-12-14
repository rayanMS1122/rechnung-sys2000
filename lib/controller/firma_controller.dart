import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reciepts/database/database_helper.dart';
import 'package:reciepts/models/firma_model.dart';
import 'package:reciepts/constants.dart';

class FirmaController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;

  // Reactive Objekt
  final Rx<Firma> firma = Firma(
    name: "",
    strasse: "",
    plz: "",
    ort: "",
    telefon: "",
    email: "",
    website: "",
  ).obs;

  // TextControllers
  late TextEditingController firmaNameController;
  late TextEditingController firmaStrasseController;
  late TextEditingController firmaPlzController;
  late TextEditingController firmaOrtController;
  late TextEditingController firmaTelefonController;
  late TextEditingController firmaWebsiteController;
  late TextEditingController firmaEmailController;

  // Liste für Dropdown
  final RxList<Map<String, dynamic>> firmenListe = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _setupListeners();
  }

  void _initControllers() {
    firmaNameController = TextEditingController(text: firma.value.name ?? '');
    firmaStrasseController = TextEditingController(text: firma.value.strasse ?? '');
    firmaPlzController = TextEditingController(text: firma.value.plz ?? '');
    firmaOrtController = TextEditingController(text: firma.value.ort ?? '');
    firmaTelefonController = TextEditingController(text: firma.value.telefon ?? '');
    firmaEmailController = TextEditingController(text: firma.value.email ?? '');
    firmaWebsiteController = TextEditingController(text: firma.value.website ?? '');
  }

  void _setupListeners() {
    firmaNameController.addListener(() {
      firma.value = firma.value.copyWith(name: firmaNameController.text);
    });
    firmaStrasseController.addListener(() {
      firma.value = firma.value.copyWith(strasse: firmaStrasseController.text);
    });
    firmaPlzController.addListener(() {
      firma.value = firma.value.copyWith(plz: firmaPlzController.text);
    });
    firmaOrtController.addListener(() {
      firma.value = firma.value.copyWith(ort: firmaOrtController.text);
    });
    firmaTelefonController.addListener(() {
      firma.value = firma.value.copyWith(telefon: firmaTelefonController.text);
    });
    firmaEmailController.addListener(() {
      firma.value = firma.value.copyWith(email: firmaEmailController.text);
    });
    firmaWebsiteController.addListener(() {
      firma.value = firma.value.copyWith(website: firmaWebsiteController.text);
    });
  }

  Future<void> loadFirmenFromDatabase() async {
    firmenListe.value = await _dbHelper.queryAllFirmen();
  }

  Future<void> addFirmaToDatabase() async {
    try {
      await _dbHelper.insertFirma({
        'name': firma.value.name,
        'strasse': firma.value.strasse,
        'plz': firma.value.plz,
        'ort': firma.value.ort,
        'telefon': firma.value.telefon,
        'email': firma.value.email,
        'website': firma.value.website,
      });
      await loadFirmenFromDatabase();
      _showSnackBar("Erfolg", "Firma wurde gespeichert!");
    } catch (e) {
      _showSnackBar("Fehler", "Firma konnte nicht gespeichert werden: ${e.toString()}", isError: true);
    }
  }

  Future<void> selectFirmaFromDatabase(int id) async {
    final firmaData = await _dbHelper.queryFirmaById(id);
    if (firmaData != null) {
      firma.value = Firma(
        id: firmaData['id'],
        name: firmaData['name'],
        strasse: firmaData['strasse'],
        plz: firmaData['plz'],
        ort: firmaData['ort'],
        telefon: firmaData['telefon'],
        email: firmaData['email'],
        website: firmaData['website'],
      );
      
      // Controller aktualisieren
      firmaNameController.text = firma.value.name ?? '';
      firmaStrasseController.text = firma.value.strasse ?? '';
      firmaPlzController.text = firma.value.plz ?? '';
      firmaOrtController.text = firma.value.ort ?? '';
      firmaTelefonController.text = firma.value.telefon ?? '';
      firmaEmailController.text = firma.value.email ?? '';
      firmaWebsiteController.text = firma.value.website ?? '';
      
      _showSnackBar("Erfolg", "Firma wurde geladen!");
    }
  }

  void loadFromEinstellungen(Map<String, dynamic> einstellungen) {
    firma.value = Firma(
      name: einstellungen['firma_name'] ?? '',
      strasse: einstellungen['firma_strasse'] ?? '',
      plz: einstellungen['firma_plz'] ?? '',
      ort: einstellungen['firma_ort'] ?? '',
      telefon: einstellungen['firma_telefon'] ?? '',
      email: einstellungen['firma_email'] ?? '',
      website: einstellungen['firma_website'] ?? '',
    );
    _initControllers();
  }

  Map<String, dynamic> getEinstellungenData() {
    return {
      'firma_name': firmaNameController.text,
      'firma_strasse': firmaStrasseController.text,
      'firma_plz': firmaPlzController.text,
      'firma_ort': firmaOrtController.text,
      'firma_telefon': firmaTelefonController.text,
      'firma_email': firmaEmailController.text,
      'firma_website': firmaWebsiteController.text,
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
    firmaNameController.dispose();
    firmaStrasseController.dispose();
    firmaPlzController.dispose();
    firmaOrtController.dispose();
    firmaTelefonController.dispose();
    firmaEmailController.dispose();
    firmaWebsiteController.dispose();
    super.onClose();
  }
}

