import 'dart:io';

/// النسخة الوهمية لخدمة التعرف على المواد (تعمل على الويب دون التسبب بانهار)
class MaterialClassifier {
  static Future<void> initialize() async {
    // لا تفعل شيئاً على الويب
  }

  static bool get isReady => false;

  static Future<Map<String, double>> classify(File imageFile) async {
    return {};
  }

  static Future<({String detected, double confidence})> detect(File imageFile) async {
    return (detected: 'Not supported on Web', confidence: 0.0);
  }

  static void dispose() {
    // لا تفعل شيئاً على الويب
  }
}
