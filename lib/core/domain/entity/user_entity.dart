import 'package:macrotracker/core/data/dbo/user_dbo.dart';
import 'package:macrotracker/core/domain/entity/user_gender_entity.dart';
import 'package:macrotracker/core/domain/entity/user_pal_entity.dart';
import 'package:macrotracker/core/domain/entity/user_weight_goal_entity.dart';

class UserEntity {
  DateTime birthday;
  double heightCM;
  double weightKG;
  String? profileImagePath;
  UserGenderEntity gender;
  UserWeightGoalEntity goal;
  UserPALEntity pal;

  UserEntity(
      {required this.birthday,
      required this.heightCM,
      required this.weightKG,
      this.profileImagePath,
      required this.gender,
      required this.goal,
      required this.pal});

  factory UserEntity.fromUserDBO(UserDBO userDBO) {
    return UserEntity(
        birthday: userDBO.birthday,
        heightCM: userDBO.heightCM,
        weightKG: userDBO.weightKG,
        profileImagePath: userDBO.profileImagePath,
        gender: UserGenderEntity.fromUserGenderDBO(userDBO.gender),
        goal: UserWeightGoalEntity.fromUserWeightGoalDBO(userDBO.goal),
        pal: UserPALEntity.fromUserPALDBO(userDBO.pal));
  }

  int get age => DateTime.now().difference(birthday).inDays ~/ 365;
}
