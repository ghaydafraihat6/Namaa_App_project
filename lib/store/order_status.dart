import 'package:namaa_project_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum OrderStatus {
  pending('pending', Color(0xFFF59E0B), '⏳'),
  confirmed('confirmed', Color(0xFF3B82F6), '✅'),
  shipping('shipping', Color(0xFF8B5CF6), '🚚'),
  delivered('delivered', Color(0xFF386641), '🎉'),
  cancelled('cancelled', Colors.red, '❌');

  const OrderStatus(this.key, this.color, this.icon);

  final String key;
  final Color color;
  final String icon;

  String getLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'pending': return l10n.store_order_processing;
      case 'confirmed': return l10n.store_order_confirmed;
      case 'shipping': return l10n.store_order_shipping;
      case 'delivered': return l10n.store_order_delivered;
      case 'cancelled': return l10n.store_order_cancelled;
      default: return key;
    }
  }

  // Temporary getter for backward compatibility if needed, but better to use getLabel
  @Deprecated('Use getLabel(context) instead')
  String get label => key; 

  Color get bg => color.withOpacity(0.12);

  static OrderStatus fromLabel(String statusStr) {
    statusStr = statusStr.toLowerCase();
    return OrderStatus.values.firstWhere(
      (s) => s.key == statusStr,
      orElse: () => OrderStatus.pending,
    );
  }
}