class Produto {
  final int? id;
  final String nome;
  final double estoque;
  final int idFornecedor;
  final int idTipoProduto;

  Produto({
    this.id,
    required this.nome,
    required this.estoque,
    required this.idFornecedor,
    required this.idTipoProduto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'estoque': estoque,
      'id_fornecedor': idFornecedor,
      'id_tipo_produto': idTipoProduto,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'],
      estoque: map['estoque'],
      idFornecedor: map['id_fornecedor'],
      idTipoProduto: map['id_tipo_produto'],
    );
  }

  bool estoqueBaixo(int idTipo, double estoque) {
    if ((idTipo == 1 && estoque < 10) || (idTipo == 2 && estoque < 100)) {
      return true;
    }

    return false;
  }
}
