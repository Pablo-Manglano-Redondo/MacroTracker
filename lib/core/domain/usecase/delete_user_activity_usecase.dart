import 'package:macrotracker/core/data/repository/user_activity_repository.dart';
import 'package:macrotracker/core/domain/entity/user_activity_entity.dart';
import 'package:macrotracker/core/domain/usecase/add_config_usecase.dart';

class DeleteUserActivityUsecase {
  final UserActivityRepository _userActivityRepository;
  final AddConfigUsecase _addConfigUsecase;

  DeleteUserActivityUsecase(
    this._userActivityRepository,
    this._addConfigUsecase,
  );

  Future<void> deleteUserActivity(UserActivityEntity activityEntity) async {
    if (activityEntity.source == UserActivitySourceEntity.healthConnect &&
        activityEntity.externalId != null &&
        activityEntity.externalId!.isNotEmpty) {
      await _addConfigUsecase.addDiscardedHealthConnectActivityId(
        activityEntity.externalId!,
      );
    }
    await _userActivityRepository.deleteUserActivity(activityEntity);
  }
}
