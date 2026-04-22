import '../dao/fornecedor_dao.dart';
import '../exceptions/fornecedor_exception.dart';
import '../model/fornecedor.dart';

class FornecedorService {
  final FornecedorDao _dao = FornecedorDao();

  Future<void> salvarFornecedor(Fornecedor fornecedor) async {
    if (fornecedor.nome.trim().isEmpty) {
      throw FornecedorException("O nome fantasia do fornecedor é obrigatório.");
    }
    
    if (fornecedor.cnpj.trim().isEmpty) {
      throw FornecedorException("O CNPJ é obrigatório.");
    }

    try {
      if (fornecedor.id == null) {
        await _dao.inserir(fornecedor);
      } else {
        await _dao.atualizar(fornecedor);
      }
    } catch (e) {
      // barra CNPJ duplicado usando a trava do SQLite
      if (e.toString().contains('UNIQUE constraint failed: fornecedor.cnpj')) {
        throw FornecedorException("Já existe um fornecedor cadastrado com este CNPJ.");
      }
      throw FornecedorException("Erro ao salvar o fornecedor. Tente novamente.");
    }
  }

  Future<List<Fornecedor>> buscarFornecedores() async {
    try {
      return await _dao.listarTodos();
    } catch (e) {
      throw FornecedorException("Erro ao buscar a lista de fornecedores.");
    }
  }

  Future<void> excluirFornecedor(int id) async {
    try {
      await _dao.excluir(id);
    } catch (e) {
      throw FornecedorException("Erro ao excluir o fornecedor.");
    }
  }
}