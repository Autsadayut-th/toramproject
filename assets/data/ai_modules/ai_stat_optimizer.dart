class AIStatOptimizer {
  Map<String, dynamic> optimizeStats({
    required String weaponType,
    required Map<String, int> stats,
  }) {
    int str = stats["STR"] ?? 0;
    int dex = stats["DEX"] ?? 0;
    int agi = stats["AGI"] ?? 0;
    int intStat = stats["INT"] ?? 0;

    Map<String, dynamic> result = {};

    if (weaponType == "Two-Handed Sword") {
      result["recommended"] = ["STR", "DEX"];
      result["reason"] = "Two-Handed Sword scales mainly with STR.";
    } else if (weaponType == "Katana") {
      result["recommended"] = ["DEX", "STR"];
      result["reason"] = "Katana gains ATK and stability from DEX.";
    } else if (weaponType == "Bow") {
      result["recommended"] = ["DEX", "STR"];
      result["reason"] = "Bow primary stat is DEX.";
    } else if (weaponType == "Staff") {
      result["recommended"] = ["INT"];
      result["reason"] = "Staff scales with INT for MATK.";
    } else if (weaponType == "Halberd") {
      result["recommended"] = ["STR", "AGI"];
      result["reason"] = "Halberd benefits from STR and AGI.";
    } else {
      result["recommended"] = ["STR"];
      result["reason"] = "Default recommendation.";
    }

    return result;
  }
}