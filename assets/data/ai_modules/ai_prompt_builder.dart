class AIPromptBuilder {
  String buildCrystaRecommendationPrompt({
    required String weaponType,
    required List<String> equippedCrysta,
    required Map<String, dynamic> stats,
    required String targetStat,
  }) {
    String prompt = "";

    prompt += "You are a Toram Online build assistant.\n";
    prompt += "Analyze the player build and recommend improvements.\n\n";

    prompt += "Player Weapon: $weaponType\n";

    prompt += "\nPlayer Stats:\n";

    stats.forEach((key, value) {
      prompt += "$key : $value\n";
    });

    prompt += "\nEquipped Crysta:\n";

    for (int i = 0; i < equippedCrysta.length; i++) {
      prompt += "- ${equippedCrysta[i]}\n";
    }

    prompt += "\nPlayer Goal:\n";
    prompt += "Focus on improving: $targetStat\n";

    prompt += "\nInstructions:\n";
    prompt += "1. Recommend better crysta if possible\n";
    prompt += "2. Suggest upgrade path if crysta has upgrade\n";
    prompt += "3. Explain advantages and disadvantages\n";
    prompt += "4. Keep explanation beginner friendly\n";

    return prompt;
  }
}