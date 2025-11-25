// import 'package:flutter/material.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'My Profile',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE53935),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.person,
//                 size: 50,
//                 color: Colors.white,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'John Doe',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               'john.doe@example.com',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF757575),
//               ),
//             ),
//             const SizedBox(height: 16),
//             OutlinedButton.icon(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/edit-profile');
//               },
//               icon: const Icon(Icons.edit, color: Color(0xFFE53935), size: 18),
//               label: const Text(
//                 'Edit Profile',
//                 style: TextStyle(
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//                 side: const BorderSide(color: Color(0xFFE53935)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 32),
//             _buildMenuItem(
//               context,
//               Icons.location_on_outlined,
//               'Saved Addresses',
//               '/saved-addresses',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.payment_outlined,
//               'Payment Methods',
//               '/payment-methods',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.notifications_outlined,
//               'Notifications',
//               '/notifications',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.local_offer_outlined,
//               'My Coupons',
//               '/my-coupons',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.help_outline,
//               'Help & Support',
//               '/help-support',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.settings_outlined,
//               'Settings',
//               '/settings',
//             ),
//             const SizedBox(height: 24),
//             OutlinedButton.icon(
//               onPressed: () {
//                 _showLogoutDialog(context);
//               },
//               icon: const Icon(Icons.logout, color: Color(0xFFE53935)),
//               label: const Text(
//                 'Logout',
//                 style: TextStyle(
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 side: const BorderSide(color: Color(0xFFE53935)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 minimumSize: const Size(double.infinity, 56),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem(
//     BuildContext context,
//     IconData icon,
//     String title,
//     String? route,
//   ) {
//     return InkWell(
//       onTap: () {
//         if (route != null) {
//           Navigator.pushNamed(context, route);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: const Color(0xFFE0E0E0).withOpacity(0.5),
//             ),
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: const Color(0xFFE53935), size: 24),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xFF2D2D2D),
//                 ),
//               ),
//             ),
//             const Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: Color(0xFF9E9E9E),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Text(
//           'Logout',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         content: const Text(
//           'Are you sure you want to logout?',
//           style: TextStyle(
//             fontSize: 14,
//             color: Color(0xFF757575),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Color(0xFF757575),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pushNamedAndRemoveUntil(
//                 context,
//                 '/',
//                 (route) => false,
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53935),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Logout',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:zenzio/services/auth_service.dart';
// import '../../data/models/user_model.dart'; // ✅ Adjust this import path if needed
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'dart:convert';

// final storage = FlutterSecureStorage();

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   User? _user;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadUser();
//   }

// //   Future<void> _loadUser() async {
// //   setState(() => _isLoading = true);

// //   try {
// //     final token = await storage.read(key: 'auth_token');
// //     final userId = await storage.read(key: 'user_id');

// //     if (token != null && userId != null) {
// //       // 👇 Call API from auth_service.dart
// //       final authService = AuthService();
// //       final fetchedUser = await authService.getUserProfile();

// //       setState(() {
// //         _user = fetchedUser;
// //       });

// //       print("✅ User profile refreshed from backend");
// //     } else {
// //       print("⚠️ Token or User ID missing");
// //     }

// //   } catch (e) {
// //     print("❌ Error fetching profile: $e");
// //   }

// //   setState(() => _isLoading = false);
// // }

// UserDisplay? _displayUser;

// Future<void> _loadUser() async {
//   setState(() => _isLoading = true);

//   try {
//     final authService = AuthService();
//     final fetchedUser = await authService.getUserProfile();

//     if (!mounted) return;

//     setState(() {
//       _user = fetchedUser;
//       // Map fetched user to display model
//       _displayUser = UserDisplay.fromUserJson(fetchedUser.toJson());
//     });

//     print('✅ User loaded: ${_displayUser?.name}');
//   } catch (e) {
//     print('❌ Failed to load user: $e');
//   }

//   if (!mounted) return;
//   setState(() => _isLoading = false);
// }



//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(color: Color(0xFFE53935)),
//         ),
//       );
//     }

