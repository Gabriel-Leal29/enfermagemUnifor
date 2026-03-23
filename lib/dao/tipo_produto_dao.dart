import '../database/db_helper.dart';
import '../model/tipo_produto.dart';

class TipoProdutoDao {
  
  Future<List<TipoProduto>> listarTipos() async {
    final db = await DbHelper.instance.database;
    
    // Busca no banco
    final List<Map<String, dynamic>> maps = await db.query('tipoProduto', orderBy: 'descricao');
    
    // Converte a lista de Maps
    return maps.map((map) => TipoProduto.fromMap(map)).toList();
  }
}