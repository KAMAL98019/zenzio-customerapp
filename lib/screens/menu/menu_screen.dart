import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  List<FoodItem> _foodItems = [];
  bool _isLoading = true;

  String? selectedCuisine = 'All';
  String? selectedCategory = 'All';
  String? selectedType = 'All';

  List<String> cuisines = ['All'];
  List<String> categories = ['All'];
  List<String> types = ['All', 'Veg', 'Non-Veg'];

  void initState() {
    super.initState();
    fetchFoodItems();
  }

 Future<void> fetchFoodItems() async {
  try {
    final response =
        await http.get(Uri.parse('https://backend.zenzio.in/api/food-items'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['success'] == true && data['data'] is List) {
        final List<dynamic> foodData = data['data'];
        final items = foodData
            .map<FoodItem>((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList();

        // ✅ Remove duplicates + empty + trim spaces
        final cuisineSet = <String>{};
        final categorySet = <String>{};

        for (var item in items) {
          final c = item.cuisine?.trim();
          final cat = item.category?.trim();
          if (c != null && c.isNotEmpty) cuisineSet.add(c);
          if (cat != null && cat.isNotEmpty) categorySet.add(cat);
        }

        final sortedCuisine = ['All', ...cuisineSet.toList()..sort()];
        final sortedCategory = ['All', ...categorySet.toList()..sort()];

        setState(() {
          _foodItems = items;
          cuisines = sortedCuisine;
          categories = sortedCategory;
          _isLoading = false;

          // ✅ Ensure selected values are valid
          if (!cuisines.contains(selectedCuisine)) selectedCuisine = 'All';
          if (!categories.contains(selectedCategory)) selectedCategory = 'All';
        });
        return;
      }
    }
    throw Exception('Failed to load food items (status: ${response.statusCode})');
  } catch (e) {
    debugPrint('❌ Error fetching food items: $e');
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}

  List<FoodItem> _applyFilters(List<FoodItem> foods) {
    return foods.where((food) {
      final matchCuisine = selectedCuisine == 'All' ||
          (food.cuisine?.toLowerCase() ?? '').contains(selectedCuisine!.toLowerCase());
      final matchCategory = selectedCategory == 'All' ||
          (food.category?.toLowerCase() ?? '').contains(selectedCategory!.toLowerCase());
      final matchType = selectedType == 'All' ||
          (selectedType == 'Veg' ? food.veg == true : food.veg == false);
      final matchSearch = _searchController.text.isEmpty ||
          food.name.toLowerCase().contains(_searchController.text.toLowerCase());
      return matchCuisine && matchCategory && matchType && matchSearch;
    }).toList();
  }

  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final filteredFoods = _applyFilters(_foodItems);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Menu",
            style: TextStyle(
                color: Color(0xFF2D2D2D),
                fontWeight: FontWeight.w600,
                fontSize: 18)),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Color(0xFFE53935)),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
                : filteredFoods.isEmpty
                    ? const Center(child: Text('No food items found', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredFoods.length,
                        itemBuilder: (context, index) => _buildFoodCard(filteredFoods[index]),
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
              borderSide: BorderSide.none),
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

  Widget _buildDropdown(String label, List<String> items, String? selected, Function(String?) onChanged) {
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
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: onChanged,
          ),
        ),
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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ Center vertically
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
              image: (food.imageUrl != null && food.imageUrl!.isNotEmpty)
                  ? DecorationImage(image: NetworkImage(food.imageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: (food.imageUrl == null || food.imageUrl!.isEmpty)
                ? const Center(child: Icon(Icons.restaurant, size: 40, color: Color(0xFFE0E0E0)))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(food.description ?? '',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
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
                Text('₹${food.price?.toStringAsFixed(0) ?? '0'}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D2D2D))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _openAddItemSheet(food),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
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
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(text,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  void _openAddItemSheet(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AddItemSheet(food: food),
      ),
    );
  }
}


// ----------------------------- 🛍 Add Item Sheet -----------------------------
class AddItemSheet extends StatefulWidget {
  final FoodItem food;
  const AddItemSheet({super.key, required this.food});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  int _quantity = 1;
  String _size = 'Medium';
  String _spice = 'Medium';

  double get _total {
    double base = widget.food.price ?? 0;
    double extra = _size == 'Large'
        ? 40
        : _size == 'Small'
            ? -50
            : 0;
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
                child: Text(widget.food.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600)),
              ),
              Text('₹${widget.food.price?.toStringAsFixed(0) ?? '0'}',
                  style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.w600)),
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
          if (widget.food.description?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(widget.food.description!,
                  style: const TextStyle(color: Colors.grey)),
            ),
          const SizedBox(height: 20),
          _buildQuantitySelector(),
          const SizedBox(height: 20),
          const Text('Choose size',
              style: TextStyle(fontWeight: FontWeight.w500)),
          _buildSizeOption('Small', '-₹50'),
          _buildSizeOption('Medium', '₹0'),
          _buildSizeOption('Large', '+₹40'),
          const SizedBox(height: 16),
          const Text('Choose spice level',
              style: TextStyle(fontWeight: FontWeight.w500)),
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: Text('Add to Cart - ₹${_total.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('Quantity',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        IconButton(
            icon: const Icon(Icons.remove_circle_outline,
                color: Color(0xFFE53935)),
            onPressed: () {
              if (_quantity > 1) setState(() => _quantity--);
            }),
        Text('$_quantity',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFFE53935)),
            onPressed: () => setState(() => _quantity++)),
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
                  color: _size == size
                      ? const Color(0xFFE53935)
                      : const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(
                _size == size
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    _size == size ? const Color(0xFFE53935) : Colors.grey),
            const SizedBox(width: 8),
            Text(size),
            const Spacer(),
            Text(price),
          ]),
        ),
      );

  Widget _buildSpiceOption(String spice) => GestureDetector(
        onTap: () => setState(() => _spice = spice),
        child: Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border.all(
                  color: _spice == spice
                      ? const Color(0xFFE53935)
                      : const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(
                _spice == spice
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    _spice == spice ? const Color(0xFFE53935) : Colors.grey),
            const SizedBox(width: 8),
            Text(spice),
          ]),
        ),
      );

  Future<void> _addToCart() async {
    try {
      final cartService = CartService();
      final item = CartItem(
        foodId: widget.food.id,
        quantity: _quantity,
        selectedAddOns: [
          if (_size == 'Large') AddOn(name: 'Large Size', price: 40),
          if (_size == 'Small') AddOn(name: 'Small Size', price: -50),
          AddOn(name: 'Spice: $_spice', price: 0),
        ],
      );
      final success = await cartService.addToCart(item);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? '${widget.food.name} added to cart successfully'
              : 'Failed to add item to cart'),
          backgroundColor: success ? Colors.green : Colors.red));
    } catch (e, st) {
      debugPrint('❌ Add to cart error: $e\n$st');
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }
}



