import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reciepts/models/baustelle.dart';
import 'package:reciepts/models/kunde.dart';
import 'package:reciepts/models/monteur.dart';
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
      TextEditingController(text: kunde.value?.ort ?? "");
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
  final ImagePicker _picker = ImagePicker();
  bool _isUpdatingControllers = false; // Flag um Listener zu deaktivieren
  @override
  void onInit() async {
    super.onInit(); // Wichtig: super.onInit() zuerst aufrufen
    
    // Controller zuerst initialisieren
    _initControllers();
    
    await _loadAllDataFromDatabase();
    await _loadEinstellungenFromDB(); // Lädt Daten und aktualisiert Controller

    _setupListeners();
    _setupAutoSaveListeners(); // Angepasst für DB
  }

  void _setupAutoSaveListeners() {
    // Firma automatisch speichern
    firmaNameController.addListener(_saveEinstellungen);
    firmaStrasseController.addListener(_saveEinstellungen);
    firmaPlzController.addListener(_saveEinstellungen);
    firmaOrtController.addListener(_saveEinstellungen);
    firmaTelefonController.addListener(_saveEinstellungen);
    firmaEmailController.addListener(_saveEinstellungen);
    firmaWebsiteController.addListener(_saveEinstellungen);

    // Baustelle
    baustelleStrasseController.addListener(_saveEinstellungen);
    baustellePlzController.addListener(_saveEinstellungen);
    baustelleOrtController.addListener(_saveEinstellungen);

    // Switch für Bearbeitung
    ever(enableEditing, (bool value) async {
      await _saveEinstellungen();
    });
  }

  Future<void> _saveEinstellungen() async {
    final data = {
      'firma_name': firmaNameController.text,
      'firma_strasse': firmaStrasseController.text,
      'firma_plz': firmaPlzController.text,
      'firma_ort': firmaOrtController.text,
      'firma_telefon': firmaTelefonController.text,
      'firma_email': firmaEmailController.text,
      'firma_website': firmaWebsiteController.text,
      'baustelle_strasse': baustelleStrasseController.text,
      'baustelle_plz': baustellePlzController.text,
      'baustelle_ort': baustelleOrtController.text,
      'logo_path': logo.value.path == 'assets/system2000_logo.png'
          ? ''
          : logo.value.path,
      'enable_editing': enableEditing.value ? 1 : 0,
      'last_monteur_id': monteur.value.id,
      'last_kunde_id': kunde.value.id,
    };

    await _dbHelper.saveEinstellungen(data);

    // Optional: Reaktive Objekte aktualisieren
    firma.refresh();
    baustelle.refresh();
  }

  Future<void> _loadEinstellungenFromDB() async {
    final einstellungen = await _dbHelper.getEinstellungen();

    if (einstellungen != null) {
      // Firma laden
      firma.value = Firma(
        name: einstellungen['firma_name'] ?? '',
        strasse: einstellungen['firma_strasse'] ?? '',
        plz: einstellungen['firma_plz'] ?? '',
        ort: einstellungen['firma_ort'] ?? '',
        telefon: einstellungen['firma_telefon'] ?? '',
        email: einstellungen['firma_email'] ?? '',
        website: einstellungen['firma_website'] ?? '',
      );

      // Baustelle laden
      baustelle.value = Baustelle(
          strasse: einstellungen['baustelle_strasse'] ?? '',
          plz: einstellungen['baustelle_plz'] ?? '',
          ort: einstellungen['baustelle_ort'] ?? '',
          kundeId: kunde.value.id ?? 0);

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

      // Zuletzt ausgewählten Monteur laden (ohne Snackbar beim App-Start)
      final lastMonteurId = einstellungen['last_monteur_id'] as int?;
      if (lastMonteurId != null && lastMonteurId > 0) {
        try {
          final monteurData = await _dbHelper.queryMonteurById(lastMonteurId);
          if (monteurData != null) {
            monteur.value = Monteur(
              id: monteurData['id'] as int?,
              vorname: monteurData['vorname']?.toString() ?? '',
              nachname: monteurData['nachname']?.toString() ?? '',
              telefon: monteurData['telefon']?.toString() ?? '',
              email: monteurData['email']?.toString() ?? '',
            );
            // Controller direkt aktualisieren
            updateMonteurControllers();
            debugPrint('Zuletzt ausgewählter Monteur (ID: $lastMonteurId) wurde geladen');
          }
        } catch (e) {
          debugPrint('Fehler beim Laden des zuletzt ausgewählten Monteurs: $e');
        }
      }

      // Zuletzt ausgewählten Kunden laden (ohne Snackbar beim App-Start)
      final lastKundeId = einstellungen['last_kunde_id'] as int?;
      if (lastKundeId != null && lastKundeId > 0) {
        try {
          final kundeData = await _dbHelper.queryKundeById(lastKundeId);
          if (kundeData != null) {
            kunde.value = Kunde(
              id: kundeData['id'] as int?,
              name: kundeData['name']?.toString() ?? '',
              strasse: kundeData['strasse']?.toString() ?? '',
              plz: kundeData['plz']?.toString() ?? '',
              ort: kundeData['ort']?.toString() ?? '',
              telefon: kundeData['telefon']?.toString() ?? '',
              email: kundeData['email']?.toString() ?? '',
            );
            // Controller direkt aktualisieren
            updateKundeControllers();
            debugPrint('Zuletzt ausgewählter Kunde (ID: $lastKundeId) wurde geladen');
          }
        } catch (e) {
          debugPrint('Fehler beim Laden des zuletzt ausgewählten Kunden: $e');
        }
      }
    } else {
      // Erste Nutzung → Standard-Logo
      resetLogo();
    }

    // Controller mit aktuellen Werten füllen (NACH dem Laden der Daten)
    _initControllers();
    
    // Nach dem Initialisieren der Controller die geladenen Werte in die Controller schreiben
    updateMonteurControllers();
    updateKundeControllers();
  }

  @override
  void onClose() {
    // Alle TextEditingController explizit dispose
    firmaNameController.dispose();
    firmaStrasseController.dispose();
    firmaPlzController.dispose();
    firmaOrtController.dispose();
    firmaTelefonController.dispose();
    firmaWebsiteController.dispose();
    firmaEmailController.dispose();
    
    kundeNameController.dispose();
    kundeStrasseController.dispose();
    kundePlzController.dispose();
    kundeOrtController.dispose();
    kundeTeleController.dispose();
    kundeEmailController.dispose();
    
    monteurVornameController.dispose();
    monteurNachnameController.dispose();
    monteurTeleController.dispose();
    monteurEmailController.dispose();
    
    baustelleStrasseController.dispose();
    baustellePlzController.dispose();
    baustelleOrtController.dispose();
    
    super.onClose();
  }

  // ==================== DATEN AUS DATABASE LADEN ====================
  Future<void> _loadAllDataFromDatabase() async {
    firmenListe.value = await _dbHelper.queryAllFirmen();
    kundenListe.value = await _dbHelper.queryAllKunden();
    monteureListe.value = await _dbHelper.queryAllMonteure();
    baustellenListe.value = await _dbHelper.queryAllBaustellen();
  }

  // Public Methode zum Neuladen der Daten (für Suchdialoge)
  Future<void> reloadAllData() async {
    await _loadAllDataFromDatabase();
  }

  void _initControllers() {
    firmaNameController = TextEditingController(text: firma.value.name ?? '');
    firmaStrasseController = TextEditingController(text: firma.value.strasse ?? '');
    firmaPlzController = TextEditingController(text: firma.value.plz ?? '');
    firmaOrtController = TextEditingController(text: firma.value.ort ?? '');
    firmaTelefonController = TextEditingController(text: firma.value.telefon ?? '');
    firmaEmailController = TextEditingController(text: firma.value.email ?? '');
    firmaWebsiteController = TextEditingController(text: firma.value.website ?? '');

    kundeNameController = TextEditingController(text: kunde.value?.name ?? '');
    kundeStrasseController = TextEditingController(text: kunde.value?.strasse ?? '');
    kundePlzController = TextEditingController(text: kunde.value?.plz ?? '');
    kundeOrtController = TextEditingController(text: kunde.value?.ort ?? '');
    kundeTeleController = TextEditingController(text: kunde.value?.telefon ?? '');
    kundeEmailController = TextEditingController(text: kunde.value?.email ?? '');

    monteurVornameController =
        TextEditingController(text: monteur.value?.vorname ?? '');
    monteurNachnameController =
        TextEditingController(text: monteur.value?.nachname ?? '');
    monteurTeleController = TextEditingController(text: monteur.value?.telefon ?? '');
    monteurEmailController =
        TextEditingController(text: monteur.value.email ?? "");
    updateMonteurControllers();
    updateKundeControllers();
    baustelleStrasseController =
        TextEditingController(text: baustelle.value.strasse ?? '');
    baustellePlzController = TextEditingController(text: baustelle.value.plz ?? '');
    baustelleOrtController = TextEditingController(text: baustelle.value.ort ?? '');
  }

  // ==================== DATABASE FUNKTIONEN ====================

  // FIRMA
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
      await _loadAllDataFromDatabase();
      Get.snackbar("Erfolg", "Firma wurde gespeichert!");
    } catch (e) {
      Get.snackbar(
        "Fehler",
        "Firma konnte nicht gespeichert werden: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
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
      _initControllers();
      Get.snackbar("Erfolg", "Firma wurde geladen!");
    }
  }

  // KUNDE
  Future<void> addKundeToDatabase() async {
    try {
      await _dbHelper.insertKunde({
        'name': kunde.value?.name ?? '',
        'strasse': kunde.value?.strasse ?? '',
        'plz': kunde.value?.plz ?? '',
        'ort': kunde.value?.ort ?? '',
        'telefon': kunde.value?.telefon ?? '',
        'email': kunde.value?.email ?? '',
      });
      await _loadAllDataFromDatabase();
      Get.snackbar("Erfolg", "Kunde wurde gespeichert!");
    } catch (e) {
      Get.snackbar(
        "Fehler",
        "Kunde konnte nicht gespeichert werden: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // MONTEUR
  Future<void> addMonteurToDatabase() async {
    try {
      await _dbHelper.insertMonteur({
        'vorname': monteur.value?.vorname ?? '',
        'nachname': monteur.value?.nachname ?? '',
        'telefon': monteur.value?.telefon ?? '',
        'email': monteur.value?.email ?? '',
      });
      await _loadAllDataFromDatabase();
      Get.snackbar("Erfolg", "Monteur wurde gespeichert!");
    } catch (e) {
      Get.snackbar(
        "Fehler",
        "Monteur konnte nicht gespeichert werden: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> selectMonteurFromDatabase(int id, {bool showSnackbar = true}) async {
    final monteurData = await _dbHelper.queryMonteurById(id);
    if (monteurData != null) {
      monteur.value = Monteur(
        id: monteurData['id'] as int?,
        vorname: monteurData['vorname']?.toString() ?? '',
        nachname: monteurData['nachname']?.toString() ?? '',
        telefon: monteurData['telefon']?.toString() ?? '',
        email: monteurData['email']?.toString() ?? '',
      );

      // Das ist der entscheidende Aufruf!
      updateMonteurControllers();

      // ID in Einstellungen speichern
      await _saveEinstellungen();

      if (showSnackbar) {
        Get.snackbar("Erfolg", "Monteur wurde geladen!");
      }
    }
  }

  Future<void> selectKundeFromDatabase(int id, {bool showSnackbar = true}) async {
    final kundeData = await _dbHelper.queryKundeById(id);
    if (kundeData != null) {
      kunde.value = Kunde(
        id: kundeData['id'] as int?,
        name: kundeData['name']?.toString() ?? '',
        strasse: kundeData['strasse']?.toString() ?? '',
        plz: kundeData['plz']?.toString() ?? '',
        ort: kundeData['ort']?.toString() ?? '',
        telefon: kundeData['telefon']?.toString() ?? '',
        email: kundeData['email']?.toString() ?? '',
      );

      // Das ist der entscheidende Aufruf!
      updateKundeControllers();

      // ID in Einstellungen speichern
      await _saveEinstellungen();

      if (showSnackbar) {
        Get.snackbar("Erfolg", "Kunde wurde geladen!");
      }
    }
  }

  // BAUSTELLE
  Future<void> addBaustelleToDatabase() async {
    try {
      await _dbHelper.insertBaustelle({
        'strasse': baustelle.value.strasse ?? '',
        'plz': baustelle.value.plz ?? '',
        'ort': baustelle.value.ort ?? '',
      });
      await _loadAllDataFromDatabase();
      Get.snackbar("Erfolg", "Baustelle wurde gespeichert!");
    } catch (e) {
      Get.snackbar(
        "Fehler",
        "Baustelle konnte nicht gespeichert werden: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
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
      if (!_isUpdatingControllers) {
        monteur.value =
            monteur.value.copyWith(vorname: monteurVornameController.text);
      }
    });
    monteurNachnameController.addListener(() {
      if (!_isUpdatingControllers) {
        monteur.value =
            monteur.value.copyWith(nachname: monteurNachnameController.text);
      }
    });
    monteurTeleController.addListener(() {
      if (!_isUpdatingControllers) {
        monteur.value =
            monteur.value.copyWith(telefon: monteurTeleController.text);
      }
    });
    monteurEmailController.addListener(() {
      if (!_isUpdatingControllers) {
        monteur.value =
            monteur.value.copyWith(email: monteurEmailController.text);
      }
    });

    // Kunde - aktualisiert reactive Objekte
    kundeNameController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(name: kundeNameController.text);
      }
    });
    kundeStrasseController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(strasse: kundeStrasseController.text);
      }
    });
    kundePlzController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(plz: kundePlzController.text);
      }
    });
    kundeOrtController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(ort: kundeOrtController.text);
      }
    });
    kundeTeleController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(telefon: kundeTeleController.text);
      }
    });
    kundeEmailController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(email: kundeEmailController.text);
      }
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

        // Sofort in DB speichern
        await _saveEinstellungen();

        Get.snackbar("Erfolg", "Logo wurde gespeichert!");
      }
    } catch (e) {
      debugPrint("Fehler beim Speichern des Logos: $e");
      Get.snackbar("Fehler", "Logo konnte nicht gespeichert werden: $e");
    }
  }

  void resetLogo() async {
    logo.value = XFile('assets/system2000_logo.png');
    await _saveEinstellungen(); // Speichert leeren Pfad in DB
  }

  void addNewTextFields() {
    rechnungTextFielde.add(ReceiptData(
      pos: rechnungTextFielde.length + 1, // Position nummerieren
      menge: 1.0, // sinnvoller Default
      einh: 'Stk',
      bezeichnung: '',
      einzelPreis: 0.0,
      img: [], // Bilder-Liste initialisieren
    ));
  }

  // ==================== BILDER FUNKTIONEN ====================
  
  // Bilder zu einer Position hinzufügen
  Future<void> addImagesToPosition(int index, {ImageSource source = ImageSource.gallery}) async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final List<String> imagePaths = [];
        
        // Bilder in App-Dokumentenverzeichnis kopieren
        final directory = await getApplicationDocumentsDirectory();
        
        for (var pickedFile in pickedFiles) {
          final String newPath = "${directory.path}/receipt_image_${DateTime.now().millisecondsSinceEpoch}_${pickedFiles.indexOf(pickedFile)}.jpg";
          final File newFile = await File(pickedFile.path).copy(newPath);
          imagePaths.add(newFile.path);
        }
        
        // Bestehende Bilder behalten und neue hinzufügen
        final currentImages = rechnungTextFielde[index].img ?? [];
        final updatedImages = [...currentImages, ...imagePaths];
        
        rechnungTextFielde[index] = rechnungTextFielde[index].copyWith(img: updatedImages);
        rechnungTextFielde.refresh();
        
        Get.snackbar("Erfolg", "${pickedFiles.length} Bild(er) hinzugefügt!");
      }
    } catch (e) {
      debugPrint("Fehler beim Hinzufügen der Bilder: $e");
      Get.snackbar("Fehler", "Bilder konnten nicht hinzugefügt werden: $e");
    }
  }

  // Einzelnes Bild von Kamera hinzufügen
  Future<void> addImageFromCamera(int index) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 90,
      );
      
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String newPath = "${directory.path}/receipt_image_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final File newFile = await File(pickedFile.path).copy(newPath);
        
        final currentImages = rechnungTextFielde[index].img ?? [];
        final updatedImages = [...currentImages, newFile.path];
        
        rechnungTextFielde[index] = rechnungTextFielde[index].copyWith(img: updatedImages);
        rechnungTextFielde.refresh();
        
        Get.snackbar("Erfolg", "Bild hinzugefügt!");
      }
    } catch (e) {
      debugPrint("Fehler beim Hinzufügen des Bildes: $e");
      Get.snackbar("Fehler", "Bild konnte nicht hinzugefügt werden: $e");
    }
  }

  // Bild von einer Position entfernen
  void removeImageFromPosition(int positionIndex, int imageIndex) {
    try {
      final currentImages = rechnungTextFielde[positionIndex].img ?? [];
      if (imageIndex >= 0 && imageIndex < currentImages.length) {
        // Datei löschen
        final imagePath = currentImages[imageIndex];
        final file = File(imagePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
        
        // Aus Liste entfernen
        final updatedImages = List<String>.from(currentImages)..removeAt(imageIndex);
        rechnungTextFielde[positionIndex] = rechnungTextFielde[positionIndex].copyWith(img: updatedImages);
        rechnungTextFielde.refresh();
        
        Get.snackbar("Erfolg", "Bild entfernt!");
      }
    } catch (e) {
      debugPrint("Fehler beim Entfernen des Bildes: $e");
      Get.snackbar("Fehler", "Bild konnte nicht entfernt werden: $e");
    }
  }

  // Alle Bilder von einer Position entfernen
  void removeAllImagesFromPosition(int index) {
    try {
      final currentImages = rechnungTextFielde[index].img ?? [];
      
      // Alle Dateien löschen
      for (var imagePath in currentImages) {
        final file = File(imagePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
      
      rechnungTextFielde[index] = rechnungTextFielde[index].copyWith(img: []);
      rechnungTextFielde.refresh();
      
      Get.snackbar("Erfolg", "Alle Bilder entfernt!");
    } catch (e) {
      debugPrint("Fehler beim Entfernen der Bilder: $e");
      Get.snackbar("Fehler", "Bilder konnten nicht entfernt werden: $e");
    }
  }

  // Bilder einer Position abrufen
  List<String> getImagesForPosition(int index) {
    if (index >= 0 && index < rechnungTextFielde.length) {
      return rechnungTextFielde[index].img ?? [];
    }
    return [];
  }

  void removePositionAt(int index) {
    rechnungTextFielde.removeAt(index);
    // Positionen neu nummerieren
    for (int i = 0; i < rechnungTextFielde.length; i++) {
      rechnungTextFielde[i] = rechnungTextFielde[i].copyWith(pos: i + 1);
    }
    rechnungTextFielde.refresh(); // UI updaten
  }

  // Aktualisiert alle TextController für Monteur
  void updateMonteurControllers() {
    _isUpdatingControllers = true; // Listener deaktivieren
    
    // TextController aktualisieren
    monteurVornameController.text = monteur.value.vorname ?? '';
    monteurNachnameController.text = monteur.value.nachname ?? '';
    monteurTeleController.text = monteur.value.telefon ?? '';
    monteurEmailController.text = monteur.value.email ?? '';
    
    _isUpdatingControllers = false; // Listener wieder aktivieren
  }

  // Aktualisiert alle TextController für Kunde
  void updateKundeControllers() {
    _isUpdatingControllers = true; // Listener deaktivieren
    
    kundeNameController.text = kunde.value.name ?? '';
    kundeStrasseController.text = kunde.value.strasse ?? '';
    kundePlzController.text = kunde.value.plz ?? '';
    kundeOrtController.text = kunde.value.ort ?? '';
    kundeTeleController.text = kunde.value.telefon ?? '';
    kundeEmailController.text = kunde.value.email ?? '';
    
    _isUpdatingControllers = false; // Listener wieder aktivieren
  }
}
