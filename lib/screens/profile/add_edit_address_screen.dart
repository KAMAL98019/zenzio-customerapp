import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:zenzio/config/api_config.dart';
import 'package:zenzio/services/api_service.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController _streetController = TextEditingController();
  final storage = const FlutterSecureStorage();

  // GOOGLE MAP DISABLED → FUTURE USE
  // GoogleMapController? _mapController;
  // LatLng? pickedLocation;
  // LatLng _initialPosition = const LatLng(12.9716, 77.5946);
  // Set<Marker> _markers = {};

  bool _isLoading = false;
  bool _gettingLocation = false;

  double? _latitude;
  double? _longitude;

  String _selectedType = "home";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ---------------- GET CURRENT LOCATION ----------------
  Future<void> _getCurrentLocation() async {
    setState(() => _gettingLocation = true);

    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        _showToast("Enable location services");
        setState(() => _gettingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        _showToast("Location permission blocked. Allow in settings.");
        setState(() => _gettingLocation = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = pos.latitude;
      _longitude = pos.longitude;

      // 🚀 REVERSE GEOCODE FROM BACKEND
      await _reverseGeocode();

      setState(() => _gettingLocation = false);

    } catch (e) {
  _showToast("Failed: $e");

  if (!mounted) return;   // ❗ very important

  setState(() => _gettingLocation = false);
}

  }

  // ---------------- REVERSE GEOCODE API ----------------
  Future<void> _reverseGeocode() async {
    if (_latitude == null || _longitude == null) return;

    try {
      final url = Uri.parse(
        "${ApiConfig.baseUrl}/maps/reverse?lat=$_latitude&lng=$_longitude"
      );

      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _streetController.text = data["data"]["address"] ?? "";
      }
    } catch (_) {}
  }

  // ---------------- SAVE ADDRESS ----------------
// Future<void> _saveAddress() async {
//   if (_streetController.text.trim().isEmpty) {
//     _showToast("Please enter your complete address");
//     return;
//   }

//   if (!mounted) return;
//   setState(() => _isLoading = true);

//   try {
//     final body = {
//       "address": _streetController.text.trim(),
//       "lat": _latitude,
//       "lng": _longitude,
//       "is_default": true,
//       "address_type": _selectedType,
//     };

//     final response = await ApiService().post(
//       ApiConfig.deliveryLocation,
//       body: body,
//       requiresAuth: true,
//     );

//     print("✅ Address API Response: $response");

//     _showToast("Address saved!", success: true);

//     if (!mounted) return; 
//     Navigator.pop(context, response["data"]?["location"]);

//   } catch (e) {
//     _showToast(e.toString());
//   } finally {
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//   }
// }