// // lib/screens/menu_screen.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// // models & services from your project
// import '../data/models/food_model.dart';
// import '../data/models/cart_model.dart';      // <- provides CartItem & AddOn
// import '../services/cart_service.dart';       // <- your API wrapper for cart

// class MenuScreen extends StatefulWidget {
//   const MenuScreen({super.key});

//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> {
//   final String _selectedFilter = 'Meat';
//   final TextEditingController _searchController = TextEditingController();

//   List<Food> _foodItems = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchFoodItems();
//   }

//   Future<void> fetchFoodItems() async {
//     try {
//       final response = await http.get(Uri.parse('https://backend.zenzio.in/api/food-items'));
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body) as Map<String, dynamic>;
//         if (data['success'] == true && data['data'] is List) {
//           final List<dynamic> foodData = data['data'];
//           setState(() {
//          _foodItems = foodData.map<Food>((e) => Food.fromJson(e as Map<String, dynamic>)).toList();

//             _isLoading = false;
//           });
//           return;
//         }
//       }
//       throw Exception('Failed to load food items (status: ${response.statusCode})');
//     } catch (e, st) {
//       debugPrint('❌ Error fetching food items: $e\n$st');
//       setState(() => _isLoading = false);
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
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Order',
//           style: TextStyle(color: Color(0xFF2D2D2D), fontSize: 18, fontWeight: FontWeight.w600),
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
//           // 🔍 Search bar
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search for restaurants or dishes',
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               onChanged: (query) => setState(() {}),
//             ),
//           ),

