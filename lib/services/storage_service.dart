import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// خدمة تخزين الصور – ترفع الصور لخدمة خارجية وترجع الرابط
class StorageService {
  StorageService._();

  // مفتاح API لخدمة ImgBB
  static const String _imgBBKey = '045d79d3e3886e915ec3f338a1b2a806';

  /// رفع صورة لخدمة ImgBB
  /// يرجع رابط الصورة في حال النجاح، أو null في حال الفشل
  static Future<String?> uploadImage(File file) async {
    try {
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBBKey');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', file.path));

      final reqResponse = await request.send();
      if (reqResponse.statusCode == 200) {
        final responseData = await reqResponse.stream.bytesToString();
        final jsonResult = json.decode(responseData);
        return jsonResult['data']['url'];
      } else {
        debugPrint('ImgBB Upload Failed: ${reqResponse.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('StorageService Error: $e');
      return null;
    }
  }
}
