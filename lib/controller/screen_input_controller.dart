import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reciepts/controller/firma_controller.dart';
import 'package:reciepts/controller/kunde_controller.dart';
import 'package:reciepts/controller/monteur_controller.dart';
import 'package:reciepts/controller/baustelle_controller.dart';
import 'package:reciepts/screens/bank_qr_generator_screen.dart';
import 'package:reciepts/screens/settings_screen.dart';
import 'package:reciepts/services/einstellungen_service.dart';
import 'package:reciepts/services/bilder_service.dart';
import 'package:reciepts/services/rechnung_service.dart';
import 'package:reciepts/database/database_helper.dart';
import 'package:reciepts/models/firma_model.dart';
import 'package:reciepts/models/kunde.dart';
import 'package:reciepts/models/monteur.dart';
import 'package:reciepts/models/baustelle.dart';
import 'package:reciepts/models/reciept_model.dart';

class ScreenInputController extends GetxController {
  // ==================== DEPENDENCIES ====================
  final _dbHelper = DatabaseHelper.instance;

  // Get Controllers
  FirmaController get firmaController => Get.find<FirmaController>();
  KundeController get kundeController => Get.find<KundeController>();
  MonteurController get monteurController => Get.find<MonteurController>();
  BaustelleController get baustelleController =>
      Get.find<BaustelleController>();
  EinstellungenService get einstellungenService =>
      Get.find<EinstellungenService>();
  BilderService get bilderService => Get.find<BilderService>();
  RechnungService get rechnungService => Get.find<RechnungService>();

  // ==================== CONVENIENCE GETTERS ====================
  // Firma
  Rx<Firma> get firma => firmaController.firma;
  TextEditingController get firmaNameController =>
      firmaController.firmaNameController;
  TextEditingController get firmaStrasseController =>
      firmaController.firmaStrasseController;
  TextEditingController get firmaPlzController =>
      firmaController.firmaPlzController;
  TextEditingController get firmaOrtController =>
      firmaController.firmaOrtController;
  TextEditingController get firmaTelefonController =>
      firmaController.firmaTelefonController;
  TextEditingController get firmaWebsiteController =>
      firmaController.firmaWebsiteController;
  TextEditingController get firmaEmailController =>
      firmaController.firmaEmailController;
  RxList<Map<String, dynamic>> get firmenListe => firmaController.firmenListe;

  // Kunde
  Rx<Kunde> get kunde => kundeController.kunde;
  TextEditingController get kundeNameController =>
      kundeController.kundeNameController;
  TextEditingController get kundeStrasseController =>
      kundeController.kundeStrasseController;
  TextEditingController get kundePlzController =>
      kundeController.kundePlzController;
  TextEditingController get kundeOrtController =>
      kundeController.kundeOrtController;
  TextEditingController get kundeTeleController =>
      kundeController.kundeTeleController;
  TextEditingController get kundeEmailController =>
      kundeController.kundeEmailController;
  RxList<Map<String, dynamic>> get kundenListe => kundeController.kundenListe;
  RxBool get canSaveKunde => kundeController.canSaveKunde;

  // Monteur
  Rx<Monteur> get monteur => monteurController.monteur;
  TextEditingController get monteurVornameController =>
      monteurController.monteurVornameController;
  TextEditingController get monteurNachnameController =>
      monteurController.monteurNachnameController;
  TextEditingController get monteurTeleController =>
      monteurController.monteurTeleController;
  TextEditingController get monteurEmailController =>
      monteurController.monteurEmailController;
  RxList<Map<String, dynamic>> get monteureListe =>
      monteurController.monteureListe;
  RxBool get canSaveMonteur => monteurController.canSaveMonteur;

  // Baustelle
  Rx<Baustelle> get baustelle => baustelleController.baustelle;
  TextEditingController get baustelleStrasseController =>
      baustelleController.baustelleStrasseController;
  TextEditingController get baustellePlzController =>
      baustelleController.baustellePlzController;
  TextEditingController get baustelleOrtController =>
      baustelleController.baustelleOrtController;
  RxList<Map<String, dynamic>> get baustellenListe =>
      baustelleController.baustellenListe;

  // Einstellungen
  Rx<XFile> get logo => einstellungenService.logo;
  RxBool get enableEditing => einstellungenService.enableEditing;
  RxString qrData = "".obs;
  // Rechnung
  RxList<ReceiptData> get rechnungTextFielde =>
      rechnungService.rechnungTextFielde;
  RxString dokumentTitel = "RECHNUNG".obs;

