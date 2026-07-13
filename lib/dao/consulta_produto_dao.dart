import 'package:projeto_enfermagem_desktop/model/consulta_produto.dart';
import '../database/db_helper.dart';

class ConsultaProdutoDao {
  Future<void> inserir(ConsultaProduto consultaProduto) async {
    final db = await DbHelper.instance.database;

    await db.insert('consulta_produto', consultaProduto.toMap());
  }

  Future<List<ConsultaProduto>> listarTodos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.query('consulta_produto');

    return result.map((map) => ConsultaProduto.fromMap(map)).toList();
  }

  Future<List<ConsultaProduto>> listarPorConsultas(List<int> ids) async {
    final db = await DbHelper.instance.database;

    return await db.query(
      'consulta_produto',
      where: 'id_consulta IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    ).then(
          (list) => list.map((e) => ConsultaProduto.fromMap(e)).toList(),
    );
  }

  Future<void> deletarPorConsulta(int idConsulta) async {
    final db = await DbHelper.instance.database;

    await db.delete(
      'consulta_produto',
      where: 'id_consulta = ?',
      whereArgs: [idConsulta],
    );
  }

  Future<void> excluir(int id) async {
    final db = await DbHelper.instance.database;
    await db.delete(
      'consulta_produto',
      where: 'id_consulta = ?',
      whereArgs: [id],
    );
  }

// busca consulta por id para resolver problema de edição de estoque nas consultas
Future<List<ConsultaProduto>> buscarPorConsulta(int idConsulta) async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      'consulta_produto',
      where: 'id_consulta = ?',
      whereArgs: [idConsulta],
    );

    return result.map((map) => ConsultaProduto.fromMap(map)).toList();
  }

}