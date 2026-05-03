import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// خدمة التعرف على نوع المادة بالصورة باستخدام Teachable Machine
class MaterialClassifier {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static const int _inputSize = 224; // Teachable Machine default

  /// تحميل الموديل والتسميات
  static Future<void> initialize() async {
    if (_interpreter != null) return; // محمّل مسبقاً

    try {
      _interpreter = await Interpreter.fromAsset('ml/model.tflite');

      final labelsData = await rootBundle.loadString('assets/ml/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('MaterialClassifier init error: $e');
    }
  }

  /// هل الموديل جاهز؟
  static bool get isReady => _interpreter != null && _labels != null;

  /// تصنيف صورة وإرجاع النتائج
  /// يرجع `Map<String, double>` مثل: {'plastic': 0.95, 'metal': 0.03, ...}
  static Future<Map<String, double>> classify(File imageFile) async {
    try {
      if (!isReady) {
        await initialize();
        if (!isReady) return {};
      }

      // 1. قراءة وتحويل الصورة
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return {};

      // 2. تصغير الصورة لـ 224x224 (حجم Teachable Machine الافتراضي)
      final resized = img.copyResize(image, width: _inputSize, height: _inputSize);

      // 3. تحويل الصورة لمصفوفة أرقام [1, 224, 224, 3]
      final input = Float32List(_inputSize * _inputSize * 3);
      int idx = 0;
      for (int y = 0; y < _inputSize; y++) {
        for (int x = 0; x < _inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          // Teachable Machine تتوقع قيم بين 0 و 1
          input[idx++] = pixel.r / 255.0; // Red
          input[idx++] = pixel.g / 255.0; // Green
          input[idx++] = pixel.b / 255.0; // Blue
        }
      }

      final inputTensor = input.reshape([1, _inputSize, _inputSize, 3]);

      // 4. تشغيل الموديل
      final output = List.filled(_labels!.length, 0.0).reshape([1, _labels!.length]);
      _interpreter!.run(inputTensor, output);

      // 5. تحويل النتائج لـ Map
      final results = <String, double>{};
      for (int i = 0; i < _labels!.length; i++) {
        results[_labels![i]] = output[0][i];
      }

      return results;
    } catch (e) {
      debugPrint('MaterialClassifier classify error: $e');
      return {};
    }
  }

  /// التحقق من تطابق الصورة مع المادة المختارة أو اكتشاف المادة تلقائياً
  /// يرجع (detected material, confidence)
  static Future<({String detected, double confidence})> detect(File imageFile) async {
    final results = await classify(imageFile);
    if (results.isEmpty) {
      return (detected: 'unknown', confidence: 0.0);
    }

    // ترتيب النتائج من الأعلى ثقة للأقل
    final sorted = results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return (
      detected: sorted.first.key,
      confidence: sorted.first.value,
    );
  }

  /// تنظيف الموارد من الذاكرة
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
