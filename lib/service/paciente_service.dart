import '../dao/paciente_dao.dart';
import '../exceptions/paciente_exception.dart';
import '../model/paciente.dart';

class PacienteService {
  final PacienteDao _dao = PacienteDao();

  Future<void> salvarPaciente(Paciente paciente) async {
    
    if (paciente.nome.trim().isEmpty) {
      throw PacienteException("O nome do paciente é obrigatório.");
    }
    
    if (paciente.cpf.trim().isEmpty) {
      throw PacienteException("O CPF é obrigatório.");
    }

    try {
      if (paciente.id == null) {
        
        await _dao.inserir(paciente);
      } else {
        // se tem ID, é edição
        await _dao.atualizar(paciente);
      }
    } catch (e) {
      // captura o erro do SQLite caso o CPF já exista na tabela (regra UNIQUE)
      if (e.toString().contains('UNIQUE constraint failed: paciente.cpf')) {
        throw PacienteException("Já existe um paciente cadastrado com este CPF.");
      }
      throw PacienteException("Erro ao salvar o paciente. Tente novamente.");
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