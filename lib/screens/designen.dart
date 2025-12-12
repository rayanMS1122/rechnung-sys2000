// designen_screen.dart (oder wie du die Datei nennst)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // falls du screenutil nutzt
import 'package:reciepts/constants.dart';

class Designen extends StatefulWidget {
  const Designen({super.key});

  @override
  State<Designen> createState() => _DesignenState();
}

class _DesignenState extends State<Designen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Positionen"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w), // einheitliches Padding
        itemCount: 10, // Beispiel – später dynamisch
        itemBuilder: (context, index) {
          return customPositionCard(index: index + 1);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          // Neue Position hinzufügen
        },
      ),
    );
  }

  Widget customPositionCard({required int index}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h), // Abstand zwischen Karten
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kopfzeile: Position + Löschen
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Position $index",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade600),
                  onPressed: () {
                    // Löschen
                  },
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Menge | Einheit | Einzelpreis
            Row(
              children: [
                Expanded(child: _infoColumn("Menge", "5")),
                _divider(),
                Expanded(child: _infoColumn("Einheit", "Stück")),
                _divider(),
                Expanded(child: _infoColumn("Einzelpreis", "5,00 €")),
              ],
            ),

            SizedBox(height: 20.h),

            // Bezeichnung + Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bezeichnung",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Beispielarbeiten am Objekt – Montage und Installation",
                  style: TextStyle(fontSize: 16.sp, color: AppColors.text),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _actionButton(
                      icon: Icons.image_outlined,
                      label: "Bild anzeigen",
                      onTap: () {
                        // Bild anzeigen
                      },
                    ),
                    SizedBox(width: 12.w),
                    _actionButton(
                      icon: Icons.photo_library_outlined,
                      label: "Bilder hinzufügen",
                      onTap: () {
                        // Bilder hinzufügen
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 48.h,
      color: AppColors.primary.withOpacity(0.3),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
