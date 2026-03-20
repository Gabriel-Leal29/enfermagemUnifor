import 'package:flutter/material.dart';
import 'package:projeto_enfermagem_desktop/pages/home.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';

import 'database/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // inicializa SQLite para desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // inicializa o banco
  await DbHelper.instance.database;

  await windowManager.ensureInitialized();

  // definindo  tamanho mínimo da tela
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(1100, 700), // TODO: tamanho mínimo da tela, pode variar com o decorrer do projeto
    center: true,
    title: "Enfermagem - UNIFOR",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });


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