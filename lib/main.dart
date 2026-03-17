import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/pages/home.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa SQLite para desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // inicializa o banco
  await DbHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}