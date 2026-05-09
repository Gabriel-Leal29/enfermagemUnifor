import '../database/db_helper.dart';
import '../model/produto.dart';

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

  // Dashboard Methods
  Future<Map<String, int>> getEstatisticasEstoque(double limiteBaixo) async {
    final db = await DbHelper.instance.database;
    final List<Map<String, dynamic>> produtos = await db.query('produto');
    
    int estoqueNormal = 0;
    int estoqueBaixo = 0;
    int semEstoque = 0;

    for (var p in produtos) {
      double estoque = (p['estoque'] is int) 
          ? (p['estoque'] as int).toDouble() 
          : (p['estoque'] as double? ?? 0.0);
          
      if (estoque <= 0) {
        semEstoque++;
      } else if (estoque <= limiteBaixo) {
        estoqueBaixo++;
      } else {
        estoqueNormal++;
      }
    }

    return {
      'normal': estoqueNormal,
      'baixo': estoqueBaixo,
      'zerado': semEstoque,
      'total': produtos.length,
    };
  }
}
