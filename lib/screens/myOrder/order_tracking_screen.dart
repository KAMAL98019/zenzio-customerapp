import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key, required orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
          // onPressed: () => Navigator.pop(context),
          onPressed: () {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/main-navigation',
      (route) => false,   // 🔥 clears stack → direct to home
    );
  },
        ),
        title: const Text(
          'Order Tracking',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFFE53935),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Estimated Delivery: ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        '7:15 PM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildTrackingStep(
                    'Order Placed',
                    '6:30 PM',
                    true,
                    true,
                    Icons.check_circle,
                  ),
                  _buildTrackingStep(
                    'Restaurant Confirmed',
                    '6:35 PM',
                    true,
                    true,
                    Icons.check_circle,
                  ),
                  _buildTrackingStep(
                    'Preparing',
                    '6:40 PM',
                    true,
                    true,
                    Icons.check_circle,
                  ),
                  _buildTrackingStep(
                    'Ready for Pickup',
                    '',
                    true,
                    false,
                    Icons.check_circle,
                  ),
                  _buildTrackingStep(
                    'Out for Delivery',
                    '',
                    true,
                    false,
                    Icons.check_circle,
                  ),
                  _buildTrackingStep(
                    'Delivered',
                    '',
                    false,
                    false,
                    Icons.radio_button_unchecked,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.map,
                      size: 80,
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 50,
                    child: _buildMapMarker(Icons.restaurant, const Color(0xFFE53935)),
                  ),
                  Positioned(
                    bottom: 80,
                    right: 60,
                    child: _buildMapMarker(Icons.delivery_dining, const Color(0xFFE53935)),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 50,
                    child: _buildMapMarker(Icons.home, const Color(0xFF4CAF50)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () {
                   Navigator.pushReplacementNamed(context, '/main-navigation');
                },
                icon: const Icon(Icons.help_outline, color: Color(0xFFE53935)),
                label: const Text(
                  'Need Help?',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE53935)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStep(
    String title,
    String time,
    bool hasLine,
    bool isCompleted,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFFE53935)
                    : const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            if (hasLine)
              Container(
                width: 2,
                height: 50,
                color: const Color(0xFFE53935),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? const Color(0xFFE53935)
                        : const Color(0xFF9E9E9E),
                  ),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 13,
                      color: isCompleted
                          ? const Color(0xFFE53935)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapMarker(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
