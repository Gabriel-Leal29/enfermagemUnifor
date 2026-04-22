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
}