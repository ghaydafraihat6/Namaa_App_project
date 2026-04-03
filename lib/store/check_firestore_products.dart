import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final db = FirebaseFirestore.instance;
  final products = await db.collection('products').get();
  print('--- Current Products in Firestore ---');
  for (var doc in products.docs) {
    final data = doc.data();
    print('Name: ${data['name']}, Image: ${data['image']}');
  }
}
