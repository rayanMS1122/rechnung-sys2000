import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reciepts/models/baustelle.dart';
import 'package:reciepts/models/kunde.dart';
import 'package:reciepts/models/monteur.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reciepts/models/firma_model.dart';
import 'package:reciepts/models/reciept_model.dart';
import 'package:reciepts/database/database_helper.dart';

class ScreenInputController extends GetxController {
  // ==================== DATABASE ====================
  final _dbHelper = DatabaseHelper.instance;

  // ==================== LISTEN FÜR DROPDOWN/AUSWAHL ====================
  final RxList<Map<String, dynamic>> firmenListe = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> kundenListe = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> monteureListe =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> baustellenListe =
      <Map<String, dynamic>>[].obs;

  // ==================== REACTIVE OBJEKTE ====================
  final Rx<Firma> firma = Firma(
    name: "",
    strasse: "",
    plz: "",
    ort: "",
    telefon: "",
    email: "",
    website: "",
  ).obs;

  Rx<Kunde> kunde = Kunde(
    name: "",
    strasse: "",
    plz: "",
    ort: "",
    telefon: "",
    email: "",
  ).obs;

  final Rx<Monteur> monteur = Monteur(
    vorname: "",
    nachname: "",
    telefon: "",
  ).obs;

  late Rx<Baustelle> baustelle = Baustelle(
    strasse: "",
    plz: "",
    ort: "",
    kundeId: kunde.value.id ?? 0,
  ).obs;

  // ==================== SONSTIGES ====================
  final Rx<XFile> logo = XFile('').obs;
  final RxString logoPath = ''.obs;
  final rechnungTextFielde = <ReceiptData>[].obs;
  final RxBool enableEditing = false.obs;

  // TextController
  late TextEditingController firmaNameController =
      TextEditingController(text: firma.value.name ?? "");
  late TextEditingController firmaStrasseController =
      TextEditingController(text: firma.value.strasse ?? "");
  late TextEditingController firmaPlzController =
      TextEditingController(text: firma.value.plz ?? "");
  late TextEditingController firmaOrtController =
      TextEditingController(text: firma.value.ort ?? "");
  late TextEditingController firmaTelefonController =
      TextEditingController(text: firma.value.telefon ?? "");
  late TextEditingController firmaWebsiteController =
      TextEditingController(text: firma.value.website ?? "");
  late TextEditingController firmaEmailController =
      TextEditingController(text: firma.value.email ?? "");

  late TextEditingController kundeNameController =
      TextEditingController(text: kunde.value?.name ?? "");
  late TextEditingController kundeStrasseController =
      TextEditingController(text: kunde.value?.strasse ?? "");
  late TextEditingController kundePlzController =
      TextEditingController(text: kunde.value?.plz ?? "");
  late TextEditingController kundeOrtController =
      TextEditingController(text: kunde?.value.ort ?? "");
  late TextEditingController kundeTeleController =
      TextEditingController(text: kunde.value?.telefon ?? "");
  late TextEditingController kundeEmailController =
      TextEditingController(text: kunde.value?.email ?? "");

  late TextEditingController monteurVornameController =
      TextEditingController(text: monteur.value?.vorname ?? "");
  late TextEditingController monteurNachnameController =
      TextEditingController(text: monteur.value?.nachname ?? "");
  late TextEditingController monteurTeleController =
      TextEditingController(text: monteur.value?.telefon ?? "");
  late TextEditingController monteurEmailController =
      TextEditingController(text: monteur.value?.email ?? "");

  late TextEditingController baustelleStrasseController =
      TextEditingController(text: baustelle.value.strasse ?? "");
  late TextEditingController baustellePlzController =
      TextEditingController(text: baustelle.value.plz ?? "");
  late TextEditingController baustelleOrtController =
      TextEditingController(text: baustelle.value.ort ?? "");

  // ==================== PRIVATE ====================
  late SharedPreferences prefs; // Nur noch für Logo-Pfad verwendet
  final ImagePicker _picker = ImagePicker();

  // ==================== LIFECYCLE ====================
  @override
  void onInit() async {
    await _loadAllDataFromDatabase();
    _setupListeners();

    super.onInit();
  }

  @override
  void onClose() {
    // Controller werden automatisch disposed durch GetX
    super.onClose();
  }

