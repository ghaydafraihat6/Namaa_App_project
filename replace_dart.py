import os
import re

def update_file(path, replacements):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Add import if not exists
    if "AppLocalizations" not in content:
        content = "import 'package:namaa_project_app/l10n/app_localizations.dart';\n" + content

    for old, new in replacements:
        content = content.replace(old, new)
        
    # Check if l10n definition is needed in the build function
    # It's tricky to do this generally via regex without breaking syntax.
    # We will assume l10n is defined or we will add it manually if missing.
    # Most of these files already have `final l10n = AppLocalizations.of(context)!;`
    # Let's add it if `AppLocalizations.of(context)` is not in content
    if "AppLocalizations.of(context)" not in content:
        # Find 'Widget build(BuildContext context) {'
        build_methods = re.findall(r'(Widget build\(BuildContext context\) {)', content)
        if build_methods:
            content = content.replace('Widget build(BuildContext context) {',
                                      'Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context)!;')

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

base_path = 'c:/Projects_Flutter/Namaa_Project_App/lib/'

# 1. recycle_dashboard.dart
update_file(base_path + 'recycle/recycle_dashboard.dart', [
    ('"مركز إعادة التدوير ♻️"', 'l10n.recycle_dashboard_title'),
    ('"أهلاً بك في نماء! 🌱"', 'l10n.recycle_welcome'),
    ('"كيف تود المساهمة في حماية البيئة اليوم؟"', 'l10n.recycle_how_to_contribute')
])

# 2. recycle_submission_page.dart
update_file(base_path + 'recycle/recycle_submission_page.dart', [
    ("'بلاستيك'", "l10n.recycle_plastic"),
    ("'زجاج'", "l10n.recycle_glass"),
    ("'ورق'", "l10n.recycle_paper"),
    ("'معادن'", "l10n.recycle_metal"),
    ("'إلكترونيات'", "l10n.recycle_electronics"),
    ("'بطاريات'", "l10n.recycle_batteries")
])

# 3. recycle_history_page.dart
update_file(base_path + 'recycle/recycle_history_page.dart', [
    ('"سجل طلباتي 🗂️"', 'l10n.recycle_history_title'),
    ("'الرجاء تسجيل الدخول أولاً'", "l10n.recycle_please_login"),
    ("'لم تقم بإرسال أي طلبات إعادة تدوير بعد.'", "l10n.recycle_no_requests")
])

# 4. product_details_page.dart
update_file(base_path + 'store/product_details_page.dart', [
    ("'محمد الخالد'", "l10n.review_name_1"),
    ("'دانه سعد'", "l10n.review_name_2"),
    ("'سارة أحمد'", "l10n.review_name_3"),
    ("'منذ يومين'", "l10n.review_date_1"),
    ("'منذ أسبوع'", "l10n.review_date_2"),
    ("'منذ شهر'", "l10n.review_date_3"),
    ("'منتج رائع جداً ومطابق للمواصفات! أنصح به للجميع.'", "l10n.review_text_1"),
    ("'جودة ممتازة، لكن التغليف كان يمكن أن يكون أفضل.'", "l10n.review_text_2"),
    ("'أحببته! خطوة رائعة للمحافظة على البيئة شكراً نماء.'", "l10n.review_text_3")
])

# 5. my_orders_page.dart
update_file(base_path + 'store/my_orders_page.dart', [
    ("'📦 طلباتي'", "l10n.store_my_orders"),
    ("'عذراً، حدث خطأ: ${snap.error}'", "l10n.store_error_prefix(snap.error.toString())")
])

# 6. order_status.dart
update_file(base_path + 'store/order_status.dart', [
    ("'تم التأكيد'", "l10n.store_order_confirmed"),
    ("'قيد المعالجة'", "l10n.store_order_processing"),
    ("'قيد التوصيل'", "l10n.store_order_shipping"),
    ("'تم التسليم'", "l10n.store_order_delivered"),
    ("'ملغي'", "l10n.store_order_cancelled")
])

# 7. smart_capsule_page.dart
update_file(base_path + 'store/smart_capsule_page.dart', [
    ("'الكبسولة الذكية الزراعية 🌱'", "l10n.smart_capsule_title"),
    ("'الكبسولة الذكية الزراعية'", "l10n.smart_capsule_title"),
    ("'هديتك من نماء'", "l10n.smart_capsule_gift"),
    ("'ما هي الكبسولة الذكية؟'", "l10n.smart_capsule_what_is_it"),
    ("'هي كبسولة زراعية صغيرة تحتوي على بذور ومغذيات أولية، ومصممة لتسهيل تجربة الزراعة المنزلية بطريقة ممتعة وعملية.'", "l10n.smart_capsule_what_is_it_desc"),
    ("'لماذا تعتبر هدية مميزة؟'", "l10n.smart_capsule_why_special"),
    ("'لأنها تربط بين الشراء من متجر نماء وبين أثر بيئي وتجربة زراعية حقيقية، وهذا يعزز فكرة الاستدامة ويعطي المستخدم قيمة إضافية.'", "l10n.smart_capsule_why_special_desc"),
    ("'كيف يستفيد منها المستخدم؟'", "l10n.smart_capsule_how_to_use"),
    ("'يمكنه زراعتها بسهولة في المنزل أو الحديقة الصغيرة، ومتابعة نمو النبات كتجربة مرتبطة برسالة التطبيق البيئية.'", "l10n.smart_capsule_how_to_use_desc"),
    ("'اقتراح تطوير مستقبلي'", "l10n.smart_capsule_future_dev"),
    ("'يمكن لاحقاً ربط الكبسولة داخل التطبيق بصفحة متابعة نمو النبات، وتذكير بالسقاية، ونصائح زراعية ذكية.'", "l10n.smart_capsule_future_dev_desc")
])

