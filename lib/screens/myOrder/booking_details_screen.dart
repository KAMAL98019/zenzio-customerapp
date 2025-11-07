import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String userId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    required this.userId,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  Map<String, dynamic>? bookingDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBookingDetails();
  }

  Future<void> fetchBookingDetails() async {
    try {
      final url =
          "https://backend.zenzio.in/api/customer/bookings/${widget.bookingId}?userId=${widget.userId}";
      debugPrint("📡 Fetching URL: $url");

      final response = await http.get(Uri.parse(url));

      debugPrint("📩 Status Code: ${response.statusCode}");
      debugPrint("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            bookingDetails = data['data'];
            isLoading = false;
          });
          debugPrint("✅ Booking Details Loaded: $bookingDetails");
        } else {
          debugPrint("⚠️ No 'data' found in response");
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("❌ Server Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Booking Details',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingDetails == null
              ? const Center(child: Text("No booking details found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Booking Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF4CAF50)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Booking ID: ${bookingDetails!['bookingNumber'] ?? ''}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ✅ Restaurant Name, Date, Guests
                      Text(
                        bookingDetails!['restaurant']?['rest_name'] ??
                            'Unknown Restaurant',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${bookingDetails!['bookingDate'] ?? ''} • ${bookingDetails!['bookingTime'] ?? ''}",
                        style: const TextStyle(
                            fontSize: 16, color: Color(0xFF757575)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${bookingDetails!['numberOfGuests'] ?? 0} Guests",
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF757575)),
                      ),

                      const SizedBox(height: 24),

                      // ✅ Special Requests
                      if (bookingDetails!['specialRequest'] != null &&
                          bookingDetails!['specialRequest']
                              .toString()
                              .isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Special Requests',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bookingDetails!['specialRequest'],
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF757575)),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      // ✅ Restaurant Information
                      const Text(
                        'Restaurant Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bookingDetails!['restaurant']?['rest_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bookingDetails!['restaurant']?['address'] ??
                            'No address available',
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF757575)),
                      ),

                      const SizedBox(height: 16),

                      // ✅ Call Button
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final phone = bookingDetails!['restaurant']
                                        ?['phone'] ??
                                    '';
                                if (phone.isNotEmpty) {
                                  final uri = Uri.parse("tel:$phone");
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  }
                                }
                              },
                              icon: const Icon(Icons.phone,
                                  color: Color(0xFFE53935)),
                              label: const Text(
                                'Call Restaurant',
                                style: TextStyle(
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                side:
                                    const BorderSide(color: Color(0xFFE53935)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ✅ Get Directions Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final lat = bookingDetails!['restaurant']?['lat'];
                            final lng = bookingDetails!['restaurant']?['lng'];
                            if (lat != null && lng != null) {
                              final googleMapsUrl =
                                  "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
                              final uri = Uri.parse(googleMapsUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            }
                          },
                          icon: const Icon(Icons.directions),
                          label: const Text(
                            'Get Directions',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ✅ Get Help Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            // TODO: Implement support page navigation
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE53935)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Get Help',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE53935),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ✅ Cancel Booking Button
                      Center(
                        child: TextButton(
                          onPressed: () => _showCancelDialog(context),
                          child: const Text(
                            'Cancel Booking',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirm Booking Cancellation?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this booking? Cancellation policies may apply.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF757575),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No, Go Back',
              style: TextStyle(
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Yes, Cancel Booking',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';

// class BookingDetailsScreen extends StatelessWidget {
//   const BookingDetailsScreen({super.key, required bookingId, required String userId});

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
//           'Booking Details',
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
//                 color: const Color(0xFF4CAF50).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: const Color(0xFF4CAF50)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFF4CAF50),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.check,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'Booking ID: #BK-75412',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Urban Bistro',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'May 15, 2023 • 7:30 PM',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF757575),
//               ),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               '2 Guests',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF757575),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Special Requests',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Window seat preferred',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF757575),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Restaurant Information',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'Urban Bistro',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 4),
//             const Text(
//               '123 Main Street, New York',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF757575),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () {},
//                     icon: const Icon(Icons.phone, color: Color(0xFFE53935)),
//                     label: const Text(
//                       'Call Restaurant',
//                       style: TextStyle(
//                         color: Color(0xFFE53935),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       side: const BorderSide(color: Color(0xFFE53935)),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton.icon(
//                 onPressed: () {},
//                 icon: const Icon(Icons.directions),
//                 label: const Text(
//                   'Get Directions',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: OutlinedButton(
//                 onPressed: () {},
//                 style: OutlinedButton.styleFrom(
//                   side: const BorderSide(color: Color(0xFFE53935)),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   'Get Help',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFFE53935),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Center(
//               child: TextButton(
//                 onPressed: () {
//                   _showCancelDialog(context);
//                 },
//                 child: const Text(
//                   'Cancel Booking',
//                   style: TextStyle(
//                     fontSize: 15,
//                     color: Color(0xFFE53935),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showCancelDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFE53935).withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.warning_amber_rounded,
//                 color: Color(0xFFE53935),
//               ),
//             ),
//             const SizedBox(width: 12),
//             const Expanded(
//               child: Text(
//                 'Confirm Booking Cancellation?',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         content: const Text(
//           'Are you sure you want to cancel your dining reservation at [Restaurant Name] for [Date] at [Time]? Cancellation policies may apply.',
//           style: TextStyle(
//             fontSize: 14,
//             color: Color(0xFF757575),
//             height: 1.5,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'No, Go Back',
//               style: TextStyle(
//                 color: Color(0xFF757575),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53935),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               'Yes, Cancel Booking',
//               style: TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
