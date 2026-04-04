import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:namaa_project_app/services/notification_service.dart';

import 'before_after_history_page.dart';

class BeforeAfterPage extends StatefulWidget {
  final String? editId;
  final Map<String, dynamic>? editData;
  const BeforeAfterPage({super.key, this.editId, this.editData});

  @override
  State<BeforeAfterPage> createState() => _BeforeAfterPageState();
}

class _BeforeAfterPageState extends State<BeforeAfterPage> {
  XFile? beforeImage;
  XFile? afterImage;
  String? existingBefore;
  String? existingAfter;
  final TextEditingController descriptionController = TextEditingController();
  bool isUploading = false;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.editId != null && widget.editData != null) {
      existingBefore = widget.editData!['before'];
      existingAfter = widget.editData!['after'];
      descriptionController.text = widget.editData!['description'] ?? '';
    }
  }

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

  // دالة الرفع إلى ImgBB
  Future<String?> uploadToImgBB(XFile image) async {
    try {
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=045d79d3e3886e915ec3f338a1b2a806');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', image.path));
      
      final reqResponse = await request.send();
      if (reqResponse.statusCode == 200) {
        final responseData = await reqResponse.stream.bytesToString();
        final jsonResult = json.decode(responseData);
        return jsonResult['data']['url'];
      }
      return null;
    } catch (e) {
      debugPrint("ImgBB Error: $e");
      return null;
    }
  }

  // حفظ البيانات في Firestore وزيادة النقاط
  Future<void> uploadInitiative() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if ((beforeImage == null && existingBefore == null) || (afterImage == null && existingAfter == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار صورتي قبل وبعد", style: TextStyle(fontFamily: 'Cairo'))),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      String? beforeUrl = existingBefore;
      if (beforeImage != null) beforeUrl = await uploadToImgBB(beforeImage!);

      String? afterUrl = existingAfter;
      if (afterImage != null) afterUrl = await uploadToImgBB(afterImage!);

      if (beforeUrl != null && afterUrl != null) {
        final Map<String, dynamic> payload = {
          'before': beforeUrl,
          'after': afterUrl,
          'description': descriptionController.text.trim(),
        };

        if (widget.editId != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('initiatives').doc(widget.editId).update(payload);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تعديل المبادرة بنجاح! ✏️", style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF386641)));
        } else {
          payload['timestamp'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('initiatives').add(payload);
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'points': FieldValue.increment(10)});
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم نشر مبادرتك بنجاح! 🎉 +10 نقاط", style: TextStyle(fontFamily: 'Cairo')), backgroundColor: Color(0xFF386641)));
          await NotificationService.send(
            title: '📸 مبادرة جديدة!',
            body: 'تم نشر مبادرتك البيئية بنجاح وحصلت على 10 نقاط ⭐',
            type: 'initiative',
          );
        }

        if (!mounted) return;
        setState(() {
          beforeImage = null;
          afterImage = null;
          existingBefore = null;
          existingAfter = null;
          if (widget.editId == null) descriptionController.clear();
        });
      } else {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("فشل في رفع بعض الصور.", style: TextStyle(fontFamily: 'Cairo'))));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء الرفع: $e", style: const TextStyle(fontFamily: 'Cairo'))));
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BeforeAfterHistoryPage())),
          )
        ],
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
                    : Text(widget.editId != null ? "تعديل المبادرة" : "نشر المبادرة (+10 نقاط)",
                    style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector(String label, XFile? image, bool isBefore) {
    String? existUrl = isBefore ? existingBefore : existingAfter;
    bool hasImage = image != null || existUrl != null;

    DecorationImage? decorImage;
    if (image != null) {
      decorImage = DecorationImage(image: FileImage(File(image.path)), fit: BoxFit.cover);
    } else if (existUrl != null) {
      decorImage = DecorationImage(image: NetworkImage(existUrl), fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: () => pickImage(isBefore),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: hasImage ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF386641).withOpacity(0.2)),
          image: decorImage,
        ),
        child: !hasImage
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