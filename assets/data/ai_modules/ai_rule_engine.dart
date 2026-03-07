import 'dart:convert';

class AIRuleEngine {

  final Map<String, dynamic> buildRules;

  AIRuleEngine({
    required this.buildRules,
  });

  /*
  ===============================
  วิเคราะห์ Build
  ===============================
  */

  Map<String, dynamic> analyzeBuild({
    required Map<String, num> stats,
    required String buildType,
  }) {

    if (!buildRules.containsKey("build_evaluation")) {
      return {"error": "build_evaluation rules not found"};
    }

    final builds = buildRules["build_evaluation"];

    if (!builds.containsKey(buildType)) {
      return {"error": "build type not found"};
    }

    final rule = builds[buildType];

    List<String> problems = [];
    List<String> goodPoints = [];

    /*
    ===============================
    Required Stats
    ===============================
    */

    if (rule.containsKey("required")) {
      Map<String, dynamic> required = rule["required"];

      required.forEach((stat, value) {

        num playerStat = stats[stat] ?? 0;

        if (playerStat < value) {
          problems.add("$stat ต่ำกว่าที่ต้องการ ($playerStat / $value)");
        } else {
          goodPoints.add("$stat ถึงค่าที่ต้องการ");
        }

      });
    }

    /*
    ===============================
    Recommended Stats
    ===============================
    */

    if (rule.containsKey("recommended")) {
      Map<String, dynamic> recommended = rule["recommended"];

      recommended.forEach((stat, value) {

        num playerStat = stats[stat] ?? 0;

        if (playerStat < value) {
          problems.add("$stat ควรเพิ่ม ($playerStat / $value)");
        } else {
          goodPoints.add("$stat อยู่ในระดับดี");
        }

      });
    }

    /*
    ===============================
    Range Stats
    ===============================
    */

    if (rule.containsKey("stats")) {

      Map<String, dynamic> statsRules = rule["stats"];

      statsRules.forEach((stat, data) {

        num playerStat = stats[stat] ?? 0;

        num minimum = data["minimum"] ?? 0;
        num ideal = data["ideal"] ?? minimum;

        if (playerStat < minimum) {

          problems.add(
              "$stat ต่ำเกินไป ($playerStat / minimum $minimum)");

        } else if (playerStat < ideal) {

          problems.add(
              "$stat ยังไม่ถึงระดับ ideal ($playerStat / $ideal)");

        } else {

          goodPoints.add("$stat อยู่ในระดับ ideal");

        }

      });

    }

    /*
    ===============================
    Priority Stats
    ===============================
    */

    List<String> priority = [];

    if (rule.containsKey("priority_stats")) {
      priority = List<String>.from(rule["priority_stats"]);
    }

    return {

      "build_type": buildType,
      "problems": problems,
      "good_points": goodPoints,
      "priority_stats": priority,

    };

  }

  /*
  ===============================
  หา Stat ที่ขาด
  ===============================
  */

  List<String> findMissingStats({
    required Map<String, num> stats,
    required String buildType,
  }) {

    List<String> missing = [];

    final result = analyzeBuild(
      stats: stats,
      buildType: buildType,
    );

    if (result.containsKey("priority_stats")) {

      List<String> priority = result["priority_stats"];

      for (var stat in priority) {

        if (!stats.containsKey(stat) || stats[stat] == 0) {
          missing.add(stat);
        }

      }

    }

    return missing;

  }

}