//           // 🔘 Filter chips (UI unchanged)
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildFilterChip('Cuisine', false),
//                   const SizedBox(width: 8),
//                   _buildFilterChip('Meat', true),
//                   const SizedBox(width: 8),
//                   _buildFilterChip('Offers', false),
//                   const SizedBox(width: 8),
//                   _buildFilterChip('Delivery Time', false),
//                 ],
//               ),
//             ),
//           ),

//           // 🍗 Food items
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
//                 : _foodItems.isEmpty
//                     ? const Center(child: Text('No food items found'))
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         itemCount: _foodItems.length,
//                         itemBuilder: (context, index) {
//                           final food = _foodItems[index];

//                           // search filter
//                           if (_searchController.text.isNotEmpty &&
//                               !food.foodName.toLowerCase().contains(_searchController.text.toLowerCase())) {
//                             return const SizedBox.shrink();
//                           }

//                           return _buildMenuItem(food);
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, bool isSelected) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: isSelected ? const Color(0xFFE53935) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
//         ),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: isSelected ? Colors.white : const Color(0xFF757575),
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem(Food food) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
//         ],
//       ),
//       child: Row(
//         children: [
//           // 🖼 Image
//           Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5F5),
//               borderRadius: BorderRadius.circular(8),
//               image: (food.image != null && food.image!.isNotEmpty)
//                   ? DecorationImage(image: NetworkImage(food.image!), fit: BoxFit.cover)
//                   : null,
//             ),
//             child: (food.image == null || food.image!.isEmpty)
//                 ? const Center(child: Icon(Icons.restaurant, size: 40, color: Color(0xFFE0E0E0)))
//                 : null,
//           ),
//           const SizedBox(width: 12),

//           // 🍴 Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(food.foodName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 4),
//                 Text(
//                   food.description ?? '',
//                   style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 8),
//                 Text('₹${food.price.toStringAsFixed(0)}',
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
//               ],
//             ),
//           ),

//           // ➕ Add Button
//           GestureDetector(
//             onTap: () => _openAddItemSheet(food),
//             child: Container(
//               width: 36,
//               height: 36,
//               decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
//               child: const Icon(Icons.add, color: Colors.white, size: 20),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _openAddItemSheet(Food food) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//         child: AddItemSheet(food: food),
//       ),
//     );
//   }
// }

// /// AddItemSheet (same UI & cart logic as your RestaurantDetailScreen)
// class AddItemSheet extends StatefulWidget {
//   final Food food;
//   const AddItemSheet({super.key, required this.food});

//   @override
//   State<AddItemSheet> createState() => _AddItemSheetState();
// }

// class _AddItemSheetState extends State<AddItemSheet> {
//   int _quantity = 1;
//   String _size = 'Medium';
//   String _spice = 'Medium';

//   double get _total {
//     double base = widget.food.price;
//     double extra = _size == 'Large' ? 40 : _size == 'Small' ? -50 : 0;
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
//           // header
//           Row(
//             children: [
//               Expanded(
//                 child: Text(widget.food.foodName,
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
//               ),
//               Text('₹${widget.food.price.toStringAsFixed(0)}',
//                   style: const TextStyle(fontSize: 18, color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
//               IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
//             ],
//           ),

//           if (widget.food.description?.isNotEmpty ?? false)
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Text(widget.food.description!, style: const TextStyle(color: Colors.grey)),
//             ),
//           const SizedBox(height: 24),

