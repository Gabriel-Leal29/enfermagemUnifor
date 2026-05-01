class Consulta {
  final int? id;
  final int idPaciente;
  final String? observacao;
  final String? responsavel;
  final String demanda;
  final DateTime data;

  Consulta({
    required this.idPaciente,
    required this.demanda,
    required this.data,
    this.responsavel,
    this.observacao,
    this.id
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_paciente': idPaciente,
      'observacao': observacao,
      'responsavel': responsavel,
      'demanda': demanda,
      'data': data.millisecondsSinceEpoch,
    };
  }

  factory Consulta.fromMap(Map<String, dynamic> map) {
    return Consulta(
      id: map['id'],
      idPaciente: map['id_paciente'],
      responsavel: map['responsavel'],
      observacao: map['observacao'],
      demanda: map['demanda'],
      data: DateTime.fromMillisecondsSinceEpoch(map['data']),
    );
  }
}