import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:customer_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:customer_app/screens/add_change_address_page.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {
  List<dynamic> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final userId = await StorageService.getUserId();
    if (userId != null) {
      try {
        final addresses = await ApiService.getAddresses(userId);
        setState(() {
          _addresses = addresses;
        });
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> _handleDeleteAddress(String addressId) async {
    try {
      await ApiService.deleteAddress(addressId);
      _loadAddresses(); // Refresh the list
    } catch (e) {
      print("Error deleting address: $e");
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Addresses"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ..._addresses.map((address) => _buildAddressCard(
                  address,
                )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddChangeAddressPage()),
                  );
                  if (result == true) {
                    _loadAddresses();
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Add New Address",
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

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final title = address['isDefault'] ? "Home" : "Work"; // Placeholder
    final addressString =
        "${address['street']}, ${address['city']}, ${address['state']}, ${address['country']}, ${address['pincode']}";

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  addressString,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.edit, size: 20, color: AppColors.primary),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddChangeAddressPage(address: address),
                    ),
                  );
                  if (result == true) {
                    _loadAddresses();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                onPressed: () => _handleDeleteAddress(address['_id']),
              ),
            ],
          ),
        ],
      ),
    );
  }
}