//           // quantity selector
//           Row(
//             children: [
//               const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w500)),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFE53935)),
//                 onPressed: () {
//                   if (_quantity > 1) setState(() => _quantity--);
//                 },
//               ),
//               Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//               IconButton(
//                 icon: const Icon(Icons.add_circle, color: Color(0xFFE53935)),
//                 onPressed: () => setState(() => _quantity++),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // size options
//           const Text('Choose your size', style: TextStyle(fontWeight: FontWeight.w500)),
//           const SizedBox(height: 8),
//           _buildSizeOption('Small', '-₹50'),
//           _buildSizeOption('Medium', '₹0'),
//           _buildSizeOption('Large', '+₹40'),
//           const SizedBox(height: 16),

//           // spice options
//           const Text('Choose spice level', style: TextStyle(fontWeight: FontWeight.w500)),
//           _buildSpiceOption('Mild'),
//           _buildSpiceOption('Medium'),
//           _buildSpiceOption('Hot'),
//           const SizedBox(height: 24),

//           // add to cart
//           SizedBox(
//             width: double.infinity,
//             height: 56,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFE53935),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onPressed: _addToCart,
//               child: Text('Add to Cart - ₹${_total.toStringAsFixed(0)}',
//                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSizeOption(String size, String price) => GestureDetector(
//         onTap: () => setState(() => _size = size),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(color: _size == size ? const Color(0xFFE53935) : const Color(0xFFE0E0E0)),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               Icon(_size == size ? Icons.radio_button_checked : Icons.radio_button_unchecked,
//                   color: _size == size ? const Color(0xFFE53935) : Colors.grey),
//               const SizedBox(width: 8),
//               Text(size),
//               const Spacer(),
//               Text(price),
//             ],
//           ),
//         ),
//       );

//   Widget _buildSpiceOption(String spice) => GestureDetector(
//         onTap: () => setState(() => _spice = spice),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(color: _spice == spice ? const Color(0xFFE53935) : const Color(0xFFE0E0E0)),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               Icon(_spice == spice ? Icons.radio_button_checked : Icons.radio_button_unchecked,
//                   color: _spice == spice ? const Color(0xFFE53935) : Colors.grey),
//               const SizedBox(width: 8),
//               Text(spice),
//             ],
//           ),
//         ),
//       );

//   Future<void> _addToCart() async {
//     try {
//       final cartService = CartService();
//       final item = CartItem(
//         foodId: widget.food.id,
//         quantity: _quantity,
//         selectedAddOns: [
//           if (_size == 'Large') AddOn(name: 'Large Size', price: 40),
//           if (_size == 'Small') AddOn(name: 'Small Size', price: -50),
//           AddOn(name: 'Spice: $_spice', price: 0),
//         ],
//       );

//       final success = await cartService.addToCart(item);

//       if (!mounted) return;
//       Navigator.pop(context);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(success ? '${widget.food.foodName} added to cart successfully' : 'Failed to add item to cart'),
//           backgroundColor: success ? Colors.green : Colors.red,
//         ),
//       );
//     } catch (e, st) {
//       debugPrint('❌ Add to cart error: $e\n$st');
//       if (!mounted) return;
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
//     }
//   }
// }


// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class MenuScreen extends StatefulWidget {
//   const MenuScreen({super.key});

//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> {
//   String _selectedFilter = 'Meat';
//   final TextEditingController _searchController = TextEditingController();

//   List<dynamic> _foodItems = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchFoodItems();
//   }

