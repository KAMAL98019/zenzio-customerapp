import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedFilter = 'Meat';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   appBar: AppBar(
    //     backgroundColor: Colors.white,
    //     elevation: 0,
    //     automaticallyImplyLeading: false,
    //     title: const Text(
    //       'Order',
    //       style: TextStyle(
    //         color: Color(0xFF2D2D2D),
    //         fontSize: 18,
    //         fontWeight: FontWeight.w600,
    //       ),
    //     ),
    //     centerTitle: true,
    //     actions: [
    //       IconButton(
    //         icon: const Icon(Icons.person_outline, color: Color(0xFFE53935)),
    //         onPressed: () {
    //           Navigator.pushNamed(context, '/profile');
    //         },
    //       ),
    //     ],
    //   ),
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
          'Order',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for restaurants or dishes',
                hintStyle: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9E9E9E),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.mic_none,
                    color: Color(0xFF9E9E9E),
                  ),
                  onPressed: () {},
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Cuisine', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Meat', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Offers', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Delivery Time', false),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildMenuItem('Chicken Breast Boneless', 'Freshly cut, antibiotic-free', '₹180', '1kg', '500g'),
                _buildMenuItem('Chicken Curry Cut', 'Bone-in curry cut with small pieces', '₹150', '750g', '500g'),
                _buildMenuItem('Chicken Drumsticks', 'Tender, marinated drumsticks', '₹220', '1kg', '800g'),
                _buildMenuItem('Chicken Thigh Boneless', 'Premium cut, no antibiotics', '₹210', '750g', '500g'),
                _buildMenuItem('Whole Chicken', 'Fresh, cleaned & dressed', '₹290', '1.2kg', ''),
                _buildMenuItem('Chicken Mince', 'Finely minced chicken', '₹190', '500g', ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE53935) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF757575),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String name, String description, String price, String weight1, String weight2) {
    return GestureDetector(
      
      child: Container(
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.restaurant, size: 40, color: Color(0xFFE0E0E0)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildWeightChip(weight1, true),
                      if (weight2.isNotEmpty) ...[const SizedBox(width: 6), _buildWeightChip(weight2, false)],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Stop event propagation and show add to cart message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$name added to cart'), duration: const Duration(seconds: 1), backgroundColor: const Color(0xFF4CAF50)),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(color: Color(0xFFE53935), shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChip(String weight, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE53935).withOpacity(0.1) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0)),
      ),
      child: Text(
        weight,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFFE53935) : const Color(0xFF757575)),
      ),
    );
  }
}