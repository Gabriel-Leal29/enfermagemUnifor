import 'package:projeto_enfermagem_desktop/dao/config_dao.dart';

import '../model/config.dart';

class ConfigService {
  final ConfigDao _configDao = ConfigDao();

  Future<void> salvarConfiguracoes(Config config) async{
    try{
      _configDao.salvar(config);
    }on Exception catch(e){
      throw Exception("Erro ao salvar as configurações!");
    }
  }
}