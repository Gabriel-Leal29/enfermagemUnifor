class GerenciadorEstoque {
  final int? id;
  final DateTime data;
  final String numeroNfe;
  final double quantidade;
  final int idProduto;
  // final int idFornecedor;

  GerenciadorEstoque({
    this.id,
    required this.data,
    required this.numeroNfe,
    required this.quantidade,
    required this.idProduto,
    // required this.idFornecedor,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // Converte o DateTime para Texto antes de ir pro SQLite
      'data': data.toIso8601String(),
      'numero_nfe': numeroNfe,
      'quantidade': quantidade,
      'id_produto': idProduto,
    };
  }

  factory GerenciadorEstoque.fromMap(Map<String, dynamic> map) {
    return GerenciadorEstoque(
      id: map['id'],
      // Converte o Texto do SQLite de volta para DateTime
      data: DateTime.parse(map['data']),
      numeroNfe: map['numero_nfe'],
      // Segurança extra para números decimais
      quantidade: (map['quantidade'] as num).toDouble(),
      idProduto: map['id_produto'],
    );
  }
}