//   Future<void> fetchFoodItems() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://backend.zenzio.in/api/food-items'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['success'] == true) {
//           setState(() {
//             _foodItems = data['data'];
//             _isLoading = false;
//           });
//         }
//       } else {
//         throw Exception('Failed to load food items');
//       }
//     } catch (e) {
//       debugPrint('Error fetching food items: $e');
//       setState(() {
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
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Order',
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
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search for restaurants or dishes',
//                 prefixIcon: const Icon(Icons.search, color: Color(0xFF9E9E9E)),
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               onChanged: (query) {
//                 setState(() {}); // Rebuild UI for filtered list
//               },
//             ),
//           ),

//           // 🔘 Filter Chips
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildFilterChip('Cuisine', false),
//                   const SizedBox(width: 8),
//                   _buildFilterChip('Meat', true),
//                   const SizedBox(width: 8),
//                   _buildFilterChip('Offers', false),
//                   const SizedBox(width: 8),
//                   _buildFilterChip('Delivery Time', false),
//                 ],
//               ),
//             ),
//           ),

//           // 🍗 Food List
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(color: Color(0xFFE53935)))
//                 : _foodItems.isEmpty
//                     ? const Center(child: Text('No food items found'))
//                     : ListView.builder(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         itemCount: _foodItems.length,
//                         itemBuilder: (context, index) {
//                           final item = _foodItems[index];
//                           final dishName = item['dishname'] ?? 'Unknown Dish';
//                           final description = item['description'] ?? '';
//                           final price = '₹${item['price']}';
//                           final image = item['dishimage'];

//                           // Apply search filter
//                           if (_searchController.text.isNotEmpty &&
//                               !dishName.toLowerCase().contains(_searchController.text.toLowerCase())) {
//                             return const SizedBox.shrink();
//                           }

//                           return _buildMenuItem(
//                             dishName,
//                             description,
//                             price,
//                             image,
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, bool isSelected) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: isSelected ? const Color(0xFFE53935) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
//         ),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: isSelected ? Colors.white : const Color(0xFF757575),
//           fontSize: 14,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem(String name, String description, String price, String? imageUrl) {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(12),
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
//         child: Row(
//           children: [
//             // 🖼 Food Image
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(8),
//                 image: imageUrl != null && imageUrl.isNotEmpty
//                     ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
//                     : null,
//               ),
//               child: imageUrl == null || imageUrl.isEmpty
//                   ? const Center(
//                       child: Icon(Icons.restaurant, size: 40, color: Color(0xFFE0E0E0)),
//                     )
//                   : null,
//             ),
//             const SizedBox(width: 12),

//             // 🍴 Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 4),
//                   Text(
//                     description,
//                     style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(price,
//                       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
//                 ],
//               ),
//             ),

//             // ➕ Add button
//             GestureDetector(
//               onTap: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('$name added to cart'),
//                     duration: const Duration(seconds: 1),
//                     backgroundColor: const Color(0xFF4CAF50),
//                   ),
//                 );
//               },
//               child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
//                 child: const Icon(Icons.add, color: Colors.white, size: 20),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




//import 'package:flutter/material.dart';
// import 'package:zenzio_customer/data/models/food_model.dart';
// import 'package:zenzio_customer/services/restaurant_service.dart';
// import 'package:zenzio_customer/services/cart_service.dart';
// import 'package:zenzio_customer/data/models/cart_model.dart';

// class MenuScreen extends StatefulWidget {
//   final String restaurantId;

//   const MenuScreen({super.key, required this.restaurantId});

//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
//   late TabController _tabController;
//   final RestaurantService _restaurantService = RestaurantService();

//   List<Food> _foods = [];
//   Map<String, List<Food>> _groupedFoods = {};
//   List<String> _categories = [];
//   bool _isLoading = true;
//   bool _hasError = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 1, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) _fetchMenuItems();
//     });
//   }

//   Future<void> _fetchMenuItems() async {
//     setState(() {
//       _isLoading = true;
//       _hasError = false;
//     });

//     try {
//       final grouped = await _restaurantService
//           .fetchRestaurantFoodsWithCategories(widget.restaurantId);

//       final categories = grouped.keys.toList();
//       final allFoods = grouped.values.expand((list) => list).toList();

//       _tabController.dispose();
//       _tabController = TabController(
//         length: categories.isNotEmpty ? categories.length : 1,
//         vsync: this,
//       );

