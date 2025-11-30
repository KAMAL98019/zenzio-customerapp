import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:zenzio/data/models/food_model.dart';
import 'package:zenzio/services/api_service.dart';
import 'package:zenzio/services/auth_service.dart';
import 'package:zenzio/services/location_service.dart';
import '../../data/models/food_item.dart';
import '../../data/models/cart_model.dart';
import '../../services/cart_service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
} 

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  List<FoodItem> _foodItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  Position? _currentPosition;

  String? selectedCuisine = 'All';
  String? selectedCategory = 'All';
  String? selectedType = 'All';

  List<String> cuisines = ['All'];
  List<String> categories = ['All'];
  List<String> types = ['All', 'Veg', 'Non-Veg'];

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Initialize location and fetch menus
  Future<void> _initializeAndFetch() async {
    // Check if user is logged in
    await _checkAuthStatus();
    await _getLocationAndFetch();
  }

  /// Check authentication status
  Future<void> _checkAuthStatus() async {
    final token = await _authService.getAccessToken();
    final isLoggedIn = _authService.isLoggedIn;
    
    debugPrint('🔐 Auth Status Check:');
    debugPrint('  - Token exists: ${token != null && token.isNotEmpty}');
    debugPrint('  - Token length: ${token?.length ?? 0}');
    debugPrint('  - Is logged in: $isLoggedIn');
    debugPrint('  - Current user: ${_authService.currentUser?.name ?? "null"}');
    
    if (token != null && token.isNotEmpty) {
      debugPrint('  - Token preview: ${token.substring(0, min(30, token.length))}...');
    }
  }

  /// Get current location and fetch menus
  Future<void> _getLocationAndFetch() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check auth first
      final token = await _authService.getAccessToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No access token - user needs to login');
        if (mounted) {
          setState(() {
            _errorMessage = 'Please log in to view menu items';
            _isLoading = false;
          });
        }
        return;
      }

      // Get current location
      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Location permission required to view nearby menus';
            _isLoading = false;
          });
        }
        return;
      }

      _currentPosition = position;
      debugPrint('📍 Location: ${position.latitude}, ${position.longitude}');

      // Fetch menus with location
      await fetchFoodItems(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('❌ Location error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to get location. Please enable location services.';
          _isLoading = false;
        });
      }
    }
  }