  // ==================== DATEN AUS DATABASE LADEN ====================
  Future<void> _loadAllDataFromDatabase() async {
    firmenListe.value = await _dbHelper.queryAllFirmen();
    kundenListe.value = await _dbHelper.queryAllKunden();
    monteureListe.value = await _dbHelper.queryAllMonteure();
    baustellenListe.value = await _dbHelper.queryAllBaustellen();
  }

  void _initControllers() {
    firmaNameController = TextEditingController(text: firma.value.name);
    firmaStrasseController = TextEditingController(text: firma.value.strasse);
    firmaPlzController = TextEditingController(text: firma.value.plz);
    firmaOrtController = TextEditingController(text: firma.value.ort);
    firmaTelefonController = TextEditingController(text: firma.value.telefon);
    firmaEmailController = TextEditingController(text: firma.value.email);
    firmaWebsiteController = TextEditingController(text: firma.value.website);

    kundeNameController = TextEditingController(text: kunde.value.name);
    kundeStrasseController = TextEditingController(text: kunde.value.strasse);
    kundePlzController = TextEditingController(text: kunde.value.plz);
    kundeOrtController = TextEditingController(text: kunde.value.ort);
    kundeTeleController = TextEditingController(text: kunde.value.telefon);
    kundeEmailController = TextEditingController(text: kunde.value.email);

    monteurVornameController =
        TextEditingController(text: monteur.value.vorname);
    monteurNachnameController =
        TextEditingController(text: monteur.value.nachname);
    monteurTeleController = TextEditingController(text: monteur.value.telefon);
    monteurEmailController =
        TextEditingController(text: monteur.value.email ?? "");
    updateMonteurControllers();
    updateKundeControllers();
    baustelleStrasseController =
        TextEditingController(text: baustelle.value.strasse);
    baustellePlzController = TextEditingController(text: baustelle.value.plz);
    baustelleOrtController = TextEditingController(text: baustelle.value.ort);
  }

  // ==================== DATABASE FUNKTIONEN ====================

