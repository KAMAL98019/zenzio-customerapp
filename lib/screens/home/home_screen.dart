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

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:zenzio_customer/services/location_service.dart';
// import 'package:zenzio_customer/services/map_service.dart';
// import 'restaurant_detail_screen.dart';
// import '../../config/api_config.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _searchController = TextEditingController();
// final storage = const FlutterSecureStorage();

//   List<dynamic> _restaurants = [];
//   List<dynamic> _nearbyRestaurants = [];
//   bool _isLoading = true;
//   bool _hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     // ✅ Use addPostFrameCallback to avoid setState during build
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       _fetchRestaurants();
//       await _loadNearbyRestaurants();
//     });
//   }
// void debugToken() async {
//   final storage = const FlutterSecureStorage();
//   String? token = await storage.read(key: 'auth_token');
//   print("🔑 DEBUG TOKEN => $token");
// }

// Future<void> _loadNearbyRestaurants() async {
//   final pos = await LocationService.getCurrentLocation();

//   if (pos == null) {
//     print("❌ No location, skipping nearest API");
//     return;
//   }

//   final response = await MapService().getNearbyRestaurants(
//     pos.latitude,
//     pos.longitude,
//   );

//   print("🍽 Nearby Restaurants => $response");

//   setState(() {
// _nearbyRestaurants = response['data']['restaurants'] ?? [];
//   });
// }




// Future<void> _fetchRestaurants() async {
//   if (!mounted) return;

//   setState(() {
//     _isLoading = true;
//     _hasError = false;
//   });

//   try {
//     // ✅ Get token from secure storage
//     final token = await storage.read(key: 'auth_token');

//     if (token == null || token.isEmpty) {
//       throw Exception('No token found. Please log in again.');
//     }

//     final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.restaurantsEndpoint}');
//     print('🌐 Fetching restaurants from: $url');
//     print('🔐 Using token: $token');

//     // ✅ Add Authorization header
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };

//     final response = await http.get(url, headers: headers).timeout(
//       const Duration(seconds: 15),
//       onTimeout: () {
//         throw Exception('Request timeout');
//       },
//     );

//     print('📥 Restaurant API Response: ${response.statusCode}');

//     if (!mounted) return;

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body);
//       print('✅ Restaurants loaded: ${jsonResponse['data']?.length ?? 0}');
      
//       setState(() {
//         _restaurants = jsonResponse['data'] ?? [];
//         _isLoading = false;
//       });
//     } else if (response.statusCode == 401) {
//       print('🚫 Unauthorized — Token might be expired or invalid');
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//       });
//       // Optional: Navigate to login screen
//     } else {
//       print('❌ Failed to load restaurants: ${response.statusCode}');
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//       });
//     }
//   } catch (e) {
//     print('❌ Error fetching restaurants: $e');

//     if (!mounted) return;

//     setState(() {
//       _hasError = true;
//       _isLoading = false;
//     });
//   }
// }


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
//           ),

//           const SizedBox(height: 8),

