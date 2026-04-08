import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

void main() async {
  print('🔍 فحص قاعدة بيانات منتجات نماء...');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final db = FirebaseFirestore.instance;
    final snapshot = await db.collection('products').get();
    
    print('📊 عدد المنتجات في Firestore: ${snapshot.docs.length}');
    
    if (snapshot.docs.isEmpty) {
      print('⚠️ تحذير: لا توجد منتجات حالياً!');
    } else {
      print('📋 قائمة بأسماء أول 5 منتجات:');
      for (var i = 0; i < (snapshot.docs.length < 5 ? snapshot.docs.length : 5); i++) {
        print('- ${snapshot.docs[i].data()['name']}');
      }
    }
  } catch (e) {
    print('❌ خطأ أثناء الفحص: $e');
  }
}