//     if (_user == null) {
//       return const Scaffold(
//         body: Center(child: Text('No user data found. Please log in again.')),
//       );
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//          onPressed: () {
//     Navigator.pushNamedAndRemoveUntil(
//       context,
//       '/main-navigation',
//       (route) => false,   // 🔥 clears stack → direct to home
//     );
//   },
//         ),
//         title: const Text(
//           'My Profile',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             // Avatar
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE53935),
//                 shape: BoxShape.circle,
//                 image: (_user?.profilePhoto ?? '').isNotEmpty
//                     ? DecorationImage(
//                         image: NetworkImage(
//                           _user!.profilePhoto!.startsWith('http')
//                               ? _user!.profilePhoto!
//                               : 'https://backend.zenzio.in${_user!.profilePhoto!}',
//                         ),
//                         fit: BoxFit.cover,
//                       )
//                     : null,
//               ),
//               child: (_user?.profilePhoto ?? '').isEmpty
//                   ? const Icon(Icons.person, size: 50, color: Colors.white)
//                   : null,
//             ),
//             const SizedBox(height: 16),

//             // User info
//            Text(
//   _displayUser?.name ?? 'Unknown User',
//   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
// ),
// Text(
//   _displayUser?.email ?? '',
//   style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
// ),
// Text(
//   _displayUser?.mobile ?? '',
//   style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
// ),

//             const SizedBox(height: 4),
//             // Text(
//             //   _user!.mobile ?? '',
//             //   style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
//             // ),

//             const SizedBox(height: 16),

//             // Edit Profile Button
//             OutlinedButton.icon(
//               onPressed: () async {
//                 final updated = await Navigator.pushNamed(context, '/edit-profile');
//                 if (updated == true) {
//                   _loadUser(); // 🔁 Reload user data after editing
//                 }
//               },
//               icon: const Icon(Icons.edit, color: Color(0xFFE53935), size: 18),
//               label: const Text(
//                 'Edit Profile',
//                 style: TextStyle(
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//                 side: const BorderSide(color: Color(0xFFE53935)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 32),

//             // Menu items
//             _buildMenuItem(
//               context,
//               Icons.location_on_outlined,
//               'Saved Addresses',
//               '/saved-addresses',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.payment_outlined,
//               'Payment Methods',
//               '/payment-methods',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.notifications_outlined,
//               'Notifications',
//               '/notifications',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.local_offer_outlined,
//               'My Coupons',
//               '/my-coupons',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.help_outline,
//               'Help & Support',
//               '/help-support',
//             ),
//             _buildMenuItem(
//               context,
//               Icons.settings_outlined,
//               'Settings',
//               '/settings',
//             ),

//             const SizedBox(height: 24),

