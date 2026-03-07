class BuildStat {
  String name;
  double value;

  BuildStat(this.name, this.value);
}

class BuildAnalyzer {
  List<BuildStat> analyze(List<BuildStat> stats) {
    List<BuildStat> result = [];

    for (int i = 0; i < stats.length; i++) {
      bool found = false;

      for (int j = 0; j < result.length; j++) {
        if (result[j].name == stats[i].name) {
          result[j].value += stats[i].value;
          found = true;
        }
      }

      if (!found) {
        result.add(BuildStat(stats[i].name, stats[i].value));
      }
    }

    return result;
  }

  double getStat(List<BuildStat> stats, String name) {
    for (int i = 0; i < stats.length; i++) {
      if (stats[i].name == name) {
        return stats[i].value;
      }
    }
    return 0;
  }
}