//           // 📦 Restaurant List
//           Expanded(
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(
//                       color: Color(0xFFE53935),
//                     ),
//                   )
//                 : _hasError
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.error_outline,
//                               size: 64,
//                               color: Colors.red,
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'Failed to load restaurants',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             ElevatedButton.icon(
//                               onPressed: _fetchRestaurants,
//                               icon: const Icon(Icons.refresh),
//                               label: const Text('Retry'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFFE53935),
//                                 foregroundColor: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : _restaurants.isEmpty
//                         ? const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(
//                                   Icons.restaurant,
//                                   size: 64,
//                                   color: Colors.grey,
//                                 ),
//                                 SizedBox(height: 16),
//                                 Text(
//                                   'No restaurants found',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : RefreshIndicator(
//                             onRefresh: _fetchRestaurants,
//                             color: const Color(0xFFE53935),
//                             child: ListView.builder(
//                               padding: const EdgeInsets.symmetric(horizontal: 16),
//                               itemCount: _nearbyRestaurants.length,
//                               itemBuilder: (context, index) {
//                                 final restaurant = _nearbyRestaurants[index];

//                                 // Search filtering
//                                 if (_searchController.text.isNotEmpty &&
//                                     !restaurant['rest_name']
//                                         .toString()
//                                         .toLowerCase()
//                                         .contains(_searchController.text.toLowerCase())) {
//                                   return const SizedBox.shrink();
//                                 }

//                                 return _buildRestaurantCard(
//                                   context,
//                                   restaurant,
//                                   index,
//                                 );
//                               },
//                             ),
//                           ),
//           ),
//         ],
//       ),
//     );
//   }

//   // 🔹 Restaurant Card
//   Widget _buildRestaurantCard(
//     BuildContext context,
//     Map<String, dynamic> restaurant,
//     int index,
//   ) {
//     final String name = restaurant['rest_name'] ?? 'Unknown';
//     final String cuisine = restaurant['rest_address'] ?? '';
//     final String avgCost = restaurant['avg_cost_two']?.toString() ?? '0';
//     final String imagePath = restaurant['rest_logo'] ?? '';
//     final String restaurantId = restaurant['id']?.toString() ?? '';

//     final String imageUrl = imagePath.isNotEmpty
//         ? 'https://backend.zenzio.in${imagePath.replaceFirst("/root/choozy-backend", "")}'
//         : '';

//     return GestureDetector(
//       onTap: () {
//         if (restaurantId.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Invalid restaurant ID'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }

//         // ✅ Navigate to restaurant detail screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RestaurantDetailScreen(
//               restaurantId: restaurantId,
//               // restaurant: restaurant,
//             ),
//           ),
//         );
//       },
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
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               child: imageUrl.isNotEmpty
//                   ? Image.network(
//                       imageUrl,
//                       height: 160,
//                       width: double.infinity,
//                       fit: BoxFit.cover,
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Container(
//                           height: 160,
//                           color: Colors.grey[200],
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               value: loadingProgress.expectedTotalBytes != null
//                                   ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                   : null,
//                               color: const Color(0xFFE53935),
//                             ),
//                           ),
//                         );
//                       },
//                       errorBuilder: (context, error, stackTrace) {
//                         print('❌ Image load error for $name: $error');
//                         return Container(
//                           height: 160,
//                           color: Colors.grey[200],
//                           child: const Icon(Icons.restaurant,
//                               size: 50, color: Colors.grey),
//                         );
//                       },
//                     )
//                   : Container(
//                       height: 160,
//                       color: Colors.grey[200],
//                       child: const Icon(Icons.restaurant,
//                           size: 50, color: Colors.grey),
//                     ),
//             ),

//             // 🍽 Restaurant Info
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Name + Cost
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
//                       Text(
//                         '₹$avgCost for two',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFFE53935),
//                         ),
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
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:zenzio/services/location_service.dart';
import 'package:zenzio/services/map_service.dart';
import 'restaurant_detail_screen.dart';
import '../../config/api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final storage = const FlutterSecureStorage();

  List<dynamic> _nearbyRestaurants = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// Initialize screen and load data
  Future<void> _initializeScreen() async {
    // Wait for frame to be rendered
    await Future.delayed(const Duration(milliseconds: 50));
    
    // Check if user is logged in
    final token = await storage.read(key: 'auth_token');
    
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Please log in to continue';
          _isLoading = false;
        });
        
        // Show error and navigate to login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to view restaurants'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate to login after delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        });
      }
      return;
    }
    
    // Load nearby restaurants
    await _loadNearbyRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load nearby restaurants based on current location
  Future<void> _loadNearbyRestaurants() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Check token first
      final token = await storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Please log in to view restaurants');
      }

      // Get location
      final pos = await LocationService.getCurrentLocation();

      if (pos == null) {
        print("⚠️ Location not available, using default coordinates");
        // You can either show error or use default coordinates
        setState(() {
          _hasError = true;
          _errorMessage = 'Location permission required to show nearby restaurants';
          _isLoading = false;
        });
        return;
      }

      print("📍 Current location: ${pos.latitude}, ${pos.longitude}");

      // Fetch nearby restaurants
      final response = await MapService().getNearbyRestaurants(
        pos.latitude,
        pos.longitude,
      );

      print("🍽 Nearby Restaurants Response => $response");

      if (!mounted) return;

      // Parse response
      final restaurants = response['data']?['restaurants'];

      if (restaurants == null) {
        throw Exception('No restaurants data in response');
      }

      setState(() {
        _nearbyRestaurants = restaurants is List ? restaurants : [];
        _isLoading = false;
        _hasError = false;
      });

      print("✅ Loaded ${_nearbyRestaurants.length} nearby restaurants");
    } catch (e) {
      print("❌ Error loading nearby restaurants: $e");

      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _loadNearbyRestaurants,
          ),
        ),
      );
    }
  }

//  Future<String?> fetchPresignedUrl(String fileKey) async {
//   try {
//     final response = await ApiService().get('/file/view/$fileKey', requiresAuth: true);
//     return response['fileUrl'] as String?;
//   } catch (e) {
//     print('Failed to fetch pre-signed URL: $e');
//     return null;
//   }
// }


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
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search for restaurants',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE53935),
                    ),
                  )
                : _hasError
                    ? _buildErrorView()
                    : _nearbyRestaurants.isEmpty
                        ? _buildEmptyView()
                        : RefreshIndicator(
                            onRefresh: _loadNearbyRestaurants,
                            color: const Color(0xFFE53935),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _nearbyRestaurants.length,
                              itemBuilder: (context, index) {
                                final restaurant = _nearbyRestaurants[index];

                                // Search filter
                                if (_searchController.text.isNotEmpty) {
                                  final name = restaurant['rest_name']
                                      ?.toString()
                                      .toLowerCase() ?? '';
                                  final query = _searchController.text.toLowerCase();

                                  if (!name.contains(query)) {
                                    return const SizedBox.shrink();
                                  }
                                }

                                return _buildRestaurantCard(restaurant);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  /// Error view with retry button
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE53935),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage.isEmpty ? 'Failed to load restaurants' : _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadNearbyRestaurants,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty state view
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No restaurants found nearby',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching in a different area',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Restaurant card UI
  // In your HomeScreen _buildRestaurantCard method, update the onTap:

Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
  final String name = restaurant['restaurant_name'] ?? 'Unknown';
  final String restaurant_uid = restaurant['restaurant_uid'] ?? 'Unknown';
  final String address = restaurant['rest_address'] ?? '';
  final String avgCost = restaurant['avg_cost_two']?.toString() ?? '0';
  final String imagePath = restaurant['rest_logo'] ?? '';
  final profile = restaurant['profile'] ?? {};
  final List photos = profile['photo'] ?? [];

  final String imageUrl = photos.isNotEmpty ? photos.first : "";

  return GestureDetector(
    onTap: () {
      // ✅ Navigate with complete restaurant data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantDetailScreen(
            restaurantData: restaurant, // Pass the entire restaurant map
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // Restaurant image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.restaurant,
                          size: 40,
                          color: Colors.grey,
                        ),
                      );
                    },
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.restaurant,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Restaurant info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (address.isNotEmpty)
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF9E9E9E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                Text(
                  "₹$avgCost for two",
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Arrow icon
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF9E9E9E),
          ),
        ],
      ),
    ),
  );
}
}