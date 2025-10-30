import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/screens/cartpage.dart';
import 'package:customer_app/screens/restaurantmenupage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final List<Map<String, dynamic>> allOrders = const [
    {
      "id": 1,
      "restaurant": "Burger Kingdom",
      "cuisine": "American • Burgers",
      "rating": 4.8,
      "time": "20-30 min",
      "offer": "20% OFF",
      "image": "assets/images/burgerkingdom.png",
    },
    {
      "id": 2,
      "restaurant": "Pizza Paradise",
      "cuisine": "Italian • Pizza",
      "rating": 4.6,
      "time": "25-35 min",
      "offer": "Free Delivery",
      "image": "assets/images/paradise.png",
    },
    {
      "id": 3,
      "restaurant": "Sushi Master",
      "cuisine": "Japanese • Sushi",
      "rating": 4.9,
      "time": "30-45 min",
      "offer": "",
      "image": "assets/images/master.png",
    },
  ];

  List<Map<String, dynamic>> filteredOrders = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredOrders = allOrders;
    searchController.addListener(filterOrders);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterOrders() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredOrders = query.isEmpty
          ? allOrders
          : allOrders.where((order) {
              final restaurant = order["restaurant"].toString().toLowerCase();
              final cuisine = order["cuisine"].toString().toLowerCase();
              return restaurant.contains(query) || cuisine.contains(query);
            }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restaurants"), centerTitle: true),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.black54),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: "Search for restaurants or dishes",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const Icon(Icons.mic, color: Colors.black87, size: 22),
                ],
              ),
            ),
          ),

          // 📋 Restaurant list
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      "No restaurants found",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return Card(
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RestaurantMenuPage(restaurant: order),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.asset(
                                  order["image"],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              ListTile(
                                title: Text(order["restaurant"]),
                                subtitle: Text(order["cuisine"]),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    Text(order["rating"].toString()),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  bottom: 12,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    order["time"],
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      // 🛒 Cart Button
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
    );
  }
}
