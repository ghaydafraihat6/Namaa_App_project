import 'package:flutter/material.dart';
import 'package:namaa_project_app/l10n/app_localizations.dart';
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  List<Map<String, String>> _getFaqs(bool isAr) => [
    {
      'q': isAr ? 'كيف أجمع النقاط؟' : 'How do I collect points?',
      'a': isAr ? 'تجمع النقاط بإكمال المهام اليومية والتحديات الأسبوعية. كل مهمة لها عدد محدد من النقاط.' : 'You collect points by completing daily tasks and weekly challenges. Each task has a set number of points.',
    },
    {
      'q': isAr ? 'كيف تنمو شجرتي؟' : 'How does my tree grow?',
      'a': isAr ? 'شجرتك تنمو مع كل نقاط تجمعها. كلما زادت نقاطك كلما أصبحت شجرتك أكبر وأكثر خضرة!' : 'Your tree grows with every point you collect. The more points you have, the bigger and greener your tree becomes!',
    },
    {
      'q': isAr ? 'كيف أستخدم كوبون الخصم؟' : 'How do I use a discount coupon?',
      'a': isAr ? 'عند وصولك لـ 300 نقطة تحصل تلقائياً على كوبون خصم 20% في المتجر البيئي لمدة 7 أيام.' : 'When you reach 300 points, you automatically get a 20% discount coupon in the eco store for 7 days.',
    },
    {
      'q': isAr ? 'كيف أدعو أصدقائي؟' : 'How do I invite friends?',
      'a': isAr ? 'من صفحة حسابي اضغط على "دعوة صديق" وشارك رمز الدعوة الخاص بك.' : 'Go to your profile, tap "Invite a Friend" and share your invitation code.',
    },
    {
      'q': isAr ? 'هل التطبيق مجاني؟' : 'Is the app free?',
      'a': isAr ? 'نعم! تطبيق نماء مجاني 100% ولا يحتاج اشتراك.' : 'Yes! Namaa is 100% free with no subscription needed.',
    },
    {
      'q': isAr ? 'كيف أتواصل مع الدعم؟' : 'How do I contact support?',
      'a': isAr ? 'يمكنك التواصل معنا عبر البريد الإلكتروني: namaa.support@gmail.com' : 'You can reach us at: namaa.support@gmail.com',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bool isAr = l10n.localeName == 'ar';
    final faqs = _getFaqs(isAr);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(l10n.help_title,
            style: const TextStyle(fontFamily: 'Cairo',
                fontSize: 19,
                fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: const Color(0xFF386641),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── هيدر ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4332), Color(0xFF386641)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: [
              Container(
                width: 150,
                height: 150,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF4DD).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/logo_namaa.png'),
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(l10n.help_how_can_we_help,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const SizedBox(height: 4),
              Text(l10n.help_find_answers,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white70)),
        ]),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 4),
            child: Text(l10n.help_faq,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey)),
          ),

          // ── الأسئلة ──
          ...faqs.map((faq) => _FaqItem(
            question: faq['q']!,
            answer: faq['a']!,
          )),

          const SizedBox(height: 20),

          // ── تواصل معنا ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8)],
            ),
            child: Column(children: [
              Text(l10n.help_did_not_find_answer,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B2E1F))),
              const SizedBox(height: 6),
              Text(l10n.help_contact_us,
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.email_outlined,
                    color: Color(0xFF386641), size: 20),
                const SizedBox(width: 6),
                const Text('namaa.app@gmail.com',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF386641))),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question, answer;
  const _FaqItem({required this.question, required this.answer});
  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8)],
      ),
      child: Column(children: [
        ListTile(
          onTap: () => setState(() => _expanded = !_expanded),
          title: Text(widget.question,
              style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B2E1F))),
          trailing: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _expanded ? 0.5 : 0,
            child: const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF386641)),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(widget.answer,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey,
                    height: 1.6)),
          ),
      ]),
    );
  }
}