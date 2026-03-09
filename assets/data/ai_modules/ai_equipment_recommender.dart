class AIEquipmentRecommender {
  List<Map<String, dynamic>> recommendEquipment({
    required List<Map<String, dynamic>> items,
    required String targetStat,
  }) {
    List<Map<String, dynamic>> results = [];

    for (int i = 0; i < items.length; i++) {
      Map<String, dynamic> item = items[i];

      if (item.containsKey("stats")) {
        List<dynamic> stats = item["stats"];

        for (int j = 0; j < stats.length; j++) {
          Map<String, dynamic> stat = stats[j];

          if (stat["stat"] == targetStat) {
            results.add(item);
            break;
          }
        }
      }
    }

    return results;
  }
}