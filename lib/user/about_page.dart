import 'package:flutter/material.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = l10n.arabic == "العربية";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),
      body: CustomScrollView(
        slivers: [
          // ── Hero AppBar ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF386641),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1B4332),
                          Color(0xFF386641),
                          Color(0xFF52B788),
                        ],
                      ),
                    ),
                  ),
                  // دوائر زخرفية
                  Positioned(
                    top: -40,
                    right: -40,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: -30,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // المحتوى
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF4DD).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Image.asset(
                            'assets/images/logo_namaa.png',
                            width: 80,
                            height: 80,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          isArabic ? "نـمـاء" : "Namaa",
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isArabic ? "بصمتك الخضراء تبدأ من هنا" : "Your green footprint starts here",
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── المحتوى ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ── من نحن ──
                  _buildSectionTitle(isArabic ? "🌿 من نحن" : "🌿 Who We Are"),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: Text(
                      isArabic
                          ? "نماء هو تطبيق بيئي تفاعلي يهدف إلى تحفيز الأفراد على اتخاذ خطوات يومية نحو حياة أكثر استدامة. نؤمن بأن كل فعل إيجابي صغير، مهما كان بسيطاً، يمكن أن يُحدث فرقاً حقيقياً في عالمنا."
                          : "Namaa is an interactive eco-friendly app aimed at motivating individuals to take daily steps toward a more sustainable life. We believe that every small positive action, however simple, can make a real difference in our world.",
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.8,
                        color: Color(0xFF2D3A2E),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── رسالتنا ──
                  _buildSectionTitle(isArabic ? "🎯 رسالتنا" : "🎯 Our Mission"),
                  const SizedBox(height: 12),
                  _buildMissionCard(isArabic),

                  const SizedBox(height: 24),

                  // ── ماذا يقدم نماء ──
                  _buildSectionTitle(isArabic ? "✨ ماذا يقدم نماء؟" : "✨ What does Namaa offer?"),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.recycling,
                    color: const Color(0xFF52B788),
                    title: isArabic ? "مهام بيئية يومية" : "Daily eco-tasks",
                    subtitle: isArabic ? "إعادة تدوير، توفير الماء والكهرباء، المشي بدل السيارة" : "Recycling, saving water and electricity, walking instead of driving",
                  ),
                  _buildFeatureItem(
                    icon: Icons.park,
                    color: const Color(0xFF386641),
                    title: isArabic ? "شجرة تنمو معك" : "A tree that grows with you",
                    subtitle: isArabic ? "شجرتك الرقمية تكبر كلما أنجزت مهاماً بيئية أكثر" : "Your digital tree grows as you complete more eco-tasks",
                  ),
                  _buildFeatureItem(
                    icon: Icons.emoji_events,
                    color: const Color(0xFFF4A261),
                    title: isArabic ? "شارات وإنجازات" : "Badges and Achievements",
                    subtitle: isArabic ? "اجمع الشارات واثبت أنك بطل البيئة الحقيقي" : "Collect badges and prove you're a true eco-hero",
                  ),
                  _buildFeatureItem(
                    icon: Icons.shopping_bag_outlined,
                    color: const Color(0xFF2196F3),
                    title: isArabic ? "متجر بيئي" : "Eco Store",
                    subtitle: isArabic ? "استبدل نقاطك بخصومات على منتجات صديقة للبيئة" : "Exchange your points for discounts on eco-friendly products",
                  ),
                  _buildFeatureItem(
                    icon: Icons.leaderboard,
                    color: const Color(0xFFE63946),
                    title: isArabic ? "لوحة الصدارة" : "Leaderboard",
                    subtitle: isArabic ? "تنافس مع أصدقائك ومن حولك لتكون الأكثر تأثيراً" : "Compete with friends and others to be the most impactful",
                  ),
                  _buildFeatureItem(
                    icon: Icons.science,
                    color: const Color(0xFF9B5DE5),
                    title: isArabic ? "تجارب بيئية" : "Eco Experiments",
                    subtitle: isArabic ? "اكتشف كيف تُحدث فرقاً من خلال تجارب علمية ممتعة" : "Discover how to make a difference through fun scientific experiments",
                  ),

                  SizedBox(height: 24),

                  // ── فريق العمل ──
                  _buildSectionTitle(isArabic ? "👥 فريق نماء" : "👥 Namaa Team"),
                  const SizedBox(height: 12),
                  _buildTeamSection(isArabic),

                  SizedBox(height: 24),

                  // ── إحصائيات ──
                  _buildSectionTitle(isArabic ? "📊 نماء بالأرقام" : "📊 Namaa in Numbers"),
                  const SizedBox(height: 12),
                  _buildStatsRow(isArabic),

                  const SizedBox(height: 24),

                  // ── تواصل معنا ──
                  _buildSectionTitle(isArabic ? "📬 تواصل معنا" : "📬 Contact Us"),
                  const SizedBox(height: 12),
                  _buildContactCard(),

                  const SizedBox(height: 24),

                  // ── Footer ──
                  _buildFooter(isArabic),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets المساعدة ──

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF386641),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B4332),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMissionCard(bool isArabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF386641), Color(0xFF52B788)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF386641).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isArabic 
              ? "\"نؤمن بأن حماية البيئة مسؤولية الجميع، وأن التغيير الحقيقي يبدأ بخطوة صغيرة واحدة كل يوم\""
              : "\"We believe that protecting the environment is everyone's responsibility, and real change starts with one small step every day\"",
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              height: 1.8,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isArabic ? "— فريق نماء 🌱" : "— Namaa Team 🌱",
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
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
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B4332),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(bool isArabic) {
    final List<Map<String, String>> team = [
      {"name": isArabic ? "غيداء" : "Ghayda", "role": isArabic ? "مطور التطبيق" : "App Developer", "emoji": "👩‍💻"},
      {"name": isArabic ? "فريق نماء" : "Namaa Team", "role": isArabic ? "التصميم والمحتوى" : "Design & Content", "emoji": "🎨"},
      {"name": isArabic ? "المجتمع" : "Community", "role": isArabic ? "شركاء التغيير" : "Partners of Change", "emoji": "🌍"},
    ];

    return Row(
      children: team.map((member) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  member["emoji"]!,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  member["name"]!,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1B4332),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),
                Text(
                  member["role"]!,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsRow(bool isArabic) {
    final List<Map<String, String>> stats = [
      {"value": "10+", "label": isArabic ? "مهام يومية" : "Daily Tasks"},
      {"value": "5", "label": isArabic ? "مستويات" : "Levels"},
      {"value": "20+", "label": isArabic ? "شارة" : "Badges"},
      {"value": "100%", "label": isArabic ? "مجاني" : "Free"},
    ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEBF4DD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  stat["value"]!,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF386641),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat["label"]!,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF52835E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContactCard() {
    return _buildCard(
      child: Column(
        children: [
          _buildContactRow(
            icon: Icons.email_outlined,
            text: "namaa.app@gmail.com",
            color: const Color(0xFF386641),
          ),
          const Divider(height: 20),
          _buildContactRow(
            icon: Icons.language,
            text: "www.namaa-app.com",
            color: const Color(0xFF2196F3),
          ),
          const Divider(height: 20),
          _buildContactRow(
            icon: Icons.camera_alt,
            text: "@namaa_app",
            color: const Color(0xFFE1306C),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            color: Color(0xFF2D3A2E),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isArabic ? "🌱 نماء" : "🌱 Namaa",
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isArabic ? "معاً نبني مستقبلاً أخضر أفضل" : "Together we build a better green future",
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isArabic ? "الإصدار 1.0.0 • 2026" : "Version 1.0.0 • 2026",
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
