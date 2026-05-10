class Produto {
  final int? id;
  final String nome;
  double estoque;
  final int idFornecedor;
  final int idTipoProduto;
  String? status;

  Produto({
    this.id,
    required this.nome,
    required this.estoque,
    required this.idFornecedor,
    required this.idTipoProduto,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'estoque': estoque,
      'id_fornecedor': idFornecedor,
      'id_tipo_produto': idTipoProduto,
      'status' : status,
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'],
      nome: map['nome'],
      estoque: (map['estoque'] as num).toDouble(),
      idFornecedor: map['id_fornecedor'],
      idTipoProduto: map['id_tipo_produto'],
      status: map['status'],
    );
  }

  bool estoqueBaixo(int idTipo, double estoque) {
    if ((idTipo == 1 && estoque <= 50)) {
      return true;
    }

    return false;
  }
}
