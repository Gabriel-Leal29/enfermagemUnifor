import 'package:projeto_enfermagem_desktop/dao/consulta_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/paciente_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/produto_dao.dart';

import '../DTO/consulta_details.dart';
import '../DTO/consulta_produto_details.dart';
import '../dao/consulta_produto_dao.dart';
import '../exceptions/consulta_exception.dart';
import '../model/consulta.dart';
import '../model/consulta_produto.dart';
import '../model/filtros/consulta_filtro.dart';
import '../model/paciente.dart';
import '../model/produto.dart';

class ConsultaService {
  final ConsultaDao _consultaDao = ConsultaDao();
  final ProdutoDao _produtoDao = ProdutoDao();
  final PacienteDao _pacienteDao = PacienteDao();
  final ConsultaProdutoDao _produtoConsultaDao = ConsultaProdutoDao();

  Future<void> criarConsultaCompleta(ConsultaDetails dto) async {
    try {
      final consulta = Consulta(
        idPaciente: dto.paciente.id!,
        responsavel: dto.responsavel,
        demanda: dto.demanda,
        data: dto.data,
        observacao: dto.observacao,
      );

      final consultaId = await _consultaDao.inserir(consulta);

      final lista = dto.produtos.map((p) {
        return ConsultaProduto(
          idConsulta: consultaId,
          idProduto: p.produto.id!, // importante
          quantProduto: p.quantidade,
        );
      }).toList();

      for (var item in lista) {
        await _produtoConsultaDao.inserir(item);
      }

    } catch (e) {
      throw ConsultaException("Erro ao salvar a consulta!");
    }
  }

  Future<void> editarConsulta(ConsultaDetails dto) async {
    try {
      final consulta = Consulta(
        id: dto.id,
        idPaciente: dto.paciente.id!,
        responsavel: dto.responsavel,
        demanda: dto.demanda,
        data: dto.data,
        observacao: dto.observacao,
      );

      await _consultaDao.atualizar(consulta);

      await _produtoConsultaDao.deletarPorConsulta(dto.id!);

      for (var p in dto.produtos) {
        final novo = ConsultaProduto(
          idConsulta: dto.id!,
          idProduto: p.produto.id!,
          quantProduto: p.quantidade,
        );

        await _produtoConsultaDao.inserir(novo);
      }

    } catch (e) {
      throw ConsultaException("Erro ao salvar a consulta!");
    }
  }

  // Métodos da busca paginada

  // parte sem filtro

  Future<int> getTotalConsultas() async {
    return await _consultaDao.contar();
  }

  Future<List<ConsultaDetails>> listarConsultasPaginado(int page, int pageSize) async {
    try {
      final offset = page * pageSize;

      final consultas = await _consultaDao.listarPaginado(pageSize, offset);

      final pacientes = await _pacienteDao.listarTodos();
      final consultaProdutos = await _produtoConsultaDao.listarTodos();
      final produtos = await _produtoDao.listarTodos();

      final pacientesMap = _mapearPacientes(pacientes);
      final produtosMap = _mapearProdutosLista(produtos);
      final medicamentosMap = _mapearProdutos(consultaProdutos, produtosMap);

      return consultas.map((c) {
        return ConsultaDetails(
          id: c.id!,
          responsavel: c.responsavel,
          observacao: c.observacao,
          demanda: c.demanda,
          data: c.data,
          paciente: pacientesMap[c.idPaciente]!,
          produtos: medicamentosMap[c.id] ?? [],
        );
      }).toList();
    } catch (e) {
      print(e);
      throw ConsultaException("Erro ao listar consultas paginadas!");
    }
  }

  // parte com filtro

  Future<int> getTotalConsultasComFiltro(ConsultaFiltro filtro) async {
    try {
      return await _consultaDao.countComFiltro(filtro);
    } catch (e) {
      throw ConsultaException("Erro ao contar consultas!");
    }
  }

  Future<List<ConsultaDetails>> listarConsultasPaginadoComFiltro(
      int page,
      int pageSize,
      ConsultaFiltro filtro,
      ) async {
    final offset = page * pageSize;

    final consultas = await _consultaDao
        .listarPaginadoComFiltro(pageSize, offset, filtro);

    final pacientes = await _pacienteDao.listarTodos();
    final consultaProdutos = await _produtoConsultaDao.listarTodos();
    final produtos = await _produtoDao.listarTodos();

    final pacientesMap = _mapearPacientes(pacientes);
    final produtosMap = _mapearProdutosLista(produtos);
    final medicamentosMap = _mapearProdutos(consultaProdutos, produtosMap);

    return consultas.map((c) {
      return ConsultaDetails(
        id: c.id!,
        responsavel: c.responsavel,
        observacao: c.observacao,
        demanda: c.demanda,
        data: c.data,
        paciente: pacientesMap[c.idPaciente]!,
        produtos: medicamentosMap[c.id] ?? [],
      );
    }).toList();
  }

  Future<void> deletarConsulta(int idConsulta) async {
    try {
      await _consultaDao.excluir(idConsulta);
      await _produtoConsultaDao.excluir(idConsulta);
    } on ConsultaException {
      throw ConsultaException("Erro ao deletar a consulta!");
    }
  }

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