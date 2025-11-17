// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class MyOrdersScreen extends StatefulWidget {
//   const MyOrdersScreen({super.key});

//   @override
//   State<MyOrdersScreen> createState() => _MyOrdersScreenState();
// }

// class _MyOrdersScreenState extends State<MyOrdersScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;

//   List<dynamic> _bookings = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _fetchDiningBookings();
//   }

  
// Future<void> _fetchDiningBookings() async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getString('user_id');

//     if (userId == null || userId.isEmpty) {
//       if (!mounted) return;
//       setState(() {
//         _errorMessage = "User not logged in.";
//         _isLoading = false;
//       });
//       return;
//     }

//     final url =
//         'https://backend.zenzio.in/api/customer/bookings?userId=$userId';
//     final response = await http.get(Uri.parse(url));

//     if (!mounted) return; // ✅ ensure still mounted before updating UI

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] == true &&
//           data['data'] != null &&
//           data['data']['bookings'] != null) {
//         setState(() {
//           _bookings = data['data']['bookings'];
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = "No bookings available.";
//           _isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         _errorMessage = "Failed to load bookings.";
//         _isLoading = false;
//       });
//     }
//   } catch (e) {
//     if (!mounted) return; // ✅ added this check before setState
//     setState(() {
//       _errorMessage = "Something went wrong. Please try again.";
//       _isLoading = false;
//     });
//     print("❌ Error fetching bookings: $e");
//   }
// }


//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'My Activity',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.person, color: Color(0xFFE53935)),
//             onPressed: () {
//               Navigator.pushNamed(context, '/profile');
//             },
//           ),
//         ],
//         bottom: TabBar(
//           controller: _tabController,
//           labelColor: const Color(0xFFE53935),
//           unselectedLabelColor: const Color(0xFF757575),
//           indicatorColor: const Color(0xFFE53935),
//           labelStyle: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.w600,
//           ),
//           tabs: const [
//             Tab(text: 'Food Orders'),
//             Tab(text: 'Dining Bookings'),
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           _buildFoodOrders(),
//           _buildDiningBookings(),
//         ],
//       ),
//     );
//   }

//   Widget _buildFoodOrders() {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         _buildSectionHeader('Current Orders'),
//         _buildOrderCard(
//           'Burger Kingdom',
//           'Today, 6:30 PM',
//           '1× Beef Burger, 2× Cheese Fries, 1× Milkshake',
//           '₹35.71',
//           'On the Way',
//           const Color(0xFF4CAF50),
//           true,
//         ),
//         _buildOrderCard(
//           'Pizza Paradise',
//           'Today, 5:15 PM',
//           '1× Pepperoni Pizza, 1× Garlic Bread, 1× Coke',
//           '₹129',
//           'Preparing',
//           const Color(0xFFFFC107),
//           true,
//         ),
//         const SizedBox(height: 16),
//         _buildSectionHeader('Past Orders'),
//         _buildOrderCard(
//           'Urban Bistro',
//           'Yesterday, 8:15 PM',
//           '1× Chicken Pasta, 1× Caesar Salad, 2× Lemonade',
//           '₹428',
//           'Delivered',
//           const Color(0xFF4CAF50),
//           false,
//         ),
//       ],
//     );
//   }

//   Widget _buildDiningBookings() {
//     if (_isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Text(
//           _errorMessage!,
//           style: const TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//       );
//     }

//     if (_bookings.isEmpty) {
//       return const Center(
//         child: Text(
//           "No dining bookings available.",
//           style: TextStyle(color: Colors.grey, fontSize: 14),
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _bookings.length,
//       itemBuilder: (context, index) {
//         final booking = _bookings[index];
//         final restaurant = booking['restaurant']?['rest_name'] ?? 'Unknown Restaurant';
//         final date = booking['bookingDate'] ?? 'Date N/A';
//         final time = booking['bookingTime'] ?? 'Time N/A';
//         final guests = booking['numberOfGuests']?.toString() ?? 'N/A';
//         final status = booking['status'] ?? 'Status N/A';

//         Color statusColor;
//         switch (status.toUpperCase()) {
//           case 'CONFIRMED':
//             statusColor = const Color(0xFF4CAF50);
//             break;
//           case 'CANCELLED':
//             statusColor = const Color(0xFFE53935);
//             break;
//           default:
//             statusColor = const Color(0xFF757575);
//         }

