class Config {
  final String nomeInstituicao;
  final String? cnpj;
  final String? endereco;
  final String? telefone;
  final String? impressora;

  Config({
    required this.nomeInstituicao,
    this.cnpj,
    this.endereco,
    this.telefone,
    this.impressora,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome_instituicao': nomeInstituicao,
      'cnpj': cnpj,
      'endereco': endereco,
      'telefone': telefone,
      'impressora': impressora,
    };
  }

  factory Config.fromMap(Map<String, dynamic> map) {
    return Config(
      nomeInstituicao: map['nome_instituicao'],
      cnpj: map['cnpj'],
      endereco: map['endereco'],
      telefone: map['telefone'],
      impressora: map['impressora'],
    );
  }
}