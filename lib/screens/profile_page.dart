import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/services/api_service.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:customer_app/screens/edit_profile_page.dart';
import 'package:customer_app/screens/saved_addresses_page.dart';
import 'package:customer_app/screens/payment_methods_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(_image!) as ImageProvider
                    : const AssetImage("https://www.vhv.rs/dpng/d/505-5058560_person-placeholder-image-free-hd-png-download.png"),
                child: _image == null
                    ? const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "kamalesh",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "kamalesh944555@gmail.com",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            _buildProfileOption(context, Icons.person, "Edit Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            }),
            _buildProfileOption(context, Icons.location_on, "Saved Addresses", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedAddressesPage()),
              );
            }),
            _buildProfileOption(context, Icons.credit_card, "Payment Methods", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentMethodsPage()),
              );
            }),
            _buildProfileOption(context, Icons.notifications, "Notifications", () {
              // Navigate to Notifications Page
            }),
            _buildProfileOption(context, Icons.help, "Help & Support", () {
              // Navigate to Help & Support Page
            }),
            _buildProfileOption(context, Icons.settings, "Settings", () {
              // Navigate to Settings Page
            }),
            const SizedBox(height: 30),
            // ElevatedButton(
            //   onPressed: () {
            //     // Implement logout functionality
            //   },
            //   child: const Text("Logout"),
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // TODO: Get actual userId and user data
      // For now, using a placeholder userId and empty data
      try {
        // Assuming you have a way to get the current user's ID
        // For demonstration, let's use a placeholder
        String userId = "someUserId"; // Replace with actual user ID
        await ApiService.updateUserProfile(
          userId,
          {}, // Pass any other profile data to update
          _image!.path,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile image: $e")),
        );
      }
    }
  }

  Widget _buildProfileOption(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}