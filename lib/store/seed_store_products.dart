// 🌱 سكريبت رفع المنتجات إلى Firestore
// تشغيل: dart run lib/store/seed_store_products.dart

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const firebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyAbzF4P5s6DuXw2APQODoWhQMLoGE81bx8',
  appId: '1:120611530859:android:31956a2b543d2ac4e8a92e',
  messagingSenderId: '120611530859',
  projectId: 'namaaprojectapp',
  storageBucket: 'namaaprojectapp.firebasestorage.app',
);

const List<Map<String, dynamic>> _products = [
  {
    'name': 'حقيبة قماشية',
    'image': 'assets/images/products/eco-friendl_canvas_bag.png',
    'category': 'other',
    'price': 3.5,
    'stock': 50,
    'active': true,
    'desc': 'حقيبة قماشية قوية ومتينة قابلة لإعادة الاستخدام أكثر من 1000 مرة. مثالية للتسوق وتقليل استهلاك أكياس البلاستيك.',
    'emoji': '🛍️',
    'plastic': '50 غ',
  },
  {
    'name': 'فرشاة البامبو',
    'image': 'assets/images/products/bamboo_brushh.png',
    'category': 'other',
    'price': 1.5,
    'stock': 120,
    'active': true,
    'desc': 'فرشاة أسنان مصنوعة من خشب البامبو الطبيعي القابل للتحلل 100%، بديل ممتاز للفرش البلاستيكية.',
    'emoji': '🪥',
    'plastic': '20 غ',
  },
  {
    'name': 'أغطية شمع النحل',
    'image': 'assets/images/products/beeswax_caps.png',
    'category': 'other',
    'price': 4.5,
    'stock': 85,
    'active': true,
    'desc': 'بديل صديق للبيئة للحفظ والتغليف، أغطية مصنوعة من القطن وشمع النحل وتتشكل بحرارة اليد.',
    'emoji': '🐝',
    'plastic': '15 غ',
  },
  {
    'name': 'ملحقات تقنية حيوية',
    'image': 'assets/images/products/bioplastic_phone_case.png',
    'category': 'recycled',
    'price': 5.5,
    'stock': 55,
    'active': true,
    'desc': 'أغطية هواتف مصنوعة من مخلفات المزارع قابلة للتحلل الحيوي.',
    'emoji': '📱',
    'plastic': '0 غ',
  },
  {
    'name': 'الصباريات والعصاريات',
    'image': 'assets/images/products/cacti_succulents.png',
    'category': 'plants',
    'price': 5.0,
    'stock': 100,
    'active': true,
    'desc': 'الخيار البديهي للبيئات الجافة. سقاية خفيفة كل أسبوعين تكفيها.',
    'emoji': '🌵',
    'plastic': '0 غ',
  },
  {
    'name': 'بيتموس جوز الهند',
    'image': 'assets/images/products/coco_coir_soil.png',
    'category': 'tools',
    'price': 4.5,
    'stock': 100,
    'active': true,
    'desc': 'بديل بيئي للبيتموس التقليدي، يحفظ الرطوبة بامتياز.',
    'emoji': '🥥',
    'plastic': '0 غ',
  },
  {
    'name': 'مرشة رذاذ زجاجية',
    'image': 'assets/images/products/sprayer.png',
    'category': 'tools',
    'price': 6.5,
    'stock': 40,
    'active': true,
    'desc': 'مرشة زجاجية أنيقة لسقاية الأوراق وتوفير كميات المياه.',
    'emoji': '🧴',
    'plastic': '0 غ',
  },
  {
    'name': 'أكواب قشور القهوة',
    'image': 'assets/images/products/huskee_cup.png',
    'category': 'recycled',
    'price': 7.0,
    'stock': 40,
    'active': true,
    'desc': 'أكواب Huskee مصنوعة من قشور القهوة المعاد تدويرها. تدوير ذكي بعينه.',
    'emoji': '☕',
    'plastic': '0 غ',
  },
  {
    'name': 'صناديق الكومبوست للمطبخ',
    'image': 'assets/images/products/kitchen_compost_bins.jpg',
    'category': 'tools',
    'price': 22.0,
    'stock': 15,
    'active': true,
    'desc': 'صناديق صغيرة لتحويل مخلفات الطعام إلى سماد عضوي غني.',
    'emoji': '🗳️',
    'plastic': '100 غ',
  },
  {
    'name': 'بذور الخزامى',
    'image': 'assets/images/products/lavender_seeds.jpg',
    'category': 'seeds',
    'price': 2.5,
    'stock': 100,
    'active': true,
    'desc': 'نبات يحب الشمس ولا يطيق كثرة الماء. رائحته تساعد على الاسترخاء.',
    'emoji': '💜',
    'plastic': '0 غ',
  },
  {
    'name': 'مصابيح LED',
    'image': 'assets/images/products/led_lights.png',
    'category': 'other',
    'price': 2.5,
    'stock': 100,
    'active': true,
    'desc': 'مصابيح موفرة للطاقة تدوم طويلاً، تقلل من فاتورة الكهرباء وتخفف الانبعاثات الكربونية.',
    'emoji': '💡',
    'plastic': '0 غ',
  },
  {
    'name': 'مجموعات المايكروغرينز',
    'image': 'assets/images/products/microgreens_kit.jpg',
    'category': 'seeds',
    'price': 4.5,
    'stock': 80,
    'active': true,
    'desc': 'جرجير وفجل ينمو خلال 7-10 أيام فقط. لا يحتاج مساحة أو كميات ماء ضخمة.',
    'emoji': '🍱',
    'plastic': '0 غ',
  },
  {
    'name': 'طبقة الحصى والنشارة',
    'image': 'assets/images/products/mulch_pebbles.jpg',
    'category': 'tools',
    'price': 4.0,
    'stock': 100,
    'active': true,
    'desc': 'تمنع تبخر الماء بسرعة وتقلل عدد مرات السقاية بشكل ملحوظ.',
    'emoji': '🧱',
    'plastic': '0 غ',
  },
  {
    'name': 'سلة خوص طبيعية',
    'image': 'assets/images/products/natural_wicker_basket.png',
    'category': 'other',
    'price': 12.0,
    'stock': 15,
    'active': true,
    'desc': 'سلة أنيقة من الخوص الطبيعي، مثالية للتخزين بدلاً من العبوات البلاستيكية.',
    'emoji': '🧺',
    'plastic': '100 غ',
  },
  {
    'name': 'حقائب بلاستيك المحيطات',
    'image': 'assets/images/products/ocean_plastic_bag.png',
    'category': 'recycled',
    'price': 25.0,
    'stock': 25,
    'active': true,
    'desc': 'حقيبة ظهر مصنوعة من زجاجات البلاستيك الملقاة في البحار.',
    'emoji': '🌊',
    'plastic': '500 غ',
  },
  {
    'name': 'أصص ألياف طبيعية',
    'image': 'assets/images/products/organic_plant_pot.png',
    'category': 'pots',
    'price': 7.5,
    'stock': 45,
    'active': true,
    'desc': 'أصص مستدامة مصنوعة من مواد نباتية قابلة للتحلل الحيوي.',
    'emoji': '🎍',
    'plastic': '0 غ',
  },
  {
    'name': 'تربة معززة بالبرلايت',
    'image': 'assets/images/products/perlite_soil.jpg',
    'category': 'tools',
    'price': 5.5,
    'stock': 80,
    'active': true,
    'desc': 'صخور بركانية طبيعية تضمن تصريفاً مثالياً وتمنع هدر الماء.',
    'emoji': '⚪',
    'plastic': '0 غ',
  },
  {
    'name': 'منسوجات منزلية مدورة',
    'image': 'assets/images/products/recycled_home_textiles.jpg',
    'category': 'recycled',
    'price': 10.0,
    'stock': 40,
    'active': true,
    'desc': 'منسوجات حمام ومطبخ من مزيج القطن العضوي والبوليستر المعاد تدويره.',
    'emoji': '🧼',
    'plastic': '0 غ',
  },
  {
    'name': 'حذاء زجاجات البلاستيك',
    'image': 'assets/images/products/recycled_sneakers.png',
    'category': 'recycled',
    'price': 45.0,
    'stock': 10,
    'active': true,
    'desc': 'أحذية رياضية مصنوعة من خيوط تدوير زجاجات المياه البلاستيكية.',
    'emoji': '👟',
    'plastic': '0 غ',
  },
  {
    'name': 'المنسوجات المجددة',
    'image': 'assets/images/products/recycled_textiles.png',
    'category': 'recycled',
    'price': 9.5,
    'stock': 35,
    'active': true,
    'desc': 'أقمشة من القطن المعاد تدويره وخيوط الخيزران. مورد متجدد بامتياز.',
    'emoji': '🧵',
    'plastic': '0 غ',
  },
  {
    'name': 'ساعة خشب مدور',
    'image': 'assets/images/products/recycled_watch.png',
    'category': 'recycled',
    'price': 55.0,
    'stock': 5,
    'active': true,
    'desc': 'ساعات مصنوعة من خشب الأثاث القديم أو ألياف الكربون المعاد تدويرها.',
    'emoji': '⌚',
    'plastic': '0 غ',
  },
  {
    'name': 'مقياس رطوبة التربة',
    'image': 'assets/images/products/soil_moisture_meter.jpg',
    'category': 'tools',
    'price': 8.5,
    'stock': 35,
    'active': true,
    'desc': 'جهاز بلا بطاريات يخبرك بمستوى رطوبة التربة لمنع السقاية الزائدة.',
    'emoji': '📉',
    'plastic': '0 غ',
  },
  {
    'name': 'نبات العنكبوت',
    'image': 'assets/images/products/spider_plant.jpg',
    'category': 'plants',
    'price': 7.0,
    'stock': 45,
    'active': true,
    'desc': 'حيوي وسهل التكاثر. فعال جداً في امتصاص الروائح وتنقية الأبخرة المنزلية.',
    'emoji': '🕷️',
    'plastic': '0 غ',
  },
  {
    'name': 'بذور دوار الشمس',
    'image': 'assets/images/products/sunflower_seeds.png',
    'category': 'seeds',
    'price': 1.0,
    'stock': 500,
    'active': true,
    'desc': 'بذور قوية تنمو بسرعة وتدعم التلقيح.',
    'emoji': '🌻',
    'plastic': '0 غ',
  },
  {
    'name': 'مطرة مياه حرارية',
    'image': 'assets/images/products/thermal_water_rain.png',
    'category': 'other',
    'price': 8.0,
    'stock': 30,
    'active': true,
    'desc': 'مطرة مياه تقلل استهلاك البلاستيك وتحفظ الحرارة.',
    'emoji': '💧',
    'plastic': '25 غ',
  },
  {
    'name': 'بذور الزعتر',
    'image': 'assets/images/products/thyme_seeds.jpg',
    'category': 'seeds',
    'price': 1.5,
    'stock': 120,
    'active': true,
    'desc': 'نبات عنيد وجميل لا يحتاج لعناية كبيرة.',
    'emoji': '🌿',
    'plastic': '0 غ',
  },
  {
    'name': 'عبوات معدنية معاد تدويرها',
    'image': 'assets/images/products/upcycled_metal_cans.jpg',
    'category': 'recycled',
    'price': 12.0,
    'stock': 20,
    'active': true,
    'desc': 'عبوات قديمة تم صقلها لتتحول إلى قطع زينة فخمة.',
    'emoji': '🥫',
    'plastic': '0 غ',
  },
  {
    'name': 'كرات السقاية الزجاجية',
    'image': 'assets/images/products/watering_globes.jpg',
    'category': 'tools',
    'price': 12.0,
    'stock': 20,
    'active': true,
    'desc': 'تفرغ الماء ببطء شديد حسب حاجة النبات.',
    'emoji': '🔮',
    'plastic': '0 غ',
  },
  {
    'name': 'طقم مائدة خشبي',
    'image': 'assets/images/products/wooden_tableware_set.png',
    'category': 'other',
    'price': 5.5,
    'stock': 40,
    'active': true,
    'desc': 'طقم شوك وملاعق من الخشب الطبيعي.',
    'emoji': '🍴',
    'plastic': '15 غ',
  },
  {
    'name': 'نبات الزاميا',
    'image': 'assets/images/products/zz_plant.png',
    'category': 'plants',
    'price': 15.0,
    'stock': 20,
    'active': true,
    'desc': 'سيقانه تخزن الماء بكفاءة عالية، صديق للبيئة.',
    'emoji': '🌿',
    'plastic': '0 غ',
  },
  {
    'name': 'أقراص معجون الأسنان',
    'image': 'assets/images/products/toothpaste_tablets.png',
    'category': 'other',
    'price': 4.0,
    'stock': 100,
    'active': true,
    'desc': 'بديل لمعجون الأسنان التقليدي: تمضغ حبة وتفرش بالفرشاة مع قليل من الماء. بدون أنبوب بلاستيك وصديقة للبيئة.',
    'emoji': '🦷',
    'plastic': '0 غ',
  },
  {
    'name': 'ليفة اللوف الطبيعية',
    'image': 'assets/images/products/natural_luffa.png',
    'category': 'other',
    'price': 2.5,
    'stock': 150,
    'active': true,
    'desc': 'تستخدم كإسفنجة استحمام طبيعية، بالإضافة إلى تنظيف الصحون وتقشير البشرة. بديل صديق للبيئة للإسفنج البلاستيكي.',
    'emoji': '🧽',
    'plastic': '0 غ',
  },
  {
    'name': 'عدة أدوات بستنة صغيرة',
    'image': 'assets/images/products/gardening_tools_set.png',
    'category': 'tools',
    'price': 6.0,
    'stock': 85,
    'active': true,
    'desc': 'تتكون من مجرفة صغيرة، مجرفة قياس للص، ومشط لتقليب التربة. مثالية للزراعة في الأصص ونقل الشتلات.',
    'emoji': '🛠️',
    'plastic': '50 غ',
  },
  {
    'name': 'مرشة سقاية النباتات',
    'image': 'assets/images/products/watering_can.png',
    'category': 'tools',
    'price': 4.5,
    'stock': 120,
    'active': true,
    'desc': 'تُستخدم لسقاية النباتات الداخلية، وتوزيع الماء بشكل خفيف وريّ الشتلات بدون إتلاف التربة.',
    'emoji': '🚿',
    'plastic': '50 غ',
  },
  {
    'name': 'شفاطات معدنية قابلة لإعادة الاستخدام',
    'image': 'assets/images/products/meta_straws.png',
    'category': 'other',
    'price': 3.5,
    'stock': 200,
    'active': true,
    'desc': 'تأتي مع شفاط مستقيم ومنحني وفرشاة تنظيف. بديل بيئي قابل لإعادة الاستخدام وسهل التنظيف لتقليل استهلاك البلاستيك.',
    'emoji': '🥤',
    'plastic': '0 غ',
  },
  {
    'name': 'أكياس سيليكون قابلة لإعادة الاستخدام',
    'image': 'assets/images/products/reusable_silicone_food_bags.png',
    'category': 'other',
    'price': 5.0,
    'stock': 140,
    'active': true,
    'desc': 'تستخدم لحفظ الطعام وتخزين الخضار والفواكه. بديل صديق للبيئة لأكياس النايلون، قابلة للغسل وتدوم طويلاً.',
    'emoji': '🛍️',
    'plastic': '0 غ',
  },
  {
    'name': 'أكياس قابلة للتسميد',
    'image': 'assets/images/products/compostable_bags.png',
    'category': 'other',
    'price': 2.0,
    'stock': 300,
    'active': true,
    'desc': 'تُستخدم لجمع بقايا الطعام ونفايات الكومبوست. بديل صديق للبيئة لأكياس البلاستيك، يتحلل طبيعياً دون تلويث.',
    'emoji': '🗑️',
    'plastic': '0 غ',
  },
  {
    'name': 'قطن تنظيف الوجه قابل لإعادة الاستخدام',
    'image': 'assets/images/products/reusable_makeup_remover_pads.png',
    'category': 'other',
    'price': 3.0,
    'stock': 120,
    'active': true,
    'desc': 'يُستخدم لإزالة المكياج، تنظيف الوجه ووضع التونر. بديل صديق للبيئة للقطن أحادي الاستخدام، قابل للغسل.',
    'emoji': '🧖‍♀️',
    'plastic': '0 غ',
  },
  {
    'name': 'صابون طبيعي يدوي',
    'image': 'assets/images/products/natural_handmade_soap.png',
    'category': 'other',
    'price': 3.5,
    'stock': 90,
    'active': true,
    'desc': 'صابون اللافندر والشوفان بمكونات طبيعية، صديق للبيئة وبدون مواد كيميائية قوية. مناسب للبشرة الحساسة.',
    'emoji': '🧼',
    'plastic': '0 غ',
  },
  {
    'name': 'دفتر ورق معاد تدويره',
    'image': 'assets/images/products/recycled_paper_notebook.png',
    'category': 'recycled',
    'price': 4.0,
    'stock': 120,
    'active': true,
    'desc': 'دفتر مصنوع من ورق معاد تدويره صديق للبيئة مناسب للملاحظات والاستخدام اليومي.',
    'emoji': '📓',
    'plastic': '0 غ',
  },
  {
    'name': 'سماد عضوي للحدائق',
    'image': 'assets/images/products/organic_fertilizer.png',
    'category': 'tools',
    'price': 9.0,
    'stock': 50,
    'active': true,
    'desc': 'سماد عضوي نباتي مغذي ومستدام لجميع أنواع النباتات والمحاصيل المنزلية.',
    'emoji': '🟤',
    'plastic': '50 غ',
  },
  {
    'name': 'نبات مونستيرا',
    'image': 'assets/images/products/monstera_plant.png',
    'category': 'plants',
    'price': 18.0,
    'stock': 25,
    'active': true,
    'desc': 'نبات منزلي شهير بجمال أوراقه الكبيرة والمميزة، سهل العناية ويضفي لمسة فخامة.',
    'emoji': '🌿',
    'plastic': '0 غ',
  },
  {
    'name': 'شتلة شجرة تفاح',
    'image': 'assets/images/products/apple_tree_sapling.png',
    'category': 'plants',
    'price': 12.0,
    'stock': 30,
    'active': true,
    'desc': 'شتلة شجرة تفاح قوية جاهزة للزراعة في حديقتك أو في أصيص كبير.',
    'emoji': '🍎',
    'plastic': '0 غ',
  },
  {
    'name': 'نبات نعناع في جرة',
    'image': 'assets/images/products/mint_in_glass_jar.png',
    'category': 'plants',
    'price': 4.0,
    'stock': 60,
    'active': true,
    'desc': 'نبات نعناع طازج ينمو في جرة زجاجية أنيقة، مثالي للمطبخ ورائحته منعشة.',
    'emoji': '🌱',
    'plastic': '0 غ',
  },
  {
    'name': 'طقم بذور وتربة عضوية',
    'image': 'assets/images/products/seeds_starter_kit.png',
    'category': 'seeds',
    'price': 15.0,
    'stock': 40,
    'active': true,
    'desc': 'طقم متكامل لبدء رحلة الزراعة، يشمل بذوراً متنوعة وتربة عضوية غنية.',
    'emoji': '📦',
    'plastic': '20 غ',
  },
  {
    'name': 'قفازات بستنة متينة',
    'image': 'assets/images/products/gardening_gloves.png',
    'category': 'tools',
    'price': 5.5,
    'stock': 100,
    'active': true,
    'desc': 'قفازات بستنة مصممة لحماية اليدين، مريحة وتدوم طويلاً للعمل الشاق.',
    'emoji': '🧤',
    'plastic': '50 غ',
  },
  {
    'name': 'ليفة جلي طبيعية',
    'image': 'assets/images/products/loofah_dish_sponge.png',
    'category': 'other',
    'price': 2.5,
    'stock': 200,
    'active': true,
    'desc': 'ليفة جلي مستخلصة من نبات اللوف الطبيعي، بديل بيئي فعال لإسفنج البلاستيك.',
    'emoji': '🧽',
    'plastic': '0 غ',
  },
];

