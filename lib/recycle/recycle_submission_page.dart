import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class RecycleSubmissionPage extends StatefulWidget {
  const RecycleSubmissionPage({super.key});
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
  double? _lat, _lng;
  String? _locationStatus;
  final TextEditingController _notesCtrl = TextEditingController();

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
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryGreen),
              title: const Text('التقاط صورة من الكاميرا', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryGreen),
              title: const Text('اختيار صورة من الهاتف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
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
    setState(() => _locationStatus = "جاري التحديد...");
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      Position position = await Geolocator.getCurrentPosition();
      setState(() { _lat = position.latitude; _lng = position.longitude; _locationStatus = "تم التحديد ✅"; });
    } catch (e) { setState(() => _locationStatus = "فشل التحديد ❌"); }
  }

  Future<String?> _uploadToImgBB(File file) async {
    try {
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=045d79d3e3886e915ec3f338a1b2a806');
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', file.path));
      
      final reqResponse = await request.send();
      if (reqResponse.statusCode == 200) {
        final responseData = await reqResponse.stream.bytesToString();
        final jsonResult = json.decode(responseData);
        return jsonResult['data']['url'];
      }
      return null;
    } catch (e) {
      debugPrint("ImgBB Upload Error: $e");
      return null;
    }
  }

  Future<void> _submitRequest() async {
    if (_totalPoints == 0 || _imageFile == null || _lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("أكمل البيانات أولاً")));
      return;
    }
    setState(() => _isProcessing = true);
    try {
      String? imageUrl = await _uploadToImgBB(_imageFile!);
      if (imageUrl != null) {
        await FirebaseFirestore.instance.collection('recycle_requests').add({
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'materials': _materials.where((m) => m['selected']).map((m) => m['name']).toList(),
          'points': _totalPoints,
          'imageUrl': imageUrl,
          'notes': _notesCtrl.text.trim(),
          'location': GeoPoint(_lat!, _lng!),
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _showSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ أثناء رفع الصورة.")));
      }
    } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e"))); }
    finally { setState(() => _isProcessing = false); }
  }

  void _showSuccess() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text("تم الإرسال!", textAlign: TextAlign.center),
      content: const Text("سيتم مراجعة الطلب وإضافة النقاط قريباً."),
      actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text("حسناً"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("طلب تجميع مواد ♻️", style: TextStyle(color: Colors.white)), backgroundColor: primaryGreen, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("النقاط المتوقعة: $_totalPoints ⭐", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen)),
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
                    Text(m['name'], style: TextStyle(color: m['selected'] ? Colors.white : darkGreen, fontSize: 12)),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 25),
          const Text("صورة المواد:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _imageFile == null ? _showImageSourceDialog : null,
            child: Container(
              height: 150, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade300)),
              child: _imageFile == null 
                  ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey) 
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(_imageFile!, fit: BoxFit.cover)),
                        Positioned(
                          top: 8, left: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageFile = null),
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
          const Text("ملاحظات إضافية (اختياري):", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "مثال: الكأوس نظيفة ومفروزة، البلاستيك بدون أغطية...",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            tileColor: Colors.grey.shade100, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            leading: Icon(Icons.location_on, color: primaryGreen),
            title: Text(_locationStatus ?? "تحديد موقع الاستلام"),
            onTap: _determinePosition,
          ),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 55, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: _isProcessing ? null : _submitRequest,
            child: _isProcessing ? const CircularProgressIndicator(color: Colors.white) : const Text("إرسال الطلب الآن", style: TextStyle(color: Colors.white, fontSize: 18)),
          )),
        ]),
      ),
    );
  }
}