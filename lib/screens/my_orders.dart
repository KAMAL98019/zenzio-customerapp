import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/screens/orders_details_page.dart';
import 'package:flutter/material.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> currentOrders = [
    {
      "restaurant": "Burger Kingdom",
      "time": "Today, 6:30 PM",
      "items": "1x Beef Burger, 2x Cheese Fries, 1x Milkshake",
      "price": "\₹35.71",
      "status": "On the Way",
    },
    {
      "restaurant": "Pizza Paradise",
      "time": "Today, 5:15 PM",
      "items": "1x Pepperoni Pizza, 1x Garlic Bread, 1x Coke",
      "price": "\₹129",
      "status": "Preparing",
    },
  ];

  final List<Map<String, dynamic>> pastOrders = [
    {
      "restaurant": "Urban Bistro",
      "time": "Yesterday, 8:15 PM",
      "items": "1x Chicken Pasta, 1x Caesar Salad, 2x Lemonade",
      "price": "\₹428",
      "status": "Delivered",
    },
    {
      "restaurant": "Sushi Master",
      "time": "May 10, 7:30 PM",
      "items": "1x Dragon Roll, 1x Miso Soup, 1x Green Tea",
      "price": "\₹428",
      "status": "Delivered",
    },
    {
      "restaurant": "Taco Fiesta",
      "time": "May 8, 6:45 PM",
      "items": "2x Beef Tacos, 1x Nachos, 1x Soda",
      "price": "\₹225",
      "status": "Cancelled",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Activity", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Food Orders"),
            Tab(text: "Dining Bookings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Food Orders Tab
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Orders
                  const Text(
                    "Current Orders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentOrders.length,
                    itemBuilder: (context, index) {
                      final order = currentOrders[index];
                      return OrderCard(
                        restaurant: order["restaurant"],
                        time: order["time"],
                        items: order["items"],
                        price: order["price"],
                        status: order["status"],
                        isCurrent: true,
                        orderData: order,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Past Orders
                  const Text(
                    "Past Orders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pastOrders.length,
                    itemBuilder: (context, index) {
                      final order = pastOrders[index];
                      return OrderCard(
                        restaurant: order["restaurant"],
                        time: order["time"],
                        items: order["items"],
                        price: order["price"],
                        status: order["status"],
                        isCurrent: false,
                        orderData: order,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Dining Bookings Tab (Placeholder)
          const Center(child: Text("Dining Bookings Content")),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final String restaurant;
  final String time;
  final String items;
  final String price;
  final String status;
  final bool isCurrent;
  final Map<String, dynamic> orderData;

  const OrderCard({
    super.key,
    required this.restaurant,
    required this.time,
    required this.items,
    required this.price,
    required this.status,
    required this.isCurrent,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  restaurant,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              items,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isCurrent)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(order: orderData),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Track Order"),
                  )
                else
                  TextButton(
                    onPressed: () {
                      // View details
                    },
                    child: const Text(
                      "View Details",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "On the Way":
        return Colors.orange;
      case "Preparing":
        return AppColors.primary;
      case "Delivered":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
