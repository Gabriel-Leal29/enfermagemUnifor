class ConsultaProduto {
  final int? id;
  final int  idProduto;
  final int  idConsulta;
  final int quantProduto;

  ConsultaProduto({
    this.id,
    required this.idProduto,
    required this.idConsulta,
    required this.quantProduto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_produto': idProduto,
      'id_consulta': idConsulta,
      'quant_produto': quantProduto,
    };
  }

  factory ConsultaProduto.fromMap(Map<String, dynamic> map) {
    return ConsultaProduto(
      id: map['id'],
      idConsulta: map['id_consulta'],
      idProduto: map['id_produto'],
      quantProduto: map['quant_produto'],
    );
  }
}