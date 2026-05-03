import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namaa_project_app/store/store_localizer.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  String searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  String _arabicToEnglishNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < arabic.length; i++) {
      result = result.replaceAll(arabic[i], english[i]);
    }
    return result;
  }

  // ── دوال تحكم الإدارة ──

  // 1. تغيير صلاحية الأدمن
  Future<void> _toggleAdminRole(String userId, bool currentIsAdmin) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'role': currentIsAdmin ? 'user' : 'admin',
      'isAdmin': !currentIsAdmin,
    });
  }

  // 2. تعديل نقاط المستخدم
  void _editPointsDialog(String userId, String userName, int currentPoints, bool isAr) {
    final TextEditingController pointsCtrl = TextEditingController();
    bool isAdding = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(isAr ? 'تعديل نقاط: $userName' : 'Edit points: $userName', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChoiceChip(
                      label: Text(isAr ? 'إضافة +' : 'Add +', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      selected: isAdding,
                      onSelected: (val) => setDialogState(() => isAdding = true),
                      selectedColor: const Color(0xFFEBF4DD),
                      checkmarkColor: const Color(0xFF386641),
                    ),
                    ChoiceChip(
                      label: Text(isAr ? 'خصم -' : 'Deduct -', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      selected: !isAdding,
                      onSelected: (val) => setDialogState(() => isAdding = false),
                      selectedColor: Colors.red.shade100,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pointsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: isAr ? 'عدد النقاط' : 'Amount',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isAr ? 'إلغاء' : 'Cancel', style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                onPressed: () async {
                  int val = int.tryParse(_arabicToEnglishNumbers(pointsCtrl.text)) ?? 0;
                  if (val <= 0) return;
                  int newPoints = isAdding ? (currentPoints + val) : (currentPoints - val);
                  if (newPoints < 0) newPoints = 0; // منع النقاط بالسالب
                  
                  await FirebaseFirestore.instance.collection('users').doc(userId).update({
                    'points': newPoints,
                  });
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(isAr ? 'تم تعديل النقاط بنجاح ✅' : 'Points updated ✅', style: const TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: const Color(0xFF386641),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF386641)),
                child: Text(isAr ? 'حفظ التعديل' : 'Save', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F5F0),
      appBar: AppBar(
        title: Text(
          isAr ? 'إدارة المستخدمين' : 'User Management',
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w900, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2D5A3F),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── 1. شريط البحث ──
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                setState(() {
                  searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: isAr ? 'بحث بالاسم، الإيميل، أو الكود...' : 'Search by name, email, or code...',
                hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF386641)),
                suffixIcon: searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey), 
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => searchQuery = '');
                      }
                    ) 
                  : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),

          // ── 2. محتوى القائمة ──
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF52B788)));
                }

                if (snapshot.hasError) {
                  return Center(child: Text(isAr ? 'حدث خطأ في التحميل' : 'Error loading', style: const TextStyle(fontFamily: 'Cairo')));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(isAr ? 'لا يوجد مستخدمين' : 'No users found', style: const TextStyle(fontFamily: 'Cairo', fontSize: 16)));
                }

                // فلترة البحث
                final allDocs = snapshot.data!.docs;
                final filteredUsers = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['fullName'] ?? '').toString().toLowerCase();
                  final name2 = (data['name'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final code = (data['referralCode'] ?? '').toString().toLowerCase();
                  
                  if (searchQuery.isEmpty) return true;
                  return name.contains(searchQuery) || name2.contains(searchQuery) || email.contains(searchQuery) || code.contains(searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(child: Text(isAr ? 'لم يتم العثور على نتائج للبحث' : 'No results found', style: const TextStyle(fontFamily: 'Cairo')));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final doc = filteredUsers[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    
                    final rawName = data['fullName'] ?? data['name'] ?? (isAr ? 'بدون اسم' : 'No Name');
                    final name = StoreLocalizer.reviewerName(context, rawName);
                    final email = data['email'] ?? '';
                    final refCode = data['referralCode'] ?? '---';
                    final int points = (data['points'] as num?)?.toInt() ?? 0;
                    final bool isAdmin = data['role'] == 'admin' || data['isAdmin'] == true;
                    

                    return Card(
                      elevation: 3,
                      shadowColor: Colors.black12,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // ── الأيقونة (تختلف بين العادي والمشرف) ──
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: isAdmin 
                                    ? const Color(0xFFF4A261).withValues(alpha: 0.15)
                                    : const Color(0xFF52B788).withValues(alpha: 0.15),
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
                            
                            // ── معلومات المستخدم ──
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          name,
                                          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1B2E1F)),
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
                                          child: Text(isAr ? 'مشرف' : 'Admin', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    email.isEmpty ? (isAr ? 'لا يوجد بريد' : 'No email') : email,
                                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.blueGrey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.stars, size: 14, color: Color(0xFFE8852A)),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAr ? '$points نقطة' : '$points pts',
                                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE8852A)),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.confirmation_number_outlined, size: 14, color: Colors.black38),
                                      const SizedBox(width: 4),
                                      Text(
                                        refCode,
                                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // ── قائمة الإجراءات (PopupMenuButton) ──
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.blueGrey),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (val) {
                                if(val == 'admin') _toggleAdminRole(docId, isAdmin);
                                if(val == 'points') _editPointsDialog(docId, name, points, isAr);
                              },
                              itemBuilder: (ctx) => [
                                PopupMenuItem(
                                  value: 'admin',
                                  child: Row(
                                    children: [
                                      Icon(isAdmin ? Icons.person_off : Icons.admin_panel_settings, color: isAdmin ? Colors.red : const Color(0xFF386641), size: 20),
                                      const SizedBox(width: 8),
                                      Text(isAdmin ? (isAr ? 'إزالة كمسؤول' : 'Remove Admin') : (isAr ? 'ترقية لمسؤول' : 'Make Admin'), style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  value: 'points',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.stars, color: Color(0xFFE8852A), size: 20),
                                      const SizedBox(width: 8),
                                      Text(isAr ? 'تعديل النقاط للمستخدم' : 'Edit User Points', style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

