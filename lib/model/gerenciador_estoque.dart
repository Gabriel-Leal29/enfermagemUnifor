class GerenciadorEstoque {
  final int? id;
  final DateTime data;
  String numeroNfe;
  double quantidade;
  final int idProduto;
  final String situacao;

  GerenciadorEstoque({
    this.id,
    required this.data,
    required this.numeroNfe,
    required this.quantidade,
    required this.idProduto,
    required this.situacao, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data.toIso8601String(),
      'numero_nfe': numeroNfe,
      'quantidade': quantidade,
      'id_produto': idProduto,
      'situacao': situacao,
    };
  }

  factory GerenciadorEstoque.fromMap(Map<String, dynamic> map) {
    return GerenciadorEstoque(
      id: map['id'],
      data: DateTime.parse(map['data']),
      numeroNfe: map['numero_nfe'],
      quantidade: (map['quantidade'] as num).toDouble(),
      idProduto: map['id_produto'],
      situacao: map['situacao'],
    );
  }
}
