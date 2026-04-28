import 'package:projeto_enfermagem_desktop/model/consulta_produto.dart';
import '../database/db_helper.dart';

class ConsultaProdutoDao {
  Future<void> inserir(ConsultaProduto consultaProduto) async {
    final db = await DbHelper.instance.database;

    return await db.insert('consulta', consultaProduto.toMap());
  }

  Future<List<ConsultaProduto>> listarTodos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.query('consulta');

    return result.map((map) => ConsultaProduto.fromMap(map)).toList();
  }

  Future<void> atualizar(ConsultaProduto consultaProduto) async {
    final db = await DbHelper.instance.database;
    return await db.update(
      'consultaProduto',
      consultaProduto.toMap(),
      where: 'id = ?',
      whereArgs: [consultaProduto.id],
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