/// Fetch food items from nearest restaurant
Future<void> fetchFoodItems(double lat, double lng) async {
  if (!mounted) return;

  setState(() => _isLoading = true);

  try {
    debugPrint('🌐 Fetching nearest food items from API');
    debugPrint('📍 Coordinates: lat=$lat, lng=$lng');

    // Double-check token before making request
    final token = await _authService.getAccessToken();
    debugPrint(
      '🔑 Token before API call: ${token != null ? "EXISTS (${token.length} chars)" : "NULL"}'
    );

    // Make API request with location parameters
    final response = await _apiService.get(
      '/restaurant-menu/nearest?lat=$lat&lng=$lng',
      requiresAuth: true,
    );

    debugPrint('📥 Food items response received');
    debugPrint('📦 Response structure: ${response.keys.toList()}');

    // Extract restaurant_menus
    List<dynamic> itemsData = [];
    if (response['status'] == 'success' &&
        response['data'] != null &&
        response['data']['restaurant_menus'] is List) {
      itemsData = response['data']['restaurant_menus'] as List;
    }

    if (itemsData.isEmpty) {
      debugPrint('⚠️ No food items found in response');
      if (mounted) {
        setState(() {
          _foodItems = [];
          _isLoading = false;
          _errorMessage = null;
        });
      }
      return;
    }

    final items = itemsData
        .map<FoodItem>((e) => FoodItem.fromJson(e as Map<String, dynamic>))
        .toList();

    // Extract unique cuisines and categories
    final cuisineSet = <String>{};
    final categorySet = <String>{};

    for (var item in items) {
      final c = item.cuisine?.trim();
      final cat = item.category?.trim();
      if (c != null && c.isNotEmpty) cuisineSet.add(c);
      if (cat != null && cat.isNotEmpty) categorySet.add(cat);
    }

    if (!mounted) return;

    setState(() {
      _foodItems = items;
      cuisines = ['All', ...cuisineSet.toList()..sort()];
      categories = ['All', ...categorySet.toList()..sort()];
      _isLoading = false;
      _errorMessage = null;

      // Ensure selected values are valid
      if (!cuisines.contains(selectedCuisine)) selectedCuisine = 'All';
      if (!categories.contains(selectedCategory)) selectedCategory = 'All';
    });

    debugPrint('✅ Loaded ${items.length} food items from nearest restaurant');

  } on ApiException catch (e) {
    debugPrint('❌ API Error: ${e.message} (Status: ${e.statusCode})');

    if (mounted) {
      setState(() {
        _errorMessage = e.statusCode == 401
            ? 'Session expired. Please log in again.'
            : e.message;
        _isLoading = false;
      });
    }

  } catch (e) {
    debugPrint('❌ Error fetching food items: $e');

    if (mounted) {
      setState(() {
        _errorMessage = 'Failed to load menu items. Please try again.';
        _isLoading = false;
      });
    }
  }
}


  // /// Fetch food items from nearest restaurant
  // Future<void> fetchFoodItems(double lat, double lng) async {
  //   if (!mounted) return;

  //   setState(() => _isLoading = true);

  //   try {
  //     debugPrint('🌐 Fetching nearest food items from API');
  //     debugPrint('📍 Coordinates: lat=$lat, lng=$lng');

  //     // Double-check token before making request
  //     final token = await _authService.getAccessToken();
  //     debugPrint('🔑 Token before API call: ${token != null ? "EXISTS (${token.length} chars)" : "NULL"}');

  //     // Make API request with location parameters
  //     final response = await _apiService.get(
  //       '/restaurant-menu/nearest?lat=$lat&lng=$lng',
  //       requiresAuth: true,
  //     );

  //     debugPrint('📥 Food items response received');
  //     debugPrint('📦 Response structure: ${response.keys.toList()}');

  //     // Handle different response formats
  //     List<dynamic> itemsData = [];
      
  //     if (response['success'] == true) {
  //       // Format 1: {success: true, data: [...]}
  //       if (response['data'] is List) {
  //         itemsData = response['data'] as List;
  //       } 
  //       // Format 2: {success: true, data: {items: [...]}}
  //       else if (response['data'] is Map && response['data']['items'] is List) {
  //         itemsData = response['data']['items'] as List;
  //       }
  //       // Format 3: {success: true, data: {menuItems: [...]}}
  //       else if (response['data'] is Map && response['data']['menuItems'] is List) {
  //         itemsData = response['data']['menuItems'] as List;
  //       }
  //     } 
  //     // Format 4: Direct list [{...}, {...}]
  //     else if (response is List) {
  //       itemsData = response;
  //     }
  //     // Format 5: {items: [...]}
  //     else if (response['items'] is List) {
  //       itemsData = response['items'] as List;
  //     }
  //     // Format 6: {menuItems: [...]}
  //     else if (response['menuItems'] is List) {
  //       itemsData = response['menuItems'] as List;
  //     }

  //     if (itemsData.isEmpty) {
  //       debugPrint('⚠️ No food items found in response');
  //       if (mounted) {
  //         setState(() {
  //           _foodItems = [];
  //           _isLoading = false;
  //           _errorMessage = null;
  //         });
  //       }
  //       return;
  //     }

  //     final items = itemsData
  //         .map<FoodItem>((e) => FoodItem.fromJson(e as Map<String, dynamic>))
  //         .toList();

  //     // Extract unique cuisines and categories
  //     final cuisineSet = <String>{};
  //     final categorySet = <String>{};

  //     for (var item in items) {
  //       final c = item.cuisine?.trim();
  //       final cat = item.category?.trim();
  //       if (c != null && c.isNotEmpty) cuisineSet.add(c);
  //       if (cat != null && cat.isNotEmpty) categorySet.add(cat);
  //     }

  //     if (!mounted) return;

  //     setState(() {
  //       _foodItems = items;
  //       cuisines = ['All', ...cuisineSet.toList()..sort()];
  //       categories = ['All', ...categorySet.toList()..sort()];
  //       _isLoading = false;
  //       _errorMessage = null;

  //       // Ensure selected values are valid
  //       if (!cuisines.contains(selectedCuisine)) selectedCuisine = 'All';
  //       if (!categories.contains(selectedCategory)) selectedCategory = 'All';
  //     });

  //     debugPrint('✅ Loaded ${items.length} food items from nearest restaurant');
      
  //   } on ApiException catch (e) {
  //     debugPrint('❌ API Error: ${e.message} (Status: ${e.statusCode})');
      
  //     if (mounted) {
  //       setState(() {
  //         _errorMessage = e.statusCode == 401 
  //             ? 'Session expired. Please log in again.'
  //             : e.message;
  //         _isLoading = false;
  //       });
  //     }
      
  //   } catch (e) {
  //     debugPrint('❌ Error fetching food items: $e');
      
  //     if (mounted) {
  //       setState(() {
  //         _errorMessage = 'Failed to load menu items. Please try again.';
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  /// Apply filters to food items
  List<FoodItem> _applyFilters(List<FoodItem> foods) {
    return foods.where((food) {
      final matchCuisine = selectedCuisine == 'All' ||
          (food.cuisine?.toLowerCase() ?? '')
              .contains(selectedCuisine!.toLowerCase());
      
      final matchCategory = selectedCategory == 'All' ||
          (food.category?.toLowerCase() ?? '')
              .contains(selectedCategory!.toLowerCase());
      
      final matchType = selectedType == 'All' ||
          (selectedType == 'Veg' ? food.veg == true : food.veg == false);
      
      final matchSearch = _searchController.text.isEmpty ||
          food.name.toLowerCase().contains(_searchController.text.toLowerCase());
      
      return matchCuisine && matchCategory && matchType && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFoods = _applyFilters(_foodItems);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          " Menu",
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
        //   onPressed: () => Navigator.pop(context),
        // ),
        actions: [
          // Debug button
          // IconButton(
          //   icon: const Icon(Icons.bug_report, color: Colors.blue),
          //   onPressed: _checkAuthStatus,
          // ),
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
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE53935),
                    ),
                  )
                : _errorMessage != null
                    ? _buildErrorState()
                    : filteredFoods.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _getLocationAndFetch,
                            color: const Color(0xFFE53935),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredFoods.length,
                              itemBuilder: (context, index) =>
                                  _buildFoodCard(filteredFoods[index]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for dishes...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (query) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDropdown("Cuisine", cuisines, selectedCuisine, (val) {
            setState(() => selectedCuisine = val);
          }),
          _buildDropdown("Category", categories, selectedCategory, (val) {
            setState(() => selectedCategory = val);
          }),
          _buildDropdown("Type", types, selectedType, (val) {
            setState(() => selectedType = val);
          }),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    String? selected,
    Function(String?) onChanged,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selected,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _getLocationAndFetch,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.login),
              label: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'No dishes found'
                : 'No food items available nearby',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    color: const Color(0xFFF5F5F5),
    borderRadius: BorderRadius.circular(8),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: (food.imageUrl != null && food.imageUrl!.isNotEmpty)
        ? Image.network(
            food.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.restaurant,
                  size: 40,
                  color: Color(0xFFE0E0E0),
                ),
              );
            },
          )
        : const Center(
            child: Icon(
              Icons.restaurant,
              size: 40,
              color: Color(0xFFE0E0E0),
            ),
          ),
  ),
)
,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (food.description != null && food.description!.isNotEmpty)
                  Text(
                    food.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (food.cuisine != null)
                        _buildTag(food.cuisine!, Icons.restaurant_menu, Colors.orange),
                      if (food.category != null)
                        _buildTag(food.category!, Icons.category, Colors.blue),
                      _buildTag(
                        food.veg == true ? "Veg" : "Non-Veg",
                        food.veg == true ? Icons.eco : Icons.set_meal,
                        food.veg == true ? Colors.green : Colors.redAccent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${food.price?.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openAddItemSheet(food),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openAddItemSheet(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddItemSheet(food: food),
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}

// Add Item Sheet remains the same...
class AddItemSheet extends StatefulWidget {
  final FoodItem food;
      // print("❌food items: $Food");

  const AddItemSheet({super.key, required this.food});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  int _quantity = 1;
  String _size = 'Medium';
  String _spice = 'Medium';
  bool _isAddingToCart = false;

  double get _total {
    double base = widget.food.price ?? 0;
    double extra = _size == 'Large' ? 40 : _size == 'Small' ? -50 : 0;
    return (base + extra) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.food.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '₹${widget.food.price?.toStringAsFixed(0) ?? '0'}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          if (widget.food.description?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                widget.food.description!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          const SizedBox(height: 20),
          _buildQuantitySelector(),
          const SizedBox(height: 20),
          const Text('Choose size', style: TextStyle(fontWeight: FontWeight.w500)),
          _buildSizeOption('Small', '-₹50'),
          _buildSizeOption('Medium', '₹0'),
          _buildSizeOption('Large', '+₹40'),
          const SizedBox(height: 16),
          const Text('Choose spice level', style: TextStyle(fontWeight: FontWeight.w500)),
          _buildSpiceOption('Mild'),
          _buildSpiceOption('Medium'),
          _buildSpiceOption('Hot'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _addToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                'Add to Cart - ₹${_total.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFE53935)),
          onPressed: () {
            if (_quantity > 1) setState(() => _quantity--);
          },
        ),
        Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE53935)),
          onPressed: () => setState(() => _quantity++),
        ),
      ],
    );
  }

  Widget _buildSizeOption(String size, String price) => GestureDetector(
        onTap: () => setState(() => _size = size),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _size == size ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                _size == size ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _size == size ? const Color(0xFFE53935) : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(size),
              const Spacer(),
              Text(price),
            ],
          ),
        ),
      );

  Widget _buildSpiceOption(String spice) => GestureDetector(
        onTap: () => setState(() => _spice = spice),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _spice == spice ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                _spice == spice ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _spice == spice ? const Color(0xFFE53935) : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(spice),
            ],
          ),
        ),
      );

  Future<void> _addToCart() async {
    final cartService = CartService();
    // final item = CartItem(
    //   foodId: widget.food.id,
    //   quantity: _quantity,
    //   selectedAddOns: [
    //     if (_size == 'Large') AddOn(name: 'Large Size', price: 40),
    //     if (_size == 'Small') AddOn(name: 'Small Size', price: -50),
    //     AddOn(name: 'Spice: $_spice', price: 0),
    //   ],
    // );
    final item = CartItem(
  restaurantUid: widget.food.restaurantUid ?? "",
    // menuUid: widget.food.menuUid ?? "", 
        menuUid: widget.food.menuUid ?? "", 

  menuName: widget.food.name,                 // <--- real name
  price: widget.food.price ?? 0,              // <--- real price
  qty: _quantity,
);


    try {
      await cartService.addToCart(item);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.food.name} added to cart'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      if (e.toString().contains('DIFFERENT_RESTAURANT')) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cart Conflict'),
            content: const Text('You already have items from another restaurant. Clear your cart?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  try {
                    await cartService.clearCart();
                    await cartService.addToCart(item);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.food.name} added to cart'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (err) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $err'), backgroundColor: Colors.red),
                    );
                  }
                },
                child: const Text('Clear & Add'),
              ),
            ],
          ),
        );
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
} 




// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:zenzio_customer/config/api_config.dart';
// import 'package:zenzio_customer/services/api_service.dart';
// import 'package:zenzio_customer/services/auth_service.dart';
// import '../../data/models/food_item.dart';
// import '../../data/models/cart_model.dart';
// import '../../services/cart_service.dart';

// class MenuScreen extends StatefulWidget {
//   const MenuScreen({super.key});

//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> {
//   final TextEditingController _searchController = TextEditingController();

//   List<FoodItem> _foodItems = [];
//   bool _isLoading = true;

//   String? selectedCuisine = 'All';
//   String? selectedCategory = 'All';
//   String? selectedType = 'All';

//   List<String> cuisines = ['All'];
//   List<String> categories = ['All'];
//   List<String> types = ['All', 'Veg', 'Non-Veg'];

//   void initState() {
//     super.initState();
//     fetchFoodItems();
//   }

//  Future<void> fetchFoodItems() async {
//   try {
//     // ✅ Check if user is logged in first
//     final authService = AuthService();
//     final hasToken = await authService.hasValidToken();
    
//     if (!hasToken) {
//       debugPrint('❌ No auth token found. User must login first.');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please log in to view menu items'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         // Optionally navigate to login
//         // Navigator.pushReplacementNamed(context, '/login');
//       }
//       return;
//     }

