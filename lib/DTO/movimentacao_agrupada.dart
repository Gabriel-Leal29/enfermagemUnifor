import '../model/gerenciador_estoque.dart';

// uma linha da tela de movimentações: o lançamento mais recente da NFe + total de itens da NFe
class MovimentacaoAgrupada {
  final GerenciadorEstoque lancamento;
  final int qtdItens;

  MovimentacaoAgrupada({
    required this.lancamento,
    required this.qtdItens,
  });
}
