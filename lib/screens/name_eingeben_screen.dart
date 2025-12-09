import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reciepts/controller/name_eingeben_controller.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/screens/screen_input.dart';

class NameEingebenScreen extends StatelessWidget {
  NameEingebenScreen({super.key});
  ScreenInputController _screenInputController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Namen eingeben"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: 500.w), // schön auch auf Tablets
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Monteur Infos",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 32.h),
                TextField(
                  controller: _screenInputController.,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: "name",
                    hintText: "Name des Monteurs",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 18.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 32.h),
                Text(
                  "Kunde Infos",
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 32.h),
                // Kunde
                TextField(
                  controller: _kundeController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "Name des Kunden",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 18.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
                // Kunde
                TextField(
                  controller: _kundeController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "",
                    hintText: "Name des Kunden",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 18.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),

                TextField(
                  controller: _kundeController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "Kunde",
                    hintText: "Name des Kunden",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 18.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),

                TextField(
                  controller: _kundeController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: "Kunde",
                    hintText: "Name des Kunden",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 18.h,
                    ),
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 48.h),

                // Weiter-Button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // Namen speichern
                      _nameEingebenController.monteur =
                          _monteurController.text.trim();
                      _nameEingebenController.kunde =
                          _kundeController.text.trim();

                      // Weiter zum Eingabe-Screen
                      Get.to(() => const ScreenInput());
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Weiter",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
