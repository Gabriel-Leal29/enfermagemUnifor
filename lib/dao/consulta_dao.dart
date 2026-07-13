import 'package:sqflite/sqflite.dart';

import '../database/db_helper.dart';
import '../model/consulta.dart';
import '../model/filtros/consulta_filtro.dart';

class ConsultaDao {
  Future<int> inserir(Consulta consulta) async {
    final db = await DbHelper.instance.database;

    return await db.insert('consulta', consulta.toMap());
  }

  Future<List<Consulta>> listarTodos() async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.query('consulta');

    return result
        .map<Consulta>((map) => Consulta.fromMap(map))
        .toList();
  }

  Future<List<Consulta>> listarPorPaciente(int idPaciente) async {
    final db = await DbHelper.instance.database;

    final List<Map<String, dynamic>> result = await db.query(
      'consulta',
      where: 'id_paciente = ?',
      whereArgs: [idPaciente],
      orderBy: 'data DESC',
    );

    return result
        .map<Consulta>((map) => Consulta.fromMap(map))
        .toList();
  }

  // Métodos da paginação

  Future<int> contar() async {
    final db = await DbHelper.instance.database;

    final result = await db.rawQuery('SELECT COUNT(*) as total FROM consulta');

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Consulta>> listarPaginado(int limit, int offset) async {
    final db = await DbHelper.instance.database;

    final result = await db.query(
      'consulta',
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );

    return (result as List<Map<String, dynamic>>)
        .map<Consulta>((map) => Consulta.fromMap(map))
        .toList();
  }

  // parte com filtro

  Future<int> countComFiltro(ConsultaFiltro filtro) async {
    final db = await DbHelper.instance.database;

    String where = "1=1";
    List<dynamic> args = [];

    // filtro nome paciente (JOIN)
    if (filtro.nomePaciente != null && filtro.nomePaciente!.isNotEmpty) {
      where += " AND p.nome LIKE ?";
      args.add('%${filtro.nomePaciente}%');
    }

    // data inicial
    if (filtro.dataInicial != null) {
      where += " AND c.data >= ?";
      args.add(filtro.dataInicial!.millisecondsSinceEpoch);
    }

    // data final
    if (filtro.dataFinal != null) {
      where += " AND c.data <= ?";
      args.add(filtro.dataFinal!.millisecondsSinceEpoch);
    }

    final result = await db.rawQuery('''
    SELECT COUNT(*) as total
    FROM consulta c
    INNER JOIN paciente p ON p.id = c.id_paciente
    WHERE $where
  ''', args);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Consulta>> listarPaginadoComFiltro(
      int limit,
      int offset,
      ConsultaFiltro filtro,
      ) async {
    final db = await DbHelper.instance.database;

    String where = "1=1";
    List<dynamic> args = [];

    // filtro por nome do paciente (JOIN necessário)
    if (filtro.nomePaciente != null && filtro.nomePaciente!.isNotEmpty) {
      where += " AND p.nome LIKE ?";
      args.add('%${filtro.nomePaciente}%');
    }

    // filtro por data inicial
    if (filtro.dataInicial != null) {
      where += " AND c.data >= ?";
      args.add(filtro.dataInicial!.millisecondsSinceEpoch);
    }

    // filtro por data final
    if (filtro.dataFinal != null) {
      where += " AND c.data <= ?";
      args.add(filtro.dataFinal!.millisecondsSinceEpoch);
    }

    final result = await db.rawQuery('''
    SELECT c.*
    FROM consulta c
    INNER JOIN paciente p ON p.id = c.id_paciente
    WHERE $where
    ORDER BY c.id DESC
    LIMIT ? OFFSET ?
  ''', [...args, limit, offset]);

    return (result as List<Map<String, dynamic>>)
        .map<Consulta>((map) => Consulta.fromMap(map))
        .toList();
  }

  Future<void> atualizar(Consulta consulta) async {
    final db = await DbHelper.instance.database;
    await db.update(
      'consulta',
      consulta.toMap(),
      where: 'id = ?',
      whereArgs: [consulta.id],
    );
  }

  Future<void> excluir(int id) async {
    final db = await DbHelper.instance.database;
    await db.delete(
      'consulta',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Dashboard Methods
  Future<int> getAtendimentosHoje() async {
    final db = await DbHelper.instance.database;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM consulta WHERE data >= ? AND data <= ?', [startOfDay, endOfDay]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getAtendimentosUltimosDias(int dias) async {
    final db = await DbHelper.instance.database;
    final now = DateTime.now();
    final pastDate = now.subtract(Duration(days: dias - 1));
    final startOfPastDate = DateTime(pastDate.year, pastDate.month, pastDate.day).millisecondsSinceEpoch;
    
    final result = await db.query('consulta', where: 'data >= ?', whereArgs: [startOfPastDate]);
    return result;
  }
}