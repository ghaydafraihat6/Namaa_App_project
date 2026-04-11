import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SmartCapsulePage extends StatelessWidget {
  const SmartCapsulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF2),
      appBar: AppBar(
        title: Text(
          l10n.smart_capsule_title,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF386641),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF386641), Color(0xFF52B788)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  '🎁',
                  style: TextStyle(fontSize: 70),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.smart_capsule_gift,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.smart_capsule_title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _card(
            title: l10n.smart_capsule_what_is_it,
            body:
            l10n.smart_capsule_what_is_it_desc,
          ),
          _card(
            title: l10n.smart_capsule_how_to_use,
            body:
            l10n.smart_capsule_how_to_use_desc,
          ),
          _card(
            title: l10n.smart_capsule_why_special,
            body:
            l10n.smart_capsule_why_special_desc,
          ),
          _card(
            title: l10n.smart_capsule_future_dev,
            body:
            l10n.smart_capsule_future_dev_desc,
          ),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String body,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              height: 1.8,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}