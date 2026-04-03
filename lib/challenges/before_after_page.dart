import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class BeforeAfterPage extends StatefulWidget {
  const BeforeAfterPage({super.key});

  @override
  State<BeforeAfterPage> createState() => _BeforeAfterPageState();
}

class _BeforeAfterPageState extends State<BeforeAfterPage> {
  XFile? beforeImage;
  XFile? afterImage;
  final TextEditingController descriptionController = TextEditingController();
  bool isUploading = false;
  final ImagePicker picker = ImagePicker();

  // ✅ تم تحديث الـ Cloud Name الخاص بك هنا
  final String cloudName = "hovp9qqg";

  // ⚠️ استبدل هذه القيمة بالـ Preset الذي أنشأته (تأكد أنه Unsigned)
  final String uploadPreset = "your_unsigned_preset";

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  // اختيار الصورة
  Future<void> pickImage(bool isBefore) async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // ضغط الصورة لسرعة الرفع
    );
    if (image != null) {
      setState(() {
        if (isBefore) {
          beforeImage = image;
        } else {
          afterImage = image;
        }
      });
    }
  }

  // دالة الرفع إلى Cloudinary
  Future<String?> uploadToCloudinary(XFile image) async {
    try {
      var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      var request = http.MultipartRequest("POST", uri);

      var file = await http.MultipartFile.fromPath('file', image.path);
      request.files.add(file);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'namaa_initiatives';

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonRes = jsonDecode(responseString);
        return jsonRes['secure_url'];
      } else {
        debugPrint("خطأ في Cloudinary: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("فشل الرفع: $e");
      return null;
    }
  }

  // حفظ البيانات في Firestore وزيادة النقاط
  Future<void> uploadInitiative() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (beforeImage == null || afterImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار صورتي قبل وبعد")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      // 1. رفع الصور لـ Cloudinary
      String? beforeUrl = await uploadToCloudinary(beforeImage!);
      String? afterUrl = await uploadToCloudinary(afterImage!);

      if (beforeUrl != null && afterUrl != null) {
        // 2. تخزين الروابط في Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('initiatives')
            .add({
          'before': beforeUrl,
          'after': afterUrl,
          'description': descriptionController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 3. تحديث نقاط المستخدم (+10 نقاط)
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'points': FieldValue.increment(10),
        });

        if (!mounted) return;

        setState(() {
          beforeImage = null;
          afterImage = null;
          descriptionController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم نشر مبادرتك بنجاح! 🎉 +10 نقاط"),
            backgroundColor: Color(0xFF386641),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء الرفع: $e")),
      );
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        title: const Text("قبل وبعد ✨",
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "وثّق تغييرك البيئي",
              style: TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1F)),
            ),
            const SizedBox(height: 25),

            // مربعات اختيار الصور
            Row(
              children: [
                Expanded(child: _buildImageSelector("قبل 🕰️", beforeImage, true)),
                const SizedBox(width: 15),
                Expanded(child: _buildImageSelector("بعد ✨", afterImage, false)),
              ],
            ),

            const SizedBox(height: 30),

            // حقل الوصف
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "أخبرنا ماذا فعلت؟ (مثلاً: تنظيف حديقة...)",
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // زر النشر
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386641),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: isUploading ? null : uploadInitiative,
                child: isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("نشر المبادرة (+10 نقاط)",
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector(String label, XFile? image, bool isBefore) {
    return GestureDetector(
      onTap: () => pickImage(isBefore),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: image == null ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF386641).withOpacity(0.2)),
          image: image != null
              ? DecorationImage(image: FileImage(File(image.path)), fit: BoxFit.cover)
              : null,
        ),
        child: image == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, color: Color(0xFF386641), size: 35),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey, fontSize: 12)),
          ],
        )
            : null,
      ),
    );
  }
}