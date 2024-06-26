import 'package:autd3_gui_app/view/connect.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AUTD3 App',
      theme: ThemeData.dark(useMaterial3: true),
      home: const ConnectPage(title: 'AUTD3 App'),
    );
  }
}
