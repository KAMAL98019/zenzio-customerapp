import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  Map<String, dynamic>? restaurant;
  Map<String, dynamic>? user;
  bool isLoading = true;
  bool isError = false;

  int _guestCount = 4;
  String _selectedTime = '5:30 PM';
  String _selectedPurpose = 'casual';
  String? _seatPreference;
  final TextEditingController _specialRequestsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData(); // ✅ Load user data first
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
    if (userData != null) {
      setState(() {
        user = json.decode(userData);
      });
      print("✅ User loaded from SharedPreferences: $user");
    } else {
      print("⚠️ No user data found in SharedPreferences");
    }
  }

  @override
  void dispose() {
    _specialRequestsController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final restaurantId = ModalRoute.of(context)!.settings.arguments as String;
    _fetchData(restaurantId);
  }

  Future<void> _fetchData(String restaurantId) async {
    try {
      await fetchRestaurant(restaurantId);

      // ✅ Ensure user is loaded from SharedPreferences if not already
      if (user == null) {
        final prefs = await SharedPreferences.getInstance();
        final userData = prefs.getString('user');
        if (userData != null) {
          user = json.decode(userData);
        }
      }

      setState(() {
        isLoading = false;
      });

      print("✅ User loaded: $user");
      print("✅ Restaurant loaded: $restaurant");
    } catch (e) {
      print("⚠️ Error fetching data: $e");
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  Future<void> fetchRestaurant(String id) async {
    final response = await http.get(
      Uri.parse('https://backend.zenzio.in/api/customer/restaurants/$id'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        restaurant = data['data'];
      } else {
        isError = true;
      }
    } else {
      isError = true;
    }
  }

  Future<void> submitBooking() async {
    print('🚀 Booking button pressed');
    print("Restaurant data: $restaurant");
    print("User data: $user");

    if (restaurant == null || user == null) {
      print('❌ Missing restaurant or user info');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User or restaurant data missing")),
      );
      return;
    }

    final bookingData = {
      "userId": user!['id'],
      "restaurantId": restaurant!['id'],
      "eventId": restaurant!['eventId'] ?? "",
      "bookingDate": DateTime.now().toIso8601String().split('T')[0],
      "bookingTime": _selectedTime.replaceAll(' ', ''),
      "numberOfGuests": _guestCount,
      "specialRequests": _specialRequestsController.text,
      "purpose": _selectedPurpose,
    };

    print('📦 Booking Data: $bookingData');

    try {
      final response = await http.post(
        Uri.parse('https://backend.zenzio.in/api/customer/bookings'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(bookingData),
      );

      print('🌐 Status code: ${response.statusCode}');
      print('🧾 Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Booking success');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking confirmed successfully")),
        );
        Navigator.pushNamed(context, '/booking-confirmation');
      } else {
        print('❌ Booking failed: ${data['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Booking failed")),
        );
      }
    } catch (e) {
      print('⚠️ Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Network error, please try again")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE53935))),
      );
    }

    if (isError || restaurant == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load restaurant details")),
      );
    }

    final rest = restaurant!;
    final rawLogo = rest['rest_logo'];
    final imageUrl = (rawLogo != null && rawLogo is String)
        ? "https://backend.zenzio.in${rawLogo.replaceFirst('/root/choozy-backend', '')}"
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dining Booking',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imageUrl == null
                        ? const Icon(Icons.restaurant, size: 40, color: Color(0xFFE0E0E0))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rest['rest_name'] ?? 'Not updated',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Color(0xFF757575)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                rest['rest_address'] ?? 'Address not updated',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF757575),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Time selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateTime.now().toLocal().toString().split(" ")[0],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Change',
                          style: TextStyle(
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTimeChip('5:30 PM'),
                      _buildTimeChip('6:00 PM'),
                      _buildTimeChip('6:30 PM'),
                      _buildTimeChip('7:00 PM'),
                      _buildTimeChip('7:30 PM'),
                      _buildTimeChip('8:00 PM'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Number of Guests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_guestCount > 1) setState(() => _guestCount--);
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFE53935)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '$_guestCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _guestCount++),
                    icon: const Icon(Icons.add_circle, color: Color(0xFFE53935)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Purpose of Booking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            _buildPurposeOption('casual', 'Casual Dining'),
            _buildPurposeOption('birthday', 'Birthday Celebration'),
            _buildPurposeOption('anniversary', 'Anniversary'),
            _buildPurposeOption('business', 'Business Meeting'),
            _buildPurposeOption('other', 'Other'),

            const SizedBox(height: 24),
            const Text(
              'Seat/Hall Preference (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _seatPreference,
              decoration: InputDecoration(
                hintText: 'Any Available',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'any', child: Text('Any Available')),
                DropdownMenuItem(value: 'window', child: Text('Window Seat')),
                DropdownMenuItem(value: 'outdoor', child: Text('Outdoor')),
                DropdownMenuItem(value: 'private', child: Text('Private Hall')),
              ],
              onChanged: (value) => setState(() => _seatPreference = value),
            ),

            const SizedBox(height: 24),
            const Text(
              'Special Requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _specialRequestsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any additional requests?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            if (user != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user!['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user!['phone'] ?? 'N/A',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: submitBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Confirm Booking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(String time) {
    final isSelected = _selectedTime == time;
    return GestureDetector(
      onTap: () => setState(() => _selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE53935) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPurposeOption(String value, String label) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPurpose = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPurpose == value
                ? const Color(0xFFE53935)
                : const Color(0xFFE0E0E0),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              _selectedPurpose == value
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: _selectedPurpose == value
                  ? const Color(0xFFE53935)
                  : const Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class BookingFormScreen extends StatefulWidget {
//   const BookingFormScreen({super.key});

//   @override
//   State<BookingFormScreen> createState() => _BookingFormScreenState();
// }

// class _BookingFormScreenState extends State<BookingFormScreen> {
//   Map<String, dynamic>? restaurant;
//   Map<String, dynamic>? user;
//   bool isLoading = true;
//   bool isError = false;

//   int _guestCount = 4;
//   String _selectedTime = '5:30 PM';
//   String _selectedPurpose = 'casual';
//   String? _seatPreference;
//   final TextEditingController _specialRequestsController = TextEditingController();

//   @override
//   void dispose() {
//     _specialRequestsController.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final restaurantId = ModalRoute.of(context)!.settings.arguments as String;
//     fetchInitialData(restaurantId);
//   }

//   Future<void> fetchInitialData(String restaurantId) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString('userId'); // store this in login step
//       await Future.wait([
//         fetchRestaurant(restaurantId),
//         fetchUser(userId),
//       ]);
//     } catch (e) {
//       setState(() {
//         isError = true;
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> fetchRestaurant(String id) async {
//     final response = await http.get(
//       Uri.parse('https://backend.zenzio.in/api/customer/restaurants/$id'),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] == true) {
//         setState(() {
//           restaurant = data['data'];
//           isLoading = false;
//         });
//       } else {
//         setState(() => isError = true);
//       }
//     } else {
//       setState(() => isError = true);
//     }
//   }

//   Future<void> fetchUser(String? id) async {
//     if (id == null) return;
//     final response = await http.get(
//       Uri.parse('https://backend.zenzio.in/api/customer/profile/$id'),
//     );
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] == true) {
//         setState(() => user = data['data']);
//       }
//     }
//   }

//  Future<void> submitBooking() async {
//   print('🚀 Booking button pressed');

//   if (restaurant == null || user == null) {
//     print('❌ Missing restaurant or user info');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("User or restaurant data missing")),
//     );
//     return;
//   }

//   final bookingData = {
//     "userId": user!['id'],
//     "restaurantId": restaurant!['id'],
//     "eventId": restaurant!['eventId'] ?? "",
//     "bookingDate": DateTime.now().toIso8601String().split('T')[0],
//     "bookingTime": _selectedTime.replaceAll(' ', ''),
//     "numberOfGuests": _guestCount,
//     "specialRequests": _specialRequestsController.text,
//     "purpose": _selectedPurpose,
//   };

//   print('📦 Booking Data: $bookingData');

//   try {
//     final response = await http.post(
//       Uri.parse('https://backend.zenzio.in/api/customer/bookings'),
//       headers: {"Content-Type": "application/json"},
//       body: json.encode(bookingData),
//     );

//     print('🌐 Status code: ${response.statusCode}');
//     print('🧾 Response body: ${response.body}');

//     final data = json.decode(response.body);

//     if (response.statusCode == 200 && data['success'] == true) {
//       print('✅ Booking success');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Booking confirmed successfully")),
//       );
//       Navigator.pushNamed(context, '/booking-confirmation');
//     } else {
//       print('❌ Booking failed: ${data['message']}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(data['message'] ?? "Booking failed")),
//       );
//     }
//   } catch (e) {
//     print('⚠️ Network error: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Network error, please try again")),
//     );
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator(color: Color(0xFFE53935))),
//       );
//     }

//     if (isError || restaurant == null) {
//       return const Scaffold(
//         body: Center(child: Text("Failed to load restaurant details")),
//       );
//     }

//     final rest = restaurant!;
//     final rawLogo = rest['rest_logo'];
// final imageUrl = (rawLogo != null && rawLogo is String)
//     ? "https://backend.zenzio.in${rawLogo.replaceFirst('/root/choozy-backend', '')}"
//     : null;

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
//           'Dining Booking out',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Restaurant Card
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       image: imageUrl != null
//                           ? DecorationImage(
//                               image: NetworkImage(imageUrl),
//                               fit: BoxFit.cover,
//                             )
//                           : null,
//                     ),
//                     child: imageUrl == null
//                         ? const Icon(Icons.restaurant, size: 40, color: Color(0xFFE0E0E0))
//                         : null,
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           rest['rest_name'] ?? 'Not updated',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF2D2D2D),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             const Icon(Icons.location_on,
//                                 size: 14, color: Color(0xFF757575)),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 rest['rest_address'] ?? 'Address not updated',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Color(0xFF757575),
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Date and Time
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         '${DateTime.now().toLocal().toString().split(" ")[0]}',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2D2D2D),
//                         ),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: () {},
//                         child: const Text(
//                           'Change',
//                           style: TextStyle(
//                             color: Color(0xFFE53935),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Select Time',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       _buildTimeChip('5:30 PM'),
//                       _buildTimeChip('6:00 PM'),
//                       _buildTimeChip('6:30 PM'),
//                       _buildTimeChip('7:00 PM'),
//                       _buildTimeChip('7:30 PM'),
//                       _buildTimeChip('8:00 PM'),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Guests, Purpose, Seat, Requests, Contact — SAME UI
//             const Text(
//               'Number of Guests',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: const Color(0xFFE0E0E0)),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       if (_guestCount > 1) setState(() => _guestCount--);
//                     },
//                     icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFE53935)),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     child: Text(
//                       '$_guestCount',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => setState(() => _guestCount++),
//                     icon: const Icon(Icons.add_circle, color: Color(0xFFE53935)),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),
//             const Text(
//               'Purpose of Booking',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildPurposeOption('casual', 'Casual Dining'),
//             _buildPurposeOption('birthday', 'Birthday Celebration'),
//             _buildPurposeOption('anniversary', 'Anniversary'),
//             _buildPurposeOption('business', 'Business Meeting'),
//             _buildPurposeOption('other', 'Other'),

//             const SizedBox(height: 24),
//             const Text(
//               'Seat/Hall Preference (Optional)',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _seatPreference,
//               decoration: InputDecoration(
//                 hintText: 'Any Available',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//               ),
//               items: const [
//                 DropdownMenuItem(value: 'any', child: Text('Any Available')),
//                 DropdownMenuItem(value: 'window', child: Text('Window Seat')),
//                 DropdownMenuItem(value: 'outdoor', child: Text('Outdoor')),
//                 DropdownMenuItem(value: 'private', child: Text('Private Hall')),
//               ],
//               onChanged: (value) => setState(() => _seatPreference = value),
//             ),

//             const SizedBox(height: 24),
//             const Text(
//               'Special Requests',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _specialRequestsController,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Any additional requests?',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),
//             const Text(
//               'Contact Information',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             if (user != null)
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF5F5F5),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       user!['name'] ?? 'Unknown',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF2D2D2D),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       user!['phone'] ?? 'N/A',
//                       style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: SizedBox(
//           height: 56,
//           child: ElevatedButton(
//             onPressed: submitBooking,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53935),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text(
//               'Confirm Booking',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeChip(String time) {
//     final isSelected = _selectedTime == time;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedTime = time),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFE53935) : Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
//           ),
//         ),
//         child: Text(
//           time,
//           style: TextStyle(
//             color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPurposeOption(String value, String label) {
//     return GestureDetector(
//       onTap: () => setState(() => _selectedPurpose = value),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: _selectedPurpose == value
//                 ? const Color(0xFFE53935)
//                 : const Color(0xFFE0E0E0),
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               _selectedPurpose == value
//                   ? Icons.radio_button_checked
//                   : Icons.radio_button_unchecked,
//               color: _selectedPurpose == value
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFF9E9E9E),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';

