import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reciepts/constants.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/screens/name_eingeben_screen.dart';
import 'package:reciepts/screens/designen.dart';
import 'package:reciepts/screens/screen_input.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitUp,
  ]);
  Get.put(UnterschriftController());
  Get.put(ScreenInputController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'de_DE';

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      child: GetMaterialApp(
        locale: const Locale('de', 'DE'),
        supportedLocales: const [
          Locale('de', 'DE'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        title: 'Rechnungs App',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: AppColors.surface,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: GoogleFonts.roboto().fontFamily, // Roboto überall!
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle:
                TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          cardColor: AppColors.primary,

          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: AppText.button,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            hintStyle: AppText.hint,
            labelStyle: AppText.label,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                  color: AppColors.primary.withOpacity(0.4), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2.5),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        home: NameEingebenScreen(),
      ),
    );
  }
}
