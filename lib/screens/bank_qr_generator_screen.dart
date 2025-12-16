import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reciepts/constants.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/database/database_helper.dart';
import 'package:reciepts/screens/settings_screen.dart';

class BankQrGeneratorScreen extends StatefulWidget {
  const BankQrGeneratorScreen({super.key});

  @override
  State<BankQrGeneratorScreen> createState() => _BankQrGeneratorScreenState();
}

class _BankQrGeneratorScreenState extends State<BankQrGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

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
        _controller.nameBankQrController.text = data['name'] ?? '';
        _controller.ibanBankQrController.text = data['iban'] ?? '';
        _controller.bicBankQrController.text = data['bic'] ?? '';
        _controller.purposeBankQrController.text = data['purpose'] ?? '';

        // QR-Code laden, falls vorhanden
        final savedQr = data['qrData'] ?? '';
        if (savedQr.isNotEmpty) {
          _controller.qrData.value = savedQr;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _controller.nameBankQrController,
                      decoration: const InputDecoration(
                          labelText: 'Name des Begünstigten (Pflicht)'),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? 'Pflichtfeld' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controller.ibanBankQrController,
                      decoration:
                          const InputDecoration(labelText: 'IBAN (Pflicht)'),
                      validator: (v) =>
                          v?.trim().isEmpty ?? true ? 'Pflichtfeld' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controller.bicBankQrController,
                      decoration:
                          const InputDecoration(labelText: 'BIC (optional)'),
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
                                  offset: _controller
                                      .currentReceiptTotalString.length),
                            ),
                        )),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _controller.purposeBankQrController,
                      decoration: const InputDecoration(
                          labelText: 'Verwendungszweck (optional)'),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _controller.generateQR,
                      child:
                          const Text('QR-Code mit Rechnungsbetrag generieren'),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)),
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
          ),
        ],
      ),
    );
  }

  // Verbesserter Custom Header mit SafeArea
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  "Bank daten eingeben",
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
