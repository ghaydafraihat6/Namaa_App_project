import 'package:flutter/material.dart';

class NotificationsListPage extends StatelessWidget {
  const NotificationsListPage({super.key});
  static const String routeName = '/notifications-list';

  @override
  Widget build(BuildContext context) {
    // قائمة الإشعارات الوهمية التي تعزز إنجازات المستخدم وتدعمه
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'أكمل مهامك اليومية! 💧',
        'body': 'شجرتك تحتاج إلى الرعاية، قم بإكمال بضع مهام يومية صغيرة لزيادة نقاطك ومساعدة شجرتك على النمو.',
        'time': 'قبل ساعتين',
        'icon': Icons.water_drop,
        'color': Colors.blue,
      },
      {
        'title': 'إنجاز جديد 🏆',
        'body': 'تهانينا! لقد حصلت على شارة "صديق البيئة". واصل جهودك الرائعة في حماية الأرض.',
        'time': 'أمس',
        'icon': Icons.emoji_events,
        'color': Colors.amber,
      },
      {
        'title': 'تحدي الأسبوع بانتظارك 🚴',
        'body': 'شارك في "تحدي الدراجة" واكسب 200 نقطة إضافية عند استخدام الدراجة بدلاً من السيارة.',
        'time': 'منذ يومين',
        'icon': Icons.directions_bike,
        'color': const Color(0xFF52B788),
      },
      {
        'title': 'مكافأة في المتجر 🎁',
        'body': 'لديك كوبون خصم حصري بنسبة 20% متاح الآن في المتجر البيئي. لا تفوت الفرصة.',
        'time': 'منذ 3 أيام',
        'icon': Icons.local_offer,
        'color': const Color(0xFFE63946),
      },
      {
        'title': 'ترقية المستوى 🌟',
        'body': 'لقد وصلت إلى المستوى 3! تمت ترقية شجرتك وأصبحت الآن شجرة صغيرة مزدهرة.',
        'time': 'الأسبوع الماضي',
        'icon': Icons.star,
        'color': Colors.orangeAccent,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notify = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notify['color'].withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notify['icon'],
                    color: notify['color'],
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notify['title'],
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B2E1F),
                              ),
                            ),
                          ),
                          Text(
                            notify['time'],
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notify['body'],
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: Color(0xFF555555),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
