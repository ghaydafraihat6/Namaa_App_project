import 'package:flutter/material.dart';

class StoreLocalizer {
  static bool isAr(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ar';

  static String productName(BuildContext context, String nameAr) {
    if (isAr(context)) return nameAr;
    return _nameMap[nameAr] ?? nameAr;
  }

  static String productDesc(BuildContext context, String descAr) {
    if (isAr(context)) return descAr;
    return _descMap[descAr] ?? descAr;
  }

  static String plasticWeight(BuildContext context, String weightAr) {
    if (isAr(context)) return weightAr;
    return weightAr.replaceAll('غ', 'g');
  }

  static final Map<String, String> _nameMap = {
    'حقيبة قماشية': 'Canvas Bag',
    'فرشاة البامبو': 'Bamboo Toothbrush',
    'أغطية شمع النحل': 'Beeswax Wraps',
    'ملحقات تقنية حيوية': 'Bioplastic Tech Accessories',
    'الصباريات والعصاريات': 'Cacti & Succulents',
    'بيتموس جوز الهند': 'Coco Coir Soil',
    'مرشة رذاذ زجاجية': 'Glass Misting Bottle',
    'أكواب قشور القهوة': 'Huskee Coffee Husk Cups',
    'صناديق الكومبوست للمطبخ': 'Kitchen Compost Bins',
    'بذور الخزامى': 'Lavender Seeds',
    'مصابيح LED': 'LED Lights',
    'مجموعات المايكروغرينز': 'Microgreens Kits',
    'طبقة الحصى والنشارة': 'Mulch & Pebbles',
    'سلة خوص طبيعية': 'Natural Wicker Basket',
    'حقائب بلاستيك المحيطات': 'Ocean Plastic Bags',
    'أصص ألياف طبيعية': 'Organic Fiber Pots',
    'تربة معززة بالبرلايت': 'Perlite Enhanced Soil',
    'منسوجات منزلية مدورة': 'Recycled Home Textiles',
    'حذاء زجاجات البلاستيك': 'Recycled Plastic Sneakers',
    'المنسوجات المجددة': 'Recycled Textiles',
    'ساعة خشب مدور': 'Recycled Wood Watch',
    'مقياس رطوبة التربة': 'Soil Moisture Meter',
    'نبات العنكبوت': 'Spider Plant',
    'بذور دوار الشمس': 'Sunflower Seeds',
    'مطرة مياه حرارية': 'Thermal Water Bottle',
    'بذور الزعتر': 'Thyme Seeds',
    'عبوات معدنية معاد تدويرها': 'Upcycled Metal Cans',
    'كرات السقاية الزجاجية': 'Watering Globes',
    'طقم مائدة خشبي': 'Wooden Tableware Set',
    'نبات الزاميا': 'ZZ Plant',
  };

  static final Map<String, String> _descMap = {
    'حقيبة قماشية قوية ومتينة قابلة لإعادة الاستخدام أكثر من 1000 مرة. مثالية للتسوق وتقليل استهلاك أكياس البلاستيك.':
        'Strong and durable canvas bag reusable over 1000 times. Perfect for shopping and reducing plastic bag consumption.',
    'فرشاة أسنان مصنوعة من خشب البامبو الطبيعي القابل للتحلل 100%، بديل ممتاز للفرش البلاستيكية.':
        'Toothbrush made from 100% biodegradable natural bamboo wood, an excellent alternative to plastic brushes.',
    'بديل صديق للبيئة للحفظ والتغليف، أغطية مصنوعة من القطن وشمع النحل وتتشكل بحرارة اليد.':
        'Eco-friendly alternative for food storage, wraps made of cotton and beeswax that mold with hand heat.',
    'أغطية هواتف مصنوعة من مخلفات المزارع قابلة للتحلل الحيوي.':
        'Phone cases made from farm waste, fully biodegradable.',
    'الخيار البديهي للبيئات الجافة. سقاية خفيفة كل أسبوعين تكفيها.':
        'The natural choice for dry environments. Light watering every two weeks is enough.',
    'بديل بيئي للبيتموس التقليدي، يحفظ الرطوبة بامتياز.':
        'An ecological alternative to traditional peat moss, excellent at retaining moisture.',
    'مرشة زجاجية أنيقة لسقاية الأوراق وتوفير كميات المياه.':
        'Elegant glass sprayer for leaf misting and water saving.',
    'أكواب Huskee مصنوعة من قشور القهوة المعاد تدويرها. تدوير ذكي بعينه.':
        'Huskee cups made from recycled coffee husks. True smart recycling.',
    'صناديق صغيرة لتحويل مخلفات الطعام إلى سماد عضوي غني.':
        'Small bins for turning food waste into rich organic compost.',
    'نبات يحب الشمس ولا يطيق كثرة الماء. رائحته تساعد على الاسترخاء.':
        'Plant that loves the sun and hates overwatering. Its scent helps with relaxation.',
    'مصابيح موفرة للطاقة تدوم طويلاً، تقلل من فاتورة الكهرباء وتخفف الانبعاثات الكربونية.':
        'Long-lasting energy-saving lights that reduce electricity bills and carbon emissions.',
    'جرجير وفجل ينمو خلال 7-10 أيام فقط. لا يحتاج مساحة أو كميات ماء ضخمة.':
        'Arugula and radish that grow in just 7-10 days. Needs minimal space or water.',
    'تمنع تبخر الماء بسرعة وتقلل عدد مرات السقاية بشكل ملحوظ.':
        'Prevents rapid water evaporation and significantly reduces watering frequency.',
    'سلة أنيقة من الخوص الطبيعي، مثالية للتخزين بدلاً من العبوات البلاستيكية.':
        'Elegant natural wicker basket, ideal for storage instead of plastic containers.',
    'حقيبة ظهر مصنوعة من زجاجات البلاستيك الملقاة في البحار.':
        'Backpack made from reclaimed ocean plastic bottles.',
    'أصص مستدامة مصنوعة من مواد نباتية قابلة للتحلل الحيوي.':
        'Sustainable pots made from biodegradable plant materials.',
    'صخور بركانية طبيعية تضمن تصريفاً مثالياً وتمنع هدر الماء.':
        'Natural volcanic rocks ensuring perfect drainage and preventing water waste.',
    'منسوجات حمام ومطبخ من مزيج القطن العضوي والبوليستر المعاد تدويرها.':
        'Bathroom and kitchen textiles from a blend of organic cotton and recycled polyester.',
    'أحذية رياضية مصنوعة من خيوط تدوير زجاجات المياه البلاستيكية.':
        'Sneakers made from recycled water bottle threads.',
    'أقمشة من القطن المعاد تدويره وخيوط الخيزران. مورد متجدد بامتياز.':
        'Fabrics from recycled cotton and bamboo threads. A truly renewable resource.',
    'ساعات مصنوعة من خشب الأثاث القديم أو ألياف الكربون المعاد تدويرها.':
        'Watches made from reclaimed furniture wood or recycled carbon fiber.',
    'جهاز بلا بطاريات يخبرك بمستوى رطوبة التربة لمنع السقاية الزائدة.':
        'Battery-free device that tells you soil moisture level to prevent overwatering.',
    'حيوي وسهل التكاثر. فعال جداً في امتصاص الروائح وتنقية الأبخرة المنزلية.':
        'Vibrant and easy to propagate. Highly effective at absorbing odors and purifying indoor air.',
    'بذور قوية تنمو بسرعة وتدعم التلقيح.':
        'Strong seeds that grow quickly and support pollination.',
    'مطرة مياه تقلل استهلاك البلاستيك وتحفظ الحرارة.':
        'Water bottle that reduces plastic consumption and maintains temperature.',
    'نبات عنيد وجميل لا يحتاج لعناية كبيرة.':
        'A resilient and beautiful plant that requires minimal care.',
    'عبوات قديمة تم صقلها لتتحول إلى قطع زينة فخمة.':
        'Old containers upcycled into luxurious decorative pieces.',
    'تفرغ الماء ببطء شديد حسب حاجة النبات.':
        'Empty water very slowly according to the plant\'s needs.',
    'طقم شوك وملاعق من الخشب الطبيعي.': 'Natural wood fork and spoon set.',
    'سيقانه تخزن الماء بكفاءة عالية، صديق للبيئة.':
        'Its stems store water efficiently, eco-friendly.',
  };
}
