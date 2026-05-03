import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namaa_project_app/providers/locale_provider.dart';
import 'package:namaa_project_app/store/admin_orders_page.dart';
import 'package:namaa_project_app/admin/task_approvals_page.dart';
import 'package:namaa_project_app/admin/admin_users_page.dart';
import 'package:namaa_project_app/store/admin_reviews_page.dart';
import 'package:namaa_project_app/admin/admin_products_page.dart';
import 'package:namaa_project_app/admin/admin_recycle_requests_page.dart';
import 'package:namaa_project_app/store/store_localizer.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF2D5A3F),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // زر تبديل اللغة
              IconButton(
                onPressed: () {
                  final provider = Provider.of<LocaleProvider>(context, listen: false);
                  final isCurrentlyAr = provider.locale.languageCode == 'ar';
                  provider.setLocale(Locale(isCurrentlyAr ? 'en' : 'ar'));
                },
                icon: const Icon(Icons.language),
                tooltip: isAr ? 'تغيير اللغة' : 'Change Language',
              ),
              // زر تسجيل الخروج
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  // مسح حالة تسجيل الدخول المحفوظة
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                tooltip: isAr ? 'تسجيل الخروج' : 'Logout',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isAr ? 'لوحة تحكم الأدمن' : 'Admin Dashboard',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B4332), Color(0xFF386641), Color(0xFF52B788)],
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo_namaa.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Stats Cards ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── إحصائيات سريعة ──
                  Text(
                    isAr ? 'إحصائيات سريعة' : 'Quick Stats',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B2E1F),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Row 1: Pending Orders + Pending Tasks
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.shopping_bag_outlined,
                          label: isAr ? 'طلبات معلقة' : 'Pending Orders',
                          color: const Color(0xFFF4A261),
                          stream: FirebaseFirestore.instance
                              .collection('orders')
                              .where('status', isEqualTo: 'confirmed')
                              .snapshots(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.task_alt,
                          label: isAr ? 'مهام للمراجعة' : 'Tasks to Review',
                          color: const Color(0xFF52B788),
                          stream: FirebaseFirestore.instance
                              .collection('task_reviews')
                              .where('status', isEqualTo: 'pending')
                              .snapshots(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Total Users + Total Orders
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people_outline,
                          label: isAr ? 'المستخدمين' : 'Total Users',
                          color: const Color(0xFF6C63FF),
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .snapshots(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.receipt_long,
                          label: isAr ? 'إجمالي الطلبات' : 'Total Orders',
                          color: const Color(0xFFE8852A),
                          stream: FirebaseFirestore.instance
                              .collection('orders')
                              .snapshots(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── أدوات الإدارة ──
                  Text(
                    isAr ? 'أدوات الإدارة' : 'Management Tools',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B2E1F),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Card 1: إدارة الطلبات
                  _AdminToolCard(
                    icon: Icons.local_shipping_outlined,
                    title: isAr ? 'إدارة الطلبات' : 'Order Management',
                    subtitle: isAr
                        ? 'تتبع وتحديث حالة الطلبات'
                        : 'Track and update order statuses',
                    gradient: const [Color(0xFFF4A261), Color(0xFFE8852A)],
                    badgeStream: FirebaseFirestore.instance
                        .collection('orders')
                        .where('status', isEqualTo: 'confirmed')
                        .snapshots(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminOrdersPage()),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card 2: مراجعة المهام
                  _AdminToolCard(
                    icon: Icons.checklist_rtl,
                    title: isAr ? 'مراجعة المهام' : 'Review Tasks',
                    subtitle: isAr
                        ? 'الموافقة أو رفض المهام وإضافة النقاط'
                        : 'Approve or reject tasks and award points',
                    gradient: const [Color(0xFF52B788), Color(0xFF386641)],
                    badgeStream: FirebaseFirestore.instance
                        .collection('task_reviews')
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TaskApprovalsPage()),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card 3: إدارة المستخدمين
                  _AdminToolCard(
                    icon: Icons.people_alt_outlined,
                    title: isAr ? 'إدارة المستخدمين' : 'User Management',
                    subtitle: isAr
                        ? 'استعراض بيانات ونقاط المستخدمين'
                        : 'View users data and points',
                    gradient: const [Color(0xFF6C63FF), Color(0xFF4C43CD)],
                    badgeStream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminUsersPage()),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card 4: إدارة التقييمات
                  _AdminToolCard(
                    icon: Icons.star_outline_rounded,
                    title: isAr ? 'إدارة التقييمات' : 'Reviews Management',
                    subtitle: isAr
                        ? 'عرض وحذف تقييمات المنتجات'
                        : 'View and delete product reviews',
                    gradient: const [Color(0xFFFFB347), Color(0xFFFF6B35)],
                    badgeStream: FirebaseFirestore.instance
                        .collection('products')
                        .snapshots(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminReviewsPage()),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card 5: إدارة المنتجات
                  _AdminToolCard(
                    icon: Icons.inventory_2_outlined,
                    title: isAr ? 'إدارة المنتجات' : 'Product Management',
                    subtitle: isAr
                        ? 'إضافة السلع للمتجر البيئي'
                        : 'Add items to the Eco Store',
                    gradient: const [Color(0xFF2A9D8F), Color(0xFF21867A)],
                    badgeStream: FirebaseFirestore.instance
                        .collection('products')
                        .snapshots(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminProductsPage()),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card 6: استلام مواد التدوير
                  _AdminToolCard(
                    icon: Icons.recycling_outlined,
                    title: isAr ? 'طلبات التدوير' : 'Recycle Requests',
                    subtitle: isAr
                        ? 'استلام مواد إعادة التدوير من المستخدمين'
                        : 'Receive recycled materials from users',
                    gradient: const [Color(0xFF00B4D8), Color(0xFF0077B6)],
                    badgeStream: FirebaseFirestore.instance
                        .collection('recycle_requests')
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminRecycleRequestsPage()),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── آخر الطلبات ──
                  Text(
                    isAr ? 'آخر الطلبات' : 'Recent Orders',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B2E1F),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _RecentOrdersList(isAr: isAr),

                  const SizedBox(height: 28),

                  // ── آخر المهام ──
                  Text(
                    isAr ? 'آخر المهام المقدمة' : 'Recent Task Submissions',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B2E1F),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _RecentTasksList(isAr: isAr),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── بطاقة إحصائية ───
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Stream<QuerySnapshot> stream;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── بطاقة أداة إدارة ───
class _AdminToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final Stream<QuerySnapshot> badgeStream;
  final VoidCallback onTap;

  const _AdminToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.badgeStream,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: badgeStream,
              builder: (context, snap) {
                final count = snap.data?.docs.length ?? 0;
                if (count == 0) {
                  return const Icon(Icons.chevron_right, color: Colors.white70, size: 24);
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: gradient[1],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── آخر الطلبات ───
class _RecentOrdersList extends StatelessWidget {
  final bool isAr;
  const _RecentOrdersList({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                isAr ? 'لا توجد طلبات بعد' : 'No orders yet',
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: snapshot.data!.docs.map((doc) {
              final order = doc.data() as Map<String, dynamic>;
              final status = order['status'] ?? 'confirmed';
              final name = order['userName'] ?? (isAr ? 'مجهول' : 'Unknown');
              final total = (order['total'] as num?)?.toStringAsFixed(2) ?? '0.00';
              final ts = order['createdAt'] as Timestamp?;
              final date = ts?.toDate().toString().substring(0, 10) ?? '';

              Color statusColor;
              String statusLabel;
              switch (status) {
                case 'delivered':
                  statusColor = Colors.green;
                  statusLabel = isAr ? 'تم التوصيل' : 'Delivered';
                  break;
                case 'shipping':
                  statusColor = Colors.blue;
                  statusLabel = isAr ? 'شحن' : 'Shipping';
                  break;
                case 'processing':
                  statusColor = Colors.orange;
                  statusLabel = isAr ? 'قيد التجهيز' : 'Processing';
                  break;
                case 'cancelled':
                  statusColor = Colors.red;
                  statusLabel = isAr ? 'ملغي' : 'Cancelled';
                  break;
                default:
                  statusColor = Colors.amber;
                  statusLabel = isAr ? 'مؤكد' : 'Confirmed';
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.shopping_bag, color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(StoreLocalizer.reviewerName(context, name), style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1B2E1F))),
                          Text(date, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isAr ? '$total د.أ' : '$total JOD',
                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1B4332)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(statusLabel, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w800, color: statusColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// ─── آخر المهام المقدمة ───
class _RecentTasksList extends StatelessWidget {
  final bool isAr;
  const _RecentTasksList({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('task_reviews')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                isAr ? 'لا توجد مهام مقدمة بعد' : 'No task submissions yet',
                style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'pending';
              final taskTitle = data['taskTitle'] ?? (isAr ? 'مهمة بيئية' : 'Eco Task');
              final points = data['points'] ?? 0;
              final ts = data['createdAt'] as Timestamp?;
              final date = ts?.toDate().toString().substring(0, 10) ?? '';

              Color statusColor;
              IconData statusIcon;
              switch (status) {
                case 'approved':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.orange;
                  statusIcon = Icons.hourglass_bottom;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            taskTitle,
                            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1B2E1F)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(date, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF386641).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+$points',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
