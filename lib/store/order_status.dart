import 'package:flutter/material.dart';

enum OrderStatus {
  pending('قيد المعالجة', Color(0xFFF59E0B), '⏳'),
  confirmed('تم التأكيد',   Color(0xFF3B82F6), '✅'),
  shipping('قيد التوصيل',  Color(0xFF8B5CF6), '🚚'),
  delivered('تم التسليم',  Color(0xFF386641), '🎉'),
  cancelled('ملغي',         Colors.red,         '❌');

  const OrderStatus(this.label, this.color, this.icon);

  final String label;
  final Color  color;
  final String icon;

  Color get bg => color.withOpacity(0.12);

  static OrderStatus fromLabel(String label) =>
      OrderStatus.values.firstWhere(
            (s) => s.label == label,
        orElse: () => OrderStatus.pending,
      );
}