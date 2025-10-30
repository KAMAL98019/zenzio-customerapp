import 'package:customer_app/core/constants/appcolors.dart';
import 'package:flutter/material.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Methods"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPaymentMethodCard(
              "Credit Card",
              "Visa ending in **** 1234",
              "Expires 10/25",
              Icons.credit_card,
            ),
            _buildPaymentMethodCard(
              "Debit Card",
              "Mastercard ending in **** 5678",
              "Expires 08/24",
              Icons.credit_card,
            ),
            _buildPaymentMethodCard(
              "PayPal",
              "john.doe@example.com",
              "",
              Icons.paypal,
            ),
            _buildPaymentMethodCard(
              "Google Pay",
              "john.doe@gmail.com",
              "",
              Icons.payment, // Placeholder icon, ideally use a custom Google Pay icon
            ),
            _buildPaymentMethodCard(
              "UPI",
              "username@upibank",
              "",
              Icons.account_balance_wallet, // Placeholder icon
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Add New Payment Method Page
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add New Method",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
      String title, String subtitle, String expiry, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
                if (expiry.isNotEmpty)
                  Text(
                    expiry,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            onPressed: () {
              // Handle delete payment method
            },
          ),
        ],
      ),
    );
  }
}