Future<void> seedDatabase() async {
  print('🚀 بدأت عملية رفع المنتجات...');

  try {
    final db = FirebaseFirestore.instance;

    // إذا المنتجات موجودة، لا تعيد رفعها (للحفاظ على التقييمات)
    final existing = await db.collection('products').get();
    if (existing.docs.isNotEmpty) {
      print('✅ المنتجات موجودة أصلاً (${existing.docs.length}), تخطي...');
      return;
    }

    print('🆕 رفع ${_products.length} منتج...');
    final addBatch = db.batch();
    for (final p in _products) {
      addBatch.set(db.collection('products').doc(), p);
    }
    await addBatch.commit();

    print('✅ تم بنجاح! إجمالي المنتجات: ${_products.length}');
  } catch (e) {
    print('❌ حدث خطأ كبير: $e');
  }
}

// ── بيانات تقييمات تجريبية ──
const List<Map<String, dynamic>> _sampleReviews = [
  {
    'userName': 'سارة أحمد',
    'rating': 5.0,
    'comment': 'منتج ممتاز! جودة عالية وصديق للبيئة فعلاً. أنصح فيه بشدة 🌿',
  },
  {
    'userName': 'محمد خالد',
    'rating': 4.0,
    'comment': 'جيد جداً، التغليف كان رائع والمنتج وصل بحالة ممتازة.',
  },
  {
    'userName': 'لينا عمر',
    'rating': 5.0,
    'comment': 'أحببته كثيراً! سأطلب منه مرة ثانية بالتأكيد ❤️',
  },
  {
    'userName': 'أحمد يوسف',
    'rating': 3.0,
    'comment': 'المنتج لا بأس به، لكن كنت أتوقع حجم أكبر. بشكل عام مقبول.',
  },
  {
    'userName': 'نور الهدى',
    'rating': 5.0,
    'comment': 'من أفضل المنتجات البيئية اللي جربتها! شكراً نماء 🌱',
  },
  {
    'userName': 'يزن محمود',
    'rating': 4.0,
    'comment': 'سعر مناسب وجودة ممتازة. التوصيل كان سريع كمان.',
  },
  {
    'userName': 'رنا حسين',
    'rating': 5.0,
    'comment': 'هدية رائعة لصديقتي! كانت سعيدة جداً فيها 🎁',
  },
  {
    'userName': 'عبدالله سمير',
    'rating': 4.0,
    'comment': 'منتج عملي ومفيد، أنصح كل شخص يهتم بالبيئة يجربه.',
  },
  {
    'userName': 'دانا فارس',
    'rating': 5.0,
    'comment': 'ماشاء الله جودة فوق الممتاز! والتصميم أنيق وبسيط ✨',
  },
  {
    'userName': 'كريم حسن',
    'rating': 3.0,
    'comment': 'المنتج جيد بس التغليف كان ممكن يكون أحسن.',
  },
  {
    'userName': 'هبة ناصر',
    'rating': 5.0,
    'comment': 'بديل بيئي ممتاز! قللت استخدام البلاستيك بشكل كبير بسببه ♻️',
  },
  {
    'userName': 'فيصل العلي',
    'rating': 4.0,
    'comment': 'طلبت منه 3 مرات وكل مرة الجودة ثابتة. ممتاز!',
  },
];

