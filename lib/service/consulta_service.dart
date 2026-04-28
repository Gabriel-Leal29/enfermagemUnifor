import 'package:projeto_enfermagem_desktop/dao/consulta_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/paciente_dao.dart';

import '../DTO/consulta_details.dart';
import '../DTO/consulta_produto_details.dart';
import '../dao/consulta_produto_dao.dart';
import '../exceptions/consulta_exception.dart';
import '../model/consulta.dart';
import '../model/consulta_produto.dart';
import '../model/paciente.dart';
import '../pages/consulta/dialog_adicionar_consulta.dart';

class ConsultaService {
  final ConsultaDao _consultaDao = ConsultaDao();
  final PacienteDao _pacienteDao = PacienteDao();
  final ConsultaProdutoDao _produtoConsultaDao = ConsultaProdutoDao();

  Future<void> gerarConsulta(Consulta consulta) async {
    try{
      await _consultaDao.inserir(consulta);
    }on ConsultaException {
      throw ConsultaException("Erro ao salvar consulta!");
    }
  }

  // Future<List<ConsultaDetails>> listarConsultas() async {
  //   try {
  //     final consultas = await _consultaDao.listarTodos();
  //     final pacientes = await _pacienteDao.listarTodos();
  //     final consultaProdutos = await _produtoConsultaDao.listarTodos();
  //    // final produtos = await _produtoDao.listarTodos();
  //
  //     final pacientesMap = _mapearPacientes(pacientes);
  //     //final produtosMap = _mapearProdutosLista(produtos);
  //     //final medicamentosMap = _mapearProdutos(consultaProdutos, produtosMap);
  //
  //     return consultas.map((c) {
  //       return ConsultaDetails(
  //         id: c.id!,
  //         responsavel: c.responsavel,
  //         demanda: c.demanda,
  //         data: c.data,
  //         paciente: pacientesMap[c.idPaciente]!,
  //         produtos: medicamentosMap[c.id] ?? [],
  //       );
  //     }).toList();
  //   } on ConsultaException {
  //     throw ConsultaException("Erro ao listar as consultas!");
  //   }
  // }

  Map<int, List<ConsultaProdutoDetails>> _mapearProdutos(
      List<ConsultaProduto> lista,
      Map<int, Produto> produtosMap,
      ) {
    final map = <int, List<ConsultaProdutoDetails>>{};

    for (var p in lista) {
      final produto = produtosMap[p.idProduto];

      if (produto == null) continue;

      final detalhe = ConsultaProdutoDetails(
        produto: produto,
        quantidade: p.quantProduto,
      );

      map.putIfAbsent(p.idConsulta, () => []).add(detalhe);
    }

    return map;
  }

  Map<int, Paciente> _mapearPacientes(List<Paciente> pacientes) {
    return {
      for (var p in pacientes) p.id!: p,
    };
  }

  Map<int, Produto> _mapearProdutosLista(List<Produto> produtos) {
    return {
      for (var p in produtos) p.id!: p,
    };
  }
}