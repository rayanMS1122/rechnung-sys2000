import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reciepts/database/database_helper.dart';
import 'package:reciepts/models/kunde.dart';
import 'package:reciepts/constants.dart';

class KundeController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;

  // Reactive Objekt
  Rx<Kunde> kunde = Kunde(
    name: "",
    strasse: "",
    plz: "",
    ort: "",
    telefon: "",
    email: "",
  ).obs;

  // TextControllers
  late TextEditingController kundeNameController;
  late TextEditingController kundeStrasseController;
  late TextEditingController kundePlzController;
  late TextEditingController kundeOrtController;
  late TextEditingController kundeTeleController;
  late TextEditingController kundeEmailController;

  // Liste für Dropdown
  final RxList<Map<String, dynamic>> kundenListe = <Map<String, dynamic>>[].obs;

  // Flags
  final RxBool canSaveKunde = true.obs;

  // Private
  bool _isUpdatingControllers = false;
  Timer? _kundeCheckTimer;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _setupListeners();
  }

  void _initControllers() {
    kundeNameController = TextEditingController(text: kunde.value?.name ?? '');
    kundeStrasseController = TextEditingController(text: kunde.value?.strasse ?? '');
    kundePlzController = TextEditingController(text: kunde.value?.plz ?? '');
    kundeOrtController = TextEditingController(text: kunde.value?.ort ?? '');
    kundeTeleController = TextEditingController(text: kunde.value?.telefon ?? '');
    kundeEmailController = TextEditingController(text: kunde.value?.email ?? '');
  }

  void _setupListeners() {
    void _scheduleKundeCheck() {
      _kundeCheckTimer?.cancel();
      _kundeCheckTimer = Timer(const Duration(milliseconds: 500), () {
        _checkCanSaveKunde();
      });
    }

    kundeNameController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(name: kundeNameController.text);
        _scheduleKundeCheck();
      }
    });
    kundeStrasseController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(strasse: kundeStrasseController.text);
        _scheduleKundeCheck();
      }
    });
    kundePlzController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(plz: kundePlzController.text);
        _scheduleKundeCheck();
      }
    });
    kundeOrtController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(ort: kundeOrtController.text);
        _scheduleKundeCheck();
      }
    });
    kundeTeleController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(telefon: kundeTeleController.text);
        _scheduleKundeCheck();
      }
    });
    kundeEmailController.addListener(() {
      if (!_isUpdatingControllers) {
        kunde.value = kunde.value.copyWith(email: kundeEmailController.text);
        _scheduleKundeCheck();
      }
    });
  }

  Future<void> loadKundenFromDatabase() async {
    kundenListe.value = await _dbHelper.queryAllKunden();
  }

  Future<void> _checkCanSaveKunde() async {
    final name = kundeNameController.text.trim();
    final strasse = kundeStrasseController.text.trim();
    final plz = kundePlzController.text.trim();
    final ort = kundeOrtController.text.trim();

    if (name.isEmpty || strasse.isEmpty || plz.isEmpty || ort.isEmpty) {
      canSaveKunde.value = false;
      return;
    }

    final kundeData = {
      'name': name,
      'strasse': strasse,
      'plz': plz,
      'ort': ort,
      'telefon': kundeTeleController.text.trim(),
      'email': kundeEmailController.text.trim(),
    };

    final exists = await _dbHelper.kundeExists(kundeData);
    canSaveKunde.value = !exists;
  }

  Future<void> _loadExistingKunde(Map<String, dynamic> kundeData) async {
    final allKunden = await _dbHelper.queryAllKunden();
    final name = (kundeData['name'] ?? '').toString().trim().toLowerCase();
    final plz = (kundeData['plz'] ?? '').toString().trim().toLowerCase();
    final ort = (kundeData['ort'] ?? '').toString().trim().toLowerCase();
    final telefon = (kundeData['telefon'] ?? '').toString().trim().toLowerCase();
    final email = (kundeData['email'] ?? '').toString().trim().toLowerCase();

    for (var dbKunde in allKunden) {
      final dbName = (dbKunde['name']?.toString() ?? '').trim().toLowerCase();
      final dbPlz = (dbKunde['plz']?.toString() ?? '').trim().toLowerCase();
      final dbOrt = (dbKunde['ort']?.toString() ?? '').trim().toLowerCase();
      final dbTelefon = (dbKunde['telefon']?.toString() ?? '').trim().toLowerCase();
      final dbEmail = (dbKunde['email']?.toString() ?? '').trim().toLowerCase();

      bool matches = false;
      if (name.isNotEmpty && plz.isNotEmpty && ort.isNotEmpty) {
        matches = dbName == name && dbPlz == plz && dbOrt == ort;
      } else if (name.isNotEmpty && telefon.isNotEmpty) {
        matches = dbName == name && dbTelefon == telefon;
      } else if (name.isNotEmpty && email.isNotEmpty) {
        matches = dbName == name && dbEmail == email;
      }

      if (matches) {
        await selectKundeFromDatabase(dbKunde['id'] as int, showSnackbar: false);
        break;
      }
    }
  }

  Future<bool> addKundeToDatabase() async {
    try {
      final kundeData = {
        'name': kunde.value?.name ?? '',
        'strasse': kunde.value?.strasse ?? '',
        'plz': kunde.value?.plz ?? '',
        'ort': kunde.value?.ort ?? '',
        'telefon': kunde.value?.telefon ?? '',
        'email': kunde.value?.email ?? '',
      };

      final exists = await _dbHelper.kundeExists(kundeData);
      if (exists) {
        await _loadExistingKunde(kundeData);
        return false;
      }

      final newId = await _dbHelper.insertKunde(kundeData);
      kunde.value = kunde.value.copyWith(id: newId);
      updateKundeControllers();
      await loadKundenFromDatabase();
      return true;
    } catch (e) {
      debugPrint('Fehler beim Speichern des Kunden: $e');
      return false;
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

      updateKundeControllers();

      if (showSnackbar) {
        _showSnackBar("Erfolg", "Kunde wurde geladen!");
      }
    }
  }

  void updateKundeControllers() {
    _isUpdatingControllers = true;

    final newName = kunde.value?.name ?? '';
    final newStrasse = kunde.value?.strasse ?? '';
    final newPlz = kunde.value?.plz ?? '';
    final newOrt = kunde.value?.ort ?? '';
    final newTelefon = kunde.value?.telefon ?? '';
    final newEmail = kunde.value?.email ?? '';

    if (kundeNameController.text != newName) {
      kundeNameController.text = newName;
    }
    if (kundeStrasseController.text != newStrasse) {
      kundeStrasseController.text = newStrasse;
    }
    if (kundePlzController.text != newPlz) {
      kundePlzController.text = newPlz;
    }
    if (kundeOrtController.text != newOrt) {
      kundeOrtController.text = newOrt;
    }
    if (kundeTeleController.text != newTelefon) {
      kundeTeleController.text = newTelefon;
    }
    if (kundeEmailController.text != newEmail) {
      kundeEmailController.text = newEmail;
    }

    _isUpdatingControllers = false;
    _checkCanSaveKunde();
  }

  void loadFromEinstellungen(Map<String, dynamic> einstellungen, int? lastKundeId) async {
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
          updateKundeControllers();
          debugPrint('Zuletzt ausgewählter Kunde (ID: $lastKundeId) wurde geladen');
        }
      } catch (e) {
        debugPrint('Fehler beim Laden des zuletzt ausgewählten Kunden: $e');
      }
    }
    _checkCanSaveKunde();
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
    _kundeCheckTimer?.cancel();
    kundeNameController.dispose();
    kundeStrasseController.dispose();
    kundePlzController.dispose();
    kundeOrtController.dispose();
    kundeTeleController.dispose();
    kundeEmailController.dispose();
    super.onClose();
  }
}