  Future<void> _loadDokumentTitel() async {
    final settings = await DatabaseHelper.instance.getEinstellungen();
    if (settings != null && settings['dokument_titel'] != null) {
      dokumentTitel.value = settings['dokument_titel'].toString().trim();
    }
    // Falls leer → Standard setzen
    if (dokumentTitel.value.isEmpty) {
      dokumentTitel.value = "RECHNUNG";
    }
  }

  Future<void> saveDokumentTitel(String newTitle) async {
    String cleaned = newTitle.trim().toUpperCase();
    if (cleaned.isEmpty) cleaned = "RECHNUNG";

    dokumentTitel.value = cleaned;

    // In DB speichern
    await DatabaseHelper.instance.saveEinstellungen({
      'dokument_titel': cleaned,
    });
  }

// Für das TextField – wird automatisch mit dem RxString synchronisiert
  late TextEditingController dokumentTitelEditController;

  void initDokumentTitelController() {
    dokumentTitelEditController =
        TextEditingController(text: dokumentTitel.value);

    // Synchronisation: Wenn im TextField geändert wird → RxString aktualisieren
    dokumentTitelEditController.addListener(() {
      String value = dokumentTitelEditController.text.trim().toUpperCase();
      if (value.isEmpty) value = "RECHNUNG";
      dokumentTitel.value = value;
    });

    // Optional: Wenn RxString von außen geändert wird → TextField aktualisieren
    ever(dokumentTitel, (_) {
      final text = dokumentTitel.value;
      if (dokumentTitelEditController.text != text) {
        dokumentTitelEditController.text = text;
      }
    });
  }

  final TextEditingController nameBankQrController = TextEditingController();
  final TextEditingController ibanBankQrController =
      TextEditingController(text: "DE89 3704 0044 0532 0130 00");
  final TextEditingController bicBankQrController = TextEditingController();
  final TextEditingController purposeBankQrController = TextEditingController();
  Future<void> loadBankDataIntoControllers() async {
    final bankData = await _dbHelper.getBankData();
    if (bankData != null) {
      nameBankQrController.text = bankData['name'] ?? '';
      ibanBankQrController.text =
          bankData['iban'] ?? 'DE89 3704 0044 0532 0130 00'; // Fallback
      bicBankQrController.text = bankData['bic'] ?? '';
      purposeBankQrController.text = bankData['purpose'] ?? '';

      if (bankData['qrData']?.isNotEmpty == true) {
        qrData.value = bankData['qrData'];
      }
    }
  }

  @override
  void onInit() async {
    super.onInit();
    initDokumentTitelController();
    _loadDokumentTitel(); // Lädt aus DB beim Start
    baustelleController.initialize(kundeController.kunde);

    await _loadAllDataFromDatabase();
    await _loadEinstellungenFromDB();

    // === HIER: Bankdaten in die Felder laden ===
    await loadBankDataIntoControllers();

    ever(rechnungTextFielde, (_) => _autoUpdateQrCodeIfPossible());
    _setupAutoSaveListeners();
  }

  // Bank daten laden und bearbeiten
  Future<void> saveBankDataToDB({
    required String name,
    required String iban,
    required String bic,
    required String amount,
    required String purpose,
    required String qrData,
  }) async {
    await _dbHelper.saveBankData(
      name: name,
      iban: iban,
      bic: bic,
      amount: amount,
      purpose: purpose,
      qrData: qrData,
    );
    this.qrData.value = qrData; // Reaktivität
  }

