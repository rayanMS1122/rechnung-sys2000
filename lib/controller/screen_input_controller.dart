import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reciepts/model/firma_model.dart';
import 'package:reciepts/model/reciept_model.dart';

class ScreenInputController extends GetxController {
  // Default-Strings (Model / Storage)
  late CompanyData data = CompanyData(
      firma: Firma(
          name: "sys2000",
          strasse: "Am Kühlturm 3a",
          plz: "44536",
          ort: "Lünen",
          telefon: "0231 9851550", // formatiert
          email: "info@system-2000.de",
          website: "https://system2000.de/"),
      baustelle: Baustelle(
        strasse: "Berliner Str. 17",
        plz: "10176",
        ort: "Berlin",
      ),
      monteur: Monteur(
          vorname: "Ahmad", nachname: "Mohammed", telefon: "02xxxxxxxxx"));
  // Firma
  late final TextEditingController firmaNameController =
      TextEditingController(text: data.firma.name);
  late final TextEditingController firmaStrasseController =
      TextEditingController(text: data.firma.strasse);
  late final TextEditingController firmaPlzController =
      TextEditingController(text: data.firma.plz);
  late final TextEditingController firmaOrtController =
      TextEditingController(text: data.firma.ort);
  late final TextEditingController firmaTelefonController =
      TextEditingController(text: data.firma.telefon);
  late final TextEditingController firmaWebsiteController =
      TextEditingController(text: data.firma.website);
  TextEditingController get firmaEmailController =>
      TextEditingController(text: data.firma.email);
  // Kunde
  late final TextEditingController kundeNameController =
      TextEditingController(text: data.kunde!.name);
  late final TextEditingController kundeStrasseController =
      TextEditingController(text: data.kunde!.strasse);
  late final TextEditingController kundPlzController =
      TextEditingController(text: data.kunde!.plz);
  late final TextEditingController kundOrtController =
      TextEditingController(text: data.kunde!.ort);
  late final TextEditingController kundeTeleController =
      TextEditingController(text: data.kunde!.telefon);
  late final TextEditingController kundeEmailController =
      TextEditingController(text: data.kunde!.email);
  // Monteur
  late final TextEditingController monteurVornameController =
      TextEditingController();
  late final TextEditingController monteurNachnameController =
      TextEditingController();
  late final TextEditingController monteurTeleController =
      TextEditingController();
  late final TextEditingController monteurEmailController =
      TextEditingController();
  // Baustelle
  late final TextEditingController baustelleStrasseController =
      TextEditingController(text: data.baustelle.strasse);
  late final TextEditingController baustellePlzController =
      TextEditingController(text: data.baustelle.plz);
  late final TextEditingController baustelleOrtController =
      TextEditingController(text: data.baustelle.ort);

  final Rx<XFile> logo = XFile('assets/system2000_logo.png').obs;

  // 2. Liste der Rechnungspositionen – bleibt gleich, aber auch richtig reaktiv
  final rechnungTextFielde = <ReceiptData>[
    ReceiptData(
        pos: 0,
        menge: 0,
        einh: '',
        bezeichnung: '',
        einzelPreis: 0.0,
        img: ["assets/loho.png"]),
  ].obs;

  final ImagePicker _picker = ImagePicker();

  // Neue Zeile hinzufügen
  void addNewTextFields() {
    rechnungTextFielde.add(ReceiptData(
      pos: rechnungTextFielde.length,
      menge: 0,
      einh: '',
      bezeichnung: '',
      einzelPreis: 0.0,
    ));
  }

  // Logo ändern – jetzt richtig reaktiv!
  Future<void> changeLogo(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        logo.value = pickedFile; // Das ist der entscheidende Unterschied!
      }
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar('Fehler', 'Bild konnte nicht geladen werden');
    }
  }

  // Optional: Zurück zum Standard-Logo
  void resetLogo() {
    logo.value = XFile('assets/system2000_logo.png');
  }

  @override
  void onInit() {
    // Falls du später das zuletzt gewählte Logo aus shared_preferences laden willst:
    // loadSavedLogo();
    super.onInit();
  }
}
