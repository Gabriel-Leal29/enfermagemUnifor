import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../model/paciente.dart';

class PacienteDao {
  // create (Inserir)
  Future<int> inserir(Paciente paciente) async {
    final db = await DbHelper.instance.database;
    // O insert retorna o ID gerado automaticamente pelo SQLite
    return await db.insert('paciente', paciente.toMap());
  }

  // listar Todos)
  Future<List<Paciente>> listarTodos() async {
    final db = await DbHelper.instance.database;
    
    final List<Map<String, dynamic>> result = await db.query('paciente');

    return result.map((map) => Paciente.fromMap(map)).toList();
  }

  Future<List<Paciente>> listarPorIds(List<int> ids) async {
    final db = await DbHelper.instance.database;

    return await db.query(
      'paciente',
      where: 'id IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    ).then(
          (list) => list.map((e) => Paciente.fromMap(e)).toList(),
    );
  }

  
  Future<int> atualizar(Paciente paciente) async {
    final db = await DbHelper.instance.database;
    return await db.update(
      'paciente',
      paciente.toMap(),
      where: 'id = ?',
      whereArgs: [paciente.id], 
    );
  }

  // delete (Excluir)
  Future<int> excluir(int id) async {
    final db = await DbHelper.instance.database;
    return await db.delete(
      'paciente',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Dashboard Methods
  Future<int> getTotalPacientes() async {
    final db = await DbHelper.instance.database;
    final result = await db.rawQuery('SELECT COUNT(*) as total FROM paciente');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Map<String, dynamic>>> getPacientesPorTipo() async {
    final db = await DbHelper.instance.database;
    return await db.rawQuery('''
      SELECT t.descricao as tipo, COUNT(p.id) as total
      FROM tipo_paciente t
      LEFT JOIN paciente p ON t.id = p.id_tipo_paciente
      GROUP BY t.id, t.descricao
    ''');
  }
}