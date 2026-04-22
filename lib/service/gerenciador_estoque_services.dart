import 'package:projeto_enfermagem_desktop/model/gerenciador_estoque.dart';
import 'package:projeto_enfermagem_desktop/model/produto.dart';
import '../database/db_helper.dart';
import '../dao/gerenciador_estoque_dao.dart';
import '../dao/produto_dao.dart';
import '../service/produtos_service.dart';
import '../model/produto.dart';

class ItemLinhaNfe {
  Produto produto;
  String numeroNfe;
  double quantidadeEntrada;

  ItemLinhaNfe({
    required this.produto,
    required this.numeroNfe,
    required this.quantidadeEntrada,
  });
}

class GerenciadorEstoqueServices {
  final GerenciadorEstoqueDao gerenciadorEstoqueDao;
  final ProdutoDao produtoDao;
  final ProdutosService produtosService;

  GerenciadorEstoqueServices(
    this.gerenciadorEstoqueDao,
    this.produtoDao,
    this.produtosService,
  );

  Future<void> salvarLoteDeEntradas(List<ItemLinhaNfe> listaDeItens) async {
    for (var item in listaDeItens) {
      if (item.quantidadeEntrada <= 0) {
        throw Exception(
          "Erro: O produto ${item.produto.nome} está com quantidade inválida.",
        );
      }

      int idDoProdutoParaNfe;

      if (item.produto.id != null) {
        await produtosService.entradaApenasEstoque(
          item.produto,
          item.quantidadeEntrada,
        );

        idDoProdutoParaNfe = item.produto.id!;
      } else {
        item.produto.estoque = item.quantidadeEntrada;

        idDoProdutoParaNfe = await produtoDao.inserir(item.produto);
      }

      GerenciadorEstoque novoLancamento = GerenciadorEstoque(
        numeroNfe: item.numeroNfe,
        idProduto: idDoProdutoParaNfe,
        quantidade: item.quantidadeEntrada,
        situacao: "ENTRADA",
        data: DateTime.now(),
      );

      await gerenciadorEstoqueDao.inserirGerenciadorEstoque(novoLancamento);
    }
  }

  Future<bool> verificarDuplicidadeNaEdicao(
    String nomeDigitado,
    int idFornecedor,
    int idTipoProduto,
    int idProdutoSendoEditado,
  ) async {
    List<Produto> todosProdutos = await produtoDao.listarTodos();

    bool existeClone = todosProdutos.any(
      (p) =>
          p.id != idProdutoSendoEditado &&
          p.nome.toLowerCase() == nomeDigitado.trim().toLowerCase() &&
          p.idFornecedor == idFornecedor &&
          p.idTipoProduto == idTipoProduto,
    );
    return existeClone;
  }

  Future<void> editarItemDaNfe(
    Produto produtoEditadoDaTela,
    GerenciadorEstoque nfeEditadaDaTela,
  ) async {
    if (nfeEditadaDaTela.quantidade <= 0) {
      throw Exception("A quantidade não pode ser zero ou negativa.");
    }

    GerenciadorEstoque? nfeAntiga = await gerenciadorEstoqueDao.buscarPorId(
      nfeEditadaDaTela.id!,
    );
    if (nfeAntiga == null)
      throw Exception("Lançamento original não encontrado no banco.");

    Produto? produtoAtualNoBanco = await produtoDao.buscarPorId(
      produtoEditadoDaTela.id!,
    );
    if (produtoAtualNoBanco == null)
      throw Exception("Produto não encontrado no banco.");

    double diferenca = nfeEditadaDaTela.quantidade - nfeAntiga.quantidade;

    double novoEstoqueCalculado = produtoAtualNoBanco.estoque + diferenca;

    if (novoEstoqueCalculado < 0) {
      throw Exception(
        "Erro: Você não pode reduzir a quantidade desta nota para ${nfeEditadaDaTela.quantidade}, "
        "pois já consumiu parte deste lote e o estoque ficaria negativo.",
      );
    }

    produtoEditadoDaTela.estoque = novoEstoqueCalculado;

    await produtoDao.atualizar(produtoEditadoDaTela);

    await gerenciadorEstoqueDao.atualizarQuantidadeDaNota(nfeEditadaDaTela);
  }

  Future<bool> checarSeNfeJaExiste(String nfe) async {
    if (nfe.trim().isEmpty) return false;
    return await gerenciadorEstoqueDao.verificarNfeExiste(nfe.trim());
  }

  Future<String> verSituacao(Produto produto, double quantidadePassada) async {
    double qtdFinal = quantidadePassada - produto.estoque;

    if (qtdFinal < 0) {
      return "SAIDA";
    } else {
      return "ENTRADA";
    }
  }
}
