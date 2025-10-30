import 'package:customer_app/core/constants/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'cart_service.dart';
import 'foodmodal.dart';
import 'cartpage.dart';

class RestaurantMenuPage extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantMenuPage({super.key, required this.restaurant});

  final Map<String, List<Map<String, dynamic>>> menuItems = const {
    "Starters": [
      {
        "name": "Truffle Arancini",
        "description": "Italian rice balls with truffle and parmesan",
        "price": "129",
        "image":
            "https://images.unsplash.com/photo-1632778149955-e80f8ceca2e8?w=400&h=300&fit=crop",
      },
      {
        "name": "Bruschetta",
        "description": "Classic tomato and basil on toasted bread",
        "price": "99",
        "image":
            "https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?w=400&h=300&fit=crop",
      },
    ],
    "Main Course": [
      {
        "name": "Ribeye Steak",
        "description": "Grilled to perfection with garlic butter and herbs",
        "price": "289",
        "image":
            "https://images.unsplash.com/photo-1546964124-0cce460f38ef?w=400&h=300&fit=crop",
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CartService>(
      create: (_) => CartService(),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    restaurant["image"].toString().startsWith("http")
                        ? Image.network(restaurant["image"], fit: BoxFit.cover)
                        : Image.asset(restaurant["image"], fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant["restaurant"],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      restaurant["cuisine"],
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Food Menu",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = menuItems.keys.toList()[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.grey.shade100,
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...menuItems[category]!.map(
                      (item) => _buildMenuItem(context, item),
                    ),
                  ],
                );
              }, childCount: menuItems.keys.length),
            ),
          ],
        ),
       floatingActionButton: FloatingActionButton(
  backgroundColor: AppColors.primary,
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CartPage()),
    );
  },
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50),
  ),
  child: SvgPicture.asset(
    'assets/images/carticon.svg', // Replace with your SVG path
    width: 64,
    height: 64,
  ),
),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, Map<String, dynamic> item) {
    final cartService = Provider.of<CartService>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item["image"],
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["name"],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item["description"],
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  "₹${item["price"]}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, size: 32, color: AppColors.primary),
            onPressed: () {
              // Use ChangeNotifierProvider.value for bottom sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => ChangeNotifierProvider.value(
                  value: cartService,
                  child: FoodItemDetailModal(foodItem: item),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
