import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

class RecycleMaterialsPage extends StatefulWidget {
  const RecycleMaterialsPage({super.key});
  static const String routeName = '/recycle';

  @override
  State<RecycleMaterialsPage> createState() => _RecycleMaterialsPageState();
}

class _RecycleMaterialsPageState extends State<RecycleMaterialsPage> {
  String selectedType = "بلاستيك";
  final List<String> materialTypes = [
    "بلاستيك",
    "ورق",
    "زجاج",
    "إلكترونيات",
    "معادن",
  ];
  final TextEditingController descriptionController = TextEditingController();
  File? selectedImage;
  bool isSubmitting = false;
  Position? _currentPosition;
  bool _isLocating = false;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'خدمات الموقع معطلة. يرجى تفعيل الـ GPS.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw 'تم رفض صلاحية الوصول للموقع.';
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'صلاحية الموقع مرفوضة دائماً. يجب السماح بها من الإعدادات.';
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _currentPosition = position);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('📍 تم تحديد الموقع بنجاح!'), backgroundColor: Colors.green.shade700)
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() => selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("خطأ في التقاط الصورة: $e");
    }
  }

  Future<void> submitMaterial() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى تسجيل الدخول أولاً")),
        );
      }
      return;
    }

    if (_currentPosition == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("يرجى تحديد موقعك أولاً 📍 ليتمكن المندوب من استلام المواد"),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => isSubmitting = true);

    try {
      String? photoUrl;
      if (selectedImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('recycled_materials')
            .child(user.uid)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
            
        await ref.putFile(selectedImage!);
        photoUrl = await ref.getDownloadURL();
      }

      final userDoc =
      FirebaseFirestore.instance.collection('users').doc(user.uid);
      const int pointsToAdd = 20;

      await userDoc.update({
        'points': FieldValue.increment(pointsToAdd),
      });

      await FirebaseFirestore.instance.collection('recycled_materials').add({
        'userId': user.uid,
        'type': selectedType,
        'description': descriptionController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'photoUrl': photoUrl,
        'location': {
          'lat': _currentPosition!.latitude,
          'lng': _currentPosition!.longitude,
        },
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("♻️ تم إرسال المادة! +20 نقطة"),
          backgroundColor: Colors.green.shade700,
        ),
      );

      setState(() {
        selectedImage = null;
        descriptionController.clear();
        selectedType = materialTypes[0];
        _currentPosition = null;
        isSubmitting = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      appBar: AppBar(
        title: const Text(
          "جمع المواد ♻️",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF386641),
        centerTitle: true,
        // ✅ تعديل 1: لون سهم الرجوع
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "اختر نوع المادة التي تريد إعادة تدويرها:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF386641),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: materialTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
              )
                  .toList(),
              onChanged: isSubmitting
                  ? null
                  : (value) {
                if (value != null) setState(() => selectedType = value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "أضف وصفًا قصيرًا (اختياري):",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF386641),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              enabled: !isSubmitting,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "مثلاً: زجاجات مياه فارغة",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "أضف صورة للمادة (اختياري):",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF386641),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: isSubmitting ? null : pickImage,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Center(
                  child: selectedImage == null
                  // ✅ تعديل 2: إزالة const من Column لأن محتواها ليس const
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_a_photo,
                          size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        "اضغط لإضافة صورة",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "حدد موقعك على الخريطة لتحديد أقرب نقطة تجميع:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF386641),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: _isLocating || isSubmitting ? null : _getCurrentLocation,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  color: _currentPosition != null ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _currentPosition != null ? Colors.green : Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      _currentPosition != null ? Icons.check_circle : Icons.location_on, 
                      color: _currentPosition != null ? Colors.green : Colors.grey.shade600
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _currentPosition != null 
                             ? "تم بنجاح! الإحداثيات محفوظة 📍" 
                             : (_isLocating ? "جاري تحديد الموقع..." : "اضغط هنا لتحديد موقعك الحالي"),
                        style: TextStyle(
                          color: _currentPosition != null ? Colors.green.shade700 : Colors.grey.shade700,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    if (_isLocating)
                      const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)
                      ),
                  ],
                ),
              ),
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
                onPressed: isSubmitting ? null : submitMaterial,
                icon: isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.send, color: Colors.white),
                label: Text(
                  isSubmitting ? "جاري الإرسال..." : "إرسال المادة",
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