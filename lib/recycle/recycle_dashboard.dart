import 'package:flutter/material.dart';
import 'recycle_submission_page.dart';
import 'recycle_tasks_page.dart';

class RecycleDashboard extends StatelessWidget {
  const RecycleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF386641);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text("مركز إعادة التدوير ♻️",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
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
            const Text("أهلاً بك في نماء! 🌱",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen, fontFamily: 'Cairo')),
            const Text("كيف تود المساهمة في حماية البيئة اليوم؟",
                style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Cairo')),
            const SizedBox(height: 30),

            // كرت طلب تجميع ميداني (Submission)
            _buildOptionCard(
              context,
              title: "طلب تجميع مواد تدوير",
              desc: "ارفع صورة لموادك (بلاستيك، ورق..) وحدد موقعك لنصل إليك.",
              icon: Icons.local_shipping_rounded,
              color: primaryGreen,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecycleSubmissionPage())),
            ),

            const SizedBox(height: 20),

            // كرت مهام سريعة (Tasks)
            _buildOptionCard(
              context,
              title: "مهام بيئية يومية",
              desc: "نفذ مهام بسيطة في منزلك واكسب نقاطاً فورية لشجرتك.",
              icon: Icons.task_alt_rounded,
              color: const Color(0xFFF4A261), // لون برتقالي للتميز
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RecycleTasksPage())),
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
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  const SizedBox(height: 5),
                  Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Cairo')),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}