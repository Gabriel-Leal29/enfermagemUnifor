import '../database/db_helper.dart';
import '../model/config.dart';

class ConfigDao {
  Future<Config?> getConfig() async {
    final db = await DbHelper.instance.database;

    final result = await db.query('config', limit: 1);

    if (result.isNotEmpty) {
      return Config.fromMap(result.first);
    }

    return null;
  }

  Future<void> salvar(Config config) async {
    final db = await DbHelper.instance.database;

    final existing = await db.query('config', limit: 1);

    if (existing.isEmpty) {
      // insere
      await db.insert('config', config.toMap());
    } else {
      // atualiza
      await db.update('config', config.toMap());
    }
  }
}