  // FIRMA
  Future<void> addFirmaToDatabase() async {
    await _dbHelper.insertFirma({
      'name': firma.value.name,
      'strasse': firma.value.strasse,
      'plz': firma.value.plz,
      'ort': firma.value.ort,
      'telefon': firma.value.telefon,
      'email': firma.value.email,
      'website': firma.value.website,
    });
    await _loadAllDataFromDatabase();
    Get.snackbar("Erfolg", "Firma wurde gespeichert!");
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
      _initControllers();
      Get.snackbar("Erfolg", "Firma wurde geladen!");
    }
  }

  // KUNDE
  Future<void> addKundeToDatabase() async {
    await _dbHelper.insertKunde({
      'name': kunde.value.name,
      'strasse': kunde.value.strasse,
      'plz': kunde.value.plz,
      'ort': kunde.value.ort,
      'telefon': kunde.value.telefon,
      'email': kunde.value.email,
    });
    await _loadAllDataFromDatabase();
    Get.snackbar("Erfolg", "Kunde wurde gespeichert!");
  }

  // MONTEUR
  Future<void> addMonteurToDatabase() async {
    await _dbHelper.insertMonteur({
      'vorname': monteur.value.vorname,
      'nachname': monteur.value.nachname,
      'telefon': monteur.value.telefon,
      'email': monteur.value.email,
    });
    await _loadAllDataFromDatabase();
    Get.snackbar("Erfolg", "Monteur wurde gespeichert!");
  }

  Future<void> selectMonteurFromDatabase(int id) async {
    final monteurData = await _dbHelper.queryMonteurById(id);
    if (monteurData != null) {
      monteur.value = Monteur(
        id: monteurData['id'],
        vorname: monteurData['vorname'],
        nachname: monteurData['nachname'],
        telefon: monteurData['telefon'],
        email: monteurData['email'],
      );

      // Das ist der entscheidende Aufruf!
      updateMonteurControllers();

      Get.snackbar("Erfolg", "Monteur wurde geladen!");
    }
  }

  Future<void> selectKundeFromDatabase(int id) async {
    final kundeData = await _dbHelper.queryKundeById(id);
    if (kundeData != null) {
      kunde.value = Kunde(
        id: kundeData['id'],
        name: kundeData['name'],
        strasse: kundeData['strasse'],
        plz: kundeData['plz'],
        ort: kundeData['ort'],
        telefon: kundeData['telefon'],
        email: kundeData['email'],
      );

      // Das ist der entscheidende Aufruf!
      updateKundeControllers();

      Get.snackbar("Erfolg", "Kunde wurde geladen!");
    }
  }

  // BAUSTELLE
  Future<void> addBaustelleToDatabase() async {
    await _dbHelper.insertBaustelle({
      'strasse': baustelle.value.strasse,
      'plz': baustelle.value.plz,
      'ort': baustelle.value.ort,
    });
    await _loadAllDataFromDatabase();
    Get.snackbar("Erfolg", "Baustelle wurde gespeichert!");
  }

  Future<void> selectBaustelleFromDatabase(int id) async {
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
      Get.snackbar("Erfolg", "Baustelle wurde geladen!");
    }
  }

  // ==================== LISTENER (Update Reactive Objects) ====================
  void _setupListeners() {
    // Monteur - aktualisiert reactive Objekte
    monteurVornameController.addListener(() {
      monteur.value.vorname = monteurVornameController.text;
    });
    monteurNachnameController.addListener(() {
      monteur.value.nachname = monteurNachnameController.text;
    });
    monteurTeleController.addListener(() {
      monteur.value.telefon = monteurTeleController.text;
    });
    monteurEmailController.addListener(() {
      monteur.value.email = monteurEmailController.text;
    });

    // Kunde - aktualisiert reactive Objekte
    kundeNameController.addListener(() {
      kunde.value.name = kundeNameController.text;
    });
    kundeStrasseController.addListener(() {
      kunde.value.strasse = kundeStrasseController.text;
    });
    kundePlzController.addListener(() {
      kunde.value.plz = kundePlzController.text;
    });
    kundeOrtController.addListener(() {
      kunde.value.ort = kundeOrtController.text;
    });
    kundeTeleController.addListener(() {
      kunde.value.telefon = kundeTeleController.text;
    });
    kundeEmailController.addListener(() {
      kunde.value.email = kundeEmailController.text;
    });

    // Baustelle - aktualisiert reactive Objekte
    baustelleStrasseController.addListener(() {
      baustelle.value.strasse = baustelleStrasseController.text;
    });
    baustellePlzController.addListener(() {
      baustelle.value.plz = baustellePlzController.text;
    });
    baustelleOrtController.addListener(() {
      baustelle.value.ort = baustelleOrtController.text;
    });

    // Firma - aktualisiert reactive Objekte
    firmaNameController.addListener(() {
      firma.value.name = firmaNameController.text;
    });
    firmaStrasseController.addListener(() {
      firma.value.strasse = firmaStrasseController.text;
    });
    firmaPlzController.addListener(() {
      firma.value.plz = firmaPlzController.text;
    });
    firmaOrtController.addListener(() {
      firma.value.ort = firmaOrtController.text;
    });
    firmaTelefonController.addListener(() {
      firma.value.telefon = firmaTelefonController.text;
    });
    firmaEmailController.addListener(() {
      firma.value.email = firmaEmailController.text;
    });
    firmaWebsiteController.addListener(() {
      firma.value.website = firmaWebsiteController.text;
    });
  }

  // ==================== LOGO FUNKTIONEN ====================
  Future<void> changeLogo(BuildContext context) async {
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
        logoPath.value = newFile.path;
        await prefs.setString('logo_path', newFile.path);

        Get.snackbar("Erfolg", "Logo wurde gespeichert!");
      }
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar("Fehler", "Logo konnte nicht gespeichert werden: $e");
    }
  }

  void resetLogo() async {
    logo.value = XFile('assets/system2000_logo.png');
    logoPath.value = '';
    await prefs.remove('logo_path');
  }

  void addNewTextFields() {
    rechnungTextFielde.add(ReceiptData(
      pos: rechnungTextFielde.length,
      menge: 0,
      einh: '',
      bezeichnung: '',
      einzelPreis: 0.0,
    ));
  }

  // Aktualisiert alle TextController für Monteur
  void updateMonteurControllers() {
    monteurVornameController.text = monteur.value.vorname ?? '';
    monteurNachnameController.text = monteur.value.nachname ?? '';
    monteurTeleController.text = monteur.value.telefon ?? '';
    monteurEmailController.text = monteur.value.email ?? '';
  }

  // Aktualisiert alle TextController für Kunde
  void updateKundeControllers() {
    kundeNameController.text = kunde.value.name ?? '';
    kundeStrasseController.text = kunde.value.strasse ?? '';
    kundePlzController.text = kunde.value.plz ?? '';
    kundeOrtController.text = kunde.value.ort ?? '';
    kundeTeleController.text = kunde.value.telefon ?? '';
    kundeEmailController.text = kunde.value.email ?? '';
  }
}
