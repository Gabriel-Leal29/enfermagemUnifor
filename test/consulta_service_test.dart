import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projeto_enfermagem_desktop/DTO/consulta_details.dart';
import 'package:projeto_enfermagem_desktop/DTO/consulta_produto_details.dart';
import 'package:projeto_enfermagem_desktop/dao/consulta_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/gerenciador_estoque_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/paciente_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/produto_dao.dart';
import 'package:projeto_enfermagem_desktop/dao/consulta_produto_dao.dart';
import 'package:projeto_enfermagem_desktop/exceptions/consulta_exception.dart';
import 'package:projeto_enfermagem_desktop/model/consulta.dart';
import 'package:projeto_enfermagem_desktop/model/consulta_produto.dart';
import 'package:projeto_enfermagem_desktop/model/gerenciador_estoque.dart';
import 'package:projeto_enfermagem_desktop/model/paciente.dart';
import 'package:projeto_enfermagem_desktop/model/produto.dart';
import 'package:projeto_enfermagem_desktop/service/consulta_service.dart';
import 'package:projeto_enfermagem_desktop/service/produtos_service.dart';

class MockConsultaDao extends Mock implements ConsultaDao {}
class MockPacienteDao extends Mock implements PacienteDao {}
class MockConsultaProdutoDao extends Mock implements ConsultaProdutoDao {}
class MockProdutoDao extends Mock implements ProdutoDao {}
class MockGerenciadorEstoqueDao extends Mock
    implements GerenciadorEstoqueDao {}
class MockProdutosService extends Mock
    implements ProdutosService {}



class FakeConsulta extends Fake implements Consulta {}

class FakeConsultaProduto extends Fake implements ConsultaProduto {}

class FakeGerenciadorEstoque extends Fake
    implements GerenciadorEstoque {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeConsulta());
    registerFallbackValue(FakeConsultaProduto());
    registerFallbackValue(FakeGerenciadorEstoque());
  });

  late ConsultaService service;
  late MockConsultaDao consultaDao;
  late MockPacienteDao pacienteDao;
  late MockConsultaProdutoDao produtoConsultaDao;
  late MockProdutoDao produtoDao;
  late MockGerenciadorEstoqueDao estoqueDao;
  late MockProdutosService produtosService;

  setUp(() {
    consultaDao = MockConsultaDao();
    pacienteDao = MockPacienteDao();
    produtoConsultaDao = MockConsultaProdutoDao();
    produtoDao = MockProdutoDao();
    estoqueDao = MockGerenciadorEstoqueDao();
    produtosService = MockProdutosService();

    service = ConsultaService(
      consultaDao: consultaDao,
      pacienteDao: pacienteDao,
      produtoConsultaDao: produtoConsultaDao,
      produtoDao: produtoDao,
      estoqueDao: estoqueDao,
      produtosService: produtosService,
    );
  });

  group("ConsultaService", () {
    test(
      "deve listar consultas paginadas com paciente e produtos",
          () async {

        final consulta = Consulta(
          id: 1,
          idPaciente: 10,
          responsavel: "Enf. Carla",
          observacao: "Obs",
          demanda: "Febre",
          data: DateTime(2025, 1, 1),
        );

        final paciente = Paciente(
          id: 10,
          nome: "João",
          idTipoPaciente: 1,
        );

        final produto = Produto(
          id: 100,
          nome: "Dipirona",
          estoque: 16,
          idFornecedor: 1,
          idTipoProduto: 1,
        );

        final consultaProduto = ConsultaProduto(
          idConsulta: 1,
          idProduto: 100,
          quantProduto: 2,
        );

        when(() => consultaDao.listarPaginado(10, 0))
            .thenAnswer((_) async => [consulta]);

        when(() => pacienteDao.listarPorIds([10]))
            .thenAnswer((_) async => [paciente]);

        when(() => produtoConsultaDao.listarPorConsultas([1]))
            .thenAnswer((_) async => [consultaProduto]);

        when(() => produtoDao.listarPorIds([100]))
            .thenAnswer((_) async => [produto]);

        final result = await service.listarConsultasPaginado(0, 10);

        expect(result, hasLength(1));
        expect(result.first.id, 1);
        expect(result.first.paciente.nome, "João");
        expect(result.first.produtos, hasLength(1));
        expect(result.first.produtos.first.produto.nome, "Dipirona");

        verify(() => consultaDao.listarPaginado(10, 0)).called(1);
        verify(() => pacienteDao.listarPorIds([10])).called(1);
        verify(() => produtoConsultaDao.listarPorConsultas([1])).called(1);
        verify(() => produtoDao.listarPorIds([100])).called(1);

        verifyNoMoreInteractions(consultaDao);
        verifyNoMoreInteractions(pacienteDao);
        verifyNoMoreInteractions(produtoConsultaDao);
        verifyNoMoreInteractions(produtoDao);
      },
    );

    test(
      "deve retornar lista vazia quando não houver consultas",
          () async {
        when(() => consultaDao.listarPaginado(10, 0))
            .thenAnswer((_) async => []);

        final result = await service.listarConsultasPaginado(0, 10);

        expect(result, isEmpty);

        verify(() => consultaDao.listarPaginado(10, 0)).called(1);

        // como saiu cedo, não deveria chamar outros DAOs
        verifyZeroInteractions(pacienteDao);
        verifyZeroInteractions(produtoConsultaDao);
        verifyZeroInteractions(produtoDao);
      },
    );

    test(
      "deve lançar ConsultaException quando dao falhar",
          () async {
        when(() => consultaDao.listarPaginado(10, 0))
            .thenThrow(Exception("Erro no banco"));

        expect(
              () => service.listarConsultasPaginado(0, 10),
          throwsA(
            isA<ConsultaException>().having(
                  (e) => e.message,
              "message",
              "Erro ao listar consultas paginadas!",
            ),
          ),
        );

        verify(() => consultaDao.listarPaginado(10, 0)).called(1);

        verifyZeroInteractions(pacienteDao);
        verifyZeroInteractions(produtoConsultaDao);
        verifyZeroInteractions(produtoDao);
      },
    );

    test("deve criar consulta completa com sucesso", () async {
      final dto = ConsultaDetails(
        id: 1,
        responsavel: "Gabriel",
        demanda: "Curativo",
        observacao: "Observação teste",
        data: DateTime(2025, 1, 1),
        paciente: Paciente(
          id: 10,
          nome: "João",
          idTipoPaciente: 1,
        ),
        produtos: [
          ConsultaProdutoDetails(
            produto: Produto(
              id: 2,
              nome: "Dipirona",
              estoque: 5,
              idFornecedor: 5,
              idTipoProduto: 5,
            ),
            quantidade: 3,
          ),
        ],
      );

      when(() => consultaDao.inserir(any()))
          .thenAnswer((_) async => 100);

      when(() => produtoConsultaDao.inserir(any()))
          .thenAnswer((_) async {});

      when(() => produtosService.saidaApenasEstoque(2, 3.0))
          .thenAnswer((_) async {});

      when(() => estoqueDao.inserirGerenciadorEstoque(any()))
          .thenAnswer((_) async => 1);

      await service.criarConsultaCompleta(dto);

      verify(() => consultaDao.inserir(any())).called(1);

      verify(() => produtoConsultaDao.inserir(any())).called(1);

      verify(() => produtosService.saidaApenasEstoque(2, 3.0))
          .called(1);

      verify(() => estoqueDao.inserirGerenciadorEstoque(any()))
          .called(1);
    });
  });
}