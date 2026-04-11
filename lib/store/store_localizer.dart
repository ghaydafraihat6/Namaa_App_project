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

  static String? getLocalAssetPath(String name) {
    final Map<String, String> mapping = {
      'حقيبة قماشية': 'assets/images/products/eco-friendl_canvas_bag.png',
      'فرشاة البامبو': 'assets/images/products/bamboo_brushh.png',
      'أغطية شمع النحل': 'assets/images/products/beeswax_caps.png',
      'ملحقات تقنية حيوية': 'assets/images/products/bioplastic_phone_case.png',
      'الصباريات والعصاريات': 'assets/images/products/cacti_succulents.png',
      'بيتموس جوز الهند': 'assets/images/products/coco_coir_soil.png',
      'مرشة رذاذ زجاجية': 'assets/images/products/sprayer.png',
      'أكواب قشور القهوة': 'assets/images/products/huskee_cup.png',
      'صناديق الكومبوست للمطبخ': 'assets/images/products/kitchen_compost_bins.jpg',
      'بذور الخزامى': 'assets/images/products/lavender_seeds.jpg',
      'مصابيح LED': 'assets/images/products/led_lights.png',
      'مجموعات المايكروغرينز': 'assets/images/products/microgreens_kit.jpg',
      'طبقة الحصى والنشارة': 'assets/images/products/mulch_pebbles.jpg',
      'سلة خوص طبيعية': 'assets/images/products/natural_wicker_basket.png',
      'حقائب بلاستيك المحيطات': 'assets/images/products/ocean_plastic_bag.png',
      'أصص ألياف طبيعية': 'assets/images/products/organic_plant_pot.png',
      'تربة معززة بالبرلايت': 'assets/images/products/perlite_soil.jpg',
      'منسوجات منزلية مدورة': 'assets/images/products/recycled_home_textiles.jpg',
      'حذاء زجاجات البلاستيك': 'assets/images/products/recycled_sneakers.png',
      'المنسوجات المجددة': 'assets/images/products/recycled_textiles.png',
      'ساعة خشب مدور': 'assets/images/products/recycled_watch.png',
      'مقياس رطوبة التربة': 'assets/images/products/soil_moisture_meter.jpg',
      'نبات العنكبوت': 'assets/images/products/spider_plant.jpg',
      'بذور دوار الشمس': 'assets/images/products/sunflower_seeds.png',
      'مطرة مياه حرارية': 'assets/images/products/thermal_water_rain.png',
      'بذور الزعتر': 'assets/images/products/thyme_seeds.jpg',
      'عبوات معدنية معاد تدويرها': 'assets/images/products/upcycled_metal_cans.jpg',
      'كرات السقاية الزجاجية': 'assets/images/products/watering_globes.jpg',
      'طقم مائدة خشبي': 'assets/images/products/wooden_tableware_set.png',
      'نبات الزاميا': 'assets/images/products/zz_plant.png',
      'أقراص معجون الأسنان': 'assets/images/products/toothpaste_tablets.png',
      'ليفة اللوف الطبيعية': 'assets/images/products/natural_luffa.png',
      'عدة أدوات بستنة صغيرة': 'assets/images/products/gardening_tools_set.png',
      'مرشة سقاية النباتات': 'assets/images/products/watering_can.png',
      'شفاطات معدنية قابلة لإعادة الاستخدام': 'assets/images/products/meta_straws.png',
      'أكياس سيليكون قابلة لإعادة الاستخدام': 'assets/images/products/reusable_silicone_food_bags.png',
      'أكياس قابلة للتسميد': 'assets/images/products/compostable_bags.png',
      'قطن تنظيف الوجه قابل لإعادة الاستخدام': 'assets/images/products/reusable_makeup_remover_pads.png',
      'صابون طبيعي يدوي': 'assets/images/products/natural_handmade_soap.png',
      'دفتر ورق معاد تدويره': 'assets/images/products/recycled_paper_notebook.png',
      'سماد عضوي للحدائق': 'assets/images/products/organic_fertilizer.png',
      'نبات مونستيرا': 'assets/images/products/monstera_plant.png',
      'شتلة شجرة تفاح': 'assets/images/products/apple_tree_sapling.png',
      'نبات نعناع في جرة': 'assets/images/products/mint_in_glass_jar.png',
      'طقم بذور وتربة عضوية': 'assets/images/products/seeds_starter_kit.png',
      'قفازات بستنة متينة': 'assets/images/products/gardening_gloves.png',
      'ليفة جلي طبيعية': 'assets/images/products/loofah_dish_sponge.png',
    };

    if (mapping.containsKey(name)) return mapping[name];

    // Fallback search
    for (final key in mapping.keys) {
      if (name.contains(key)) return mapping[key];
    }

    return null;
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
    'أقراص معجون الأسنان': 'Toothpaste Tablets',
    'ليفة اللوف الطبيعية': 'Natural Luffa / Loofah',
    'عدة أدوات بستنة صغيرة': 'Small Gardening Tools Set',
    'مرشة سقاية النباتات': 'Watering Can',
    'شفاطات معدنية قابلة لإعادة الاستخدام': 'Reusable Metal Straws',
    'أكياس سيليكون قابلة لإعادة الاستخدام': 'Reusable Silicone Food Bags',
    'أكياس قابلة للتسميد': 'Compostable Bags',
    'قطن تنظيف الوجه قابل لإعادة الاستخدام': 'Reusable Makeup Remover Pads',
    'صابون طبيعي يدوي': 'Natural Handmade Soap',
    'دفتر ورق معاد تدويره': 'Recycled Paper Notebook',
    'سماد عضوي للحدائق': 'Organic Gardening Fertilizer',
    'نبات مونستيرا': 'Monstera Deliciosa',
    'شتلة شجرة تفاح': 'Apple Tree Sapling',
    'نبات نعناع في جرة': 'Mint in Glass Jar',
    'طقم بذور وتربة عضوية': 'Seeds Starter Kit',
    'قفازات بستنة متينة': 'Durable Gardening Gloves',
    'ليفة جلي طبيعية': 'Natural Loofah Dish Sponge',
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
    'بديل لمعجون الأسنان التقليدي: تمضغ حبة وتفرش بالفرشاة مع قليل من الماء. بدون أنبوب بلاستيك وصديقة للبيئة.':
        'Alternative to traditional toothpaste: chew a tablet, brush with a little water. No plastic tube and eco-friendly.',
    'تستخدم كإسفنجة استحمام طبيعية، بالإضافة إلى تنظيف الصحون وتقشير البشرة. بديل صديق للبيئة للإسفنج البلاستيكي.':
        'Used as a natural bath sponge, as well as for dishwashing and skin exfoliation. An eco-friendly alternative to plastic sponges.',
    'تتكون من مجرفة صغيرة، مجرفة قياس للص، ومشط لتقليب التربة. مثالية للزراعة في الأصص ونقل الشتلات.':
        'Includes a small trowel, measuring trowel, and cultivator. Ideal for potting plants and transplanting seedlings.',
    'تُستخدم لسقاية النباتات الداخلية، وتوزيع الماء بشكل خفيف وريّ الشتلات بدون إتلاف التربة.':
        'Used for watering indoor plants, providing a gentle sprinkle, and watering seedlings without damaging the soil.',
    'تأتي مع شفاط مستقيم ومنحني وفرشاة تنظيف. بديل بيئي قابل لإعادة الاستخدام وسهل التنظيف لتقليل استهلاك البلاستيك.':
        'Includes a straight and bent straw with a cleaning brush. An eco-friendly, reusable, and easy-to-clean alternative to plastic.',
    'تستخدم لحفظ الطعام وتخزين الخضار والفواكه. بديل صديق للبيئة لأكياس النايلون، قابلة للغسل وتدوم طويلاً.':
        'Used for food storage, including vegetables and fruits. An eco-friendly alternative to plastic bags, washable and durable.',
    'تُستخدم لجمع بقايا الطعام ونفايات الكومبوست. بديل صديق للبيئة لأكياس البلاستيك، يتحلل طبيعياً دون تلويث.':
        'Used to collect food scraps and compost waste. An eco-friendly alternative to plastic bags, decomposes naturally without pollution.',
    'يُستخدم لإزالة المكياج، تنظيف الوجه ووضع التونر. بديل صديق للبيئة للقطن أحادي الاستخدام، قابل للغسل.':
        'Used for removing makeup, cleansing the face, and applying toner. An eco-friendly alternative to single-use cotton pads, washable and reusable.',
    'صابون اللافندر والشوفان بمكونات طبيعية، صديق للبيئة وبدون مواد كيميائية قوية. مناسب للبشرة الحساسة.':
        'Lavender and oat soap with natural ingredients, eco-friendly and without harsh chemicals. Suitable for sensitive skin.',
    'دفتر مصنوع من ورق معاد تدويره صديق للبيئة مناسب للملاحظات والاستخدام اليومي.':
        'Notebook made from eco-friendly recycled paper, perfect for notes and daily use.',
    'سماد عضوي نباتي مغذي ومستدام لجميع أنواع النباتات والمحاصيل المنزلية.':
        'Nutritious and sustainable plant-based organic fertilizer for all types of plants and home crops.',
    'نبات منزلي شهير بجمال أوراقه الكبيرة والمميزة، سهل العناية ويضفي لمسة فخامة.':
        'Popular houseplant known for its large and unique leaves, easy to care for and adds a touch of luxury.',
    'شتلة شجرة تفاح قوية جاهزة للزراعة في حديقتك أو في أصيص كبير.':
        'Strong apple tree sapling ready to be planted in your garden or in a large pot.',
    'نبات نعناع طازج ينمو في جرة زجاجية أنيقة، مثالي للمطبخ ورائحته منعشة.':
        'Fresh mint plant growing in an elegant glass jar, perfect for the kitchen with a refreshing scent.',
    'طقم متكامل لبدء رحلة الزراعة، يشمل بذوراً متنوعة وتربة عضوية غنية.':
        'Complete kit to start your gardening journey, includes various seeds and rich organic soil.',
    'قفازات بستنة مصممة لحماية اليدين، مريحة وتدوم طويلاً للعمل الشاق.':
        'Gardening gloves designed to protect hands, comfortable and durable for heavy-duty work.',
    'ليفة جلي مستخلص من نبات اللوف الطبيعي، بديل بيئي فعال لإسفنج البلاستيك.':
        'Dishwashing sponge extracted from the natural loofah plant, an effective eco-friendly alternative to plastic sponges.',
  };
}
