class GerenciadorEstoque {
  final int? id;
  final DateTime data;
  final String numeroNfe;
  final double quantidade;
  final int idProduto;
  final int idFornecedor;

  GerenciadorEstoque({
    this.id,
    required this.data,
    required this.numeroNfe,
    required this.quantidade,
    required this.idProduto,
    required this.idFornecedor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'numero_nfe': numeroNfe,
      'quantidade': quantidade,
      'id_produto': idProduto,
      'id_fornecedor': idFornecedor,
    };
  }

  factory GerenciadorEstoque.fromMap(Map<String, dynamic> map) {
    return GerenciadorEstoque(
      id: map['id'],
      data: map['data'],
      numeroNfe: map['numero_nfe'],
      quantidade: map['quantidade'],
      idProduto: map['id_produto'],
      idFornecedor: map['id_fornecedor'],
    );

  }

}
