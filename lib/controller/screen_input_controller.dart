import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reciepts/model/firma_model.dart';
import 'package:reciepts/model/reciept_model.dart';

class ScreenInputController extends GetxController {
  late CompanyData data = CompanyData(
    firma: Firma(
      name: "",
      strasse: "",
      plz: "",
      ort: "",
      telefon: "",
      email: "",
      website: "",
    ),
    baustelle: Baustelle(
      strasse: "",
      plz: "",
      ort: "",
    ),
    kunde: Kunde(
      name: "",
      strasse: "",
      plz: "",
      ort: "",
      telefon: "",
      email: "",
    ),
    monteur: Monteur(
      vorname: "",
      nachname: "",
      telefon: "",
    ),
  );

  final Rx<XFile> logo = XFile('').obs;
  final RxString logoPath = ''.obs;
  final rechnungTextFielde = <ReceiptData>[].obs;
  final RxBool enableEditing = false.obs;

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

  // ==================== PRIVATE ====================
  late SharedPreferences prefs;
  Timer? _debounceTimer;
  final ImagePicker _picker = ImagePicker();

  // ==================== LIFECYCLE ====================
  @override
  void onInit() async {
    // 1. SharedPreferences einmalig laden (einziger Ort!)
    prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // WICHTIG für iOS!

    // 2. Daten laden + Controller initialisieren
    await _loadAllDataFromStorage();
    _setupListeners();

    super.onInit();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadAllDataFromStorage() async {
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

    _initControllers();

    // Logo laden
    String? savedLogoPath = prefs.getString('logo_path');
    if (savedLogoPath != null && await File(savedLogoPath).exists()) {
      logo.value = XFile(savedLogoPath);
      logoPath.value = savedLogoPath;
    } else {
      logo.value = XFile('assets/system2000_logo.png');
    }

    // Erste Rechnungsposition falls leer
    if (rechnungTextFielde.isEmpty) {
      rechnungTextFielde.add(ReceiptData(
        pos: 0,
        menge: 0,
        einh: '',
        bezeichnung: '',
        einzelPreis: 0.0,
      ));
    }
  }

  void _initControllers() {
    firmaNameController = TextEditingController(text: data.firma.name);
    firmaStrasseController = TextEditingController(text: data.firma.strasse);
    firmaPlzController = TextEditingController(text: data.firma.plz);
    firmaOrtController = TextEditingController(text: data.firma.ort);
    firmaTelefonController = TextEditingController(text: data.firma.telefon);
    firmaEmailController = TextEditingController(text: data.firma.email);
    firmaWebsiteController = TextEditingController(text: data.firma.website);

    kundeNameController = TextEditingController(text: data.kunde?.name ?? '');
    kundeStrasseController =
        TextEditingController(text: data.kunde?.strasse ?? '');
    kundePlzController = TextEditingController(text: data.kunde?.plz ?? '');
    kundeOrtController = TextEditingController(text: data.kunde?.ort ?? '');
    kundeTeleController =
        TextEditingController(text: data.kunde?.telefon ?? '');
    kundeEmailController = TextEditingController(text: data.kunde?.email ?? '');

    monteurVornameController =
        TextEditingController(text: data.monteur?.vorname ?? '');
    monteurNachnameController =
        TextEditingController(text: data.monteur?.nachname ?? '');
    monteurTeleController =
        TextEditingController(text: data.monteur?.telefon ?? '');
    monteurEmailController =
        TextEditingController(text: data.monteur?.email ?? '');

    baustelleStrasseController =
        TextEditingController(text: data.baustelle.strasse);
    baustellePlzController = TextEditingController(text: data.baustelle.plz);
    baustelleOrtController = TextEditingController(text: data.baustelle.ort);
  }

  // ==================== DEBOUNCED SAVE ====================
  void _debouncedSave(String key, String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () async {
      final trimmedValue = value.trim();
      await prefs.setString(key, trimmedValue);

      // DIES IST DIE MAGISCHE ZEILE FÜR iOS!!!
      await prefs.reload(); // ← zwingt sofortigen Refresh des Caches
    });
  }

