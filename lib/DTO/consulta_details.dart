import '../model/paciente.dart';
import 'consulta_produto_details.dart';

class ConsultaDetails {
  final int? id;
  final String responsavel;
  final String demanda;
  final DateTime data;
  final String? observacao;
  final Paciente paciente;
  final List<ConsultaProdutoDetails> produtos;

  ConsultaDetails({
    this.id,
    required this.responsavel,
    required this.demanda,
    required this.data,
    required this.paciente,
    required this.produtos,
    this.observacao,
  });
}