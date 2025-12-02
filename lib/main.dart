import 'package:flutter/material.dart';

import 'package:reciepts/screen_input.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 👈 REQUIRED before using plugins

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENOC Receipt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Courier',
      ),
      home: const ScreenInput(),
      debugShowCheckedModeBanner: false,
    );
  }
}