//     setState(() => _isLoading = true);

//     final api = ApiService();
//     final response = await api.get(
//       '/restaurant-menu',
//       requiresAuth: true,
//     );

//     debugPrint('📥 Food items response: $response');

//     if (response['success'] == true && response['data'] is List) {
//       final List<dynamic> foodData = response['data'];

//       final items = foodData
//           .map<FoodItem>((e) => FoodItem.fromJson(e))
//           .toList();

//       final cuisineSet = <String>{};
//       final categorySet = <String>{};

//       for (var item in items) {
//         final c = item.cuisine?.trim();
//         final cat = item.category?.trim();
//         if (c != null && c.isNotEmpty) cuisineSet.add(c);
//         if (cat != null && cat.isNotEmpty) categorySet.add(cat);
//       }

//       setState(() {
//         _foodItems = items;
//         cuisines = ['All', ...cuisineSet.toList()..sort()];
//         categories = ['All', ...categorySet.toList()..sort()];
//         _isLoading = false;
//       });

//       debugPrint('✅ Loaded ${items.length} food items');
//       return;
//     }
    
//     throw Exception('Invalid response format');
    
//   } on ApiException catch (e) {
//     debugPrint('❌ API Error fetching food items: ${e.message}');
//     if (e.statusCode == 401) {
//       // Token expired or invalid
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Session expired. Please log in again.'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//         // Clear invalid token
//         await AuthService().logout();
//         // Navigate to login
//         // Navigator.pushReplacementNamed(context, '/login');
//       }
//     }
//     setState(() => _isLoading = false);
//   } catch (e) {
//     debugPrint('❌ Error fetching food items: $e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//     setState(() => _isLoading = false);
//   }
// }

