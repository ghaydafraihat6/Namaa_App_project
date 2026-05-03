import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'recycle_submission_page.dart';
import 'recycle_tasks_page.dart';
import 'recycle_history_page.dart';

class RecycleDashboard extends StatelessWidget {
  const RecycleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const Color primaryGreen = Color(0xFF386641);
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(isAr ? l10n.recycle_dashboard_title : "Recycle Center",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: Colors.white, fontFamily: 'Cairo')),
        backgroundColor: primaryGreen,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAr ? l10n.recycle_welcome : "Welcome to NAMAA!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryGreen, fontFamily: 'Cairo')),
            Text(isAr ? l10n.recycle_how_to_contribute : "How would you like to help the environment today?",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.grey, fontFamily: 'Cairo')),
            const SizedBox(height: 30),

            // كرت طلب تجميع ميداني (Submission)
            _buildOptionCard(
              context,
              title: isAr ? "طلب تجميع مواد تدوير" : "Recycling Collection Request",
              desc: isAr ? "ارفع صورة لموادك (بلاستيك، ورق..) وحدد موقعك لنصل إليك." : "Upload a photo of your materials (plastics, paper...) and set location for pickup.",
              icon: Icons.local_shipping_rounded,
              color: primaryGreen,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecycleSubmissionPage())),
            ),

            const SizedBox(height: 20),

            // كرت مهام سريعة (Tasks)
            _buildOptionCard(
              context,
              title: isAr ? "مهام بيئية يومية" : "Daily Eco Tasks",
              desc: isAr ? "نفذ مهام بسيطة في منزلك واكسب نقاطاً فورية لشجرتك." : "Complete simple daily tasks at home and earn instant points.",
              icon: Icons.task_alt_rounded,
              color: const Color(0xFFF4A261),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecycleTasksPage())),
            ),

            const SizedBox(height: 20),

            // كرت سجل الطلبات (History)
            _buildOptionCard(
              context,
              title: isAr ? "سجل طلباتي" : "My Requests History",
              desc: isAr ? "تابع طلبات إعادة التدوير السابقة وحالتها وصورها." : "Track your previous recycling requests, statuses, and photos.",
              icon: Icons.history_rounded,
              color: Colors.blueAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecycleHistoryPage())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 35),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, fontFamily: 'Cairo')),
                  const SizedBox(height: 5),
                  Text(desc, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.grey, fontFamily: 'Cairo')),
                ],
              ),
            ),
            Icon((Directionality.of(context) == TextDirection.rtl) ? Icons.chevron_left : Icons.chevron_right, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}