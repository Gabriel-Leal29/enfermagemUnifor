import 'package:sqflite/sqflite.dart';

import '../DTO/movimentacao_agrupada.dart';
import '../model/filtros/movimentacao_filtro.dart';
import '../model/gerenciador_estoque.dart';
import '../database/db_helper.dart';

class GerenciadorEstoqueDao {
  // lançamentos da mesma NFe viram uma linha só; correções (NFe começando com 000)
  // ficam uma por linha, por isso entram no agrupamento pelo próprio id
  static const String _agrupamentoNfe =
      "numero_nfe, CASE WHEN numero_nfe LIKE '000%' THEN id END";

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
    await db.update(
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

  Future<GerenciadorEstoque?> buscarUltimaEntradaDoProduto(int idProduto) async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'gerenciar_estoque',
      where: "id_produto = ? AND situacao = 'ENTRADA'",
      whereArgs: [idProduto],
      orderBy: 'data DESC, id DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return GerenciadorEstoque.fromMap(maps.first);
    }
    return null;
  }

  Future<List<GerenciadorEstoque>> listarPorNfe(String numeroNfe) async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'gerenciar_estoque',
      where: 'numero_nfe = ?',
      whereArgs: [numeroNfe],
      orderBy: 'data DESC',
    );

    return maps.map((map) => GerenciadorEstoque.fromMap(map)).toList();
  }

  (String, List<dynamic>) _montarWhereFiltro(MovimentacaoFiltro filtro) {
    String where = "1=1";
    List<dynamic> args = [];

    // filtro por número da NFe
    if (filtro.numeroNfe != null && filtro.numeroNfe!.isNotEmpty) {
      where += " AND numero_nfe LIKE ?";
      args.add('%${filtro.numeroNfe}%');
    }

    // filtro por situação
    if (filtro.situacao == 'ENTRADA') {
      where += " AND situacao = 'ENTRADA' AND numero_nfe NOT LIKE '000%'";
    } else if (filtro.situacao == 'SAÍDA') {
      where += " AND situacao = 'SAIDA' AND numero_nfe NOT LIKE '000%'";
    } else if (filtro.situacao == 'CORREÇÕES') {
      where += " AND numero_nfe LIKE '000%'";
    }

    return (where, args);
  }

  Future<int> countAgrupadoComFiltro(MovimentacaoFiltro filtro) async {
    final db = await DbHelper.instance.database;
    final (where, args) = _montarWhereFiltro(filtro);

    final result = await db.rawQuery('''
    SELECT COUNT(*) AS total FROM (
      SELECT 1
      FROM gerenciar_estoque
      WHERE $where
      GROUP BY $_agrupamentoNfe
    )
  ''', args);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<MovimentacaoAgrupada>> listarAgrupadoPaginadoComFiltro(
      int limit,
      int offset,
      MovimentacaoFiltro filtro,
      ) async {
    final db = await DbHelper.instance.database;
    final (where, args) = _montarWhereFiltro(filtro);

    // o ROW_NUMBER pega o lançamento mais recente de cada grupo; a contagem de itens
    // fica na consulta de fora para rodar só nas linhas da página
    final result = await db.rawQuery('''
    SELECT p.*,
      (SELECT COUNT(*) FROM gerenciar_estoque t WHERE t.numero_nfe = p.numero_nfe) AS qtd_itens
    FROM (
      SELECT id, data, numero_nfe, quantidade, id_produto, situacao
      FROM (
        SELECT *,
          ROW_NUMBER() OVER (PARTITION BY $_agrupamentoNfe ORDER BY data DESC, id DESC) AS posicao
        FROM gerenciar_estoque
        WHERE $where
      )
      WHERE posicao = 1
      ORDER BY data DESC, id DESC
      LIMIT ? OFFSET ?
    ) p
    ORDER BY p.data DESC, p.id DESC
  ''', [...args, limit, offset]);

    return result.map((map) {
      return MovimentacaoAgrupada(
        lancamento: GerenciadorEstoque.fromMap(map),
        qtdItens: map['qtd_itens'] as int,
      );
    }).toList();
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