Future<void> _saveAddress() async {
  if (_streetController.text.trim().isEmpty) {
    _showToast("Please enter your complete address");
    return;
  }

  if (!mounted) return;
  setState(() => _isLoading = true);

  try {
    final body = {
      "address": _streetController.text.trim(),
      "lat": _latitude,
      "lng": _longitude,
      "is_default": true,
      "address_type": _selectedType,
    };

    final response = await ApiService().post(
      ApiConfig.deliveryLocation,
      body: body,
      requiresAuth: true,
    );

    print("✅ Address API Response: $response");

    _showToast("Address saved!", success: true);

    if (!mounted) return; 
    Navigator.pop(context, true);  

  } catch (e) {
    _showToast(e.toString());
  } finally {
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}

  void _showToast(String msg, {bool success = false}) {
  if (!mounted) return; // 🔥 Avoid calling after dispose

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: success ? Colors.green : Colors.red,
    ),
  );
}


  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Address"),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _gettingLocation ? null : _getCurrentLocation,
          ),
        ],
      ),

      body: Column(
        children: [
          // ---------------- GOOGLE MAP (DISABLED) ----------------
          /*
          SizedBox(
  height: 150,
  child: Container(
    alignment: Alignment.center,
    color: Colors.grey.shade200,
    child: const Text(
      "Map disabled (API key not added)",
      style: TextStyle(fontSize: 14, color: Colors.black54),
    ),
  ),
),

          */

          // ---------------- LOWER FORM ----------------
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  if (_latitude != null)
                    Text(
                      "Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}",
                      style: const TextStyle(fontSize: 12),
                    ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _streetController,
                    decoration: const InputDecoration(
                      labelText: "Complete Address",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.home),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 20),

                  const Text("Address Type",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),

                  Wrap(
                    spacing: 10,
                    children: [
                       ChoiceChip(
                        label: const Text("primary"),
                        selected: _selectedType == "primary",
                        onSelected: (_) => setState(() =>
                            _selectedType = "primary"),
                      ),
                      ChoiceChip(
                        label: const Text("Home"),
                        selected: _selectedType == "home",
                        onSelected: (_) => setState(() => _selectedType = "home"),
                      ),
                      ChoiceChip(
                        label: const Text("Work"),
                        selected: _selectedType == "work",
                        onSelected: (_) => setState(() =>
                            _selectedType = "work"),
                      ),
                     
                      ChoiceChip(
                        label: const Text("office"),
                        selected: _selectedType == "office",
                        onSelected: (_) =>
                            setState(() => _selectedType = "office"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save Address"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    // _mapController?.dispose();  // FUTURE USE
    super.dispose();
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';

// class AddEditAddressScreen extends StatefulWidget {
//   const AddEditAddressScreen({super.key});

//   @override
//   State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
// }

// class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
//   final TextEditingController _flatController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();
//   final TextEditingController _landmarkController = TextEditingController();
//   String _selectedType = 'home';

//   double? _latitude;
//   double? _longitude;

//   @override
//   void dispose() {
//     _flatController.dispose();
//     _streetController.dispose();
//     _landmarkController.dispose();
//     super.dispose();
//   }

//   // Get user current location
// Future<void> _getCurrentLocation() async {
//   try {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings(); // Opens location settings page
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enable location services and try again'),
//         ),
//       );
//       return;
//     }

//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Location permission denied')),
//         );
//         return;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Permission permanently denied. Enable it from Settings'),
//         ),
//       );
//       return;
//     }

//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );

//     if (!mounted) return;
//     setState(() {
//       _latitude = position.latitude;
//       _longitude = position.longitude;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Location fetched successfully')),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error getting location: $e')),
//     );
//   }
// }



//   // Save address to backend
//  Future<void> _saveAddress() async {
//   if (_streetController.text.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please enter street/locality')),
//     );
//     return;
//   }

//   if (_latitude == null || _longitude == null) {
//     await _getCurrentLocation();
//     if (_latitude == null || _longitude == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Unable to get location. Try again.')),
//       );
//       return;
//     }
//   }

//   String userId = 'd9f1b5a4-1c2e-4a6f-9b1f-1234567890ab';

//   final Map<String, dynamic> data = {
//     "userId": userId,
//     "street": _streetController.text.trim(),
//     "city": "Bangalore",
//     "state": "Karnataka",
//     "country": "India",
//     "pincode": "560001",
//     "latitude": _latitude,
//     "longitude": _longitude,
//     "isDefault": true
//   };

//   print("📦 Sending data to backend: $data");

//   final url = Uri.parse('https://backend.zenzio.in/api/addresses');

//   try {
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(data),
//     );

//     print("🌐 Response status: ${response.statusCode}");
//     print("🌐 Response body: ${response.body}");

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Address saved successfully'),
//           backgroundColor: Color(0xFF4CAF50),
//         ),
//       );
//       Navigator.pop(context);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save address: ${response.body}')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error: $e')),
//     );
//   }
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Add/Change Address',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Map placeholder
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Stack(
//                 children: [
//                   const Center(
//                     child: Icon(
//                       Icons.map,
//                       size: 80,
//                       color: Color(0xFFE0E0E0),
//                     ),
//                   ),
//                   Center(
//                     child: Icon(
//                       Icons.location_on,
//                       size: 50,
//                       color: const Color(0xFFE53935),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: _getCurrentLocation,
//               icon: const Icon(Icons.my_location),
//               label: const Text('Set Location on Map'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFE53935),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 48),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Flat/House No./Building',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _flatController,
//               decoration: InputDecoration(
//                 hintText: 'Enter flat/house no./building',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE53935)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Street/Locality',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _streetController,
//               decoration: InputDecoration(
//                 hintText: 'Enter street/locality',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE53935)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Landmark (Optional)',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _landmarkController,
//               decoration: InputDecoration(
//                 hintText: 'Enter landmark',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE53935)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Save as',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildTypeButton('home', 'Home', Icons.home),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildTypeButton('work', 'Work', Icons.work),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildTypeButton('other', 'Other', Icons.more_horiz),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: _saveAddress,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   'Save Address',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTypeButton(String value, String label, IconData icon) {
//     final isSelected = _selectedType == value;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedType = value),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFE53935) : Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? Colors.white : const Color(0xFF757575),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: isSelected ? Colors.white : const Color(0xFF757575),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// class AddEditAddressScreen extends StatefulWidget {
//   const AddEditAddressScreen({super.key});

//   @override
//   State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
// }

// class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
//   final TextEditingController _flatController = TextEditingController();
//   final TextEditingController _streetController = TextEditingController();
//   final TextEditingController _landmarkController = TextEditingController();
//   String _selectedType = 'home';

//   @override
//   void dispose() {
//     _flatController.dispose();
//     _streetController.dispose();
//     _landmarkController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF2D2D2D)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Add/Change Address',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: 200,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF5F5F5),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Stack(
//                 children: [
//                   const Center(
//                     child: Icon(
//                       Icons.map,
//                       size: 80,
//                       color: Color(0xFFE0E0E0),
//                     ),
//                   ),
//                   Center(
//                     child: Icon(
//                       Icons.location_on,
//                       size: 50,
//                       color: const Color(0xFFE53935),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () {},
//               icon: const Icon(Icons.my_location),
//               label: const Text('Set Location on Map'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFE53935),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 48),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Flat/House No./Building',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _flatController,
//               decoration: InputDecoration(
//                 hintText: 'Enter flat/house no./building',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE53935)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Street/Locality',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _streetController,
//               decoration: InputDecoration(
//                 hintText: 'Enter street/locality',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE53935)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Landmark (Optional)',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextField(
//               controller: _landmarkController,
//               decoration: InputDecoration(
//                 hintText: 'Enter landmark',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: const BorderSide(color: Color(0xFFE53935)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Save as',
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Color(0xFF2D2D2D),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildTypeButton('home', 'Home', Icons.home),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildTypeButton('work', 'Work', Icons.work),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: _buildTypeButton('other', 'Other', Icons.more_horiz),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               height: 56,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Address saved successfully'),
//                       backgroundColor: Color(0xFF4CAF50),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFE53935),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   'Save Address',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTypeButton(String value, String label, IconData icon) {
//     final isSelected = _selectedType == value;
//     return GestureDetector(
//       onTap: () => setState(() => _selectedType = value),
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFFE53935) : Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: isSelected ? const Color(0xFFE53935) : const Color(0xFFE0E0E0),
//           ),
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               color: isSelected ? Colors.white : const Color(0xFF757575),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w500,
//                 color: isSelected ? Colors.white : const Color(0xFF757575),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
