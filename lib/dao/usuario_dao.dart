import 'package:bcrypt/bcrypt.dart';
import '../database/db_helper.dart';
import '../model/usuario.dart';

class UsuarioDao {
  Future<Usuario?> login(String login, String senha) async {
    final db = await DbHelper.instance.database;

    final result = await db.query(
      'usuario',
      where: 'login = ?',
      whereArgs: [login],
    );

    if (result.isEmpty) return null;

    final usuario = Usuario.fromMap(result.first);

    final senhaCorreta = BCrypt.checkpw(
      senha,
      usuario.senha,
    );

    if (!senhaCorreta) {
      return null;
    }

    return usuario;
  }
}