// //  Future<void> fetchFoodItems() async {
// //   try {
// //     final response =
// //         await http.get(Uri.parse('https://backend.zenzio.in/api/food-items'));
// //     if (response.statusCode == 200) {
// //       final data = json.decode(response.body) as Map<String, dynamic>;
// //       if (data['success'] == true && data['data'] is List) {
// //         final List<dynamic> foodData = data['data'];
// //         final items = foodData
// //             .map<FoodItem>((e) => FoodItem.fromJson(e as Map<String, dynamic>))
// //             .toList();

// //         // ✅ Remove duplicates + empty + trim spaces
// //         final cuisineSet = <String>{};
// //         final categorySet = <String>{};

// //         for (var item in items) {
// //           final c = item.cuisine?.trim();
// //           final cat = item.category?.trim();
// //           if (c != null && c.isNotEmpty) cuisineSet.add(c);
// //           if (cat != null && cat.isNotEmpty) categorySet.add(cat);
// //         }

// //         final sortedCuisine = ['All', ...cuisineSet.toList()..sort()];
// //         final sortedCategory = ['All', ...categorySet.toList()..sort()];

// //         setState(() {
// //           _foodItems = items;
// //           cuisines = sortedCuisine;
// //           categories = sortedCategory;
// //           _isLoading = false;

// //           // ✅ Ensure selected values are valid
// //           if (!cuisines.contains(selectedCuisine)) selectedCuisine = 'All';
// //           if (!categories.contains(selectedCategory)) selectedCategory = 'All';
// //         });
// //         return;
// //       }
// //     }
// //     throw Exception('Failed to load food items (status: ${response.statusCode})');
// //   } catch (e) {
// //     debugPrint('❌ Error fetching food items: $e');
// //     if (!mounted) return;
// //     setState(() => _isLoading = false);
// //   }
// // }

//   List<FoodItem> _applyFilters(List<FoodItem> foods) {
//     return foods.where((food) {
//       final matchCuisine = selectedCuisine == 'All' ||
//           (food.cuisine?.toLowerCase() ?? '').contains(selectedCuisine!.toLowerCase());
//       final matchCategory = selectedCategory == 'All' ||
//           (food.category?.toLowerCase() ?? '').contains(selectedCategory!.toLowerCase());
//       final matchType = selectedType == 'All' ||
//           (selectedType == 'Veg' ? food.veg == true : food.veg == false);
//       final matchSearch = _searchController.text.isEmpty ||
//           food.name.toLowerCase().contains(_searchController.text.toLowerCase());
//       return matchCuisine && matchCategory && matchType && matchSearch;
//     }).toList();
//   }

//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Widget build(BuildContext context) {
//     final filteredFoods = _applyFilters(_foodItems);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Menu",
//             style: TextStyle(
//                 color: Color(0xFF2D2D2D),
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18)),
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.shopping_cart, color: Color(0xFFE53935)),
//             onPressed: () => Navigator.pushNamed(context, '/cart'),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           _buildSearchBar(),
//           _buildFilterChips(),
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
//                 : filteredFoods.isEmpty
//                     ? const Center(child: Text('No food items found', style: TextStyle(color: Colors.grey)))
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: filteredFoods.length,
//                         itemBuilder: (context, index) => _buildFoodCard(filteredFoods[index]),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       child: TextField(
//         controller: _searchController,
//         decoration: InputDecoration(
//           hintText: 'Search for dishes...',
//           prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
//           filled: true,
//           fillColor: const Color(0xFFF5F5F5),
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//               borderSide: BorderSide.none),
//         ),
//         onChanged: (query) => setState(() {}),
//       ),
//     );
//   }

