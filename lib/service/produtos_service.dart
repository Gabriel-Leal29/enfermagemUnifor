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

  Future<void> entradaApenasEstoque(
    int idProduto,
    double quantidadeEntrada,
  ) async {
    if (quantidadeEntrada <= 0) {
      throw Exception('A quantidade de entrada não pode ser zero ou negativa.');
    }
    await produtoDao.atualizaEstoqueEntrada(idProduto, quantidadeEntrada);
  }

  Future<void> saidaApenasEstoque(int idProduto, double quantidadeSaida) async {
    if (quantidadeSaida <= 0) {
      throw Exception('Quantidade de saída não pode ser zero ou negativa.');
    }

    int linhasAfetadas = await produtoDao.atualizaEstoqueSaida(
      idProduto,
      quantidadeSaida,
    );

    if (linhasAfetadas == 0) {
      throw Exception(
        'Quantidade a ser retirada é maior que o estoque total disponível.',
      );
    }
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

  Future<List<Produto>> buscarTodosOsAtivos() async {
    List<Produto> listaDeProdutos = await produtoDao.listarAtivos();

    listaDeProdutos.sort(
      (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
    );

    return listaDeProdutos;
  }

  Future<List<Produto>> buscarTodosOsInativos() async {
    List<Produto> listaDeProdutos = await produtoDao.listarInativos();

    listaDeProdutos.sort(
      (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
    );

    return listaDeProdutos;
  }

  Future<void> desativarProduto(int idProduto) async {
    await produtoDao.desativarProduto(idProduto);
  }

  Future<void> ativarProduto(int idProduto) async {
    await produtoDao.ativarProduto(idProduto);
  }
}
