import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../model/fornecedor.dart';

class FornecedorDao {
  Future<int> inserir(Fornecedor fornecedor) async {
    final db = await DbHelper.instance.database;
    return await db.insert('fornecedor', fornecedor.toMap());
  }

  Future<List<Fornecedor>> listarTodos() async {
    final db = await DbHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query('fornecedor');
    return result.map((map) => Fornecedor.fromMap(map)).toList();
  }

  Future<int> atualizar(Fornecedor fornecedor) async {
    final db = await DbHelper.instance.database;
    return await db.update(
      'fornecedor',
      fornecedor.toMap(),
      where: 'id = ?',
      whereArgs: [fornecedor.id],
    );
  }

  Future<int> excluir(int id) async {
    final db = await DbHelper.instance.database;
    return await db.delete(
      'fornecedor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}