// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:zenzio_customer/screens/restaurant_detail_screen.dart';
// import '../../config/api_config.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   String _selectedFilter = 'Offers';

//   List<dynamic> _restaurants = [];
//   bool _isLoading = true;
//   bool _hasError = false;
  
//   get restaurant => null;
  
//   get index => null;

//   @override
//   void initState() {
//     super.initState();
//     _fetchRestaurants();
//   }

//   Future<void> _fetchRestaurants() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.restaurantsEndpoint}');
//       final response = await http.get(url, headers: ApiConfig.headers);

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         setState(() {
//           _restaurants = jsonResponse['data'];
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _hasError = true;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
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
//           'Zenzio',
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
//       ),
//       body: Column(
//         children: [
//           // 🔍 Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _searchController,
//               onChanged: (value) => setState(() {}),
//               decoration: InputDecoration(
//                 hintText: 'Search for restaurants or dishes',
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // 📦 Restaurant List
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _hasError
//                     ? const Center(child: Text('Failed to load restaurants'))
//                     : _restaurants.isEmpty
//                         ? const Center(child: Text('No restaurants found'))
//                         : RefreshIndicator(
//                             onRefresh: _fetchRestaurants,
//                             child: ListView.builder(
//                               padding: const EdgeInsets.symmetric(horizontal: 16),
//                               itemCount: _restaurants.length,
//                               itemBuilder: (context, index) {
//                                 final restaurant = _restaurants[index];

//                                 // Search filtering
//                                 if (_searchController.text.isNotEmpty &&
//                                     !restaurant['rest_name']
//                                         .toString()
//                                         .toLowerCase()
//                                         .contains(_searchController.text.toLowerCase())) {
//                                   return const SizedBox.shrink();
//                                 }

//                                 // ✅ Pass restaurantId here
//                                 return _buildRestaurantCard(
//                                   restaurant['rest_name'] ?? 'Unknown',
//                                   restaurant['rest_address'] ?? '',
//                                   '20–30 min',
//                                   '4.5',
//                                   restaurant['rest_logo'] ?? '',
//                                   null,
//                                   restaurantId: restaurant['id'] ?? restaurant['rest_id'] ?? 0,
//                                 );
//                               },
//                             ),
//                           ),
//           ),
//         ],
//       ),

//       // 🛒 Floating Cart Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.pushNamed(context, '/cart');
//         },
//         backgroundColor: const Color(0xFFE53935),
//         child: const Icon(Icons.shopping_cart),
//       ),
//     );
//   }

//   // 🔹 Restaurant Card
//   Widget _buildRestaurantCard(
//     String name,
//     String cuisine,
//     String time,
//     String rating,
//     String imagePath,
//     String? offer, {
//     required dynamic restaurantId,
//   }) {
//     final String imageUrl = imagePath.isNotEmpty
//         ? 'https://backend.zenzio.in${imagePath.replaceFirst("/root/choozy-backend", "")}'
//         : '';

//     return GestureDetector(
//    onTap: () {
//   final restaurant = _restaurants[index];
//   Navigator.push(
//     context,
//     MaterialPageRoute(
//       builder: (context) => RestaurantDetailScreen(
//         restaurantId: restaurant['id']?.toString() ?? '',
//         restaurant: restaurant,
//       ),
//     ),
//   );
// },





//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🍴 Restaurant Image
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                   child: imageUrl.isNotEmpty
//                       ? Image.network(
//                           imageUrl,
//                           height: 160,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) => Container(
//                             height: 160,
//                             color: Colors.grey[200],
//                             child: const Icon(Icons.restaurant,
//                                 size: 50, color: Colors.grey),
//                           ),
//                         )
//                       : Container(
//                           height: 160,
//                           color: Colors.grey[200],
//                           child: const Icon(Icons.restaurant,
//                               size: 50, color: Colors.grey),
//                         ),
//                 ),
//                 if (offer != null)
//                   Positioned(
//                     top: 12,
//                     left: 12,
//                     child: Container(
//                       padding:
//                           const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                       decoration: BoxDecoration(
//                         color: offer.contains('Free')
//                             ? const Color(0xFF4CAF50)
//                             : const Color(0xFFFFC107),
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                       child: Text(
//                         offer,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),

//             // 🍽 Restaurant Info
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Name + Rating
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           name,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF2D2D2D),
//                           ),
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           const Icon(Icons.star,
//                               size: 16, color: Color(0xFFE53935)),
//                           const SizedBox(width: 4),
//                           Text(
//                             rating,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF2D2D2D),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     cuisine,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Color(0xFF757575),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     time,
//                     style: const TextStyle(
//                       fontSize: 13,
//                       color: Color(0xFF757575),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'restaurant_detail_screen.dart';
import '../../config/api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _restaurants = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // ✅ Use addPostFrameCallback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchRestaurants();
    });
  }

  Future<void> _fetchRestaurants() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.restaurantsEndpoint}');
      print('🌐 Fetching restaurants from: $url');
      
      final response = await http.get(
        url,
        headers: ApiConfig.headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('📥 Restaurant API Response: ${response.statusCode}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('✅ Restaurants loaded: ${jsonResponse['data']?.length ?? 0}');
        
        setState(() {
          _restaurants = jsonResponse['data'] ?? [];
          _isLoading = false;
        });
      } else {
        print('❌ Failed to load restaurants: ${response.statusCode}');
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching restaurants: $e');
      
      if (!mounted) return;
      
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          'Zenzio',
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
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search for restaurants or dishes',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE53935)),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 📦 Restaurant List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE53935),
                    ),
                  )
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load restaurants',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _fetchRestaurants,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE53935),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _restaurants.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No restaurants found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchRestaurants,
                            color: const Color(0xFFE53935),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _restaurants.length,
                              itemBuilder: (context, index) {
                                final restaurant = _restaurants[index];

                                // Search filtering
                                if (_searchController.text.isNotEmpty &&
                                    !restaurant['rest_name']
                                        .toString()
                                        .toLowerCase()
                                        .contains(_searchController.text.toLowerCase())) {
                                  return const SizedBox.shrink();
                                }

                                return _buildRestaurantCard(
                                  context,
                                  restaurant,
                                  index,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  // 🔹 Restaurant Card
  Widget _buildRestaurantCard(
    BuildContext context,
    Map<String, dynamic> restaurant,
    int index,
  ) {
    final String name = restaurant['rest_name'] ?? 'Unknown';
    final String cuisine = restaurant['rest_address'] ?? '';
    final String avgCost = restaurant['avg_cost_two']?.toString() ?? '0';
    final String imagePath = restaurant['rest_logo'] ?? '';
    final String restaurantId = restaurant['id']?.toString() ?? '';

    final String imageUrl = imagePath.isNotEmpty
        ? 'https://backend.zenzio.in${imagePath.replaceFirst("/root/choozy-backend", "")}'
        : '';

    return GestureDetector(
      onTap: () {
        if (restaurantId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid restaurant ID'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // ✅ Navigate to restaurant detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(
              restaurantId: restaurantId,
              // restaurant: restaurant,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🍴 Restaurant Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: const Color(0xFFE53935),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ Image load error for $name: $error');
                        return Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant,
                              size: 50, color: Colors.grey),
                        );
                      },
                    )
                  : Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant,
                          size: 50, color: Colors.grey),
                    ),
            ),

            // 🍽 Restaurant Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Cost
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      Text(
                        '₹$avgCost for two',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cuisine,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}