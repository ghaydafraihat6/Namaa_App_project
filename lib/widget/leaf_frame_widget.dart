import 'package:flutter/material.dart';

/// إطار الأوراق الدائري - يستخدم الصورة الشفافة (PNG) المختارة من طرف المستخدم
class LeafFrameWidget extends StatelessWidget {
  final double size;
  final Widget child;

  const LeafFrameWidget({
    super.key,
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الودجت داخل الإطار (مثل الصورة الشخصية أو الأيقونة)
          child,
          // صورة الإطار الشفافة (PNG) التي تم رفعها
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/leaf_frame.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
