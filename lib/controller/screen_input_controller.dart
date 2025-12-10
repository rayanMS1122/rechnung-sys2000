import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reciepts/model/firma_model.dart';
import 'package:reciepts/model/reciept_model.dart';

class ScreenInputController extends GetxController {
  late CompanyData data;

  // TextController
  late TextEditingController firmaNameController =
      TextEditingController(text: data.firma.name ?? "");
  late TextEditingController firmaStrasseController =
      TextEditingController(text: data.firma.strasse ?? "");
  late TextEditingController firmaPlzController =
      TextEditingController(text: data.firma.plz ?? "");
  late TextEditingController firmaOrtController =
      TextEditingController(text: data.firma.ort ?? "");
  late TextEditingController firmaTelefonController =
      TextEditingController(text: data.firma.telefon ?? "");
  late TextEditingController firmaWebsiteController =
      TextEditingController(text: data.firma.website ?? "");
  late TextEditingController firmaEmailController =
      TextEditingController(text: data.firma.email ?? "");

  late TextEditingController kundeNameController =
      TextEditingController(text: data.kunde?.name ?? "");
  late TextEditingController kundeStrasseController =
      TextEditingController(text: data.kunde?.strasse ?? "");
  late TextEditingController kundePlzController =
      TextEditingController(text: data.kunde?.plz ?? "");
  late TextEditingController kundeOrtController =
      TextEditingController(text: data.kunde?.ort ?? "");
  late TextEditingController kundeTeleController =
      TextEditingController(text: data.kunde?.telefon ?? "");
  late TextEditingController kundeEmailController =
      TextEditingController(text: data.kunde?.email ?? "");

  late TextEditingController monteurVornameController =
      TextEditingController(text: data.monteur?.vorname ?? "");
  late TextEditingController monteurNachnameController =
      TextEditingController(text: data.monteur?.nachname ?? "");
  late TextEditingController monteurTeleController =
      TextEditingController(text: data.monteur?.telefon ?? "");
  late TextEditingController monteurEmailController =
      TextEditingController(text: data.monteur?.email ?? "");

  late TextEditingController baustelleStrasseController =
      TextEditingController(text: data.baustelle.strasse ?? "");
  late TextEditingController baustellePlzController =
      TextEditingController(text: data.baustelle.plz ?? "");
  late TextEditingController baustelleOrtController =
      TextEditingController(text: data.baustelle.ort ?? "");
  final Rx<XFile> logo = XFile('').obs;
  final RxString logoPath = ''.obs; // Speichert den Pfad zum gespeicherten Logo

  final rechnungTextFielde = <ReceiptData>[].obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() async {
    await _loadAllDataFromStorage();
    _setupListeners(); // Live-Speichern bei jeder Änderung
    super.onInit();
  }

  // ====================== LADEN ======================
  Future<void> _loadAllDataFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    // Standarddaten (falls nichts gespeichert)
    data = CompanyData(
      firma: Firma(
        name: prefs.getString('firma_name') ?? "sys2000",
        strasse: prefs.getString('firma_strasse') ?? "Am Kühlturm 3a",
        plz: prefs.getString('firma_plz') ?? "44536",
        ort: prefs.getString('firma_ort') ?? "Lünen",
        telefon: prefs.getString('firma_telefon') ?? "0231 9851550",
        email: prefs.getString('firma_email') ?? "info@system-2000.de",
        website: prefs.getString('firma_website') ?? "https://system2000.de/",
      ),
      baustelle: Baustelle(
        strasse: prefs.getString('baustelle_strasse') ?? "Berliner Str. 17",
        plz: prefs.getString('baustelle_plz') ?? "10176",
        ort: prefs.getString('baustelle_ort') ?? "Berlin",
      ),
      monteur: Monteur(
        vorname: prefs.getString('monteur_vorname') ?? "",
        nachname: prefs.getString('monteur_nachname') ?? "",
        telefon: prefs.getString('monteur_telefon') ?? "",
        email: prefs.getString('monteur_email') ?? "",
      ),
      kunde: Kunde(
        name: prefs.getString('kunde_name') ?? "",
        strasse: prefs.getString('kunde_strasse') ?? "",
        plz: prefs.getString('kunde_plz') ?? "",
        ort: prefs.getString('kunde_ort') ?? "",
        telefon: prefs.getString('kunde_telefon') ?? "",
        email: prefs.getString('kunde_email') ?? "",
      ),
    );

    // Controller mit geladenen Werten füllen
    _initControllers();

    // Logo laden (wenn gespeichert)
    String? savedLogoPath = prefs.getString('logo_path');
    if (savedLogoPath != null && await File(savedLogoPath).exists()) {
      logo.value = XFile(savedLogoPath);
      logoPath.value = savedLogoPath;
    } else {
      logo.value = XFile('assets/system2000_logo.png');
    }

