import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

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
          'Payment Methods',
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
          _buildPaymentCard(
            context,
            'Credit Card',
            'Visa ending in •••• 1234',
            'Expires 10/25',
            Icons.credit_card,
            Colors.blue,
          ),
          _buildPaymentCard(
            context,
            'Debit Card',
            'Mastercard ending in •••• 5678',
            'Expires 08/24',
            Icons.credit_card,
            Colors.orange,
          ),
          _buildPaymentCard(
            context,
            'PayPal',
            'john.doe@example.com',
            null,
            Icons.account_balance_wallet,
            const Color(0xFF003087),
          ),
          _buildPaymentCard(
            context,
            'Google Pay',
            'john.doe@gmail.com',
            null,
            Icons.g_mobiledata,
            const Color(0xFF4285F4),
          ),
          _buildPaymentCard(
            context,
            'UPI',
            'username@upibank',
            null,
            Icons.account_balance,
            const Color(0xFF6B4226),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                _showAddPaymentDialog(context);
              },
              icon: const Icon(Icons.add, color: Color(0xFFE53935)),
              label: const Text(
                'Add New Method',
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

  Widget _buildPaymentCard(
    BuildContext context,
    String title,
    String subtitle,
    String? expiry,
    IconData icon,
    Color iconColor,
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
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
                if (expiry != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    expiry,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF9E9E9E)),
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18, color: Color(0xFF757575)),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
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

  void _showAddPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Add Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaymentOption(context, 'Credit/Debit Card', Icons.credit_card),
            _buildPaymentOption(context, 'PayPal', Icons.account_balance_wallet),
            _buildPaymentOption(context, 'Google Pay', Icons.g_mobiledata),
            _buildPaymentOption(context, 'UPI', Icons.account_balance),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String title, IconData icon) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE53935)),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