  Future<void> loadBankDataFromDB() async {
    final data = await _dbHelper.getBankData();
    if (data != null) {
      qrData.value = data['qrData'] ?? '';
    }
  }

// === VERBESSERTE generateQR FUNKTION ===
  Future<void> generateQR() async {
    final name = nameBankQrController.text.trim();
    final iban = ibanBankQrController.text.trim().replaceAll(' ', '');
    final bic = bicBankQrController.text.trim();
    final purpose = purposeBankQrController.text.trim();

    // Fall 1: Bankdaten fehlen → User in Einstellungen schicken
    if (name.isEmpty || iban.isEmpty) {
      Get.snackbar(
        'Bankdaten fehlen',
        'Bitte gib zuerst deinen Namen und IBAN in den Einstellungen ein. Unter Bank daten ein geben.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () {
            Get.back(); // Snackbar schließen

            // === HIER ANPASSEN JE NACH DEINER NAVIGATION ===
            // Variante A: Wenn du BottomNavigationBar oder TabBar hast
            // Get.offAllNamed('/home'); // oder welchen Screen auch immer
            // dann z.B.:
            // Get.find<BottomNavController>().changeTabIndex(3); // z.B. Index 3 = Einstellungen

            // Variante B: Direkter Push zum Einstellungen-Screen
            Get.to(BankQrGeneratorScreen());

            // Variante C: Wenn du GetMaterialApp mit indexedStack oder ähnlichem nutzt
            // Get.offNamed('/einstellungen');
          },
          child: const Text('Zu Einstellungen',
              style: TextStyle(color: Colors.white)),
        ),
      );
      return;
    }

    // Fall 2: IBAN hat falsches Format
    if (!RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$').hasMatch(iban)) {
      Get.snackbar(
        'Ungültige IBAN',
        'Bitte überprüfe das Format deiner IBAN (z. B. DE89 3704 0044 0532 0130 00)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    // Fall 4: Alles OK → QR-Code generieren
    await generateQrCodeWithCurrentTotal(
      name: name,
      iban: iban,
      bic: bic,
      purpose: purpose,
    );
  }

  Future<void> generateQrCodeWithCurrentTotal({
    required String name,
    required String iban,
    required String bic,
    String purpose = '',
  }) async {
    final double amount = currentReceiptTotal;

    final String amountStr = amount.toStringAsFixed(2); // 600.00

    final String qrString = 'BCD\n'
        '002\n'
        '1\n'
        'SCT\n'
        '${bic.isNotEmpty ? '$bic\n' : ''}' // ← Kein \n bei leerer BIC!
        '$name\n'
        '$iban\n'
        'EUR$amountStr\n'
        '\n' // Leere Zeile für structured reference (optional)
        '$purpose\n';
    // In DB speichern
    await saveBankDataToDB(
      name: name,
      iban: iban,
      bic: bic,
      amount:
          amountStr.replaceAll('.', ','), // z.B. "600,00" für deutsche Anzeige
      purpose: purpose,
      qrData: qrString,
    );

    qrData.value = qrString;
  }

  // Gesamtbetrag der aktuellen Rechnung berechnen
  double get currentReceiptTotal {
    return rechnungTextFielde.fold(0.0, (sum, item) => sum + item.gesamtPreis);
  }

  // Formatierten String für Anzeige/Speicherung (z.B. "600.00")
  String get currentReceiptTotalString {
    return currentReceiptTotal
        .toStringAsFixed(2)
        .replaceAll('.', ','); // deutsches Format: 600,00
  }

  void _autoUpdateQrCodeIfPossible() async {
    final bankData = await DatabaseHelper.instance.getBankData();
    if (bankData != null &&
        (bankData['name'] as String?)?.isNotEmpty == true &&
        (bankData['iban'] as String?)?.isNotEmpty == true &&
        currentReceiptTotal > 0) {
      await generateQrCodeWithCurrentTotal(
        name: bankData['name'] ?? '',
        iban: bankData['iban'] ?? '',
        bic: bankData['bic'] ?? '',
        purpose: bankData['purpose'] ?? '',
      );
    }
  }

  void _setupAutoSaveListeners() {
    // Firma automatisch speichern
    firmaNameController.addListener(saveEinstellungen);
    firmaStrasseController.addListener(saveEinstellungen);
    firmaPlzController.addListener(saveEinstellungen);
    firmaOrtController.addListener(saveEinstellungen);
    firmaTelefonController.addListener(saveEinstellungen);
    firmaEmailController.addListener(saveEinstellungen);
    firmaWebsiteController.addListener(saveEinstellungen);

    // Baustelle
    baustelleStrasseController.addListener(saveEinstellungen);
    baustellePlzController.addListener(saveEinstellungen);
    baustelleOrtController.addListener(saveEinstellungen);
// === Bankdaten automatisch speichern ===
    nameBankQrController.addListener(_saveBankDataIfPossible);
    ibanBankQrController.addListener(_saveBankDataIfPossible);
    bicBankQrController.addListener(_saveBankDataIfPossible);
    purposeBankQrController.addListener(_saveBankDataIfPossible);
    // Switch für Bearbeitung
    ever(enableEditing, (bool value) async {
      await saveEinstellungen();
    });
  }

  void _saveBankDataIfPossible() async {
    // Debounce: nicht bei jeder Taste sofort speichern
    debounce(
      'saveBankData'.obs,
      (_) async {
        final name = nameBankQrController.text.trim();
        final iban = ibanBankQrController.text.trim();
        if (name.isNotEmpty && iban.isNotEmpty) {
          await generateQrCodeWithCurrentTotal(
            name: name,
            iban: iban,
            bic: bicBankQrController.text.trim(),
            purpose: purposeBankQrController.text.trim(),
          );
        }
      },
      time: const Duration(milliseconds: 800),
    );
  }

  Future<void> saveEinstellungen() async {
    await einstellungenService.saveEinstellungen(
      firmaData: firmaController.getEinstellungenData(),
      baustelleData: baustelleController.getEinstellungenData(),
      lastMonteurId: monteur.value.id,
      lastKundeId: kunde.value.id,
    );

    firma.refresh();
    baustelle.refresh();
  }

  Future<void> _loadEinstellungenFromDB() async {
    final einstellungen = await _dbHelper.getEinstellungen();

    if (einstellungen != null) {
      // Load from services
      await einstellungenService.loadEinstellungen();

      // Load Firma
      firmaController.loadFromEinstellungen(einstellungen);

      // Load Baustelle
      baustelleController.loadFromEinstellungen(
          einstellungen, kundeController.kunde);

      // Load last selected Monteur and Kunde
      final lastMonteurId = einstellungen['last_monteur_id'] as int?;
      final lastKundeId = einstellungen['last_kunde_id'] as int?;

      monteurController.loadFromEinstellungen(einstellungen, lastMonteurId);
      kundeController.loadFromEinstellungen(einstellungen, lastKundeId);
    } else {
      einstellungenService.resetLogo();
    }
  }

  // ==================== DATEN AUS DATABASE LADEN ====================
  Future<void> _loadAllDataFromDatabase() async {
    await firmaController.loadFirmenFromDatabase();
    await kundeController.loadKundenFromDatabase();
    await monteurController.loadMonteureFromDatabase();
    await baustelleController.loadBaustellenFromDatabase();
  }

  // Public Methode zum Neuladen der Daten (für Suchdialoge)
  Future<void> reloadAllData() async {
    await _loadAllDataFromDatabase();
  }

  // ==================== DELEGATE METHODS ====================

  // FIRMA
  Future<void> addFirmaToDatabase() => firmaController.addFirmaToDatabase();
  Future<void> selectFirmaFromDatabase(int id) =>
      firmaController.selectFirmaFromDatabase(id);

  // KUNDE
  Future<bool> addKundeToDatabase() => kundeController.addKundeToDatabase();
  Future<void> selectKundeFromDatabase(int id, {bool showSnackbar = true}) =>
      kundeController.selectKundeFromDatabase(id, showSnackbar: showSnackbar);
  void updateKundeControllers() => kundeController.updateKundeControllers();

  // MONTEUR
  Future<bool> addMonteurToDatabase() =>
      monteurController.addMonteurToDatabase();
  Future<void> selectMonteurFromDatabase(int id, {bool showSnackbar = true}) =>
      monteurController.selectMonteurFromDatabase(id,
          showSnackbar: showSnackbar);
  void updateMonteurControllers() =>
      monteurController.updateMonteurControllers();

  // BAUSTELLE
  Future<void> addBaustelleToDatabase() =>
      baustelleController.addBaustelleToDatabase();
  Future<void> selectBaustelleFromDatabase(int id) => baustelleController
      .selectBaustelleFromDatabase(id, kundeController.kunde);

  // EINSTELLUNGEN
  Future<void> changeLogo(BuildContext context) async {
    await einstellungenService.changeLogo();
    await saveEinstellungen();
  }

  void resetLogo() => einstellungenService.resetLogo();

  // REchnung
  void addNewTextFields() => rechnungService.addNewTextFields();
  void removePositionAt(int index) => rechnungService.removePositionAt(index);

  // BILDER
  Future<void> addImagesToPosition(int index,
          {ImageSource source = ImageSource.gallery}) =>
      bilderService.addImagesToPosition(index, source: source);
  Future<void> addImageFromCamera(int index) =>
      bilderService.addImageFromCamera(index);
  void removeImageFromPosition(int positionIndex, int imageIndex) =>
      bilderService.removeImageFromPosition(positionIndex, imageIndex);
  void removeAllImagesFromPosition(int index) =>
      bilderService.removeAllImagesFromPosition(index);
  List<String> getImagesForPosition(int index) =>
      bilderService.getImagesForPosition(index);
}