//       if (!mounted) return;
//       setState(() {
//         _foods = allFoods;
//         _groupedFoods = grouped;
//         _categories = categories;
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _hasError = true;
//         _isLoading = false;
//         _errorMessage = e.toString();
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   String _getImageUrl(String? path) {
//     if (path == null || path.isEmpty) return '';
//     if (path.startsWith('http')) return path;
//     String cleanPath = path.replaceFirst("/root/choozy-backend", "");
//     return 'https://backend.zenzio.in$cleanPath';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Menu'),
//         backgroundColor: const Color(0xFFE53935),
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
//               ),
//             )
//           : _hasError
//               ? Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(32),
//                     child: Column(
//                       children: [
//                         const Icon(Icons.error_outline,
//                             size: 64, color: Colors.red),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'Failed to load menu',
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.w600),
//                         ),
//                         if (_errorMessage != null)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8),
//                             child: Text(
//                               _errorMessage!,
//                               style: const TextStyle(color: Colors.grey),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         const SizedBox(height: 16),
//                         ElevatedButton.icon(
//                           onPressed: _fetchMenuItems,
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Retry'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFFE53935),
//                             foregroundColor: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : _categories.isEmpty
//                   ? const Center(
//                       child: Text('No menu items available'),
//                     )
//                   : Column(
//                       children: [
//                         Container(
//                           color: const Color(0xFFF5F5F5),
//                           child: TabBar(
//                             controller: _tabController,
//                             isScrollable: true,
//                             labelColor: const Color(0xFFE53935),
//                             unselectedLabelColor: Colors.grey,
//                             indicatorColor: const Color(0xFFE53935),
//                             tabs:
//                                 _categories.map((cat) => Tab(text: cat)).toList(),
//                           ),
//                         ),
//                         Expanded(
//                           child: TabBarView(
//                             controller: _tabController,
//                             children: _categories
//                                 .map((cat) => _buildCategoryMenu(cat))
//                                 .toList(),
//                           ),
//                         ),
//                       ],
//                     ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: const Color(0xFFE53935),
//         child: const Icon(Icons.shopping_cart),
//         onPressed: () => Navigator.pushNamed(context, '/cart-rest'),
//       ),
//     );
//   }

//   Widget _buildCategoryMenu(String category) {
//     final foods = _groupedFoods[category] ?? [];
//     if (foods.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(32),
//           child: Text('No items in this category'),
//         ),
//       );
//     }

//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         Text(
//           category,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//             color: Color(0xFF2D2D2D),
//           ),
//         ),
//         const SizedBox(height: 12),
//         ...foods.map(_buildMenuItem).toList(),
//       ],
//     );
//   }

//   Widget _buildMenuItem(Food food) {
//     final imageUrl = _getImageUrl(food.image);
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F5F5),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: imageUrl.isNotEmpty
//                 ? ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) =>
//                           const Icon(Icons.restaurant_menu, color: Colors.grey),
//                     ),
//                   )
//                 : const Icon(Icons.restaurant_menu, color: Colors.grey),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       width: 16,
//                       height: 16,
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: food.veg ? Colors.green : Colors.red,
//                           width: 1.5,
//                         ),
//                       ),
//                       child: Center(
//                         child: Container(
//                           width: 8,
//                           height: 8,
//                           decoration: BoxDecoration(
//                             color: food.veg ? Colors.green : Colors.red,
//                             shape: BoxShape.circle,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         food.foodName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (food.description?.isNotEmpty ?? false)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4),
//                     child: Text(
//                       food.description!,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(fontSize: 13, color: Colors.grey),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Column(
//             children: [
//               Text(
//                 '₹${food.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () => _showAddItemSheet(food),
//                 child: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: const BoxDecoration(
//                     color: Color(0xFFE53935),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.add, color: Colors.white, size: 20),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _showAddItemSheet(Food food) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Padding(
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//         child: AddItemSheet(food: food),
//       ),
//     );
//   }
// }

