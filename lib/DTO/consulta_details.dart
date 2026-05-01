import 'package:intl/intl.dart';

import '../model/paciente.dart';
import 'consulta_produto_details.dart';

class ConsultaDetails {
  final int? id;
  final String? responsavel;
  final String demanda;
  final DateTime data;
  final String? observacao;
  final Paciente paciente;
  final List<ConsultaProdutoDetails> produtos;

  ConsultaDetails({
    this.id,
    required this.demanda,
    required this.data,
    required this.paciente,
    required this.produtos,
    this.responsavel,
    this.observacao,
  });

  String get dataFormatada {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  String limitarTexto(String texto, int limite) {
    if (texto.length <= limite) return texto;
    return '${texto.substring(0, limite)}...';
  }

  String get medicamentosSimplificados {
    final prod = produtos
        .map((p) => p.produto.nome.split(' ').first)
        .join(', ');

    return limitarTexto(prod, 40);
  }

  String get demandaResumida => limitarTexto(demanda, 25);
}