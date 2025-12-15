import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/database/database_helper.dart';

class BankQrGeneratorScreen extends StatefulWidget {
  const BankQrGeneratorScreen({super.key});

  @override
  State<BankQrGeneratorScreen> createState() => _BankQrGeneratorScreenState();
}

class _BankQrGeneratorScreenState extends State<BankQrGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ibanController =
      TextEditingController(text: "DE89 3704 0044 0532 0130 00");
  final TextEditingController _bicController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  final ScreenInputController _controller = Get.find();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedBankData();
  }

  Future<void> _loadSavedBankData() async {
    final data = await DatabaseHelper.instance.getBankData();
    if (data != null && mounted) {
      setState(() {
        _nameController.text = data['name'] ?? '';
        _ibanController.text = data['iban'] ?? '';
        _bicController.text = data['bic'] ?? '';
        _purposeController.text = data['purpose'] ?? '';

        // QR-Code laden, falls vorhanden
        final savedQr = data['qrData'] ?? '';
        if (savedQr.isNotEmpty) {
          _controller.qrData.value = savedQr;
        }
      });
    }
  }

  Future<void> generateQR() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _errorMessage = 'Bitte alle Pflichtfelder ausfüllen');
      return;
    }

    final name = _nameController.text.trim();
    final iban = _ibanController.text.trim().replaceAll(' ', '');
    final bic = _bicController.text.trim();
    final purpose = _purposeController.text.trim();

    // IBAN-Validierung
    if (!RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]{1,30}$').hasMatch(iban)) {
      setState(() => _errorMessage = 'Ungültige IBAN');
      return;
    }

    // Automatisch mit aktuellem Rechnungsbetrag generieren
    await _controller.generateQrCodeWithCurrentTotal(
      name: name,
      iban: iban,
      bic: bic,
      purpose: purpose,
    );

    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SEPA QR-Code für Rechnung')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Name des Begünstigten (Pflicht)'),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ibanController,
                decoration: const InputDecoration(labelText: 'IBAN (Pflicht)'),
                validator: (v) =>
                    v?.trim().isEmpty ?? true ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bicController,
                decoration: const InputDecoration(labelText: 'BIC (optional)'),
              ),
              const SizedBox(height: 16),

              // Betrag: Nur Anzeige (automatisch aus Rechnung)
              Obx(() => TextFormField(
                    enabled: false, // Nicht editierbar
                    decoration: InputDecoration(
                      labelText: 'Betrag in EUR (aus Rechnung)',
                      suffixText: '€',
                    ),
                    controller: TextEditingController(
                      text: _controller.currentReceiptTotalString,
                    )..selection = TextSelection.fromPosition(
                        TextPosition(
                            offset:
                                _controller.currentReceiptTotalString.length),
                      ),
                  )),
              const SizedBox(height: 16),

              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                    labelText: 'Verwendungszweck (optional)'),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: generateQR,
                child: const Text('QR-Code mit Rechnungsbetrag generieren'),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ],

              Obx(() {
                final qrString = _controller.qrData.value;
                if (qrString.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Text(
                      "Noch kein QR-Code generiert",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: QrImageView(
                        data: qrString,
                        version: QrVersions.auto,
                        size: 300,
                        gapless: false,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scanne diesen QR-Code mit deiner Banking-App',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Betrag: ${_controller.currentReceiptTotalString} €',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    _purposeController.dispose();
    super.dispose();
  }
}
