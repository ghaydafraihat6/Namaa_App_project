import 'package:flutter/material.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:namaa_project_app/services/notification_service.dart';
import 'package:namaa_project_app/services/material_classifier.dart';
import 'package:namaa_project_app/services/storage_service.dart';

class RecycleSubmissionPage extends StatefulWidget {
  final String? editId;
  final Map<String, dynamic>? editData;
  const RecycleSubmissionPage({super.key, this.editId, this.editData});
  static const routeName = '/recycle-submission';

  @override
  State<RecycleSubmissionPage> createState() => _RecycleSubmissionPageState();
}

class _RecycleSubmissionPageState extends State<RecycleSubmissionPage> {
  final Color primaryGreen = const Color(0xFF386641);
  final Color darkGreen = const Color(0xFF1B4332);

  final List<Map<String, dynamic>> _materials = [
    {'name': 'بلاستيك', 'emoji': '🧴', 'pts': 20, 'selected': false},
    {'name': 'معادن', 'emoji': '🔩', 'pts': 30, 'selected': false},
    {'name': 'ورق', 'emoji': '📦', 'pts': 15, 'selected': false},
    {'name': 'زجاج', 'emoji': '🪟', 'pts': 20, 'selected': false},
    {'name': 'إلكترونيات', 'emoji': '💻', 'pts': 50, 'selected': false},
    {'name': 'بطاريات', 'emoji': '🔋', 'pts': 40, 'selected': false},
  ];

