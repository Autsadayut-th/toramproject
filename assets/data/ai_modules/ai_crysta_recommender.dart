class Crysta {
  String name;
  List<BuildStat> stats;

  Crysta(this.name, this.stats);
}

class CrystaRecommendation {
  String current;
  String recommended;
  double score;

  CrystaRecommendation(this.current, this.recommended, this.score);
}

class CrystaRecommender {

  double scoreCrysta(List<String> priority, Crysta crysta) {
    double score = 0;

    for (int i = 0; i < crysta.stats.length; i++) {
      for (int j = 0; j < priority.length; j++) {
        if (crysta.stats[i].name == priority[j]) {
          score += crysta.stats[i].value;
        }
      }
    }

    return score;
  }

  CrystaRecommendation recommend(
    Crysta current,
    List<Crysta> allCrysta,
    List<String> priority,
  ) {

    double bestScore = scoreCrysta(priority, current);
    String bestName = current.name;

    for (int i = 0; i < allCrysta.length; i++) {
      double score = scoreCrysta(priority, allCrysta[i]);

      if (score > bestScore) {
        bestScore = score;
        bestName = allCrysta[i].name;
      }
    }

    return CrystaRecommendation(
      current.name,
      bestName,
      bestScore,
    );
  }
}