// /// ✅ Reuses your existing AddItemSheet exactly the same way
// class AddItemSheet extends StatefulWidget {
//   final Food food;
//   const AddItemSheet({super.key, required this.food});

//   @override
//   State<AddItemSheet> createState() => _AddItemSheetState();
// }

// class _AddItemSheetState extends State<AddItemSheet> {
//   int _quantity = 1;
//   String _size = 'Medium';
//   String _spice = 'Medium';

//   double get _total {
//     double base = widget.food.price;
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
//               Text(
//                 widget.food.foodName,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '₹${widget.food.price.toStringAsFixed(0)}',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.close),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               const Text('Quantity'),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.remove_circle_outline,
//                     color: Color(0xFFE53935)),
//                 onPressed: () {
//                   if (_quantity > 1) setState(() => _quantity--);
//                 },
//               ),
//               Text('$_quantity'),
//               IconButton(
//                 icon:
//                     const Icon(Icons.add_circle, color: Color(0xFFE53935)),
//                 onPressed: () => setState(() => _quantity++),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Text('Choose Size'),
//           _buildSizeOption('Small', '-₹50'),
//           _buildSizeOption('Medium', '₹0'),
//           _buildSizeOption('Large', '+₹40'),
//           const SizedBox(height: 16),
//           const Text('Choose Spice'),
//           _buildSpiceOption('Mild'),
//           _buildSpiceOption('Medium'),
//           _buildSpiceOption('Hot'),
//           const SizedBox(height: 24),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFE53935),
//               foregroundColor: Colors.white,
//               minimumSize: const Size(double.infinity, 56),
//             ),
//             onPressed: () async {
//               try {
//                 final cartService = CartService();
//                 final item = CartItem(
//                   foodId: widget.food.id,
//                   quantity: _quantity,
//                   selectedAddOns: [
//                     if (_size == 'Large') AddOn(name: 'Large Size', price: 40),
//                     if (_size == 'Small')
//                       AddOn(name: 'Small Size', price: -50),
//                     AddOn(name: 'Spice: $_spice', price: 0),
//                   ],
//                 );

