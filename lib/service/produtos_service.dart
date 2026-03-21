import 'package:projeto_enfermagem_desktop/dao/produto_dao.dart';
import 'package:projeto_enfermagem_desktop/model/produto.dart';

class ProdutosService {
  final ProdutoDao produtoDao;

  ProdutosService(this.produtoDao);

  Future<void> adicionarProduto(Produto produto) async {
    //verificação de campo nulo
    if (produto.nome.trim().isEmpty) {
      throw Exception("Nome não pode ser nulo");
    }
    if (produto.estoque < 0) {
      throw Exception("Não é possível atribuir números negativo ao estoque");
    }
    await produtoDao.inserir(produto);
  }

  Future<double> editarEstoqueProduto(
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