// class BookingFormScreen extends StatefulWidget {
//   const BookingFormScreen({super.key});

//   @override
//   State<BookingFormScreen> createState() => _BookingFormScreenState();
// }

// class _BookingFormScreenState extends State<BookingFormScreen> {
//   int _guestCount = 4;
//   String _selectedTime = '5:30 PM';
//   String _selectedPurpose = 'casual';
//   final TextEditingController _specialRequestsController = TextEditingController();

//   @override
//   void dispose() {
//     _specialRequestsController.dispose();
//     super.dispose();
//   }

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
//           'Dining Booking out',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.restaurant,
//                       size: 40,
//                       color: Color(0xFFE0E0E0),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Bistro Deluxe',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF2D2D2D),
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(Icons.location_on, size: 14, color: Color(0xFF757575)),
//                             SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 '123 Gourmet Avenue, Culinary District',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Color(0xFF757575),
//                                 ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Text(
//                         'Friday, July 21',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF2D2D2D),
//                         ),
//                       ),
//                       const Spacer(),
//                       TextButton(
//                         onPressed: () {},
//                         child: const Text(
//                           'Change',
//                           style: TextStyle(
//                             color: Color(0xFFE53935),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Select Time',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       _buildTimeChip('5:30 PM'),
//                       _buildTimeChip('6:00 PM'),
//                       _buildTimeChip('6:30 PM'),
//                       _buildTimeChip('7:00 PM'),
//                       _buildTimeChip('7:30 PM'),
//                       _buildTimeChip('8:00 PM'),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Number of Guests',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: const Color(0xFFE0E0E0)),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       if (_guestCount > 1) setState(() => _guestCount--);
//                     },
//                     icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFE53935)),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     child: Text(
//                       '$_guestCount',
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => setState(() => _guestCount++),
//                     icon: const Icon(Icons.add_circle, color: Color(0xFFE53935)),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Purpose of Booking',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildPurposeOption('casual', 'Casual Dining'),
//             _buildPurposeOption('birthday', 'Birthday Celebration'),
//             _buildPurposeOption('anniversary', 'Anniversary'),
//             _buildPurposeOption('business', 'Business Meeting'),
//             _buildPurposeOption('other', 'Other'),
//             const SizedBox(height: 24),
//             const Text(
//               'Seat/Hall Preference (Optional)',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 hintText: 'Any Available',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE53935)),
//                 ),
//               ),
//               items: const [
//                 DropdownMenuItem(value: 'any', child: Text('Any Available')),
//                 DropdownMenuItem(value: 'window', child: Text('Window Seat')),
//                 DropdownMenuItem(value: 'outdoor', child: Text('Outdoor')),
//                 DropdownMenuItem(value: 'private', child: Text('Private Hall')),
//               ],
//               onChanged: (value) {},
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Special Requests',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: _specialRequestsController,
//               maxLines: 4,
//               decoration: InputDecoration(
//                 hintText: 'Any additional requests? (e.g., high chair, accessibility needs)',
//                 hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE53935)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Contact Information',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'John Smith',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     '+1 (555) 123-4567',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF757575),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextButton(
//                     onPressed: () {},
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: Size.zero,
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: const Text(
//                       'Edit',
//                       style: TextStyle(
//                         color: Color(0xFFE53935),
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, -2),
//             ),
//           ],
//         ),
//         child: SizedBox(
//           height: 56,
//           child: ElevatedButton(
//             onPressed: () {
//               Navigator.pushNamed(context, '/booking-confirmation');
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53935),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             child: const Text(
//               'Confirm Booking',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeChip(String time) {
//     final isSelected = _selectedTime == time;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedTime = time),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFE53935) : Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
//           ),
//         ),
//         child: Text(
//           time,
//           style: TextStyle(
//             color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPurposeOption(String value, String label) {
//     return GestureDetector(
//       onTap: () => setState(() => _selectedPurpose = value),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: _selectedPurpose == value
//                 ? const Color(0xFFE53935)
//                 : const Color(0xFFE0E0E0),
//           ),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               _selectedPurpose == value
//                   ? Icons.radio_button_checked
//                   : Icons.radio_button_unchecked,
//               color: _selectedPurpose == value
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFF9E9E9E),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
