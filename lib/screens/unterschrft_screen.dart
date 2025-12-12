import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:reciepts/constants.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/screens/settings_screen.dart';

class UnterschrftScreen extends StatefulWidget {
  final title;
  UnterschrftScreen({required this.title, super.key});

  @override
  State<UnterschrftScreen> createState() => _UnterschrftScreenState();
}

class _UnterschrftScreenState extends State<UnterschrftScreen> {
  UnterschriftController _controller = Get.find();
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Zurück auf Hochformat, wenn du willst
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Unterschriften"),
      //   actions: [
      //     IconButton(
      //       onPressed: _controller.clearSignature(widget.title == "Kunde"
      //           ? _controller.kundeSignatureController
      //           : _controller.monteurSignatureController),
      //       icon: Icon(Icons.clear),
      //     ),
      //     IconButton(
      //       onPressed: () {
      //         widget.title == "Kunde"
      //             ? _controller.saveKundeBytesToImage(context)
      //             : _controller.saveMonteurBytesToImage(context);

      //         // _controller.update();
      //       },
      //       icon: Icon(Icons.save),
      //     )
      //   ],
      // ),
      body: Container(
        width: MediaQuery.sizeOf(context).width * .9,
        height: MediaQuery.sizeOf(context).height * .9,
        child: Column(children: [
          _buildHeader(context),
          widget.title == "Kunde"
              ? _controller.kundeSignatureCanvas
              : _controller.monteurSignatureCanvas,
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
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

            // Titel zentriert
            Expanded(
              child: Center(
                child: Text(
                  "Eingabe",
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