//   Widget _buildFilterChips() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _buildDropdown("Cuisine", cuisines, selectedCuisine, (val) {
//             setState(() => selectedCuisine = val);
//           }),
//           _buildDropdown("Category", categories, selectedCategory, (val) {
//             setState(() => selectedCategory = val);
//           }),
//           _buildDropdown("Type", types, selectedType, (val) {
//             setState(() => selectedType = val);
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildDropdown(String label, List<String> items, String? selected, Function(String?) onChanged) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 8),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF5F5F5),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             isExpanded: true,
//             value: selected,
//             icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
//             items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//             onChanged: onChanged,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFoodCard(FoodItem food) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center vertically
//         children: [
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5F5),
//               borderRadius: BorderRadius.circular(8),
//               image: (food.imageUrl != null && food.imageUrl!.isNotEmpty)
//                   ? DecorationImage(image: NetworkImage(food.imageUrl!), fit: BoxFit.cover)
//                   : null,
//             ),
//             child: (food.imageUrl == null || food.imageUrl!.isEmpty)
//                 ? const Center(child: Icon(Icons.restaurant, size: 40, color: Color(0xFFE0E0E0)))
//                 : null,
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(food.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 4),
//                 Text(food.description ?? '',
//                     style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis),
//                 const SizedBox(height: 6),
//                SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: Row(
//     children: [
//       if (food.cuisine != null)
//         _buildTag(food.cuisine!, Icons.restaurant_menu, Colors.orange),
//       if (food.category != null)
//         _buildTag(food.category!, Icons.category, Colors.blue),
//       _buildTag(
//         food.veg == true ? "Veg" : "Non-Veg",
//         food.veg == true ? Icons.eco : Icons.set_meal,
//         food.veg == true ? Colors.green : Colors.redAccent,
//       ),
//     ],
//   ),
// ),


//                 const SizedBox(height: 8),
//                 Text('₹${food.price?.toStringAsFixed(0) ?? '0'}',
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
//               ],
//             ),
//           ),
//           GestureDetector(
//             onTap: () => _openAddItemSheet(food),
//             child: Container(
//               width: 40,
//               height: 40,
//               decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
//               child: const Center(
//                 child: Icon(Icons.add, color: Colors.white, size: 22),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTag(String text, IconData icon, Color color) {
//     return Container(
//       margin: const EdgeInsets.only(right: 6),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(mainAxisSize: MainAxisSize.min, children: [
//         Icon(icon, size: 12, color: color),
//         const SizedBox(width: 4),
//         Text(text,
//             style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
//       ]),
//     );
//   }

//   void _openAddItemSheet(FoodItem food) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//         child: AddItemSheet(food: food),
//       ),
//     );
//   }
// }


// // ----------------------------- 🛍 Add Item Sheet -----------------------------
// class AddItemSheet extends StatefulWidget {
//   final FoodItem food;
//   const AddItemSheet({super.key, required this.food});

//   @override
//   State<AddItemSheet> createState() => _AddItemSheetState();
// }

// class _AddItemSheetState extends State<AddItemSheet> {
//   int _quantity = 1;
//   String _size = 'Medium';
//   String _spice = 'Medium';

//   double get _total {
//     double base = widget.food.price ?? 0;
//     double extra = _size == 'Large'
//         ? 40
//         : _size == 'Small'
//             ? -50
//             : 0;
//     return (base + extra) * _quantity;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(widget.food.name,
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.w600)),
//               ),
//               Text('₹${widget.food.price?.toStringAsFixed(0) ?? '0'}',
//                   style: const TextStyle(
//                       fontSize: 18,
//                       color: Color(0xFFE53935),
//                       fontWeight: FontWeight.w600)),
//               IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context)),
//             ],
//           ),
//           if (widget.food.description?.isNotEmpty ?? false)
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text(widget.food.description!,
//                   style: const TextStyle(color: Colors.grey)),
//             ),
//           const SizedBox(height: 20),
//           _buildQuantitySelector(),
//           const SizedBox(height: 20),
//           const Text('Choose size',
//               style: TextStyle(fontWeight: FontWeight.w500)),
//           _buildSizeOption('Small', '-₹50'),
//           _buildSizeOption('Medium', '₹0'),
//           _buildSizeOption('Large', '+₹40'),
//           const SizedBox(height: 16),
//           const Text('Choose spice level',
//               style: TextStyle(fontWeight: FontWeight.w500)),
//           _buildSpiceOption('Mild'),
//           _buildSpiceOption('Medium'),
//           _buildSpiceOption('Hot'),
//           const SizedBox(height: 24),
//           SizedBox(
//             width: double.infinity,
//             height: 52,
//             child: ElevatedButton(
//               onPressed: _addToCart,
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                    foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10))),
//               child: Text('Add to Cart - ₹${_total.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                       fontSize: 16, fontWeight: FontWeight.bold)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuantitySelector() {
//     return Row(
//       children: [
//         const Text('Quantity',
//             style: TextStyle(fontWeight: FontWeight.w500)),
//         const Spacer(),
//         IconButton(
//             icon: const Icon(Icons.remove_circle_outline,
//                 color: Color(0xFFE53935)),
//             onPressed: () {
//               if (_quantity > 1) setState(() => _quantity--);
//             }),
//         Text('$_quantity',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         IconButton(
//             icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE53935)),
//             onPressed: () => setState(() => _quantity++)),
//       ],
//     );
//   }

