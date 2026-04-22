class Paciente {
  final int? id; // pode ser nulo antes de salvar no banco
  final String nome;
  final String? matricula; // visitante não tem matrícula
  final String cpf;
  final int idTipoPaciente; // foreign key pro banco

  Paciente({
    this.id,
    required this.nome,
    this.matricula,
    required this.cpf,
    required this.idTipoPaciente,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'matricula': matricula,
      'cpf': cpf,
      'id_tipo_paciente': idTipoPaciente,
    };
  }

  factory Paciente.fromMap(Map<String, dynamic> map) {
    return Paciente(
      id: map['id'],
      nome: map['nome'],
      matricula: map['matricula'],
      cpf: map['cpf'],
      idTipoPaciente: map['id_tipo_paciente'],
    );
  }

  // pra facilitar na hora de editar
  Paciente copyWith({
    int? id,
    String? nome,
    String? matricula,
    String? cpf,
    int? idTipoPaciente,
  }) {
    return Paciente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      matricula: matricula ?? this.matricula,
      cpf: cpf ?? this.cpf,
      idTipoPaciente: idTipoPaciente ?? this.idTipoPaciente,
    );
  }
}