class AIBuildPipeline {

  final dynamic statCalculator;
  final dynamic ruleEngine;
  final dynamic buildAnalyzer;
  final dynamic statOptimizer;
  final dynamic crystaRecommender;
  final dynamic equipmentRecommender;
  final dynamic upgradePathFinder;
  final dynamic explanationEngine;

  AIBuildPipeline({
    required this.statCalculator,
    required this.ruleEngine,
    required this.buildAnalyzer,
    required this.statOptimizer,
    required this.crystaRecommender,
    required this.equipmentRecommender,
    required this.upgradePathFinder,
    required this.explanationEngine,
  });

  /*
  ===============================
  วิเคราะห์ Build ทั้งระบบ
  ===============================
  */

  Map<String, dynamic> analyzeFullBuild({

    required Map<String, num> characterStats,
    required List<Map<String, num>> equipments,
    required List<Map<String, num>> crystas,
    required List<Map<String, num>> avatars,
    required Map<String, num> personalStats,
    required String buildType,

  }) {

    /*
    ===============================
    รวม Equipment Stats
    ===============================
    */

    Map<String, num> equipmentStats =
        statCalculator.combineEquipmentStats(equipments);

    /*
    ===============================
    รวม Crysta Stats
    ===============================
    */

    Map<String, num> crystaStats =
        statCalculator.combineCrystaStats(crystas);

    /*
    ===============================
    รวม Avatar Stats
    ===============================
    */

    Map<String, num> avatarStats =
        statCalculator.combineAvatarStats(avatars);

    /*
    ===============================
    คำนวณ Final Stats
    ===============================
    */

    Map<String, num> finalStats =
        statCalculator.calculateBuildStats(

      characterStats: characterStats,
      equipmentStats: equipmentStats,
      crystaStats: crystaStats,
      avatarStats: avatarStats,
      personalStats: personalStats,

    );

    /*
    ===============================
    วิเคราะห์ Build
    ===============================
    */

    Map<String, dynamic> buildAnalysis =
        buildAnalyzer.analyzeBuild(
      stats: finalStats,
      buildType: buildType,
    );

    /*
    ===============================
    หา Stat ที่ขาด
    ===============================
    */

    List<String> missingStats =
        statOptimizer.findMissingStats(
      stats: finalStats,
      buildType: buildType,
    );

    /*
    ===============================
    แนะนำ Crysta
    ===============================
    */

    List crystaSuggestions =
        crystaRecommender.recommendCrysta(
      missingStats: missingStats,
      currentCrystas: crystas,
    );

    /*
    ===============================
    หา Upgrade Path
    ===============================
    */

    List upgradePaths =
        upgradePathFinder.findUpgradePaths(
      currentCrystas: crystas,
    );

    /*
    ===============================
    แนะนำ Equipment
    ===============================
    */

    List equipmentSuggestions =
        equipmentRecommender.recommendEquipment(
      missingStats: missingStats,
    );

    /*
    ===============================
    สร้าง AI Explanation
    ===============================
    */

    String explanation =
        explanationEngine.generateExplanation(

      buildType: buildType,
      stats: finalStats,
      missingStats: missingStats,
      crystaSuggestions: crystaSuggestions,
      equipmentSuggestions: equipmentSuggestions,

    );

    /*
    ===============================
    Result
    ===============================
    */

    return {

      "final_stats": finalStats,

      "build_analysis": buildAnalysis,

      "missing_stats": missingStats,

      "crysta_recommendations": crystaSuggestions,

      "equipment_recommendations": equipmentSuggestions,

      "upgrade_paths": upgradePaths,

      "ai_explanation": explanation,

    };

  }

}