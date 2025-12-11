import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:reciepts/controller/screen_input_controller.dart';
import 'package:reciepts/controller/unterschrift_controller.dart';
import 'package:reciepts/database/database_helper.dart';
import 'package:reciepts/screens/name_eingeben_screen.dart';

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
        locale: const Locale('de', 'DE'), // Deutsch
        supportedLocales: const [
          Locale('de', 'DE'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: 'ENOC Receipt',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          fontFamily: 'Courier',
        ),
        home: NameEingebenScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
