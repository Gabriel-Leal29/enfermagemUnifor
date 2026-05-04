import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../model/usuario.dart';

class UsuarioDao {
  Future<Usuario?> login(String login, String senha) async {
    Database db = await DbHelper.instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      'usuario',
      where: 'login = ? AND senha = ?',
      whereArgs: [login, senha],
    );

    if (maps.isNotEmpty) {
      return Usuario.fromMap(maps.first);
    }
    return null;
  }
}
