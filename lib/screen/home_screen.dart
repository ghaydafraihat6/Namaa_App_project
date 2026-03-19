// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:namaa_project_app/screen/login_screen.dart';
//
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   static const String routeName = '/home';
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   final User? user = FirebaseAuth.instance.currentUser;
//
//   // Custom theme colors
//   final Color primaryGreen = const Color(0xFF386641);
//   final Color accentColor = const Color(0xFFEBF4DD);
//
//   // Logout Function
//   Future<void> _logout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('isLoggedIn', false); // Clear login status
//
//       if (mounted) {
//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           LoginPage.routeName,
//               (route) => false,
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error logging out: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: primaryGreen,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () {
//               // Show confirmation dialog before logout
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text("Logout"),
//                   content: const Text("Are you sure you want to logout?"),
//                   actions: [
//                     TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
//                     TextButton(onPressed: _logout, child: const Text("Logout", style: TextStyle(color: Colors.red))),
//                   ],
//                 ),
//               );
//             },
//           )
//         ],
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         // Fetching user data from Firestore using the current user's UID
//         stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text("User data not found"));
//           }
//
//           var userData = snapshot.data!.data() as Map<String, dynamic>;
//
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Header Profile Section
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(30),
//                   decoration: BoxDecoration(
//                     color: primaryGreen,
//                     borderRadius: const BorderRadius.only(
//                       bottomLeft: Radius.circular(40),
//                       bottomRight: Radius.circular(40),
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       CircleAvatar(
//                         radius: 50,
//                         backgroundColor: accentColor,
//                         child: Icon(Icons.person, size: 50, color: primaryGreen),
//                       ),
//                       const SizedBox(height: 15),
//                       Text(
//                         userData['fullName'] ?? "User Name",
//                         style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         userData['email'] ?? "Email",
//                         style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8)),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 30),
//
//                 // Details Card
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Card(
//                     color: accentColor,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(20),
//                       child: Column(
//                         children: [
//                           _buildInfoTile(Icons.phone, "Phone", userData['phone'] ?? "N/A"),
//                           const Divider(),
//                           _buildInfoTile(Icons.cake, "Birthday", userData['dob'] ?? "N/A"),
//                           const Divider(),
//                           _buildInfoTile(Icons.wc, "Gender", userData['gender'] ?? "N/A"),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // Helper Widget for Info Rows
//   Widget _buildInfoTile(IconData icon, String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           Icon(icon, color: primaryGreen),
//           const SizedBox(width: 15),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
//               Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }