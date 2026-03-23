class TipoProduto {
  final int? id;
  final String descricao;

  TipoProduto({this.id, required this.descricao});

  Map<String, dynamic> toMap() {
    return {'id': id, 'descricao': descricao};
  }

  factory TipoProduto.fromMap(Map<String, dynamic> map) {
    return TipoProduto(id: map['id'], descricao: map['descricao']);
  }
}
