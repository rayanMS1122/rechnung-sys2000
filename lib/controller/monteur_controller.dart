import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reciepts/database/database_helper.dart';
import 'package:reciepts/models/monteur.dart';
import 'package:reciepts/constants.dart';

class MonteurController extends GetxController {
  final _dbHelper = DatabaseHelper.instance;

  // Reactive Objekt
  final Rx<Monteur> monteur = Monteur(
    vorname: "",
    nachname: "",
    telefon: "",
  ).obs;

  // TextControllers
  late TextEditingController monteurVornameController;
  late TextEditingController monteurNachnameController;
  late TextEditingController monteurTeleController;
  late TextEditingController monteurEmailController;

  // Liste für Dropdown
  final RxList<Map<String, dynamic>> monteureListe = <Map<String, dynamic>>[].obs;

  // Flags
  final RxBool canSaveMonteur = true.obs;

  // Private
  bool _isUpdatingControllers = false;
  Timer? _monteurCheckTimer;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    _setupListeners();
  }

  void _initControllers() {
    monteurVornameController = TextEditingController(text: monteur.value?.vorname ?? '');
    monteurNachnameController = TextEditingController(text: monteur.value?.nachname ?? '');
    monteurTeleController = TextEditingController(text: monteur.value?.telefon ?? '');
    monteurEmailController = TextEditingController(text: monteur.value?.email ?? '');
  }

  void _setupListeners() {
    void _scheduleMonteurCheck() {
      _monteurCheckTimer?.cancel();
      _monteurCheckTimer = Timer(const Duration(milliseconds: 500), () {
        _checkCanSaveMonteur();
      });
    }

    monteurVornameController.addListener(() {
      if (!_isUpdatingControllers) {
        monteur.value = monteur.value.copyWith(vorname: monteurVornameController.text);
        _scheduleMonteurCheck();
      }
    });
    monteurNachnameController.addListener(() {
      if (!_isUpdatingControllers) {
        monteur.value = monteur.value.copyWith(nachname: monteurNachnameController.text);
        _scheduleMonteurCheck();
      }
    });
    monteurTeleController.addListener(() {
      if (!_isUpdatingControllers) {
        monteur.value = monteur.value.copyWith(telefon: monteurTeleController.text);
        _scheduleMonteurCheck();
      }
    });
    monteurEmailController.addListener(() {
      if (!_isUpdatingControllers) {
        monteur.value = monteur.value.copyWith(email: monteurEmailController.text);
        _scheduleMonteurCheck();
      }
    });
  }

  Future<void> loadMonteureFromDatabase() async {
    monteureListe.value = await _dbHelper.queryAllMonteure();
  }

  Future<void> _checkCanSaveMonteur() async {
    final vorname = monteurVornameController.text.trim();
    final nachname = monteurNachnameController.text.trim();
    final telefon = monteurTeleController.text.trim();

    if (vorname.isEmpty || nachname.isEmpty || telefon.isEmpty) {
      canSaveMonteur.value = false;
      return;
    }

    final monteurData = {
      'vorname': vorname,
      'nachname': nachname,
      'telefon': telefon,
      'email': monteurEmailController.text.trim(),
    };

    final exists = await _dbHelper.monteurExists(monteurData);
    canSaveMonteur.value = !exists;
  }

  Future<void> _loadExistingMonteur(Map<String, dynamic> monteurData) async {
    final allMonteure = await _dbHelper.queryAllMonteure();
    final vorname = (monteurData['vorname'] ?? '').toString().trim().toLowerCase();
    final nachname = (monteurData['nachname'] ?? '').toString().trim().toLowerCase();
    final telefon = (monteurData['telefon'] ?? '').toString().trim().toLowerCase();

    for (var dbMonteur in allMonteure) {
      final dbVorname = (dbMonteur['vorname']?.toString() ?? '').trim().toLowerCase();
      final dbNachname = (dbMonteur['nachname']?.toString() ?? '').trim().toLowerCase();
      final dbTelefon = (dbMonteur['telefon']?.toString() ?? '').trim().toLowerCase();

      bool matches = false;
      if (vorname.isNotEmpty && nachname.isNotEmpty) {
        if (telefon.isNotEmpty) {
          matches = dbVorname == vorname && dbNachname == nachname && dbTelefon == telefon;
        } else {
          matches = dbVorname == vorname && dbNachname == nachname;
        }
      }

      if (matches) {
        await selectMonteurFromDatabase(dbMonteur['id'] as int, showSnackbar: false);
        break;
      }
    }
  }

  Future<bool> addMonteurToDatabase() async {
    try {
      final monteurData = {
        'vorname': monteur.value?.vorname ?? '',
        'nachname': monteur.value?.nachname ?? '',
        'telefon': monteur.value?.telefon ?? '',
        'email': monteur.value?.email ?? '',
      };

      final exists = await _dbHelper.monteurExists(monteurData);
      if (exists) {
        await _loadExistingMonteur(monteurData);
        return false;
      }

      final newId = await _dbHelper.insertMonteur(monteurData);
      monteur.value = monteur.value.copyWith(id: newId);
      updateMonteurControllers();
      await loadMonteureFromDatabase();
      return true;
    } catch (e) {
      debugPrint('Fehler beim Speichern des Monteurs: $e');
      return false;
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

      updateMonteurControllers();

      if (showSnackbar) {
        _showSnackBar("Erfolg", "Monteur wurde geladen!");
      }
    }
  }

  void updateMonteurControllers() {
    _isUpdatingControllers = true;

    final newVorname = monteur.value?.vorname ?? '';
    final newNachname = monteur.value?.nachname ?? '';
    final newTelefon = monteur.value?.telefon ?? '';
    final newEmail = monteur.value?.email ?? '';

    if (monteurVornameController.text != newVorname) {
      monteurVornameController.text = newVorname;
    }
    if (monteurNachnameController.text != newNachname) {
      monteurNachnameController.text = newNachname;
    }
    if (monteurTeleController.text != newTelefon) {
      monteurTeleController.text = newTelefon;
    }
    if (monteurEmailController.text != newEmail) {
      monteurEmailController.text = newEmail;
    }

    _isUpdatingControllers = false;
    _checkCanSaveMonteur();
  }

  void loadFromEinstellungen(Map<String, dynamic> einstellungen, int? lastMonteurId) async {
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
          updateMonteurControllers();
          debugPrint('Zuletzt ausgewählter Monteur (ID: $lastMonteurId) wurde geladen');
        }
      } catch (e) {
        debugPrint('Fehler beim Laden des zuletzt ausgewählten Monteurs: $e');
      }
    }
    _checkCanSaveMonteur();
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
    _monteurCheckTimer?.cancel();
    monteurVornameController.dispose();
    monteurNachnameController.dispose();
    monteurTeleController.dispose();
    monteurEmailController.dispose();
    super.onClose();
  }
}

