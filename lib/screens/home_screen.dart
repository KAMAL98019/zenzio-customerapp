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
import 'package:zenzio_customer/screens/restaurant_detail_screen.dart';
import '../../config/api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Offers';

  List<dynamic> _restaurants = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.restaurantsEndpoint}');
      final response = await http.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _restaurants = jsonResponse['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
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
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 📦 Restaurant List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? const Center(child: Text('Failed to load restaurants'))
                    : _restaurants.isEmpty
                        ? const Center(child: Text('No restaurants found'))
                        : RefreshIndicator(
                            onRefresh: _fetchRestaurants,
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

                                // ✅ Pass restaurantId and restaurant data
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

      // 🛒 Floating Cart Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/cart');
        },
        backgroundColor: const Color(0xFFE53935),
        child: const Icon(Icons.shopping_cart),
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
    final String restaurantId = restaurant['id'] ?? '';

    final String imageUrl = imagePath.isNotEmpty
        ? 'https://backend.zenzio.in${imagePath.replaceFirst("/root/choozy-backend", "")}'
        : '';

    return GestureDetector(
      onTap: () {
        // ✅ Navigate to restaurant detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(
              restaurantId: restaurantId,
              restaurant: restaurant,
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 160,
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant,
                                size: 50, color: Colors.grey),
                          ),
                        )
                      : Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: const Icon(Icons.restaurant,
                              size: 50, color: Colors.grey),
                        ),
                ),
              ],
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