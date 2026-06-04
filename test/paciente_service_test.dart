import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:projeto_enfermagem_desktop/dao/paciente_dao.dart';
import 'package:projeto_enfermagem_desktop/exceptions/paciente_exception.dart';
import 'package:projeto_enfermagem_desktop/model/paciente.dart';
import 'package:projeto_enfermagem_desktop/service/paciente_service.dart';

class MockPacienteDao extends Mock implements PacienteDao {}

class FakePaciente extends Fake implements Paciente {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePaciente());
  });

  late PacienteService service;
  late MockPacienteDao dao;

  setUp(() {
    dao = MockPacienteDao();

    service = PacienteService(
      dao: dao,
    );
  });

  group("PacienteService", () {

    test("deve cadastrar paciente com sucesso", () async {

      final paciente = Paciente(
        nome: "Gabriel",
        cpf: "52998224725",
        idTipoPaciente: 1,
      );

      when(() => dao.inserir(any()))
          .thenAnswer((_) async => 1);

      await service.salvarPaciente(paciente);

      verify(() => dao.inserir(any())).called(1);

      verifyNever(() => dao.atualizar(any()));
    });

    test("deve editar paciente com sucesso", () async {

      final paciente = Paciente(
        id: 1,
        nome: "Gabriel Editado",
        cpf: "52998224725",
        idTipoPaciente: 1,
      );

      when(() => dao.atualizar(any()))
          .thenAnswer((_) async => 1);

      await service.salvarPaciente(paciente);

      verify(() => dao.atualizar(any())).called(1);

      verifyNever(() => dao.inserir(any()));
    });

    test("deve excluir paciente com sucesso", () async {

      when(() => dao.excluir(1))
          .thenAnswer((_) async => 1);

      await service.excluirPaciente(1);

      verify(() => dao.excluir(1)).called(1);
    });

    test("deve lançar erro quando nome estiver vazio", () async {

      final paciente = Paciente(
        nome: "",
        cpf: "52998224725",
        idTipoPaciente: 1,
      );

      expect(
            () => service.salvarPaciente(paciente),
        throwsA(isA<PacienteException>()),
      );

      verifyNever(() => dao.inserir(any()));
    });

    test("deve lançar erro quando CPF for inválido", () async {

      final paciente = Paciente(
        nome: "Gabriel",
        cpf: "12345678900",
        idTipoPaciente: 1,
      );

      expect(
            () => service.salvarPaciente(paciente),
        throwsA(isA<PacienteException>()),
      );

      verifyNever(() => dao.inserir(any()));
    });

  });
}