  // ==================== ALLE LISTENER (Auto-Save) ====================
  void _setupListeners() {
    // Monteur
    monteurVornameController.addListener(() {
      data.monteur!.vorname = monteurVornameController.text;
      _debouncedSave('monteur_vorname', monteurVornameController.text);
    });
    monteurNachnameController.addListener(() {
      data.monteur!.nachname = monteurNachnameController.text;
      _debouncedSave('monteur_nachname', monteurNachnameController.text);
    });
    monteurTeleController.addListener(() {
      data.monteur!.telefon = monteurTeleController.text;
      _debouncedSave('monteur_telefon', monteurTeleController.text);
    });
    monteurEmailController.addListener(() {
      data.monteur!.email = monteurEmailController.text;
      _debouncedSave('monteur_email', monteurEmailController.text);
    });

    // Kunde
    kundeNameController.addListener(() {
      data.kunde!.name = kundeNameController.text;
      _debouncedSave('kunde_name', kundeNameController.text);
    });
    kundeStrasseController.addListener(() {
      data.kunde!.strasse = kundeStrasseController.text;
      _debouncedSave('kunde_strasse', kundeStrasseController.text);
    });
    kundePlzController.addListener(() {
      data.kunde!.plz = kundePlzController.text;
      _debouncedSave('kunde_plz', kundePlzController.text);
    });
    kundeOrtController.addListener(() {
      data.kunde!.ort = kundeOrtController.text;
      _debouncedSave('kunde_ort', kundeOrtController.text);
    });
    kundeTeleController.addListener(() {
      data.kunde!.telefon = kundeTeleController.text;
      _debouncedSave('kunde_telefon', kundeTeleController.text);
    });
    kundeEmailController.addListener(() {
      data.kunde!.email = kundeEmailController.text;
      _debouncedSave('kunde_email', kundeEmailController.text);
    });

    // Baustelle
    baustelleStrasseController.addListener(() {
      data.baustelle.strasse = baustelleStrasseController.text;
      _debouncedSave('baustelle_strasse', baustelleStrasseController.text);
    });
    baustellePlzController.addListener(() {
      data.baustelle.plz = baustellePlzController.text;
      _debouncedSave('baustelle_plz', baustellePlzController.text);
    });
    baustelleOrtController.addListener(() {
      data.baustelle.ort = baustelleOrtController.text;
      _debouncedSave('baustelle_ort', baustelleOrtController.text);
    });

    // Firma (falls du sie bearbeitbar machst)
    firmaNameController.addListener(() {
      data.firma.name = firmaNameController.text;
      _debouncedSave('firma_name', firmaNameController.text);
    });
    firmaStrasseController.addListener(() {
      data.firma.strasse = firmaStrasseController.text;
      _debouncedSave('firma_strasse', firmaStrasseController.text);
    });
    firmaPlzController.addListener(() {
      data.firma.plz = firmaPlzController.text;
      _debouncedSave('firma_plz', firmaPlzController.text);
    });
    firmaOrtController.addListener(() {
      data.firma.ort = firmaOrtController.text;
      _debouncedSave('firma_ort', firmaOrtController.text);
    });
    firmaTelefonController.addListener(() {
      data.firma.telefon = firmaTelefonController.text;
      _debouncedSave('firma_telefon', firmaTelefonController.text);
    });
    firmaEmailController.addListener(() {
      data.firma.email = firmaEmailController.text;
      _debouncedSave('firma_email', firmaEmailController.text);
    });
    firmaWebsiteController.addListener(() {
      data.firma.website = firmaWebsiteController.text;
      _debouncedSave('firma_website', firmaWebsiteController.text);
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

  // ==================== RECHNUNGSPOSITIONEN ====================
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
