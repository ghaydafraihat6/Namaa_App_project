import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class RecycleSubmissionPage extends StatefulWidget {
  const RecycleSubmissionPage({Key? key}) : super(key: key);

  @override
  State<RecycleSubmissionPage> createState() => _RecycleSubmissionPageState();
}

class _RecycleSubmissionPageState extends State<RecycleSubmissionPage> {
  String? _selectedMaterial;
  File? _imageFile;
  Position? _currentPosition;
  bool _isLoading = false;

  final List<String> _materials = [
    'plastic',
    'metal',
    'paper',
    'electronics',
    'batteries',
  ];

  String _getMaterialLabel(String type, AppLocalizations l10n) {
    switch (type) {
      case 'plastic': return l10n.plastic;
      case 'metal': return l10n.metal;
      case 'paper': return l10n.paper;
      case 'electronics': return l10n.electronics;
      case 'batteries': return l10n.batteries;
      default: return type;
    }
  }

  IconData _getMaterialIcon(String type) {
    switch (type) {
      case 'plastic': return Icons.local_drink;
      case 'metal': return Icons.settings_input_component;
      case 'paper': return Icons.menu_book;
      case 'electronics': return Icons.computer;
      case 'batteries': return Icons.battery_charging_full;
      default: return Icons.recycling;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() => _isLoading = true);

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تفعيل خدمات الموقع.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = pos;
      _isLoading = false;
    });
  }

  Future<void> _submitRequest(AppLocalizations l10n) async {
    if (_selectedMaterial == null || _imageFile == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.error_missing_data), backgroundColor: Colors.red),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // رفع الصورة
      String fileName = 'recycle_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child('recycle_requests').child(fileName);
      await ref.putFile(_imageFile!);
      String imageUrl = await ref.getDownloadURL();

      // إضافة الطلب إلى قاعدة البيانات
      await FirebaseFirestore.instance.collection('recycle_requests').add({
        'userId': user.uid,
        'materialType': _selectedMaterial,
        'imageUrl': imageUrl,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // إضافة نقاط للمستخدم
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'points': FieldValue.increment(50),
      });

      setState(() => _isLoading = false);

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Center(child: Text('🌱', style: TextStyle(fontSize: 40))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.recycle_request_success, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)),
                const SizedBox(height: 10),
                Text(l10n.reward_points, style: const TextStyle(color: Color(0xFF386641), fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A3F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to dashboard screen
                  },
                  child: const Text('موافق', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
                ),
              )
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: Text(l10n.recycle_title, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF2D5A3F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D5A3F)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.recycle_subtitle, style: const TextStyle(fontFamily: 'Cairo', fontSize: 15, color: Color(0xFF616161))),
                  const SizedBox(height: 24),

                  // Material Selection
                  Text(l10n.material_type, style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2E1F))),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _materials.map((type) {
                      final isSelected = _selectedMaterial == type;
                      return ChoiceChip(
                        label: Text(_getMaterialLabel(type, l10n), style: TextStyle(fontFamily: 'Cairo', color: isSelected ? Colors.white : Colors.black87)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF386641),
                        backgroundColor: Colors.white,
                        avatar: Icon(_getMaterialIcon(type), color: isSelected ? Colors.white : const Color(0xFF5D705F), size: 18),
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedMaterial = selected ? type : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  // Image Upload
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFEBF4DD), width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(_imageFile!, fit: BoxFit.cover),
                                  Container(color: Colors.black38),
                                  Center(child: Text(l10n.change_photo, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold))),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.camera_alt, size: 40, color: Color(0xFF5D705F)),
                                const SizedBox(height: 8),
                                Text(l10n.take_photo, style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF5D705F), fontWeight: FontWeight.w600)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Location
                  GestureDetector(
                    onTap: _determinePosition,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _currentPosition != null ? const Color(0xFFEBF4DD) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _currentPosition != null ? const Color(0xFF52B788) : const Color(0xFFEBF4DD), width: 2),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: _currentPosition != null ? const Color(0xFF52B788) : const Color(0xFFF0F5F0), shape: BoxShape.circle),
                            child: Icon(Icons.location_on, color: _currentPosition != null ? Colors.white : const Color(0xFF5D705F), size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_currentPosition != null ? l10n.location_determined : l10n.get_location, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1B2E1F))),
                                if (_currentPosition != null) Text('Lat: ${_currentPosition!.latitude.toStringAsFixed(3)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(3)}', style: const TextStyle(fontSize: 12, color: Color(0xFF386641))),
                              ],
                            ),
                          ),
                          if (_currentPosition != null) const Icon(Icons.check_circle, color: Color(0xFF386641)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _submitRequest(l10n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5A3F),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: const Color(0xFF2D5A3F).withOpacity(0.5),
                      ),
                      child: Text(l10n.submit_recycle_request, style: const TextStyle(fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