// ── أسماء المنتجات اللي بدنا نضيفلها تقييمات ──
const List<String> _productsToReview = [
  'حقيبة قماشية',
  'فرشاة البامبو',
  'أغطية شمع النحل',
  'صناديق الكومبوست للمطبخ',
  'مطرة مياه حرارية',
  'أكواب قشور القهوة',
  'نبات العنكبوت',
  'طقم مائدة خشبي',
  'سلة خوص طبيعية',
  'حذاء زجاجات البلاستيك',
  'أكياس قابلة للتسميد',
  'صابون طبيعي يدوي',
  'دفتر ورق معاد تدويره',
  'نبات مونستيرا',
  'بذور الخزامى',
];

Future<void> seedReviews() async {
  print('⭐ بدأت عملية إضافة التقييمات...');

  try {
    final db = FirebaseFirestore.instance;

    // جلب كل المنتجات
    final productsSnap = await db.collection('products').get();
    final productDocs = productsSnap.docs;

    int totalAdded = 0;

    for (final productName in _productsToReview) {
      // البحث عن المنتج بالاسم
      final matchingDocs = productDocs.where(
        (d) => (d.data()['name'] as String?) == productName,
      );

      if (matchingDocs.isEmpty) {
        print('⚠️ لم يتم العثور على: $productName');
        continue;
      }

      final productDoc = matchingDocs.first;
      final productId = productDoc.id;

      // التحقق إذا فيه تقييمات موجودة أصلاً
      final existingReviews = await db
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .limit(1)
          .get();

      if (existingReviews.docs.isNotEmpty) {
        print('⏭️ $productName عنده تقييمات أصلاً، تخطي...');
        continue;
      }

      // اختيار 3-5 تقييمات عشوائية لكل منتج
      final shuffled = List<Map<String, dynamic>>.from(_sampleReviews)..shuffle();
      final reviewCount = 3 + (productName.hashCode.abs() % 3); // 3 إلى 5
      final selectedReviews = shuffled.take(reviewCount).toList();

      for (int i = 0; i < selectedReviews.length; i++) {
        final review = selectedReviews[i];
        await db
            .collection('products')
            .doc(productId)
            .collection('reviews')
            .add({
          ...review,
          'userId': 'seed_user_${i + 1}',
          'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: i * 3 + 1)),
          ),
        });
        totalAdded++;
      }

      print('✅ تم إضافة ${selectedReviews.length} تقييم لـ: $productName');
    }

    print('🎉 اكتملت العملية! تم إضافة $totalAdded تقييم إجمالاً');
  } catch (e) {
    print('❌ خطأ في إضافة التقييمات: $e');
  }
}