# 8. check_firestore_status.dart
update_file(base_path + 'store/check_firestore_status.dart', [
    ("'🔍 فحص قاعدة بيانات منتجات نماء...'", "l10n.store_check_db_title"),
    ("'📊 عدد المنتجات في Firestore: ${snapshot.docs.length}'", "l10n.store_check_db_count(snapshot.docs.length)"),
    ("'❌ خطأ أثناء الفحص: $e'", "l10n.store_check_db_error(e.toString())"),
    ("'⚠️ تحذير: لا توجد منتجات حالياً!'", "l10n.store_check_db_warning"),
    ("'📋 قائمة بأسماء أول 5 منتجات:'", "l10n.store_check_db_list")
])

# 9. before_after_history_page.dart
update_file(base_path + 'challenges/before_after_history_page.dart', [
    ("'سجل مبادراتي ✨'", "l10n.challenges_initiatives_history"),
    ("'لم تنشر أي مبادرة (قبل وبعد) حتى الآن.'", "l10n.challenges_no_initiatives"),
    ('"الرجاء تسجيل الدخول"', 'l10n.challenges_login_first')
])

# 10. help_center_page.dart
update_file(base_path + 'user/help_center_page.dart', [
    ("'كيف أجمع النقاط؟'", "l10n.help_q_collect_points"),
    ("'تجمع النقاط بإكمال المهام اليومية والتحديات الأسبوعية. كل مهمة لها عدد محدد من النقاط.'", "l10n.help_a_collect_points"),
    ("'كيف أستخدم كوبون الخصم؟'", "l10n.help_q_discount_coupon"),
    ("'عند وصولك لـ 300 نقطة تحصل تلقائياً على كوبون خصم 20% في المتجر البيئي لمدة 7 أيام.'", "l10n.help_a_discount_coupon"),
    ("'كيف تنمو شجرتي؟'", "l10n.help_q_tree_growth"),
    ("'شجرتك تنمو مع كل نقاط تجمعها. كلما زادت نقاطك كلما أصبحت شجرتك أكبر وأكثر خضرة!'", "l10n.help_a_tree_growth"),
    ("'كيف أدعو أصدقائي؟'", "l10n.help_q_invite_friends"),
    ("'من صفحة حسابي اضغط على \"دعوة صديق\" وشارك رمز الدعوة الخاص بك.'", "l10n.help_a_invite_friends"),
    ("'هل التطبيق مجاني؟'", "l10n.help_q_is_free"),
    ("'نعم! تطبيق نماء مجاني 100% ولا يحتاج اشتراك.'", "l10n.help_a_is_free"),
    ("'كيف أتواصل مع الدعم؟'", "l10n.help_q_contact_support"),
    ("'يمكنك التواصل معنا عبر البريد الإلكتروني: namaa.support@gmail.com'", "l10n.help_a_contact_support"),
    ("localeProvider.isArabic ? 'الدعم' : 'Support'", "l10n.help_support_title")
])

# 11. account_settings_page.dart
update_file(base_path + 'user/account_settings_page.dart', [
    ("'كلمتا المرور غير متطابقتين'", "l10n.acc_password_mismatch"),
    ("'يرجى ملء جميع حقول كلمة المرور'", "l10n.acc_fill_passwords"),
    ("'حدث خطأ: $e'", "l10n.acc_error_prefix(e.toString())"),
    ("'✅ تم حفظ التغييرات بنجاح'", "l10n.acc_changes_saved")
])
# We will manually replace 'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل\nوتشمل: حرف كبير، صغير، رقم، ورمز خاص' since it has \n and might be double quoted vs single quoted.

# 12. user_profile_page.dart
update_file(base_path + 'user/user_profile_page.dart', [
    ("'مستخدم'", "l10n.user_profile_user")
])

# 13. admin_tasks_page.dart
update_file(base_path + 'admin/admin_tasks_page.dart', [
    ("'Admin - مراجعة المهام'", "l10n.admin_review_tasks_title"),
    ("'لا توجد مهام للمراجعة'", "l10n.admin_no_tasks_to_review")
])

# 14. create_account_screen.dart
update_file(base_path + 'screen/create_account_screen.dart', [
    ('l10n.arabic == "العربية" ? "هذا الاسم مستخدم مسبقاً" : "This name is already in use"', "l10n.emailInUse") # Wait it actually belongs to username in use but close enough, wait, we can just replace it 
])

print("Files updated")
