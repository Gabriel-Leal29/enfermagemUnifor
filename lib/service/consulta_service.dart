import 'package:projeto_enfermagem_desktop/dao/consulta_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/paciente_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/produto_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/gerenciador_estoque_dao.dart';

import '../DTO/consulta_details.dart';
import '../DTO/consulta_produto_details.dart';
import '../dao/consulta_produto_dao.dart';
import '../exceptions/consulta_exception.dart';
import '../model/consulta.dart';
import '../model/consulta_produto.dart';
import '../model/filtros/consulta_filtro.dart';
import '../model/paciente.dart';
import '../model/produto.dart';
import '../model/gerenciador_estoque.dart';
import '../service/produtos_service.dart';   // novos imports do meu gerenciador e produtos

class ConsultaService {
  final ConsultaDao _consultaDao = ConsultaDao();
  final ProdutoDao _produtoDao = ProdutoDao();
  final PacienteDao _pacienteDao = PacienteDao();
  final ConsultaProdutoDao _produtoConsultaDao = ConsultaProdutoDao();
  
  final GerenciadorEstoqueDao _estoqueDao = GerenciadorEstoqueDao();  //1° chamando o dao e o service de gerenciador e de produtos

  late final ProdutosService _produtosService = ProdutosService(_produtoDao);

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
          idProduto: p.produto.id!,
          quantProduto: p.quantidade,
        );
      }).toList();

      for (var item in lista) {
        await _produtoConsultaDao.inserir(item);
        
        await _produtosService.saidaApenasEstoque(
          item.idProduto,                                  //2° depois de inserido pega o id dos produtos que foram usados
          item.quantProduto.toDouble()                     //3° para dar baixa no estoque deles
        );

        await _estoqueDao.inserirGerenciadorEstoque(
          GerenciadorEstoque(
            idProduto: item.idProduto,
            quantidade: item.quantProduto.toDouble(),  // 4° depois de sair do estoque gera uma movimentação de SAIDA
            data: DateTime.now(),
            situacao: 'SAIDA',
            numeroNfe: 'CONS-$consultaId',
          ),
        );
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

      final produtosAntigos = await _produtoConsultaDao.buscarPorConsulta(dto.id!);  // busca ps itens que estavam anteriormente na consulta

      Map<int, num> diferencasEstoque = {}; // Map que vai guardar o iten com seu estoque
      
      for (var antigo in produtosAntigos) {
        diferencasEstoque[antigo.idProduto] = -antigo.quantProduto; // pega todos os itens que estava na consulta pelo id e coloca a quantidade com o - na frente (porque é saida)
      }                                                                                                                                               // ex: 1: -5, 2: -50
      
      for (var novo in dto.produtos) {
        diferencasEstoque[novo.produto.id!] = (diferencasEstoque[novo.produto.id!] ?? 0) + novo.quantidade; // pega os valores antigo e soma com os novos ex tinha 5 mais ele auterou
      }                                                                                                     // para apenas 2 itens ent fica -5 + 2 = -3 ent no caso vai retirar so 3  

      for (var entry in diferencasEstoque.entries) {
        int idProduto = entry.key;                   // percorre os itens com suas diferencas de estoque
        num diferenca = entry.value;

        if (diferenca > 0) {  // inicio -5 novo 10 = 5(então usou mais 5 do que estava de inicio) então tem que sair mais 5
          await _produtosService.saidaApenasEstoque(idProduto, diferenca.toDouble());
          await _estoqueDao.inserirGerenciadorEstoque(
            GerenciadorEstoque(
              idProduto: idProduto,
              quantidade: diferenca.toDouble(), // faz a movimentação como SAIDA
              data: DateTime.now(),
              situacao: 'SAIDA',
              numeroNfe: '000-CONS-${dto.id}',
            )
          );
        } else if (diferenca < 0) {  // inicio -10 novo 5 = -10 + 5 = -5(então daqueles 10 que tinha colocado so usou 5) então tem q voltar pro estoque 5
          await _produtosService.entradaApenasEstoque(idProduto, diferenca.abs().toDouble());
          await _estoqueDao.inserirGerenciadorEstoque(
            GerenciadorEstoque(
              idProduto: idProduto,
              quantidade: diferenca.abs().toDouble(), // faz a movimentação como uma ENTRADA
              data: DateTime.now(),
              situacao: 'ENTRADA',
              numeroNfe: '000-CONS-${dto.id}',
            )
          );
        }
      }

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
      throw ConsultaException("Erro ao editar a consulta!");
    }
  }

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
      final produtosAntigos = await _produtoConsultaDao.buscarPorConsulta(idConsulta); // 1° pega os produtos que estava naquela consulta

      for (var antigo in produtosAntigos) {
        await _produtosService.entradaApenasEstoque(   //2° devolve o estoque deles 
          antigo.idProduto, 
          antigo.quantProduto.toDouble()
        );
        
        await _estoqueDao.inserirGerenciadorEstoque(
            GerenciadorEstoque(
              idProduto: antigo.idProduto,
              quantidade: antigo.quantProduto.toDouble(),  //3° gera a ENTRADA do estoque noa movimentações
              data: DateTime.now(),
              situacao: 'ENTRADA',
              numeroNfe: '000-CONS-$idConsulta',
            )
        );
      }

      await _produtoConsultaDao.excluir(idConsulta);  //4° ai no final deleta a consulta (essa parte já é sua)
      await _consultaDao.excluir(idConsulta);
      
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