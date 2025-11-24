import 'package:flutter/material.dart';
import 'package:zenzio/widgets/app_back_handler.dart';
import 'home_screen.dart';
import '../menu/menu_screen.dart';
import '../booking/bookings_home_screen.dart';
import '../myOrder/my_orders_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // ✅ 5 screens to match 5 bottom nav items
  final List<Widget> _screens = [
    const HomeScreen(),
    const MenuScreen(),
    const BookingsHomeScreen(),
    const MyOrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBackHandler(
    child: Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFE53935),
          unselectedItemColor: const Color(0xFF9E9E9E),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'My Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex != 4
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/cart-rest');
              },
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              child: const Icon(Icons.shopping_cart),
            )
          : null,
    )
    );
  }
}


// running 
// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';

// /// MINIMAL VERSION - Add your screens back ONE BY ONE to find the culprit
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});

//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _selectedIndex = 0;
//   final AuthService _authService = AuthService();

//   @override
//   void initState() {
//     super.initState();
//     print('✅ MainNavigationScreen initState completed');
//   }

//   // ✅ Simple placeholder screens - NO HEAVY OPERATIONS
//   Widget _buildScreen(int index) {
//     final user = _authService.currentUser;
    
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_getScreenTitle(index)),
//         backgroundColor: const Color(0xFFE53935),
//         foregroundColor: Colors.white,
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   _getScreenIcon(index),
//                   size: 80,
//                   color: const Color(0xFFE53935),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   _getScreenTitle(index),
//                   style: const TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 if (user != null) ...[
//                   const Divider(height: 32),
//                   if (user.profilePhoto != null && user.profilePhoto!.isNotEmpty)
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundImage: NetworkImage(user.profilePhoto!),
//                       onBackgroundImageError: (_, __) {
//                         print('❌ Failed to load profile photo');
//                       },
//                     )
//                   else
//                     const CircleAvatar(
//                       radius: 50,
//                       child: Icon(Icons.person, size: 50),
//                     ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Welcome, ${user.name}!',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '${user.email}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   if (user.mobile != null && user.mobile!.isNotEmpty) ...[
//                     const SizedBox(height: 4),
//                     Text(
//                       user.mobile!,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: () async {
//                       try {
//                         await _authService.logout();
//                         if (mounted) {
//                           Navigator.pushNamedAndRemoveUntil(
//                             context,
//                             '/',
//                             (route) => false,
//                           );
//                         }
//                       } catch (e) {
//                         print('❌ Logout error: $e');
//                         if (mounted) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text('Logout failed: $e'),
//                               backgroundColor: Colors.red,
//                             ),
//                           );
//                         }
//                       }
//                     },
//                     icon: const Icon(Icons.logout),
//                     label: const Text('Logout'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE53935),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 32,
//                         vertical: 16,
//                       ),
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 32),
//                 const Text(
//                   'This is a placeholder screen.\nReplace with your actual screen content.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String _getScreenTitle(int index) {
//     switch (index) {
//       case 0:
//         return 'Home';
//       case 1:
//         return 'Menu';
//       case 2:
//         return 'Bookings';
//       case 3:
//         return 'My Orders';
//       default:
//         return 'Screen $index';
//     }
//   }

//   IconData _getScreenIcon(int index) {
//     switch (index) {
//       case 0:
//         return Icons.home;
//       case 1:
//         return Icons.restaurant_menu;
//       case 2:
//         return Icons.calendar_today;
//       case 3:
//         return Icons.receipt_long;
//       default:
//         return Icons.apps;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     print('🔍 Building MainNavigationScreen, index: $_selectedIndex');
    
//     return Scaffold(
//       body: _buildScreen(_selectedIndex),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _selectedIndex,
//           onTap: (index) {
//             print('📱 Tab selected: $index');
//             setState(() {
//               _selectedIndex = index;
//             });
//           },
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: const Color(0xFFE53935),
//           unselectedItemColor: const Color(0xFF9E9E9E),
//           selectedLabelStyle: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//           unselectedLabelStyle: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w500,
//           ),
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.restaurant_menu_outlined),
//               activeIcon: Icon(Icons.restaurant_menu),
//               label: 'Menu',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today_outlined),
//               activeIcon: Icon(Icons.calendar_today),
//               label: 'Bookings',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.receipt_long_outlined),
//               activeIcon: Icon(Icons.receipt_long),
//               label: 'My Orders',
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: _selectedIndex != 2
//           ? FloatingActionButton(
//               onPressed: () {
//                 print('🛒 Cart button pressed');
//                 try {
//                   Navigator.pushNamed(context, '/cart');
//                 } catch (e) {
//                   print('❌ Cart navigation error: $e');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Cart error: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               backgroundColor: const Color(0xFFE53935),
//               foregroundColor: Colors.white,
//               child: const Icon(Icons.shopping_cart),
//             )
//           : null,
//     );
//   }

//   @override
//   void dispose() {
//     print('🗑️ MainNavigationScreen disposing');
//     super.dispose();
//   }
// }