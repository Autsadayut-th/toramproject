import 'ai_crysta_recommender.dart';

class AIExplanationEngine {

  String shortExplain(CrystaRecommendation rec) {
    if (rec.current == rec.recommended) {
      return "Crysta ปัจจุบันเหมาะสมแล้ว";
    }

    return "แนะนำเปลี่ยน ${rec.current} → ${rec.recommended}";
  }

  String fullExplain(
    CrystaRecommendation rec,
    List<String> priorityStats,
  ) {

    String text = "";

    if (rec.current == rec.recommended) {
      return "Crysta ปัจจุบันเหมาะกับ build นี้แล้ว";
    }

    text += "AI Recommendation\n";
    text += "${rec.current} → ${rec.recommended}\n\n";

    text += "เหตุผล\n";

    for (int i = 0; i < priorityStats.length; i++) {
      text += "- Build นี้เน้น ${priorityStats[i]}\n";
    }

    text += "\nCrysta ที่แนะนำให้ค่า stat ที่เหมาะสมกว่า";

    return text;
  }
}