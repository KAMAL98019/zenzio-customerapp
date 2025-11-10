import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  Map<String, dynamic>? restaurant;
  bool isLoading = true;
  bool isError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final restaurantId = ModalRoute.of(context)!.settings.arguments as String;
    fetchRestaurant(restaurantId);
  }

 Future<void> fetchRestaurant(String id) async {
  try {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    final headers = {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    print('📡 Fetching restaurant $id with token: ${token != null ? "✅ Present" : "❌ Missing"}');

    final response = await http.get(
      Uri.parse('https://backend.zenzio.in/api/customer/restaurants/$id'),
      headers: headers,
    );

    print('📥 Response status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    if (!mounted) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] != null) {
        setState(() {
          restaurant = data['data'];
          isLoading = false;
          isError = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  } catch (e) {
    print('❌ Exception while fetching restaurant: $e');
    if (!mounted) return;
    setState(() {
      isError = true;
      isLoading = false;
    });
  }
}
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE53935)),
        ),
      );
    }

    if (isError || restaurant == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load restaurant details")),
      );
    }

    final rest = restaurant!;
    final logoPath = rest['rest_logo'];
    String? imageUrl;

    if (logoPath != null && logoPath.isNotEmpty) {
      final cleanPath = logoPath.replaceAll('/root/choozy-backend', '');
      imageUrl = "https://backend.zenzio.in$cleanPath";
    }

    final events = rest['events'] as List? ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFFE53935),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(Icons.broken_image,
                            size: 80, color: Colors.grey),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.restaurant,
                          size: 80, color: Colors.grey),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rest['rest_name'] ?? 'Not updated',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rest['rest_address'] ?? 'Address not updated',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Avg cost for two: ₹${rest['avg_cost_two'] ?? "Not updated"}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    rest['description'] ?? 'Description not available',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Restaurant Gallery',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildGallerySection(rest['images']),
                  const SizedBox(height: 24),
                  const Text(
                    'Special Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  events.isNotEmpty
                      ? Column(
                          children: events.map((e) {
                            final eventId = e['id'];
                            final name = e['eventName'] ?? 'Unnamed Event';
                            final day = e['eventDay'] ?? 'N/A';
                            final times = (e['eventTimes'] as List<dynamic>? ?? [])
                                .map((t) => t.toString())
                                .toList();

                            return _buildEventCard(
                              name,
                              'Day: $day',
                              'Timings: ${times.join(', ')}',
                              rest['id'],
                              eventId,
                              times,
                            );
                          }).toList(),
                        )
                      : const Text(
                          'No special events available',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection(List? images) {
    if (images == null || images.isEmpty) {
      return const Text(
        "No images available",
        style: TextStyle(color: Colors.grey),
      );
    }

    return Row(
      children: List.generate(
        images.length > 2 ? 2 : images.length,
        (index) {
          final img = "https://backend.zenzio.in${images[index]}";
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(String title, String schedule, String description,
      String restaurantId, String eventId, List<String> eventTimes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D2D2D))),
          const SizedBox(height: 4),
          Text(schedule,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFE53935))),
          const SizedBox(height: 8),
          Text(description,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF757575), height: 1.4)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/booking-form',
                  arguments: {
                    'restaurantId': restaurantId,
                    'eventId': eventId,
                    'eventTimes': eventTimes,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.event_seat, size: 18),
              label: const Text(
                'Book a Table',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class BookingDetailScreen extends StatefulWidget {
//   const BookingDetailScreen({super.key});

//   @override
//   State<BookingDetailScreen> createState() => _BookingDetailScreenState();
// }

// class _BookingDetailScreenState extends State<BookingDetailScreen> {
//   Map<String, dynamic>? restaurant;
//   bool isLoading = true;
//   bool isError = false;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final restaurantId = ModalRoute.of(context)!.settings.arguments as String;
//     fetchRestaurant(restaurantId);
//   }

//  Future<void> fetchRestaurant(String id) async {
//   try {
//     final response = await http.get(
//       Uri.parse('https://backend.zenzio.in/api/customer/restaurants/$id'),
//     );

//     if (!mounted) return; // <-- Add this check

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       if (data['success'] == true && data['data'] != null) {
//         setState(() {
//           restaurant = data['data'];
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isError = true;
//           isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         isError = true;
//         isLoading = false;
//       });
//     }
//   } catch (e) {
//     if (!mounted) return; // <-- Check here as well
//     setState(() {
//       isError = true;
//       isLoading = false;
//     });
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
//    final logoPath = rest['rest_logo'];
// String? imageUrl;

// if (logoPath != null && logoPath.isNotEmpty) {
//   final cleanPath = logoPath.replaceAll('/root/choozy-backend', '');
//   imageUrl = "https://backend.zenzio.in$cleanPath";
// }

// print("Restaurant Image URL (Detail): $imageUrl");


//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 220,
//             pinned: true,
//             backgroundColor: const Color(0xFFE53935),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.favorite_border),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.share),
//                 onPressed: () {},
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               background: imageUrl != null
//     ? Image.network(
//         imageUrl,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) => const Center(
//           child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
//         ),
//       )
//     : const Center(
//         child: Icon(Icons.restaurant, size: 80, color: Colors.grey),
//       ),

//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Restaurant name
//                   Text(
//                     rest['rest_name'] ?? 'Not updated',
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // Address
//                   Text(
//                     rest['rest_address'] ?? 'Address not updated',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF757575),
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // Average cost
//                   Text(
//                     'Avg cost for two: ₹${rest['avg_cost_two'] ?? "Not updated"}',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Description
//                   Text(
//                     rest['description'] ?? 'Description not available',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF757575),
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Book Table Button
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.pushNamed(
//                         context,
//                         '/booking-form',
//                         arguments: rest['id'],
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE53935),
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 56),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     icon: const Icon(Icons.event_seat),
//                     label: const Text(
//                       'Book a Table',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Gallery section
//                   const Text(
//                     'Restaurant Gallery',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildGallerySection(rest['images']),
//                   const SizedBox(height: 24),

//                   // Events section
//                   const Text(
//                     'Special Events',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildEventCard('Wine Tasting Night', 'Every Thursday, 7-9 PM',
//                       'Enjoy a curated selection of fine wines paired with appetizers'),
//                   _buildEventCard('Live Jazz Evening', 'Fridays & Saturdays, 8 PM onwards',
//                       'Relax with smooth jazz performances while you dine'),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGallerySection(List? images) {
//     if (images == null || images.isEmpty) {
//       return const Text(
//         "No images available",
//         style: TextStyle(color: Colors.grey),
//       );
//     }

//     return Row(
//       children: List.generate(
//         images.length > 2 ? 2 : images.length,
//         (index) {
//           final img = "https://backend.zenzio.in${images[index]}";
//           return Expanded(
//             child: Container(
//               margin: const EdgeInsets.only(right: 8),
//               height: 120,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 image: DecorationImage(
//                   image: NetworkImage(img),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEventCard(String title, String schedule, String description) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5F5F5),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,
//               style: const TextStyle(
//                   fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
//           const SizedBox(height: 4),
//           Text(schedule,
//               style: const TextStyle(
//                   fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFFE53935))),
//           const SizedBox(height: 8),
//           Text(description,
//               style: const TextStyle(fontSize: 13, color: Color(0xFF757575), height: 1.4)),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';

// class BookingDetailScreen extends StatelessWidget {
//   const BookingDetailScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200,
//             pinned: true,
//             backgroundColor: const Color(0xFFE53935),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.pop(context),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.favorite_border),
//                 onPressed: () {},
//               ),
//               IconButton(
//                 icon: const Icon(Icons.share),
//                 onPressed: () {},
//               ),
//             ],
//             flexibleSpace: FlexibleSpaceBar(
//               background: Container(
//                 color: const Color(0xFFF5F5F5),
//                 child: const Center(
//                   child: Icon(
//                     Icons.restaurant,
//                     size: 80,
//                     color: Color(0xFFE0E0E0),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Expanded(
//                         child: Text(
//                           'Urban Bistro',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF2D2D2D),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFE53935),
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: const Row(
//                           children: [
//                             Icon(Icons.star, color: Colors.white, size: 14),
//                             SizedBox(width: 4),
//                             Text(
//                               '4.5',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Urban Bistro offers an elegant yet comfortable dining atmosphere perfect for both casual meals and special occasions. Our spacious main dining room features panoramic city views through floor-to-ceiling windows.',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF757575),
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Private dining options are available for intimate gatherings and corporate events, with customizable menus and dedicated staff to ensure a memorable experience for all your guests.',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF757575),
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   ElevatedButton.icon(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/booking-form');
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE53935),
//                       foregroundColor: Colors.white,
//                       minimumSize: const Size(double.infinity, 56),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     icon: const Icon(Icons.event_seat),
//                     label: const Text(
//                       'Book a Table',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Restaurant Gallery',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           height: 120,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF5F5F5),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Center(
//                             child: Icon(
//                               Icons.image,
//                               size: 40,
//                               color: Color(0xFFE0E0E0),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Container(
//                           height: 120,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFF5F5F5),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Center(
//                             child: Icon(
//                               Icons.image,
//                               size: 40,
//                               color: Color(0xFFE0E0E0),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Special Events',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF2D2D2D),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildEventCard(
//                     'Wine Tasting Night',
//                     'Every Thursday, 7-9 PM',
//                     'Enjoy a curated selection of fine wines paired with chef\'s special appetizers',
//                   ),
//                   _buildEventCard(
//                     'Live Jazz Evening',
//                     'Fridays & Saturdays, 8 PM onwards',
//                     'Relax with smooth jazz performances by local artists while you dine',
//                   ),
//                   _buildEventCard(
//                     'Chef\'s Table Experience',
//                     'By reservation only',
//                     'Exclusive multi-course tasting menu prepared by our executive chef',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEventCard(String title, String schedule, String description) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5F5F5),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF2D2D2D),
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             schedule,
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w500,
//               color: Color(0xFFE53935),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             description,
//             style: const TextStyle(
//               fontSize: 13,
//               color: Color(0xFF757575),
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
