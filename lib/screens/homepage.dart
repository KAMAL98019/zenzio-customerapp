import 'package:flutter/material.dart';
import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:customer_app/screens/restaurants_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List<dynamic> categories = [];
  List<dynamic> foodItems = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await Future.wait([_getCategories(), _getFoodItems()]);
  }

  Future<void> _getCategories() async {
    try {
      final fetchedCategories = await ApiService.getCategories();
      if (mounted) setState(() => categories = fetchedCategories ?? []);
    } catch (e) {
      debugPrint("❌ Error fetching categories: $e");
    }
  }

  Future<void> _getFoodItems() async {
    try {
      final fetchedFoodItems = await ApiService.getFoodItems();
      if (mounted) setState(() => foodItems = fetchedFoodItems ?? []);
    } catch (e) {
      debugPrint("❌ Error fetching food items: $e");
    }
  }

  final List<Map<String, dynamic>> offers = [
    {"title": "50% OFF on Burgers", "image": "assets/images/burger.jpg"},
    {"title": "Buy 1 Get 1 Pizza", "image": "assets/images/pizza.jpg"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 22),

              // 🔍 Search Bar
              _buildSearchBar(),
              const SizedBox(height: 30),

              // 🍴 Categories
              _sectionHeader("Categories"),
              _buildCategorySection(),
              const SizedBox(height: 20),

              // 🎉 Offers
              _sectionHeader("Top Offers"),
              _buildOfferSection(),
              const SizedBox(height: 20),

              // 🍔 Popular Near You
              _sectionHeader("Popular Near You"),
              _buildItemSection(foodItems),
              const SizedBox(height: 30),

              // // 🆕 New on Choosy
              // _sectionHeader("New on Zenzio"),
              // _buildItemSection(foodItems, isCompact: true),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  // 🔍 Search Bar
  Widget _buildSearchBar() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        Icon(Icons.search, color: Colors.black54, size: 24),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search for restaurants or dishes",
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
        Icon(Icons.mic, color: Colors.black87, size: 22),
      ],
    ),
  );

  // 🍱 Category Section
  Widget _buildCategorySection() {
    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => selectedIndex = index),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.white,
                        width: 2,
                      ),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.fastfood,
                      color: isSelected ? AppColors.primary : Colors.black87,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categories[index]["name"] ?? "Unnamed",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🎁 Offer Section
  Widget _buildOfferSection() => SizedBox(
    height: 150,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: offers.length,
      itemBuilder: (context, index) {
        return Container(
          width: 220,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(offers[index]["image"]!),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Text(
              offers[index]["title"],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    ),
  );

  // 🍔 Item Section
  Widget _buildItemSection(List<dynamic> items, {bool isCompact = false}) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SizedBox(
      height: isCompact ? 230 : 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final imageUrl =
              item["image"] ??
              "https://via.placeholder.com/300x200.png?text=Food+Image";

          return Container(
            width: isCompact ? 200 : 250,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ Network Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: isCompact ? 110 : 140,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      "assets/images/food_placeholder.jpg",
                      width: double.infinity,
                      height: isCompact ? 110 : 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // 🧾 Info Section
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // ✅ Prevent overflow
                    children: [
                      Text(
                        item["dishname"] ?? "Unknown Dish",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item["description"] ?? "",
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${item["category"]?["name"] ?? "Food"} • ₹${item["price"] ?? 0}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔹 Section Header
  Widget _sectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // TextButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (_) => const RestaurantsListPage()),
        //     );
        //   },
        //   child: const Text(
        //     "View All",
        //     style: TextStyle(
        //       color: AppColors.primary,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
