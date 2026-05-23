import 'package:cpf_cnpj_validator/cpf_validator.dart';
import '../dao/paciente_dao.dart';
import '../exceptions/paciente_exception.dart';
import '../model/paciente.dart';

class PacienteService {
  final PacienteDao _dao = PacienteDao();

  Future<void> salvarPaciente(Paciente paciente) async {
    
    if (paciente.nome.trim().isEmpty) {
      throw PacienteException("O nome do paciente é obrigatório.");
    }
    
    
    if (paciente.cpf != null && paciente.cpf!.trim().isNotEmpty && !CPFValidator.isValid(paciente.cpf!)) {
      throw PacienteException("O CPF informado é inválido.");
    }

    try {
      if (paciente.id == null) {
        await _dao.inserir(paciente);
      } else {
        await _dao.atualizar(paciente);
      }
} catch (e) {
      if (e.toString().contains('UNIQUE constraint failed: paciente.cpf')) {
        throw PacienteException("Já existe um paciente cadastrado com este CPF.");
      }
      
      throw PacienteException("ERRO REAL: ${e.toString()}");
    }
  }

  Future<List<Paciente>> buscarPacientes() async {
    try {
      return await _dao.listarTodos();
    } catch (e) {
      throw PacienteException("Erro ao buscar a lista de pacientes.");
    }
  }

  Future<void> excluirPaciente(int id) async {
    try {
      await _dao.excluir(id);
    } catch (e) {
      throw PacienteException("Erro ao excluir o paciente.");
    }
  }
}