import json
import os

ar_path = 'c:/Projects_Flutter/Namaa_Project_App/lib/l10n/app_ar.arb'
en_path = 'c:/Projects_Flutter/Namaa_Project_App/lib/l10n/app_en.arb'

new_keys = {
  "recycle_dashboard_title": {"en": "Recycle Center ♻️", "ar": "مركز إعادة التدوير ♻️"},
  "recycle_history_title": {"en": "My Requests History 🗂️", "ar": "سجل طلباتي 🗂️"},
  "recycle_welcome": {"en": "Welcome to Namaa! 🌱", "ar": "أهلاً بك في نماء! 🌱"},
  "recycle_how_to_contribute": {"en": "How would you like to contribute to saving the environment today?", "ar": "كيف تود المساهمة في حماية البيئة اليوم؟"},
  "recycle_no_requests": {"en": "You haven't submitted any recycle requests yet.", "ar": "لم تقم بإرسال أي طلبات إعادة تدوير بعد."},
  "recycle_please_login": {"en": "Please login first", "ar": "الرجاء تسجيل الدخول أولاً"},
  "recycle_plastic": {"en": "Plastic", "ar": "بلاستيك"},
  "recycle_glass": {"en": "Glass", "ar": "زجاج"},
  "recycle_paper": {"en": "Paper", "ar": "ورق"},
  "recycle_metal": {"en": "Metal", "ar": "معادن"},
  "recycle_electronics": {"en": "Electronics", "ar": "إلكترونيات"},
  "recycle_batteries": {"en": "Batteries", "ar": "بطاريات"},

  "store_order_confirmed": {"en": "Confirmed", "ar": "تم التأكيد"},
  "store_order_processing": {"en": "Processing", "ar": "قيد المعالجة"},
  "store_order_shipping": {"en": "Shipping", "ar": "قيد التوصيل"},
  "store_order_delivered": {"en": "Delivered", "ar": "تم التسليم"},
  "store_order_cancelled": {"en": "Cancelled", "ar": "ملغي"},
  "store_my_orders": {"en": "📦 My Orders", "ar": "📦 طلباتي"},

  "smart_capsule_title": {"en": "Agriculture Smart Capsule 🌱", "ar": "الكبسولة الذكية الزراعية 🌱"},
  "smart_capsule_gift": {"en": "Your gift from Namaa", "ar": "هديتك من نماء"},
  "smart_capsule_what_is_it": {"en": "What is the Smart Capsule?", "ar": "ما هي الكبسولة الذكية؟"},
  "smart_capsule_what_is_it_desc": {"en": "It is a small agricultural capsule containing seeds and basic nutrients, designed to make the home planting experience fun and practical.", "ar": "هي كبسولة زراعية صغيرة تحتوي على بذور ومغذيات أولية، ومصممة لتسهيل تجربة الزراعة المنزلية بطريقة ممتعة وعملية."},
  "smart_capsule_why_special": {"en": "Why is it a special gift?", "ar": "لماذا تعتبر هدية مميزة؟"},
  "smart_capsule_why_special_desc": {"en": "Because it links buying from the Namaa store with an environmental impact and a real farming experience, which enhances the idea of sustainability and gives the user added value.", "ar": "لأنها تربط بين الشراء من متجر نماء وبين أثر بيئي وتجربة زراعية حقيقية، وهذا يعزز فكرة الاستدامة ويعطي المستخدم قيمة إضافية."},
  "smart_capsule_how_to_use": {"en": "How does the user benefit?", "ar": "كيف يستفيد منها المستخدم؟"},
  "smart_capsule_how_to_use_desc": {"en": "They can easily plant it at home or in a small garden, and track the plant's growth as an experience connected to the app's environmental message.", "ar": "يمكنه زراعتها بسهولة في المنزل أو الحديقة الصغيرة، ومتابعة نمو النبات كتجربة مرتبطة برسالة التطبيق البيئية."},
  "smart_capsule_future_dev": {"en": "Future Development Proposal", "ar": "اقتراح تطوير مستقبلي"},
  "smart_capsule_future_dev_desc": {"en": "The capsule can later be linked within the app to a plant growth tracking page, providing watering reminders and smart planting tips.", "ar": "يمكن لاحقاً ربط الكبسولة داخل التطبيق بصفحة متابعة نمو النبات، وتذكير بالسقاية، ونصائح زراعية ذكية."},

  "challenges_initiatives_history": {"en": "My Initiatives History ✨", "ar": "سجل مبادراتي ✨"},
  "challenges_no_initiatives": {"en": "You haven't published any (Before & After) initiative yet.", "ar": "لم تنشر أي مبادرة (قبل وبعد) حتى الآن."},
  "challenges_login_first": {"en": "Please login", "ar": "الرجاء تسجيل الدخول"},

  "help_q_collect_points": {"en": "How do I collect points?", "ar": "كيف أجمع النقاط؟"},
  "help_a_collect_points": {"en": "You collect points by completing daily tasks and weekly challenges. Each task has a specific number of points.", "ar": "تجمع النقاط بإكمال المهام اليومية والتحديات الأسبوعية. كل مهمة لها عدد محدد من النقاط."},
  "help_q_discount_coupon": {"en": "How do I use a discount coupon?", "ar": "كيف أستخدم كوبون الخصم؟"},
  "help_a_discount_coupon": {"en": "When you reach 300 points, you automatically get a 20% discount coupon in the Eco Store, valid for 7 days.", "ar": "عند وصولك لـ 300 نقطة تحصل تلقائياً على كوبون خصم 20% في المتجر البيئي لمدة 7 أيام."},
  "help_q_tree_growth": {"en": "How does my tree grow?", "ar": "كيف تنمو شجرتي؟"},
  "help_a_tree_growth": {"en": "Your tree grows with every point you collect. The more points you gain, the bigger and greener your tree becomes!", "ar": "شجرتك تنمو مع كل نقاط تجمعها. كلما زادت نقاطك كلما أصبحت شجرتك أكبر وأكثر خضرة!"},
  "help_q_invite_friends": {"en": "How do I invite friends?", "ar": "كيف أدعو أصدقائي؟"},
  "help_a_invite_friends": {"en": "From the 'My Account' page, click on 'Invite Friend' and share your invitation code.", "ar": "من صفحة حسابي اضغط على \"دعوة صديق\" وشارك رمز الدعوة الخاص بك."},
  "help_q_is_free": {"en": "Is the app free?", "ar": "هل التطبيق مجاني؟"},
  "help_a_is_free": {"en": "Yes! The Namaa app is 100% free and requires no subscription.", "ar": "نعم! تطبيق نماء مجاني 100% ولا يحتاج اشتراك."},
  "help_q_contact_support": {"en": "How do I contact support?", "ar": "كيف أتواصل مع الدعم؟"},
  "help_a_contact_support": {"en": "You can contact us via email: namaa.support@gmail.com", "ar": "يمكنك التواصل معنا عبر البريد الإلكتروني: namaa.support@gmail.com"},
  "help_support_title": {"en": "Support", "ar": "الدعم"},

  "admin_review_tasks_title": {"en": "Admin - Review Tasks", "ar": "Admin - مراجعة المهام"},
  "admin_no_tasks_to_review": {"en": "No tasks to review", "ar": "لا توجد مهام للمراجعة"},

  "acc_password_req": {"en": "Password must be at least 8 characters long,\\ninclude: uppercase, lowercase, number, and special character", "ar": "كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل\\nوتشمل: حرف كبير، صغير، رقم، ورمز خاص"},
  "acc_password_mismatch": {"en": "Passwords do not match", "ar": "كلمتا المرور غير متطابقتين"},
  "acc_fill_passwords": {"en": "Please fill all password fields", "ar": "يرجى ملء جميع حقول كلمة المرور"},
  "user_profile_user": {"en": "User", "ar": "مستخدم"},

  "review_name_1": {"en": "Mohammed Al-Khalid", "ar": "محمد الخالد"},
  "review_name_2": {"en": "Dana Saad", "ar": "دانه سعد"},
  "review_name_3": {"en": "Sara Ahmed", "ar": "سارة أحمد"},
  "review_date_1": {"en": "2 days ago", "ar": "منذ يومين"},
  "review_date_2": {"en": "1 week ago", "ar": "منذ أسبوع"},
  "review_date_3": {"en": "1 month ago", "ar": "منذ شهر"},
  "review_text_1": {"en": "Very excellent product and perfectly matches the description! Highly recommended.", "ar": "منتج رائع جداً ومطابق للمواصفات! أنصح به للجميع."},
  "review_text_2": {"en": "Excellent quality, but the packaging could be better.", "ar": "جودة ممتازة، لكن التغليف كان يمكن أن يكون أفضل."},
  "review_text_3": {"en": "Loved it! A great step towards saving the environment. Thanks Namaa.", "ar": "أحببته! خطوة رائعة للمحافظة على البيئة شكراً نماء."},

  "store_check_db_title": {"en": "🔍 Checking Namaa store DB...", "ar": "🔍 فحص قاعدة بيانات منتجات نماء..."},
  "store_check_db_count": {"en": "📊 Number of products in Firestore: {count}", "ar": "📊 عدد المنتجات في Firestore: {count}"},
  "store_check_db_error": {"en": "❌ Error checking: {error}", "ar": "❌ خطأ أثناء الفحص: {error}"},
  "store_check_db_warning": {"en": "⚠️ Warning: No products found!", "ar": "⚠️ تحذير: لا توجد منتجات حالياً!"},
  "store_check_db_list": {"en": "📋 List of first 5 products:", "ar": "📋 قائمة بأسماء أول 5 منتجات:"},
  "acc_error_prefix": {"en": "An error occurred: {error}", "ar": "حدث خطأ: {error}"},
  "store_error_prefix": {"en": "Sorry, an error occurred: {error}", "ar": "عذراً، حدث خطأ: {error}"}
}

extra_info = {
  "@store_check_db_count": { "placeholders": { "count": { "type": "int" } } },
  "@store_check_db_error": { "placeholders": { "error": { "type": "String" } } },
  "@acc_error_prefix": { "placeholders": { "error": { "type": "String" } } },
  "@store_error_prefix": { "placeholders": { "error": { "type": "String" } } }
}

def update_arb(path, lang):
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    for key, value in new_keys.items():
        if key not in data:
            data[key] = value[lang]

    for key, val in extra_info.items():
        if key not in data:
            data[key] = val
            
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

update_arb(ar_path, "ar")
update_arb(en_path, "en")

print("ARB files updated successfully")
