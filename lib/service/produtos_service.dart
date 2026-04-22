import 'package:projeto_enfermagem_desktop/dao/produto_dao.dart';
import 'package:projeto_enfermagem_desktop/model/produto.dart';

class ProdutosService {
  final ProdutoDao produtoDao;

  ProdutosService(this.produtoDao);

  Future<void> adicionarProduto(Produto produto) async {
    
    if (produto.nome.trim().isEmpty) {
      throw Exception("Nome não pode ser nulo");
    }
    if (produto.estoque < 0) {
      throw Exception("Não é possível atribuir números negativo ao estoque");
    }
    await produtoDao.inserir(produto);
  }

  Future<double> editarEstoqueProdutoTotal(
    Produto produto,
    double novaQuantidade,
  ) async {
    if (novaQuantidade < 0) {
      throw Exception('Quantidade não pode ser negativa');
    }
    double diferenca = novaQuantidade - produto.estoque;
    await produtoDao.atualizarApenasEstoque(produto.id!, novaQuantidade);
    return diferenca;
  }

  Future<void> entradaApenasEstoque(Produto produto, double quantidadeEntrada) async {
    if(quantidadeEntrada <= 0){
      throw Exception('quantidade de entrada não pode ser 0 ou negativa');
    }
    double novoEstoque = produto.estoque + quantidadeEntrada;
    await produtoDao.atualizarApenasEstoque(produto.id!, novoEstoque);
  }

  Future<void> saidaApenasEstoque(Produto produto, double quantidadeEntrada) async {
    if(quantidadeEntrada <= 0){
      throw Exception('quantidade de saida não pode ser 0 ou negativa');
    }if(quantidadeEntrada > produto.estoque){
      throw Exception('quantiade a ser retirada maior que estoque total');
    }
    double novoEstoque = produto.estoque - quantidadeEntrada;
    await produtoDao.atualizarApenasEstoque(produto.id!, novoEstoque);
  }

  Future<void> editarProduto(Produto produto) async {
    if (produto.nome.trim().isEmpty || produto.estoque < 0) {
      throw Exception("campo vazio invalido");
    }
    await produtoDao.atualizar(produto);
  }

  Future<List<Produto>> buscarTodosOsProdutos() async {
    List<Produto> listaDeProdutos = await produtoDao.listarTodos();

    listaDeProdutos.sort(
      (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
    );

    return listaDeProdutos;
  }
}
