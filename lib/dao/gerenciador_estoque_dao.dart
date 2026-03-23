import '../database/db_helper.dart';
import '../model/gerenciador_estoque.dart';

class GerenciadorEstoqueDao {


Future<int> inserirGerenciadorEstoque(GerenciadorEstoque gerenciarEstoque) async{
  final db = await DbHelper.instance.database;

  return await db.insert('gerenciar_estoque', gerenciarEstoque.toMap());
}


Future<void> updadeGerenciadorEstoque(GerenciadorEstoque gerenciadorEstoque) async{
  final db = await DbHelper.instance.database;

}
  // se produto não estiver cadastrado, mandar função cadastro, se ja tiver cadastrado
  // chamar função de atualizar apenas estoque
}