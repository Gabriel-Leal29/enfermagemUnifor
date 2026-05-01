import 'package:projeto_enfermagem_desktop/model/consulta_produto.dart';
import '../database/db_helper.dart';

class ConsultaProdutoDao {
  Future<void> inserir(ConsultaProduto consultaProduto) async {
    final db = await DbHelper.instance.database;

    return await db.insert('consulta_produto', consultaProduto.toMap());
  }

  Future<List<ConsultaProduto>> listarTodos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.query('consulta_produto');

    return result.map((map) => ConsultaProduto.fromMap(map)).toList();
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
    return await db.delete(
      'consulta_produto',
      where: 'id_consulta = ?',
      whereArgs: [id],
    );
  }
}