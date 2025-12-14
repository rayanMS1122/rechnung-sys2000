import 'package:get/get.dart';
import 'package:reciepts/models/reciept_model.dart';

class RechnungService extends GetxService {
  final RxList<ReceiptData> rechnungTextFielde = <ReceiptData>[].obs;

  void addNewTextFields() {
    rechnungTextFielde.add(ReceiptData(
      pos: rechnungTextFielde.length + 1,
      menge: 1.0,
      einh: 'Stk',
      bezeichnung: '',
      einzelPreis: 0.0,
      img: [],
    ));
  }

  void removePositionAt(int index) {
    rechnungTextFielde.removeAt(index);
    // Positionen neu nummerieren
    for (int i = 0; i < rechnungTextFielde.length; i++) {
      rechnungTextFielde[i] = rechnungTextFielde[i].copyWith(pos: i + 1);
    }
    rechnungTextFielde.refresh();
  }

  void clearAll() {
    rechnungTextFielde.clear();
  }
}