    // Erste Rechnungsposition
    if (rechnungTextFielde.isEmpty) {
      rechnungTextFielde.add(ReceiptData(
          pos: 0, menge: 0, einh: '', bezeichnung: '', einzelPreis: 0.0));
    }
  }

  void _initControllers() {
    firmaNameController = TextEditingController(text: data.firma.name);
    firmaStrasseController = TextEditingController(text: data.firma.strasse);
    firmaPlzController = TextEditingController(text: data.firma.plz);
    firmaOrtController = TextEditingController(text: data.firma.ort);
    firmaTelefonController = TextEditingController(text: data.firma.telefon);
    firmaWebsiteController = TextEditingController(text: data.firma.website);
    firmaEmailController = TextEditingController(text: data.firma.email);

    kundeNameController = TextEditingController(text: data.kunde?.name ?? '');
    kundeStrasseController =
        TextEditingController(text: data.kunde?.strasse ?? '');
    kundePlzController = TextEditingController(text: data.kunde?.plz ?? '');
    kundeOrtController = TextEditingController(text: data.kunde?.ort ?? '');
    kundeTeleController =
        TextEditingController(text: data.kunde?.telefon ?? '');
    kundeEmailController = TextEditingController(text: data.kunde?.email ?? '');

    monteurVornameController =
        TextEditingController(text: data.monteur!.vorname);
    monteurNachnameController =
        TextEditingController(text: data.monteur!.nachname);
    monteurTeleController = TextEditingController(text: data.monteur!.telefon);
    monteurEmailController = TextEditingController(text: data.monteur!.email);

    baustelleStrasseController =
        TextEditingController(text: data.baustelle.strasse);
    baustellePlzController = TextEditingController(text: data.baustelle.plz);
    baustelleOrtController = TextEditingController(text: data.baustelle.ort);
  }

  // ====================== AUTOMATISCHES SPEICHERN BEI JEDER ÄNDERUNG ======================
  void _setupListeners() {
    // Monteur
    monteurVornameController.addListener(
        () => _saveToPrefs('monteur_vorname', monteurVornameController.text));
    monteurNachnameController.addListener(
        () => _saveToPrefs('monteur_nachname', monteurNachnameController.text));
    monteurTeleController.addListener(
        () => _saveToPrefs('monteur_telefon', monteurTeleController.text));
    monteurEmailController.addListener(
        () => _saveToPrefs('monteur_email', monteurEmailController.text));

    // Kunde
    kundeNameController.addListener(
        () => _saveToPrefs('kunde_name', kundeNameController.text));
    kundeStrasseController.addListener(
        () => _saveToPrefs('kunde_strasse', kundeStrasseController.text));
    kundePlzController
        .addListener(() => _saveToPrefs('kunde_plz', kundePlzController.text));
    kundeOrtController
        .addListener(() => _saveToPrefs('kunde_ort', kundeOrtController.text));
    kundeTeleController.addListener(
        () => _saveToPrefs('kunde_telefon', kundeTeleController.text));
    kundeEmailController.addListener(
        () => _saveToPrefs('kunde_email', kundeEmailController.text));

    // Baustelle
    baustelleStrasseController.addListener(() =>
        _saveToPrefs('baustelle_strasse', baustelleStrasseController.text));
    baustellePlzController.addListener(
        () => _saveToPrefs('baustelle_plz', baustellePlzController.text));
    baustelleOrtController.addListener(
        () => _saveToPrefs('baustelle_ort', baustelleOrtController.text));

    // Firma (optional – meist fix, aber falls du sie änderbar machst)
    firmaNameController.addListener(
        () => _saveToPrefs('firma_name', firmaNameController.text));
    // ... weitere Firma-Felder wenn gewünscht
  }

  Future<void> _saveToPrefs(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value.trim());
  }

  // ====================== LOGO SPEICHERN ======================
  Future<void> changeLogo(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Bild in App-Verzeichnis kopieren (dauerhaft speichern)
        final directory = await getApplicationDocumentsDirectory();
        final String newPath =
            "${directory.path}/logo_${DateTime.now().millisecondsSinceEpoch}.png";
        final File newFile = await File(pickedFile.path).copy(newPath);

        logo.value = XFile(newFile.path);
        logoPath.value = newFile.path;

        // Pfad speichern
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('logo_path', newFile.path);

        Get.snackbar("Erfolg", "Logo wurde gespeichert!");
      }
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar("Fehler", "Logo konnte nicht gespeichert werden");
    }
  }

  void resetLogo() async {
    logo.value = XFile('assets/system2000_logo.png');
    logoPath.value = '';
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('logo_path');
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
}
