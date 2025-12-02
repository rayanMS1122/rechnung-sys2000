import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/screen_reciept.dart';
import 'model/reciept_model.dart';

class ScreenInput extends StatefulWidget {
  const ScreenInput({super.key});

  @override
  _ScreenInputState createState() => _ScreenInputState();
}

class _ScreenInputState extends State<ScreenInput> {
  final _formKey = GlobalKey<FormState>();
  final ScreenInputController controller = Get.put(ScreenInputController());

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ReceiptScreen(receiptData: controller.rechnungTextFielde),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Receipt Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.sizeOf(context).width * 1,
                  height: MediaQuery.sizeOf(context).height * 0.6,
                  child: Obx(
                    () => ListView.builder(
                      itemCount: controller.rechnungTextFielde.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                enableInteractiveSelection: true,
                                enabled: false,
                                decoration: InputDecoration(
                                    labelText: (index + 1).toString(),
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {},
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Menge',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  controller.rechnungTextFielde[index].menge =
                                      int.tryParse(value) ?? 0;
                                },
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Einh',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  controller.rechnungTextFielde[index].einh =
                                      value ?? "";
                                },
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'Bezeichnung',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  controller.rechnungTextFielde[index]
                                      .bezeichnung = value ?? "";
                                },
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    labelText: 'einzelPreis',
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  controller.rechnungTextFielde[index]
                                          .einzelPreis =
                                      double.tryParse(value) ?? 0;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  controller.rechnungTextFielde.removeAt(index);
                                });
                              },
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.addNewTextFields,
                  child: const Text('Neue Zeile'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Generate Receipt'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
