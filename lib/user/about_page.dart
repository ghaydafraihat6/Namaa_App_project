import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  static const String routeName = '/about';

  @override
  Widget build(BuildContext context) {
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
                          "نـمـاء",
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "بصمتك الخضراء تبدأ من هنا",
                          style: TextStyle(
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
                  _buildSectionTitle("🌿 من نحن"),
                  const SizedBox(height: 12),
                  _buildCard(
                    child: const Text(
                      "نماء هو تطبيق بيئي تفاعلي يهدف إلى تحفيز الأفراد على اتخاذ خطوات يومية نحو حياة أكثر استدامة. نؤمن بأن كل فعل إيجابي صغير، مهما كان بسيطاً، يمكن أن يُحدث فرقاً حقيقياً في عالمنا.",
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
                  _buildSectionTitle("🎯 رسالتنا"),
                  const SizedBox(height: 12),
                  _buildMissionCard(),

                  const SizedBox(height: 24),

                  // ── ماذا يقدم نماء ──
                  _buildSectionTitle("✨ ماذا يقدم نماء؟"),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.recycling,
                    color: const Color(0xFF52B788),
                    title: "مهام بيئية يومية",
                    subtitle:
                        "إعادة تدوير، توفير الماء والكهرباء، المشي بدل السيارة",
                  ),
                  _buildFeatureItem(
                    icon: Icons.park,
                    color: Color(0xFF386641),
                    title: "شجرة تنمو معك",
                    subtitle: "شجرتك الرقمية تكبر كلما أنجزت مهاماً بيئية أكثر",
                  ),
                  _buildFeatureItem(
                    icon: Icons.emoji_events,
                    color: Color(0xFFF4A261),
                    title: "شارات وإنجازات",
                    subtitle: "اجمع الشارات واثبت أنك بطل البيئة الحقيقي",
                  ),
                  _buildFeatureItem(
                    icon: Icons.shopping_bag_outlined,
                    color: Color(0xFF2196F3),
                    title: "متجر بيئي",
                    subtitle: "استبدل نقاطك بخصومات على منتجات صديقة للبيئة",
                  ),
                  _buildFeatureItem(
                    icon: Icons.leaderboard,
                    color: Color(0xFFE63946),
                    title: "لوحة الصدارة",
                    subtitle: "تنافس مع أصدقائك ومن حولك لتكون الأكثر تأثيراً",
                  ),
                  _buildFeatureItem(
                    icon: Icons.science,
                    color: Color(0xFF9B5DE5),
                    title: "تجارب بيئية",
                    subtitle: "اكتشف كيف تُحدث فرقاً من خلال تجارب علمية ممتعة",
                  ),

                  SizedBox(height: 24),

                  // ── فريق العمل ──
                  _buildSectionTitle("👥 فريق نماء"),
                  SizedBox(height: 12),
                  _buildTeamSection(),

                  SizedBox(height: 24),

                  // ── إحصائيات ──
                  _buildSectionTitle("📊 نماء بالأرقام"),
                  SizedBox(height: 12),
                  _buildStatsRow(),

                  SizedBox(height: 24),

                  // ── تواصل معنا ──
                  _buildSectionTitle("📬 تواصل معنا"),
                  SizedBox(height: 12),
                  _buildContactCard(),

                  SizedBox(height: 24),

                  // ── Footer ──
                  _buildFooter(),

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

  Widget _buildMissionCard() {
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
      child: const Column(
        children: [
          Text(
            "\"نؤمن بأن حماية البيئة مسؤولية الجميع، وأن التغيير الحقيقي يبدأ بخطوة صغيرة واحدة كل يوم\"",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              height: 1.8,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            "— فريق نماء 🌱",
            style: TextStyle(
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

  Widget _buildTeamSection() {
    final List<Map<String, String>> team = [
      {"name": "غيداء", "role": "مطور التطبيق", "emoji": "👩‍💻"},
      {"name": "فريق نماء", "role": "التصميم والمحتوى", "emoji": "🎨"},
      {"name": "المجتمع", "role": "شركاء التغيير", "emoji": "🌍"},
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

  Widget _buildStatsRow() {
    final List<Map<String, String>> stats = [
      {"value": "١٠+", "label": "مهام يومية"},
      {"value": "٥", "label": "مستويات"},
      {"value": "٢٠+", "label": "شارة"},
      {"value": "١٠٠%", "label": "مجاني"},
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "🌱 نماء",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "معاً نبني مستقبلاً أخضر أفضل",
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "الإصدار 1.0.0 • 2026",
            style: TextStyle(
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
