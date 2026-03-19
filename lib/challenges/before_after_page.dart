import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  // ✅ تعديل 3: إضافة dispose للـ controller
  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage(bool isBefore) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() {
        if (isBefore) {
          beforeImage = image;
        } else {
          afterImage = image;
        }
      });
    }
  }

  Future<void> uploadInitiative() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (beforeImage == null || afterImage == null) {
      // mounted مضمون هنا لأننا قبل أي await
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار صورتي قبل وبعد")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(
        'initiatives/${user.uid}/${DateTime.now().millisecondsSinceEpoch}',
      );

      final beforeRef = storageRef.child('before.jpg');
      final afterRef = storageRef.child('after.jpg');

      await beforeRef.putFile(File(beforeImage!.path));
      await afterRef.putFile(File(afterImage!.path));

      final beforeUrl = await beforeRef.getDownloadURL();
      final afterUrl = await afterRef.getDownloadURL();

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('initiatives')
          .doc();

      await docRef.set({
        'before': beforeUrl,
        'after': afterUrl,
        'description': descriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      final userDoc =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        int currentPoints = snapshot.data()?['points'] ?? 0;
        transaction.update(userDoc, {'points': currentPoints + 10});
      });

      // ✅ تعديل 1: mounted check بعد كل await
      if (!mounted) return;

      setState(() {
        beforeImage = null;
        afterImage = null;
        descriptionController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🎉 تم رفع المبادرة وإضافة 10 نقاط!"),
          backgroundColor: Color(0xFF386641),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // ✅ تعديل 1: mounted check في catch
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ أثناء الرفع: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  Widget _buildImagePlaceholder(
      String label,
      XFile? image,
      bool isBefore,
      ) {
    return GestureDetector(
      onTap: isUploading ? null : () => pickImage(isBefore),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: image == null
              ? (isBefore ? Colors.grey.shade300 : Colors.green.shade100)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400),
          image: image != null
              ? DecorationImage(
            image: FileImage(File(image.path)),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: image == null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBefore ? Icons.history : Icons.auto_awesome,
                size: 50,
                color: Colors.grey.shade600,
              ),
              const SizedBox(height: 10),
              Text(
                "اضغط لإضافة صورة $label",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        title: const Text(
          "قبل وبعد نماء ✨",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF386641),
        // ✅ تعديل 2: لون سهم الرجوع
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "وثّق تغييرك الإيجابي! 📸",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF386641),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "شارك صوراً لمبادراتك البيئية وشاهد الفرق.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: _buildImagePlaceholder("قبل", beforeImage, true),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildImagePlaceholder("بعد", afterImage, false),
                ),
              ],
            ),

            const SizedBox(height: 30),
            TextField(
              controller: descriptionController,
              enabled: !isUploading,
              decoration: const InputDecoration(
                labelText: "وصف المبادرة (اختياري)",
                hintText: "مثلاً: تنظيف حديقة الحي",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF386641),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: isUploading ? null : uploadInitiative,
                icon: isUploading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.cloud_upload, color: Colors.white),
                label: Text(
                  isUploading ? "جارٍ الرفع..." : "نشر المبادرة",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}