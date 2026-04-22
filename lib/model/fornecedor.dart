class Fornecedor {
  final int? id;
  final String nome; // Nome Fantasia
  final String? razaoSocial; 
  final String cnpj;

  Fornecedor({
    this.id,
    required this.nome,
    this.razaoSocial,
    required this.cnpj,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'razao_social': razaoSocial,
      'cnpj': cnpj,
    };
  }

  factory Fornecedor.fromMap(Map<String, dynamic> map) {
    return Fornecedor(
      id: map['id'],
      nome: map['nome'],
      razaoSocial: map['razao_social'],
      cnpj: map['cnpj'],
    );
  }

  Fornecedor copyWith({
    int? id,
    String? nome,
    String? razaoSocial,
    String? cnpj,
  }) {
    return Fornecedor(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      razaoSocial: razaoSocial ?? this.razaoSocial,
      cnpj: cnpj ?? this.cnpj,
    );
  }
}