//   Widget _buildSizeOption(String size, String price) => GestureDetector(
//         onTap: () => setState(() => _size = size),
//         child: Container(
//           margin: const EdgeInsets.only(top: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//               border: Border.all(
//                   color: _size == size
//                       ? const Color(0xFFE53935)
//                       : const Color(0xFFE0E0E0)),
//               borderRadius: BorderRadius.circular(10)),
//           child: Row(children: [
//             Icon(
//                 _size == size
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//                 color:
//                     _size == size ? const Color(0xFFE53935) : Colors.grey),
//             const SizedBox(width: 8),
//             Text(size),
//             const Spacer(),
//             Text(price),
//           ]),
//         ),
//       );

//   Widget _buildSpiceOption(String spice) => GestureDetector(
//         onTap: () => setState(() => _spice = spice),
//         child: Container(
//           margin: const EdgeInsets.only(top: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//               border: Border.all(
//                   color: _spice == spice
//                       ? const Color(0xFFE53935)
//                       : const Color(0xFFE0E0E0)),
//               borderRadius: BorderRadius.circular(10)),
//           child: Row(children: [
//             Icon(
//                 _spice == spice
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//                 color:
//                     _spice == spice ? const Color(0xFFE53935) : Colors.grey),
//             const SizedBox(width: 8),
//             Text(spice),
//           ]),
//         ),
//       );

//   Future<void> _addToCart() async {
//   final cartService = CartService();
//   final item = CartItem(
//     foodId: widget.food.id,
//     quantity: _quantity,
//     selectedAddOns: [
//       if (_size == 'Large') AddOn(name: 'Large Size', price: 40),
//       if (_size == 'Small') AddOn(name: 'Small Size', price: -50),
//       AddOn(name: 'Spice: $_spice', price: 0),
//     ],
//   );

//   try {
//     await cartService.addToCart(item);

//     if (!mounted) return;
//     Navigator.pop(context);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('${widget.food.name} added to cart successfully'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   } catch (e) {
//     if (!mounted) return;
//     Navigator.pop(context);

