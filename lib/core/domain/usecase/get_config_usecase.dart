import 'package:macrotracker/core/data/repository/config_repository.dart';
import 'package:macrotracker/core/domain/entity/config_entity.dart';

class GetConfigUsecase {
  final ConfigRepository _configRepository;

  GetConfigUsecase(this._configRepository);

  Future<ConfigEntity> getConfig() async {
    return await _configRepository.getConfig();
  }
}
