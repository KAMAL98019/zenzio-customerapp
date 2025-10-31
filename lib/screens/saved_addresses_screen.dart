import 'package:flutter/material.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          'Saved Addresses',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAddressCard(
            context,
            'Home',
            '123 Main Street, Apt 4B, New York, NY 10001',
            Icons.home,
          ),
          _buildAddressCard(
            context,
            'Work',
            '456 Business Avenue, Suite 305, New York, NY 10022',
            Icons.work,
          ),
          _buildAddressCard(
            context,
            'Gym',
            '789 Fitness Blvd, New York, NY 10018',
            Icons.fitness_center,
          ),
          _buildAddressCard(
            context,
            'Mom\'s Place',
            '321 Family Road, Queens, NY 11101',
            Icons.favorite,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/add-address');
              },
              icon: const Icon(Icons.add, color: Color(0xFFE53935)),
              label: const Text(
                'Add New Address',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE53935)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    String label,
    String address,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE53935),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF9E9E9E)),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 18, color: Color(0xFF757575)),
                    const SizedBox(width: 12),
                    const Text('Edit'),
                  ],
                ),
                onTap: () {
                  Future.delayed(Duration.zero, () {
                    Navigator.pushNamed(context, '/add-address');
                  });
                },
              ),
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
                    SizedBox(width: 12),
                    Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFFE53935)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
