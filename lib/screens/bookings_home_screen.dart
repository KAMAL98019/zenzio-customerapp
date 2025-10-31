import 'package:flutter/material.dart';

class BookingsHomeScreen extends StatefulWidget {
  const BookingsHomeScreen({super.key});

  @override
  State<BookingsHomeScreen> createState() => _BookingsHomeScreenState();
}

class _BookingsHomeScreenState extends State<BookingsHomeScreen> {
  int _guestCount = 2;
  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '12:30 PM';
  String _selectedCuisine = 'Italian';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Order',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Color(0xFFE53935),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Today, May 12',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Color(0xFF9E9E9E),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 18,
                              color: Color(0xFFE53935),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                if (_guestCount > 1) {
                                  setState(() => _guestCount--);
                                }
                              },
                              icon: const Icon(Icons.remove),
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$_guestCount',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() => _guestCount++);
                              },
                              icon: const Icon(Icons.add),
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCuisineChip('Italian', true),
                      _buildCuisineChip('Asian', false),
                      _buildCuisineChip('Mexican', false),
                      _buildCuisineChip('Casual', false),
                      _buildCuisineChip('Upscale', false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildRestaurantCard(
                  'Urban Bistro',
                  'Modern European cuisine in a casual setting with panoramic city views',
                  '7:00 PM',
                  '8:00 PM',
                  '9:30 PM',
                  4.5,
                ),
                _buildRestaurantCard(
                  'Seaside Grill',
                  'Fresh seafood and grilled specialties with ocean views',
                  '6:30 PM',
                  '7:35 PM',
                  '8:30 PM',
                  4.7,
                ),
                _buildRestaurantCard(
                  'Trattoria Italiana',
                  'Authentic Italian cuisine in a warm, family-friendly atmosphere',
                  '6:00 PM',
                  '7:15 PM',
                  '8:45 PM',
                  4.6,
                ),
                _buildRestaurantCard(
                  'The Garden Kitchen',
                  'Farm-to-table dining with outdoor garden seating',
                  '5:45 PM',
                  '7:20 PM',
                  '9:00 PM',
                  4.8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuisineChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFE53935) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF757575),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(
    String name,
    String description,
    String time1,
    String time2,
    String time3,
    double rating,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/booking-detail');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(
                  Icons.restaurant,
                  size: 60,
                  color: Color(0xFFE0E0E0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFFE53935),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Available:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTimeSlot(time1),
                      const SizedBox(width: 8),
                      _buildTimeSlot(time2),
                      const SizedBox(width: 8),
                      _buildTimeSlot(time3),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/booking-detail');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE53935),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
