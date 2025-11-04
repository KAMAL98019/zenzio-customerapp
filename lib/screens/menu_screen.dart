import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _foodItems = [];
  bool _isLoading = true;
  bool _isError = false;

  // 🔹 Filter states
  String? selectedCuisine;
  String? selectedCategory;
  String? selectedType; // "veg" or "non-veg"

  List<String> cuisines = [];
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    try {
      final response = await http.get(
        Uri.parse('https://backend.zenzio.in/api/food-items'),
      );

      if (!mounted) return; // 🧩 Prevent setState after dispose

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final foodList = List<Map<String, dynamic>>.from(data['data']);
          // Extract cuisine and category names dynamically
          final cuisineSet = <String>{};
          final categorySet = <String>{};

          for (var item in foodList) {
            final cuisine = item['cuisine']?['name'];
            final category = item['category']?['name'];
            if (cuisine != null) cuisineSet.add(cuisine.toString().toLowerCase());
            if (category != null) categorySet.add(category.toString().toLowerCase());
          }

          if (!mounted) return; // 🧩 Double-check before setState
          setState(() {
            _foodItems = foodList;
            cuisines = cuisineSet.toList();
            categories = categorySet.toList();
            _isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _isError = true;
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filteredFoodItems() {
    final query = _searchController.text.toLowerCase();
    return _foodItems.where((item) {
      final name = (item['dishname'] ?? '').toLowerCase();
      final cuisine = (item['cuisine']?['name'] ?? '').toLowerCase();
      final category = (item['category']?['name'] ?? '').toLowerCase();
      final isVeg = item['veg'] ?? false;

      final matchesSearch = query.isEmpty || name.contains(query);
      final matchesCuisine = selectedCuisine == null || cuisine == selectedCuisine;
      final matchesCategory = selectedCategory == null || category == selectedCategory;
      final matchesType = selectedType == null ||
          (selectedType == 'veg' && isVeg) ||
          (selectedType == 'non-veg' && !isVeg);

      return matchesSearch && matchesCuisine && matchesCategory && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredFoodItems();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Menu',
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)))
          : _isError
              ? const Center(
                  child: Text('Failed to load menu. Please try again later.'),
                )
              : Column(
                  children: [
                    // 🔍 Search bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        onChanged: (value) => setState(() {}),
                      ),
                    ),

                    // 🔹 Filters
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              "Cuisine",
                              cuisines,
                              selectedCuisine,
                              (val) => setState(() => selectedCuisine = val),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDropdown(
                              "Category",
                              categories,
                              selectedCategory,
                              (val) => setState(() => selectedCategory = val),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔹 Veg / Non-Veg Filter
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildTypeChip('Veg', 'veg'),
                          const SizedBox(width: 8),
                          _buildTypeChip('Non-Veg', 'non-veg'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🍽️ Food List
                    Expanded(
                      child: filteredList.isEmpty
                          ? const Center(child: Text("No dishes found"))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                return _buildMenuItem(
                                  item['dishname'] ?? 'No name',
                                  item['description'] ?? '',
                                  '₹${item['price'] ?? 0}',
                                  item['dishimage'] ?? '',
                                  item['cuisine']?['name'] ?? '',
                                  item['category']?['name'] ?? '',
                                  item['veg'] ?? false,
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  // ✅ Dropdown widget
  Widget _buildDropdown(
      String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        hint: Text(label),
        underline: const SizedBox(),
        isExpanded: true,
        items: [
          const DropdownMenuItem(value: null, child: Text("All")),
          ...items.map((e) => DropdownMenuItem(
                value: e,
                child: Text(e[0].toUpperCase() + e.substring(1)),
              )),
        ],
        onChanged: onChanged,
      ),
    );
  }

  // ✅ Veg / Non-Veg chips
  Widget _buildTypeChip(String label, String value) {
    bool isSelected = selectedType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedType = selected ? value : null;
        });
      },
    );
  }

  // ✅ Menu item
  Widget _buildMenuItem(String name, String description, String price, String imageUrl,
      String cuisine, String category, bool veg) {
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.fastfood, size: 40, color: Color(0xFFE0E0E0)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                    const SizedBox(width: 6),
                    Icon(Icons.circle, color: veg ? Colors.green : Colors.red, size: 10),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text("Cuisine: $cuisine | Category: $category",
                    style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                const SizedBox(height: 6),
                Text(price,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFFE53935))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name added to cart'),
                  backgroundColor: const Color(0xFF4CAF50),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}



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