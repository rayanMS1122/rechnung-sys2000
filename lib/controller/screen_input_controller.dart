import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reciepts/controller/firma_controller.dart';
import 'package:reciepts/controller/kunde_controller.dart';
import 'package:reciepts/controller/monteur_controller.dart';
import 'package:reciepts/controller/baustelle_controller.dart';
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

  @override
  void onInit() async {
    super.onInit();

    // Initialize Baustelle with Kunde reference
    baustelleController.initialize(kundeController.kunde);

    await _loadAllDataFromDatabase();
    await _loadEinstellungenFromDB();
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

  Future<void> generateQrCodeWithCurrentTotal({
    required String name,
    required String iban,
    required String bic,
    String purpose = '',
  }) async {
    final double amount = currentReceiptTotal;
    if (amount <= 0) {
      Get.snackbar(
          "Hinweis", "Rechnungsbetrag ist 0 – QR-Code nicht generiert");
      qrData.value = '';
      return;
    }

    final String amountStr = amount.toStringAsFixed(2); // 600.00

    final String qrString = 'BCD\n'
        '002\n'
        '1\n'
        'SCT\n'
        '${bic.isNotEmpty ? '$bic\n' : '\n'}'
        '$name\n'
        '$iban\n'
        'EUR$amountStr\n'
        '\n'
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

    // Switch für Bearbeitung
    ever(enableEditing, (bool value) async {
      await saveEinstellungen();
    });
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
