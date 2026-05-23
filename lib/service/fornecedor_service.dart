import '../dao/fornecedor_dao.dart';
import '../exceptions/fornecedor_exception.dart';
import '../model/fornecedor.dart';

class FornecedorService {
  final FornecedorDao _dao = FornecedorDao();

  Future<void> salvarFornecedor(Fornecedor fornecedor) async {
    if (fornecedor.nome.trim().isEmpty) {
      throw FornecedorException("O nome fantasia do fornecedor é obrigatório.");
    }
    
    
    if (fornecedor.cnpj != null && fornecedor.cnpj!.trim().isNotEmpty) {
      if (!_isCnpjAlfanumericoValido(fornecedor.cnpj!)) {
        throw FornecedorException("O CNPJ informado é inválido.");
      }
    }

    try {
      if (fornecedor.id == null) {
        await _dao.inserir(fornecedor);
      } else {
        await _dao.atualizar(fornecedor);
      }
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed: fornecedor.cnpj')) {
        throw FornecedorException("Já existe um fornecedor cadastrado com este CNPJ.");
      }
      throw FornecedorException("Erro ao salvar o fornecedor. Tente novamente.");
    }
  }

  
  bool _isCnpjAlfanumericoValido(String cnpjOriginal) {
    String cnpj = cnpjOriginal.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
    
    if (cnpj.length != 14) return false;

    
    if (!RegExp(r'^[0-9]{2}$').hasMatch(cnpj.substring(12))) return false;

    List<int> pesos1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    List<int> pesos2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    
    int soma1 = 0;
    for (int i = 0; i < 12; i++) {
      int valor = cnpj.codeUnitAt(i) - 48; 
      soma1 += valor * pesos1[i];
    }
    int resto1 = soma1 % 11;
    int digito1 = resto1 < 2 ? 0 : 11 - resto1;
    if (int.parse(cnpj[12]) != digito1) return false;

    
    int soma2 = 0;
    for (int i = 0; i < 13; i++) {
      int valor = cnpj.codeUnitAt(i) - 48;
      soma2 += valor * pesos2[i];
    }
    int resto2 = soma2 % 11;
    int digito2 = resto2 < 2 ? 0 : 11 - resto2;
    if (int.parse(cnpj[13]) != digito2) return false;

    return true;
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