//     // Handle different restaurant
//     if (e.toString().contains('DIFFERENT_RESTAURANT')) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text('Cart Conflict'),
//           content: const Text(
//               'You already have items from another restaurant. Clear your cart and add this item?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context); // Close dialog
//                 try {
//                   await cartService.clearCart();
//                   await cartService.addToCart(item);
//                   if (!mounted) return;
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text(
//                           '${widget.food.name} added to cart successfully'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                   Navigator.pop(context); // Close AddItemSheet if open
//                 } catch (err) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error: $err'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               child: const Text('Clear & Add'),
//             ),
//           ],
//         ),
//       );
//     } else {
//       // Generic error
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//       );
//     }
//   }
// }
// }



// // import 'package:flutter/material.dart';

// // class MenuScreen extends StatefulWidget {
// //   const MenuScreen({super.key});

// //   @override
// //   State<MenuScreen> createState() => _MenuScreenState();
// // }

// // class _MenuScreenState extends State<MenuScreen> {
// //   String _selectedFilter = 'Meat';
// //   final TextEditingController _searchController = TextEditingController();

// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // return Scaffold(
// //     //   backgroundColor: Colors.white,
// //     //   appBar: AppBar(
// //     //     backgroundColor: Colors.white,
// //     //     elevation: 0,
// //     //     automaticallyImplyLeading: false,
// //     //     title: const Text(
// //     //       'Order',
// //     //       style: TextStyle(
// //     //         color: Color(0xFF2D2D2D),
// //     //         fontSize: 18,
// //     //         fontWeight: FontWeight.w600,
// //     //       ),
// //     //     ),
// //     //     centerTitle: true,
// //     //     actions: [
// //     //       IconButton(
// //     //         icon: const Icon(Icons.person_outline, color: Color(0xFFE53935)),
// //     //         onPressed: () {
// //     //           Navigator.pushNamed(context, '/profile');
// //     //         },
// //     //       ),
// //     //     ],
// //     //   ),
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: const Text(
// //           'Order',
// //           style: TextStyle(
// //             color: Color(0xFF2D2D2D),
// //             fontSize: 18,
// //             fontWeight: FontWeight.w600,
// //           ),
// //         ),
// //         centerTitle: true,
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.person, color: Color(0xFFE53935)),
// //             onPressed: () {
// //               Navigator.pushNamed(context, '/profile');
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             child: TextField(
// //               controller: _searchController,
// //               decoration: InputDecoration(
// //                 hintText: 'Search for restaurants or dishes',
// //                 hintStyle: const TextStyle(
// //                   color: Color(0xFF9E9E9E),
// //                   fontSize: 14,
// //                 ),
// //                 prefixIcon: const Icon(
// //                   Icons.search,
// //                   color: Color(0xFF9E9E9E),
// //                 ),
// //                 suffixIcon: IconButton(
// //                   icon: const Icon(
// //                     Icons.mic_none,
// //                     color: Color(0xFF9E9E9E),
// //                   ),
// //                   onPressed: () {},
// //                 ),
// //                 filled: true,
// //                 fillColor: const Color(0xFFF5F5F5),
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                   borderSide: BorderSide.none,
// //                 ),
// //                 contentPadding: const EdgeInsets.symmetric(
// //                   horizontal: 16,
// //                   vertical: 12,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //             child: SingleChildScrollView(
// //               scrollDirection: Axis.horizontal,
// //               child: Row(
// //                 children: [
// //                   _buildFilterChip('Cuisine', false),
// //                   const SizedBox(width: 8),
// //                   _buildFilterChip('Meat', true),
// //                   const SizedBox(width: 8),
// //                   _buildFilterChip('Offers', false),
// //                   const SizedBox(width: 8),
// //                   _buildFilterChip('Delivery Time', false),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: ListView(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //               children: [
// //                 _buildMenuItem('Chicken Breast Boneless', 'Freshly cut, antibiotic-free', '₹180', '1kg', '500g'),
// //                 _buildMenuItem('Chicken Curry Cut', 'Bone-in curry cut with small pieces', '₹150', '750g', '500g'),
// //                 _buildMenuItem('Chicken Drumsticks', 'Tender, marinated drumsticks', '₹220', '1kg', '800g'),
// //                 _buildMenuItem('Chicken Thigh Boneless', 'Premium cut, no antibiotics', '₹210', '750g', '500g'),
// //                 _buildMenuItem('Whole Chicken', 'Fresh, cleaned & dressed', '₹290', '1.2kg', ''),
// //                 _buildMenuItem('Chicken Mince', 'Finely minced chicken', '₹190', '500g', ''),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFilterChip(String label, bool isSelected) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       decoration: BoxDecoration(
// //         color: isSelected ? const Color(0xFFE53935) : Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(
// //           color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
// //         ),
// //       ),
// //       child: Center(
// //         child: Text(
// //           label,
// //           style: TextStyle(
// //             color: isSelected ? Colors.white : const Color(0xFF757575),
// //             fontSize: 14,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMenuItem(String name, String description, String price, String weight1, String weight2) {
// //     return GestureDetector(
      
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 16),
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(color: const Color(0xFFE0E0E0)),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.03),
// //               blurRadius: 8,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 80,
// //               height: 80,
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF5F5F5),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: const Center(
// //                 child: Icon(Icons.restaurant, size: 40, color: Color(0xFFE0E0E0)),
// //               ),
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
// //                   const SizedBox(height: 4),
// //                   Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)), maxLines: 1, overflow: TextOverflow.ellipsis),
// //                   const SizedBox(height: 8),
// //                   Row(
// //                     children: [
// //                       _buildWeightChip(weight1, true),
// //                       if (weight2.isNotEmpty) ...[const SizedBox(width: 6), _buildWeightChip(weight2, false)],
// //                     ],
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
// //                 ],
// //               ),
// //             ),
// //             GestureDetector(
// //               onTap: () {
// //                 // Stop event propagation and show add to cart message
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   SnackBar(content: Text('$name added to cart'), duration: const Duration(seconds: 1), backgroundColor: const Color(0xFF4CAF50)),
// //                 );
// //               },
// //               child: Container(
// //                 width: 36,
// //                 height: 36,
// //                 decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
// //                 child: const Icon(Icons.add, color: Colors.white, size: 20),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWeightChip(String weight, bool isSelected) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: isSelected ? const Color(0xFFE53935).withOpacity(0.1) : const Color(0xFFF5F5F5),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0)),
// //       ),
// //       child: Text(
// //         weight,
// //         style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFFE53935) : const Color(0xFF757575)),
// //       ),
// //     );
// //   }
// // }