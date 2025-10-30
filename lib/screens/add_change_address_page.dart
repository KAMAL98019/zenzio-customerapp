import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:customer_app/services/storage_service.dart';
import 'package:flutter/material.dart';

class AddChangeAddressPage extends StatefulWidget {
  final Map<String, dynamic>? address;

  const AddChangeAddressPage({super.key, this.address});

  @override
  State<AddChangeAddressPage> createState() => _AddChangeAddressPageState();
}

class _AddChangeAddressPageState extends State<AddChangeAddressPage> {
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pincodeController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _streetController.text = widget.address!['street'] ?? '';
      _cityController.text = widget.address!['city'] ?? '';
      _stateController.text = widget.address!['state'] ?? '';
      _countryController.text = widget.address!['country'] ?? '';
      _pincodeController.text = widget.address!['pincode'] ?? '';
      _isDefault = widget.address!['isDefault'] ?? false;
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add/Change Address"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage("assets/images/map_placeholder.png"), // Placeholder image for map
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle set location on map
                  },
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  label: const Text(
                    "Set Location on Map",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildInputField("Street", "Enter street", _streetController),
            const SizedBox(height: 16),
            _buildInputField("City", "Enter city", _cityController),
            const SizedBox(height: 16),
            _buildInputField("State", "Enter state", _stateController),
            const SizedBox(height: 16),
            _buildInputField("Country", "Enter country", _countryController),
            const SizedBox(height: 16),
            _buildInputField("Pincode", "Enter pincode", _pincodeController),
            const SizedBox(height: 24),
            const Text(
              "Save as",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSaveAsOption(Icons.home, "Home", true),
                const SizedBox(width: 12),
                _buildSaveAsOption(Icons.work, "Work", false),
                const SizedBox(width: 12),
                _buildSaveAsOption(Icons.more_horiz, "Other", false),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Save Address",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
          ),
        ),
      ],
    );
  }

  Future<void> _saveAddress() async {
    final userId = await StorageService.getUserId();
    if (userId == null) {
      // Handle user not logged in
      return;
    }

    final address = {
      "userId": userId,
      "street": _streetController.text,
      "city": _cityController.text,
      "state": _stateController.text,
      "country": _countryController.text,
      "pincode": _pincodeController.text,
      "isDefault": _isDefault,
    };

    try {
      if (widget.address == null) {
        await ApiService.addAddress(address);
      } else {
        await ApiService.updateAddress(widget.address!['_id'], address);
      }
      Navigator.pop(context, true);
    } catch (e) {
      // Handle error
    }
  }

  Widget _buildSaveAsOption(IconData icon, String label, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}