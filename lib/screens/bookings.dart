import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/screens/booking_details_page.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:customer_app/services/storage_service.dart';
import 'package:flutter/material.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeUserAndFetchBookings();
  }

  Future<void> _initializeUserAndFetchBookings() async {
    _userId = await StorageService.getUserId();
    if (_userId != null) {
      _fetchBookings();
    } else {
      setState(() {
        _isLoading = false;
      });
      // Optionally, navigate to login or show an error
      print("User ID not found. Cannot fetch bookings.");
    }
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.getBookings(_userId!);
      setState(() {
        _bookings = response["bookings"] ?? [];
      });
    } catch (e) {
      print("Error fetching bookings: $e");
      // Optionally, show a user-friendly error message
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookings", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.mic, color: Colors.black87, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // _buildFilterChip("Cuisine", Icons.restaurant),
                    // _buildFilterChip("Rating", Icons.star),
                    // _buildFilterChip("Offers", Icons.local_offer),
                    // _buildFilterChip("Dining & Events", Icons.event),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Date Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const Text(
                  //   "Today, May 12",
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
                  // IconButton(
                  //   onPressed: () {},
                  //   icon: const Icon(Icons.arrow_forward_ios),
                  // ),
                ],
              ),
              const SizedBox(height: 10),
              // Time Slots
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // _buildTimeSlot("11:30 AM", false),
                    // _buildTimeSlot("12:00 PM", false),
                    // _buildTimeSlot("12:30 PM", true),
                    // _buildTimeSlot("1:00 PM", false),
                    // _buildTimeSlot("1:30 PM", false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Number of Guests
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const Text(
                  //   "2 Guests",
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
                  // Row(
                  //   children: [
                  //     _buildGuestButton(Icons.remove),
                  //     const SizedBox(width: 10),
                  //     const Text("2", style: TextStyle(fontSize: 16)),
                  //     const SizedBox(width: 10),
                  //     _buildGuestButton(Icons.add),
                  //   ],
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              // Cuisine Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // _buildCuisineChip("Italian", true),
                    // _buildCuisineChip("Asian", false),
                    // _buildCuisineChip("Mexican", false),
                    // _buildCuisineChip("Casual", true),
                    // _buildCuisineChip("Upscale", false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Restaurant List
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _bookings.isEmpty
                      ? const Center(child: Text("No bookings found."))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _bookings.length,
                          itemBuilder: (context, index) {
                            final booking = _bookings[index];
                            return RestaurantBookingCard(
                              name: booking["restaurantName"] ?? "N/A",
                              cuisine: booking["cuisine"] ?? "N/A",
                              rating: (booking["rating"] ?? 0.0).toDouble(),
                              image: booking["restaurantImage"] ?? "assets/images/burger2.jpg", // Placeholder
                              availableTimes: (booking["timeSlots"] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        avatar: Icon(icon, color: AppColors.primary),
        label: Text(label),
        backgroundColor: Colors.grey.shade200,
      ),
    );
  }

  Widget _buildTimeSlot(String time, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGuestButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }

  Widget _buildCuisineChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class RestaurantBookingCard extends StatelessWidget {
  final String name;
  final String cuisine;
  final double rating;
  final String image;
  final List<String> availableTimes;

  const RestaurantBookingCard({
    super.key,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.image,
    required this.availableTimes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.asset(
              image,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cuisine,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Available:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: availableTimes
                      .map((time) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(time, style: const TextStyle(fontSize: 12)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingDetailsPage(),
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
                    child: const Text("Book Now"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
