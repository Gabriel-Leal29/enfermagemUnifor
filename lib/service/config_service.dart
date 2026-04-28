import 'package:printing/printing.dart';
import 'package:projeto_enfermagem_desktop/dao/config_dao.dart';
import 'package:projeto_enfermagem_desktop/exceptions/config_exception.dart';

import '../model/config.dart';

class ConfigService {
  final ConfigDao _configDao = ConfigDao();

  Future<void> salvarConfiguracoes(Config config) async{
    try{
      _configDao.salvar(config);
    }on ConfigException catch(e){
      throw ConfigException("Erro ao salvar as configurações");
    }
  }

  Future<Config?> buscarConfiguracoes() async{
    try{
      return await _configDao.getConfig();
    }on ConfigException catch(e){
      throw ConfigException("Erro buscar as configurações armazenadas");
    }
  }

  Future<List<Printer>> listarImpressoras() async{
    try{
      final impressoras = Printing.listPrinters();
      return impressoras;
    }on ConfigException catch(e){
      throw ConfigException("Erro ao buscar as impressoras");
    }
  }

  Future<String?> nomeImpressoraSelecionada() async {
      try{
        final impressoraNome = await _configDao.getImpressora();
        return impressoraNome;
      }on ConfigException catch(e){
        throw ConfigException("Erro ao buscar a impressora");
      }
  }
}