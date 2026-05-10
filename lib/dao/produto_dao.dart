import '../database/db_helper.dart';
import '../model/produto.dart';
import 'package:sqflite/sqflite.dart';

class ProdutoDao {
  Future<int> inserir(Produto produto) async {
    final db = await DbHelper.instance.database;

    return await db.insert('produto', produto.toMap());
  }

  Future<Produto?> buscarPorId(int id) async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'produto',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Produto.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Produto>> listarTodos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query('produto');
    return maps.map((map) => Produto.fromMap(map)).toList();
  }

  Future<List<Produto>> listarAtivos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'produto',
      where: 'status = ?',
      whereArgs: ['ativo'],
    );
    return maps.map((map) => Produto.fromMap(map)).toList();
  }

  Future<List<Produto>> listarInativos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'produto',
      where: 'status = ?',
      whereArgs: ['inativo'],
    );
    return maps.map((map) => Produto.fromMap(map)).toList();
  }

  Future<int> atualizar(Produto produto) async {
    final db = await DbHelper.instance.database;

    return await db.update(
      'produto',
      produto.toMap(),
      where: 'id = ?',
      whereArgs: [produto.id],
    );
  }

  Future<int> desativarProduto(int idProduto) async {
    final db = await DbHelper.instance.database;

    return await db.update(
      'produto',
      {'status': 'inativo'},
      where: 'id = ?',
      whereArgs: [idProduto],
    );
  }

  Future<int> ativarProduto(int idProduto) async {
    final db = await DbHelper.instance.database;

    return await db.update(
      'produto',
      {'status': 'ativo'},
      where: 'id = ?',
      whereArgs: [idProduto],
    );
  }

  Future<int> atualizarApenasEstoque(int idProduto, double novoEstoque) async {
    final db = await DbHelper.instance.database;

    return await db.update(
      'produto',
      {'estoque': novoEstoque},
      where: 'id = ?',
      whereArgs: [idProduto],
    );
  }

  Future<int> atualizaEstoqueEntrada(
    int idProduto,
    double quantidadeEntrada,
  ) async {
    final db = await DbHelper.instance.database;

    return await db.rawUpdate(
      '''
    UPDATE produto 
    SET estoque = estoque + ? 
    WHERE id = ?
  ''',
      [quantidadeEntrada, idProduto],
    );
  }

  Future<int> atualizaEstoqueSaida(
    int idProduto,
    double quantidadeSaida,
  ) async {
    final db = await DbHelper.instance.database;

    return await db.rawUpdate(
      '''
    UPDATE produto 
    SET estoque = estoque - ? 
    WHERE id = ? AND estoque >= ?
  ''',
      [quantidadeSaida, idProduto, quantidadeSaida],
    );
  }
}