  File? _imageFile;
  bool _isProcessing = false;
  bool _isAnalyzing = false; // حالة تحليل الذكاء الاصطناعي
  String? _detectedLabel; // المادة المكتشفة
  double? _lat, _lng;
  String? _locationStatus;
  final TextEditingController _notesCtrl = TextEditingController();

  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.editId != null && widget.editData != null) {
      _existingImageUrl = widget.editData!['imageUrl'];
      _notesCtrl.text = widget.editData!['notes'] ?? '';
      
      final existingMats = List<dynamic>.from(widget.editData!['materials'] ?? []);
      for (var mat in _materials) {
        if (existingMats.contains(mat['name'])) mat['selected'] = true;
      }

      if (widget.editData!['location'] != null) {
        GeoPoint gp = widget.editData!['location'];
        _lat = gp.latitude;
        _lng = gp.longitude;
        _locationStatus = "موقع محفوظ مسبقاً ✅"; // Will be overridden in UI based on locale anyway
      }
    }
  }

  String _getTranslatedMaterial(String arName, BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (isAr) return arName;
    switch (arName) {
      case 'بلاستيك': return 'Plastic';
      case 'معادن': return 'Metals';
      case 'ورق': return 'Paper';
      case 'زجاج': return 'Glass';
      case 'إلكترونيات': return 'Electronics';
      case 'بطاريات': return 'Batteries';
      default: return arName;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  int get _totalPoints => _materials
      .where((m) => m['selected'] == true)
      .fold(0, (sum, m) => sum + (m['pts'] as int));

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        _imageFile = file;
        _detectedLabel = null;
      });
      _runAIAnalysis(file);
    }
  }

  Future<void> _runAIAnalysis(File file) async {
    setState(() => _isAnalyzing = true);
    try {
      final result = await MaterialClassifier.detect(file);
      if (result.confidence > 0.6) {
        // خريطة لربط الـ labels بالأسماء العربية في القائمة
        final labelMap = {
          'plastic': 'بلاستيك',
          'metal': 'معادن',
          'paper': 'ورق',
          'glass': 'زجاج',
          'electronics': 'إلكترونيات',
          'batteries': 'بطاريات',
        };

        final arabicName = labelMap[result.detected.toLowerCase()];
        if (arabicName != null) {
          setState(() {
            for (var m in _materials) {
              m['selected'] = (m['name'] == arabicName);
            }
            _detectedLabel = arabicName;
          });
          final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
          final String translatedName = _getTranslatedMaterial(arabicName, context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isAr ? '✨ تم التعرف على المادة: $translatedName (${(result.confidence * 100).toInt()}%)' : '✨ Material recognized: $translatedName (${(result.confidence * 100).toInt()}%)', style: const TextStyle(fontFamily: 'Cairo')),
              backgroundColor: primaryGreen,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('AI Analysis Error: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  void _showImageSourceDialog() {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryGreen),
              title: Text(isAr ? 'التقاط صورة من الكاميرا' : 'Take a picture with Camera', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryGreen),
              title: Text(isAr ? 'اختيار صورة من الهاتف' : 'Choose a picture from Gallery', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _determinePosition() async {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    setState(() => _locationStatus = isAr ? "جاري التحديد..." : "Locating...");
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() { _lat = position.latitude; _lng = position.longitude; _locationStatus = isAr ? "تم التحديد ✅" : "Location Selected ✅"; });
    } catch (e) { setState(() => _locationStatus = isAr ? "فشل التحديد ❌" : "Location Failed ❌"); }
  }

  // تم نقل منطق الرفع لـ StorageService

  Future<void> _submitRequest() async {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_totalPoints == 0 || (_imageFile == null && _existingImageUrl == null) || _lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "أكمل البيانات أولاً" : "Please complete all fields first")));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) imageUrl = await StorageService.uploadImage(_imageFile!);
      
      if (imageUrl != null) {
        final payload = {
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'materials': _materials.where((m) => m['selected']).map((m) => m['name']).toList(),
          'points': _totalPoints,
          'imageUrl': imageUrl,
          'notes': _notesCtrl.text.trim(),
          'location': GeoPoint(_lat!, _lng!),
          'status': 'pending',
        };

        if (widget.editId != null) {
          await FirebaseFirestore.instance.collection('recycle_requests').doc(widget.editId).update(payload);
          _showSuccess(isAr ? "تم التعديل بنجاح!" : "Edited successfully!");
        } else {
          payload['createdAt'] = FieldValue.serverTimestamp();
          await FirebaseFirestore.instance.collection('recycle_requests').add(payload);

          // ✅ إضافة النقاط لرصيد المستخدم
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'points': FieldValue.increment(_totalPoints)});

            // إرسال إشعار
            final matNames = _materials
                .where((m) => m['selected'] == true)
                .map((m) => m['name'])
                .join(' و ');
            await NotificationService.send(
              title: '♻️ طلب تدوير جديد!',
              body: 'تم إرسال طلب تدوير $matNames وحصلت على $_totalPoints نقطة ⭐',
              type: 'recycle',
            );
          }

          _showSuccess(isAr ? "تم الإرسال! وتم إضافة $_totalPoints نقطة لرصيدك 🌟" : "Submitted! You earned $_totalPoints pts 🌟");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "حدث خطأ أثناء رفع الصورة." : "Error uploading image.")));
      }
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAr ? "خطأ: $e" : "Error: $e"))); }
    finally { setState(() => _isProcessing = false); }
  }

  void _showSuccess(String message) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(isAr ? "نجاح!" : "Success!", textAlign: TextAlign.center),
      content: Text(message),
      actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: Text(isAr ? "حسناً" : "OK"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = AppLocalizations.of(context);
    final String title = l10n != null ? l10n.recycle_title : (isAr ? "طلب تجميع مواد ♻️" : "Recycle Request ♻️");
    
    return Scaffold(
      appBar: AppBar(title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')), backgroundColor: primaryGreen, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isAr ? "النقاط المتوقعة: $_totalPoints ⭐" : "Expected Points: $_totalPoints ⭐", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen, fontFamily: 'Cairo')),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: _materials.length,
            itemBuilder: (ctx, i) {
              final m = _materials[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    for (var mat in _materials) {
                      mat['selected'] = false;
                    }
                    m['selected'] = true;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(color: m['selected'] ? primaryGreen : Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(m['emoji'], style: const TextStyle(fontSize: 24)),
                    Text(_getTranslatedMaterial(m['name'], context), style: TextStyle(color: m['selected'] ? Colors.white : darkGreen, fontSize: 12, fontFamily: 'Cairo')),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 25),
          Text(isAr ? "صورة المواد:" : "Material Image:", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _imageFile == null && _existingImageUrl == null ? _showImageSourceDialog : null,
            child: Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
              child: _imageFile == null && _existingImageUrl == null
                  ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey) 
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: _imageFile != null
                              ? Image.file(_imageFile!, fit: BoxFit.cover)
                              : Image.network(_existingImageUrl!, fit: BoxFit.cover),
                        ),
                        if (_isAnalyzing)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(color: Colors.white),
                                   const SizedBox(height: 10),
                                  Text(isAr ? 'جاري التعرف على المادة... ✨' : 'Detecting material... ✨', style: const TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                                ],
                              ),
                            ),
                          ),
                        Positioned(
                          top: 8, left: 8,
                          child: GestureDetector(
                            onTap: () => setState(() { _imageFile = null; _existingImageUrl = null; }),
                            child: CircleAvatar(
                              backgroundColor: Colors.red.withValues(alpha: 0.8),
                              radius: 16,
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8, right: 8,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.6),
                              radius: 18,
                              child: const Icon(Icons.edit, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Text(isAr ? "ملاحظات إضافية (اختياري):" : "Additional Notes (Optional):", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
          const SizedBox(height: 10),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: isAr ? "مثال: الكؤوس نظيفة ومفروزة، البلاستيك بدون أغطية..." : "Example: Cups are clean and sorted, plastic without caps...",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            tileColor: Colors.grey.shade100, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: Icon(Icons.location_on, color: primaryGreen),
            title: Text(_locationStatus ?? (l10n != null ? l10n.get_location : (isAr ? "تحديد موقع الاستلام" : "Determine pickup location")), style: const TextStyle(fontFamily: 'Cairo')),
            onTap: _determinePosition,
          ),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: _isProcessing ? null : _submitRequest,
            child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : Text(widget.editId != null ? (isAr ? "تعديل الطلب" : "Edit Request") : (l10n != null ? l10n.submit_recycle_request : (isAr ? "إرسال الطلب الآن" : "Submit Request Now")), style: const TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          )),
        ]),
      ),
    );
  }
}