//                 final success = await cartService.addToCart(item);
//                 if (!mounted) return;
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(success
//                         ? '${widget.food.foodName} added to cart successfully'
//                         : 'Failed to add item to cart'),
//                     backgroundColor: success ? Colors.green : Colors.red,
//                   ),
//                 );
//               } catch (e) {
//                 if (!mounted) return;
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('Error: $e'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             child: Text(
//               'Add to Cart - ₹${_total.toStringAsFixed(0)}',
//               style:
//                   const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSizeOption(String size, String price) => GestureDetector(
//         onTap: () => setState(() => _size = size),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: _size == size
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFFE0E0E0),
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 _size == size
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//                 color: _size == size ? const Color(0xFFE53935) : Colors.grey,
//               ),
//               const SizedBox(width: 8),
//               Text(size),
//               const Spacer(),
//               Text(price),
//             ],
//           ),
//         ),
//       );

//   Widget _buildSpiceOption(String spice) => GestureDetector(
//         onTap: () => setState(() => _spice = spice),
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 8),
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             border: Border.all(
//               color: _spice == spice
//                   ? const Color(0xFFE53935)
//                   : const Color(0xFFE0E0E0),
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 _spice == spice
//                     ? Icons.radio_button_checked
//                     : Icons.radio_button_unchecked,
//                 color: _spice == spice ? const Color(0xFFE53935) : Colors.grey,
//               ),
//               const SizedBox(width: 8),
//               Text(spice),
//             ],
//           ),
//         ),
//       );
// }



// import 'package:flutter/material.dart';

// class MenuScreen extends StatefulWidget {
//   const MenuScreen({super.key});

//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> {
//   String _selectedFilter = 'Meat';
//   final TextEditingController _searchController = TextEditingController();

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return Scaffold(
//     //   backgroundColor: Colors.white,
//     //   appBar: AppBar(
//     //     backgroundColor: Colors.white,
//     //     elevation: 0,
//     //     automaticallyImplyLeading: false,
//     //     title: const Text(
//     //       'Order',
//     //       style: TextStyle(
//     //         color: Color(0xFF2D2D2D),
//     //         fontSize: 18,
//     //         fontWeight: FontWeight.w600,
//     //       ),
//     //     ),
//     //     centerTitle: true,
//     //     actions: [
//     //       IconButton(
//     //         icon: const Icon(Icons.person_outline, color: Color(0xFFE53935)),
//     //         onPressed: () {
//     //           Navigator.pushNamed(context, '/profile');
//     //         },
//     //       ),
//     //     ],
//     //   ),
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
//           'Order',
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
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: TextField(
//               controller: _searchController,
//               decoration: InputDecoration(
//                 hintText: 'Search for restaurants or dishes',
//                 hintStyle: const TextStyle(
//                   color: Color(0xFF9E9E9E),
//                   fontSize: 14,
//                 ),
//                 prefixIcon: const Icon(
//                   Icons.search,
//                   color: Color(0xFF9E9E9E),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: const Icon(
//                     Icons.mic_none,
//                     color: Color(0xFF9E9E9E),
//                   ),
//                   onPressed: () {},
//                 ),
//                 filled: true,
//                 fillColor: const Color(0xFFF5F5F5),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildFilterChip('Cuisine', false),
//                   const SizedBox(width: 8),
//                   _buildFilterChip('Meat', true),
//                   const SizedBox(width: 8),
//                   _buildFilterChip('Offers', false),
//                   const SizedBox(width: 8),
//                   _buildFilterChip('Delivery Time', false),
//                 ],
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               children: [
//                 _buildMenuItem('Chicken Breast Boneless', 'Freshly cut, antibiotic-free', '₹180', '1kg', '500g'),
//                 _buildMenuItem('Chicken Curry Cut', 'Bone-in curry cut with small pieces', '₹150', '750g', '500g'),
//                 _buildMenuItem('Chicken Drumsticks', 'Tender, marinated drumsticks', '₹220', '1kg', '800g'),
//                 _buildMenuItem('Chicken Thigh Boneless', 'Premium cut, no antibiotics', '₹210', '750g', '500g'),
//                 _buildMenuItem('Whole Chicken', 'Fresh, cleaned & dressed', '₹290', '1.2kg', ''),
//                 _buildMenuItem('Chicken Mince', 'Finely minced chicken', '₹190', '500g', ''),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChip(String label, bool isSelected) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: isSelected ? const Color(0xFFE53935) : Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
//         ),
//       ),
//       child: Center(
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : const Color(0xFF757575),
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem(String name, String description, String price, String weight1, String weight2) {
//     return GestureDetector(
      
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         padding: const EdgeInsets.all(12),
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
//         child: Row(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Center(
//                 child: Icon(Icons.restaurant, size: 40, color: Color(0xFFE0E0E0)),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
//                   const SizedBox(height: 4),
//                   Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)), maxLines: 1, overflow: TextOverflow.ellipsis),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       _buildWeightChip(weight1, true),
//                       if (weight2.isNotEmpty) ...[const SizedBox(width: 6), _buildWeightChip(weight2, false)],
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
//                 ],
//               ),
//             ),
//             GestureDetector(
//               onTap: () {
//                 // Stop event propagation and show add to cart message
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('$name added to cart'), duration: const Duration(seconds: 1), backgroundColor: const Color(0xFF4CAF50)),
//                 );
//               },
//               child: Container(
//                 width: 36,
//                 height: 36,
//                 decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
//                 child: const Icon(Icons.add, color: Colors.white, size: 20),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWeightChip(String weight, bool isSelected) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: isSelected ? const Color(0xFFE53935).withOpacity(0.1) : const Color(0xFFF5F5F5),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0)),
//       ),
//       child: Text(
//         weight,
//         style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFFE53935) : const Color(0xFF757575)),
//       ),
//     );
//   }
// }