import 'package:projeto_enfermagem_desktop/model/produto.dart';
import '../model/gerenciador_estoque.dart';
import '../database/db_helper.dart';
import '../model/gerenciador_estoque.dart';

class GerenciadorEstoqueDao {
  Future<int> inserirGerenciadorEstoque(
    GerenciadorEstoque gerenciarEstoque,
  ) async {
    final db = await DbHelper.instance.database;

    return await db.insert('gerenciar_estoque', gerenciarEstoque.toMap());
  }

  Future<void> updadeGerenciadorEstoque(
    GerenciadorEstoque gerenciadorEstoque,
  ) async {
    final db = await DbHelper.instance.database;
    return await db.update(
      'gerenciar_estoque',
      gerenciadorEstoque.toMap(),
      where: 'id = ?',
      whereArgs: [gerenciadorEstoque.id],
    );
  }

  Future<int> deletar(int id) async {
    final db = await DbHelper.instance.database;
    return await db.delete(
      'gerenciar_estoque',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<GerenciadorEstoque?> buscarPorId(int id) async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'gerenciar_estoque',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return GerenciadorEstoque.fromMap(maps.first);
    }
    return null;
  }

  Future<List<GerenciadorEstoque>> listarTodos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'gerenciar_estoque',
      orderBy: 'data DESC',
    );

    return maps.map((map) => GerenciadorEstoque.fromMap(map)).toList();
  }

  Future<int> atualizarQuantidadeDaNota(GerenciadorEstoque nfe) async {
    final db = await DbHelper.instance.database;

    return await db.update(
      'gerenciar_estoque',
      {'quantidade': nfe.quantidade, 'id_produto': nfe.idProduto},
      where: 'id = ?',
      whereArgs: [nfe.id],
    );
  }

  Future<bool> verificarNfeExiste(String nfe) async {
    final db = await DbHelper.instance.database;
    final result = await db.query(
      'gerenciar_estoque',
      where: 'numero_nfe = ?',
      whereArgs: [nfe],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