//             // Logout button
//             OutlinedButton.icon(
//               onPressed: () => _showLogoutDialog(context),
//               icon: const Icon(Icons.logout, color: Color(0xFFE53935)),
//               label: const Text(
//                 'Logout',
//                 style: TextStyle(
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 side: const BorderSide(color: Color(0xFFE53935)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 minimumSize: const Size(double.infinity, 56),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem(
//     BuildContext context,
//     IconData icon,
//     String title,
//     String? route,
//   ) {
//     return InkWell(
//       onTap: () {
//         if (route != null) {
//           Navigator.pushNamed(context, route);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(color: const Color(0xFFE0E0E0).withOpacity(0.5)),
//           ),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: const Color(0xFFE53935), size: 24),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Color(0xFF2D2D2D),
//                 ),
//               ),
//             ),
//             const Icon(
//               Icons.arrow_forward_ios,
//               size: 16,
//               color: Color(0xFF9E9E9E),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Logout',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//         ),
//         content: const Text(
//           'Are you sure you want to logout?',
//           style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(
//                 color: Color(0xFF757575),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final prefs = await SharedPreferences.getInstance();
//               await prefs.clear();
//               Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53935),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Logout',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class UserDisplay {
//   final String name;
//   final String email;
//   final String mobile;

//   UserDisplay({
//     required this.name,
//     required this.email,
//     required this.mobile,
//   });

//   factory UserDisplay.fromUserJson(Map<String, dynamic> json) {
//   String name = json['contact']?['encryptedUsername'] ??
//                 json['contact']?['encryptedEmail'] ?? 
//                 'Unknown User';
//   String email = json['contact']?['encryptedEmail'] ?? '';
//   String mobile = json['contact']?['encryptedPhone'] ?? '';

//   return UserDisplay(
//     name: name,
//     email: email,
//     mobile: mobile,
//   );
// }

// }


import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:zenzio/services/auth_service.dart';
import '../../data/models/user_model.dart'; // Adjust path if needed
import 'package:shared_preferences/shared_preferences.dart';

final storage = FlutterSecureStorage();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  UserDisplay? _displayUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }
Future<void> _loadUser() async {
  setState(() => _isLoading = true);

  try {
    final authService = AuthService();
    final result = await authService.getUserProfileWithJson();

    if (!mounted) return;

   setState(() {
  _user = result['user'] as User;
  print('🔍 JSON before parsing: ${result['json']}'); // Debug line
  _displayUser = UserDisplay.fromUserJson(result['json'] as Map<String, dynamic>);
});

    print('✅ User loaded: ${_displayUser?.name}');
  } catch (e) {
    print('❌ Failed to load user: $e');
  }

  if (!mounted) return;
  setState(() => _isLoading = false);
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE53935)),
        ),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text('No user data found. Please log in again.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main-navigation',
              (route) => false,
            );
          },
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                shape: BoxShape.circle,
                image: (_user?.profilePhoto ?? '').isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(
                          _user!.profilePhoto!.startsWith('http')
                              ? _user!.profilePhoto!
                              : 'https://backend.zenzio.in${_user!.profilePhoto!}',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (_user?.profilePhoto ?? '').isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),

            // User info
            Text(
              _displayUser?.name ?? 'Unknown User',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              _displayUser?.email ?? '',
              style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
            // Text(
            //   _displayUser?.mobile ?? '',
            //   style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
            // ),

            const SizedBox(height: 16),

            // Edit Profile Button
            OutlinedButton.icon(
              onPressed: () async {
                final updated = await Navigator.pushNamed(context, '/edit-profile');
                if (updated == true) {
                  _loadUser(); // Reload after editing
                }
              },
              icon: const Icon(Icons.edit, color: Color(0xFFE53935), size: 18),
              label: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                side: const BorderSide(color: Color(0xFFE53935)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Menu items
            _buildMenuItem(context, Icons.location_on_outlined, 'Saved Addresses', '/saved-addresses'),
            _buildMenuItem(context, Icons.payment_outlined, 'Payment Methods', '/payment-methods'),
            _buildMenuItem(context, Icons.notifications_outlined, 'Notifications', '/notifications'),
            _buildMenuItem(context, Icons.local_offer_outlined, 'My Coupons', '/my-coupons'),
            _buildMenuItem(context, Icons.help_outline, 'Help & Support', '/help-support'),
            _buildMenuItem(context, Icons.settings_outlined, 'Settings', '/settings'),

            const SizedBox(height: 24),

            // Logout button
            OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Color(0xFFE53935)),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFE53935)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, String? route) {
    return InkWell(
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(0xFFE0E0E0).withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE53935), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        content: const Text('Are you sure you want to logout?', style: TextStyle(fontSize: 14, color: Color(0xFF757575))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.w500))),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await storage.deleteAll();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

/// Display model for easier UI mapping
class UserDisplay {
  final String name;
  final String email;
  final String mobile;

  UserDisplay({required this.name, required this.email, required this.mobile});

 factory UserDisplay.fromUserJson(Map<String, dynamic> json) {
  final contact = json['contact'] ?? {};

  String email = contact['encryptedEmail'] ?? '';
  String mobile = contact['encryptedPhone'] ?? '';
  String name = email.isNotEmpty ? email.split('@')[0] : 'Unknown User';

  return UserDisplay(name: name, email: email, mobile: mobile);
}

}
