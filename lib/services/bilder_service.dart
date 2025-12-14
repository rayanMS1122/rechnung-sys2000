import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reciepts/models/reciept_model.dart';
import 'package:reciepts/services/rechnung_service.dart';
import 'package:reciepts/constants.dart';

class BilderService extends GetxService {
  final ImagePicker _picker = ImagePicker();

  RxList<ReceiptData> get rechnungTextFielde {
    return Get.find<RechnungService>().rechnungTextFielde;
  }

  // Bilder zu einer Position hinzufügen
  Future<void> addImagesToPosition(int index,
      {ImageSource source = ImageSource.gallery}) async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final List<String> imagePaths = [];

        final directory = await getApplicationDocumentsDirectory();

        for (var pickedFile in pickedFiles) {
          final String newPath =
              "${directory.path}/receipt_image_${DateTime.now().millisecondsSinceEpoch}_${pickedFiles.indexOf(pickedFile)}.jpg";
          final File newFile = await File(pickedFile.path).copy(newPath);
          imagePaths.add(newFile.path);
        }

        final currentImages = rechnungTextFielde[index].img ?? [];
        final updatedImages = [...currentImages, ...imagePaths];

        rechnungTextFielde[index] =
            rechnungTextFielde[index].copyWith(img: updatedImages);
        rechnungTextFielde.refresh();

        _showSnackBar("Erfolg", "${pickedFiles.length} Bild(er) hinzugefügt!");
      }
    } catch (e) {
      debugPrint("Fehler beim Hinzufügen der Bilder: $e");
      _showSnackBar("Fehler", "Bilder konnten nicht hinzugefügt werden: $e",
          isError: true);
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
        final String newPath =
            "${directory.path}/receipt_image_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final File newFile = await File(pickedFile.path).copy(newPath);

        final currentImages = rechnungTextFielde[index].img ?? [];
        final updatedImages = [...currentImages, newFile.path];

        rechnungTextFielde[index] =
            rechnungTextFielde[index].copyWith(img: updatedImages);
        rechnungTextFielde.refresh();

        _showSnackBar("Erfolg", "Bild hinzugefügt!");
      }
    } catch (e) {
      debugPrint("Fehler beim Hinzufügen des Bildes: $e");
      _showSnackBar("Fehler", "Bild konnte nicht hinzugefügt werden: $e",
          isError: true);
    }
  }

  // Bild von einer Position entfernen
  void removeImageFromPosition(int positionIndex, int imageIndex) {
    try {
      final currentImages = rechnungTextFielde[positionIndex].img ?? [];
      if (imageIndex >= 0 && imageIndex < currentImages.length) {
        final imagePath = currentImages[imageIndex];
        final file = File(imagePath);
        if (file.existsSync()) {
          file.deleteSync();
        }

        final updatedImages = List<String>.from(currentImages)
          ..removeAt(imageIndex);
        rechnungTextFielde[positionIndex] =
            rechnungTextFielde[positionIndex].copyWith(img: updatedImages);
        rechnungTextFielde.refresh();

        _showSnackBar("Erfolg", "Bild entfernt!");
      }
    } catch (e) {
      debugPrint("Fehler beim Entfernen des Bildes: $e");
      _showSnackBar("Fehler", "Bild konnte nicht entfernt werden: $e",
          isError: true);
    }
  }

  // Alle Bilder von einer Position entfernen
  void removeAllImagesFromPosition(int index) {
    try {
      final currentImages = rechnungTextFielde[index].img ?? [];

      for (var imagePath in currentImages) {
        final file = File(imagePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }

      rechnungTextFielde[index] = rechnungTextFielde[index].copyWith(img: []);
      rechnungTextFielde.refresh();

      _showSnackBar("Erfolg", "Alle Bilder entfernt!");
    } catch (e) {
      debugPrint("Fehler beim Entfernen der Bilder: $e");
      _showSnackBar("Fehler", "Bilder konnten nicht entfernt werden: $e",
          isError: true);
    }
  }

  // Bilder einer Position abrufen
  List<String> getImagesForPosition(int index) {
    if (index >= 0 && index < rechnungTextFielde.length) {
      return rechnungTextFielde[index].img ?? [];
    }
    return [];
  }

  void _showSnackBar(String title, String message, {bool isError = false}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent.withOpacity(0.9)
          : AppColors.primary.withOpacity(0.9),
      colorText: Colors.white,
      borderRadius: 15,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }
}
