import '../database/db_helper.dart';
import '../model/consulta.dart';

class ConsultaDao {
  Future<void> inserir(Consulta consulta) async {
    final db = await DbHelper.instance.database;

    return await db.insert('consulta', consulta.toMap());
  }

  Future<List<Consulta>> listarTodos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.query('consulta');

    return result.map((map) => Consulta.fromMap(map)).toList();
  }

  Future<void> atualizar(Consulta consulta) async {
    final db = await DbHelper.instance.database;
    return await db.update(
      'consulta',
      consulta.toMap(),
      where: 'id = ?',
      whereArgs: [consulta.id],
    );
  }


  // TODO: analisar esse método

  // Future<void> excluir(int id) async {
  //   final db = await DbHelper.instance.database;
  //   return await db.delete(
  //     'consulta',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //   );
  // }
}