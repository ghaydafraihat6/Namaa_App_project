import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(
          isAr ? 'إدارة المستخدمين' : 'User Management',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2D5A3F),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF52B788)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                isAr ? 'حدث خطأ في تحميل البيانات' : 'Error loading data',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                isAr ? 'لا يوجد مستخدمين بعد' : 'No users found',
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final data = users[index].data() as Map<String, dynamic>;
              final name = data['fullName'] ?? (isAr ? 'بدون اسم' : 'No Name');
              final email = data['email'] ?? '';
              final points = data['points'] ?? 0;
              final bool isAdmin = data['role'] == 'admin' || data['isAdmin'] == true;
              
              // Formatting the date safely
              String dateStr = '';
              if (data['createdAt'] != null) {
                try {
                  final ts = data['createdAt'] as Timestamp;
                  dateStr = ts.toDate().toString().substring(0, 10);
                } catch (_) {}
              }

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // User Avatar Initials
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isAdmin 
                              ? const Color(0xFFF4A261).withValues(alpha: 0.2)
                              : const Color(0xFF52B788).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isAdmin ? Icons.admin_panel_settings : Icons.person,
                            color: isAdmin ? const Color(0xFFE8852A) : const Color(0xFF386641),
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // User Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF1B2E1F),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isAdmin)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    margin: EdgeInsets.only(left: isAr ? 0 : 8, right: isAr ? 8 : 0),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4A261),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Admin',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.blueGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.stars, size: 14, color: Color(0xFFE8852A)),
                                const SizedBox(width: 4),
                                Text(
                                  isAr ? '$points نقطة' : '$points points',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE8852A),
                                  ),
                                ),
                                const Spacer(),
                                if (dateStr.isNotEmpty) ...[
                                  const Icon(Icons.date_range, size: 14, color: Colors.black38),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
