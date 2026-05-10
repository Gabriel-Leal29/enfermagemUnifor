class Usuario {
  int? id;
  String login;
  String senha;

  Usuario({this.id, required this.login, required this.senha});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'login': login,
      'senha': senha,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      login: map['login'],
      senha: map['senha'],
    );
  }
}