//         return _buildBookingCard(
//           restaurant,
//           "$date • $time",
//           "$guests Guests",
//           status,
//           statusColor, 
//           bookingId: booking['id'] ?? '',
//           userId: booking['userId'] ?? '',
//         );
//       },
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           color: Color(0xFF2D2D2D),
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderCard(
//     String restaurant,
//     String time,
//     String items,
//     String price,
//     String status,
//     Color statusColor,
//     bool isCurrent,
//   ) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, '/order-details');
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFFE0E0E0)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.03),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     restaurant,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     status,
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: statusColor,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 4),
//             Text(
//               time,
//               style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               items,
//               style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   price,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, isCurrent
//                         ? '/order-tracking'
//                         : '/order-details');
//                   },
//                   style: TextButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                     minimumSize: Size.zero,
//                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                   ),
//                   child: Text(
//                     isCurrent ? 'Track Order' : 'View Details',
//                     style: const TextStyle(
//                       color: Color(0xFFE53935),
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//  Widget _buildBookingCard(
//   String restaurant,
//   String dateTime,
//   String guests,
//   String status,
//   Color statusColor, {
//   required String bookingId,
//   required String userId,
// }) {
//   return GestureDetector(
//   onTap: () async {
//   final prefs = await SharedPreferences.getInstance();
//   final userId = prefs.getString('user_id') ?? '';

//   if (userId.isEmpty) {
//     print("⚠️ userId not found — please check login saving");
//     return;
//   }

//   print("➡️ Navigating with bookingId=$bookingId, userId=$userId");

//   Navigator.pushNamed(
//     context,
//     '/booking-details',
//     arguments: {
//       'bookingId': bookingId,
//       'userId': userId,
//     },
//   );
// },

//     child: Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Text(
//                   restaurant,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   status,
//                   style: TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: statusColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             dateTime,
//             style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             guests,
//             style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//     }



import 'package:flutter/material.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Activity',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFFE53935)),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE53935),
          unselectedLabelColor: const Color(0xFF757575),
          indicatorColor: const Color(0xFFE53935),
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Food Orders'),
            Tab(text: 'Dining Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFoodOrders(),
          _buildDiningBookings(),
        ],
      ),
    );
  }

  Widget _buildFoodOrders() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Current Orders'),
        _buildOrderCard(
          'Burger Kingdom',
          'Today, 6:30 PM',
          '1× Beef Burger, 2× Cheese Fries, 1× Milkshake',
          '₹35.71',
          'On the Way',
          const Color(0xFF4CAF50),
          true,
        ),
        _buildOrderCard(
          'Pizza Paradise',
          'Today, 5:15 PM',
          '1× Pepperoni Pizza, 1× Garlic Bread, 1× Coke',
          '₹129',
          'Preparing',
          const Color(0xFFFFC107),
          true,
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Past Orders'),
        _buildOrderCard(
          'Urban Bistro',
          'Yesterday, 8:15 PM',
          '1× Chicken Pasta, 1× Caesar Salad, 2× Lemonade',
          '₹428',
          'Delivered',
          const Color(0xFF4CAF50),
          false,
        ),
        _buildOrderCard(
          'Sushi Master',
          'May 10, 7:30 PM',
          '1× Dragon Roll, 1× Miso Soup, 1× Green Tea',
          '₹428',
          'Delivered',
          const Color(0xFF4CAF50),
          false,
        ),
        _buildOrderCard(
          'Taco Fiesta',
          'May 6, 6:45 PM',
          '2× Beef Tacos, 1× Nachos, 1× Soda',
          '₹225',
          'Cancelled',
          const Color(0xFFE53935),
          false,
        ),
      ],
    );
  }

  Widget _buildDiningBookings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Upcoming Bookings'),
        _buildBookingCard(
          'Urban Bistro',
          'May 15, 2023 • 7:30 PM',
          '2 Guests',
          'Confirmed',
          const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 16),
        _buildSectionHeader('Past Bookings'),
        _buildBookingCard(
          'Seaside Grill',
          'May 10, 2023 • 8:00 PM',
          '4 Guests',
          'Completed',
          const Color(0xFF757575),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D2D2D),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    String restaurant,
    String time,
    String items,
    String price,
    String status,
    Color statusColor,
    bool isCurrent,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/order-details');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    restaurant,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              items,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                if (isCurrent)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/order-tracking');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Track Order',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/order-details');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'View Details',
                      style: TextStyle(
                        color: Color(0xFFE53935),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(
    String restaurant,
    String dateTime,
    String guests,
    String status,
    Color statusColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/booking-details');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    restaurant,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateTime,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              guests,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
