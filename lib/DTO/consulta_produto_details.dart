import '../model/produto.dart';

class ConsultaProdutoDetails {
  final Produto produto;
  final int quantidade;

  ConsultaProdutoDetails({
    required this.produto,
    required this.quantidade,
  });
}