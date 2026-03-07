import 'dart:convert';
import 'package:http/http.dart' as http;

class AIGeminiService {
  final String apiKey;

  static const String _endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";

  AIGeminiService({
    required this.apiKey,
  });

  /// ส่ง prompt ไปยัง Gemini และรับข้อความตอบกลับ
  Future<String> generateText(String prompt) async {
    try {
      final uri = Uri.parse("$_endpoint?key=$apiKey");

      final response = await http
          .post(
            uri,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {"text": prompt}
                  ]
                }
              ]
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception(
            "Gemini API error: ${response.statusCode} ${response.body}");
      }

      final data = jsonDecode(response.body);

      final text =
          data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ?? "";

      if (text.isEmpty) {
        return "AI ไม่สามารถสร้างคำตอบได้";
      }

      return text;
    } catch (e) {
      return "AI Error: $e";
    }
  }

  /// สร้างคำอธิบาย Build
  Future<String> generateBuildExplanation({
    required String buildSummary,
  }) async {
    final prompt = """
คุณคือ AI ผู้ช่วยสำหรับเกม Toram Online

อธิบาย Build นี้ให้ผู้เล่นมือใหม่เข้าใจง่าย

Build:
$buildSummary

อธิบาย
- จุดเด่น
- จุดอ่อน
- เหมาะกับผู้เล่นสายไหน

ตอบแบบกระชับ
""";

    return generateText(prompt);
  }

  /// สร้างคำแนะนำคริสตัล
  Future<String> generateCrystaAdvice({
    required String currentCrysta,
    required String suggestedCrysta,
  }) async {
    final prompt = """
เกม Toram Online

คริสตัลปัจจุบัน:
$currentCrysta

คริสตัลที่แนะนำ:
$suggestedCrysta

อธิบายว่าทำไมคริสตัลใหม่ดีกว่า
และเหมาะกับสาย build แบบไหน
""";

    return generateText(prompt);
  }

  /// อธิบาย Build แบบสั้น
  Future<String> generateShortTip(String context) async {
    final prompt = """
คุณคือ AI ผู้ช่วย Toram Online

ให้คำแนะนำสั้นๆเกี่ยวกับ

$context

ไม่เกิน 2 ประโยค
""";

    return generateText(prompt);
  }
}