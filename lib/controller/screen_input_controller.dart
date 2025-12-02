import 'package:get/get.dart';
import 'package:reciepts/model/reciept_model.dart';

class ScreenInputController extends GetxController {
  late final RxList<ReceiptData> rechnungTextFielde = [
    ReceiptData(
      pos: 0,
      menge: 0,
      einh: '',
      bezeichnung: '',
      einzelPreis: 0.0,
    ),
  ].obs;
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
