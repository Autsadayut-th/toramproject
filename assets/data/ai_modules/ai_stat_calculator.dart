class AIStatCalculator {

  /*
  ===============================
  รวม Stat หลาย Map
  ===============================
  */

  Map<String, num> mergeStats(List<Map<String, num>> statSources) {

    Map<String, num> result = {};

    for (var source in statSources) {

      source.forEach((stat, value) {

        if (!result.containsKey(stat)) {
          result[stat] = value;
        } else {
          result[stat] = result[stat]! + value;
        }

      });

    }

    return result;

  }

  /*
  ===============================
  คำนวณ Final Build Stats
  ===============================
  */

  Map<String, num> calculateBuildStats({

    required Map<String, num> characterStats,
    required Map<String, num> equipmentStats,
    required Map<String, num> crystaStats,
    required Map<String, num> avatarStats,
    required Map<String, num> personalStats,

  }) {

    return mergeStats([
      characterStats,
      equipmentStats,
      crystaStats,
      avatarStats,
      personalStats,
    ]);

  }

  /*
  ===============================
  รวม Equipment Stats
  ===============================
  */

  Map<String, num> combineEquipmentStats(
      List<Map<String, num>> equipments) {

    Map<String, num> result = {};

    for (var item in equipments) {

      item.forEach((stat, value) {

        if (!result.containsKey(stat)) {
          result[stat] = value;
        } else {
          result[stat] = result[stat]! + value;
        }

      });

    }

    return result;

  }

  /*
  ===============================
  รวม Crysta Stats
  ===============================
  */

  Map<String, num> combineCrystaStats(
      List<Map<String, num>> crystas) {

    Map<String, num> result = {};

    for (var crysta in crystas) {

      crysta.forEach((stat, value) {

        if (!result.containsKey(stat)) {
          result[stat] = value;
        } else {
          result[stat] = result[stat]! + value;
        }

      });

    }

    return result;

  }

  /*
  ===============================
  รวม Avatar Stats
  ===============================
  */

  Map<String, num> combineAvatarStats(
      List<Map<String, num>> avatars) {

    Map<String, num> result = {};

    for (var stat in avatars) {

      stat.forEach((key, value) {

        if (!result.containsKey(key)) {
          result[key] = value;
        } else {
          result[key] = result[key]! + value;
        }

      });

    }

    return result;

  }

}