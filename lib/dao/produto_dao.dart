import '../database/db_helper.dart';
import '../model/produto.dart';

class ProdutoDao {
  Future<int> inserir(Produto produto) async {
    final db = await DbHelper.instance.database;

    return await db.insert('produto', produto.toMap());
  }

  Future<List<Produto>> listarTodos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query('produto');
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

  Future<int> deletar(int id) async {
    final db = await DbHelper.instance.database;

    return await db.delete('produto', where: 'id = ?', whereArgs: [id]);
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
}
