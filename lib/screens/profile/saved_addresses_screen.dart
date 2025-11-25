import 'package:flutter/material.dart';
import 'package:zenzio/services/delivery_location_service.dart' show DeliveryLocationService;

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  List<dynamic> _locations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      // 🔥 TEMP — Replace this with your saved user uid
      // const userUid = "TVZ5zFpUsR";  

      final list = await DeliveryLocationService.getSavedLocations();

      if (!mounted) return;

      setState(() {
        _locations = list;
        _loading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      if (!mounted) return;

      setState(() => _loading = false);
    }
  }

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

      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (var item in _locations)
             _buildAddressCard(
  context,
  item["address_type"] ?? "",       // label → String
  item["address"] ?? "",            // address → String
  _getIcon(item["address_type"]),   // icon → IconData
  item,                             // full item
),



                const SizedBox(height: 24),

                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () async {
    final result = await Navigator.pushNamed(context, '/add-address');
    if (result == true) {
      _fetchAddresses();
    }
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

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case "home":
        return Icons.home;
      case "office":
      case "work":
        return Icons.work;
      case "primary":
        return Icons.location_on;
      default:
        return Icons.place;
    }
  }
Widget _buildAddressCard(
  BuildContext context,
  String label,
  String address,
  IconData icon,   // 👈 THIS IS CORRECT
  Map<String, dynamic> item,
)
 {
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
       PopupMenuButton<String>(
  icon: const Icon(Icons.more_vert, color: Color(0xFF9E9E9E)),
  onSelected: (value) async {
    if (value == 'edit') {
      final result = await Navigator.pushNamed(
        context,
        '/add-address',
        arguments: item,
      );
      if (result == true) {
        _fetchAddresses(); // Refresh after edit
      }
    }
  if (value == 'delete') {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete Address?'),
      content: const Text('Are you sure you want to delete this address?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    try {
      final success = await DeliveryLocationService.deleteLocation(item["delivery_uid"]);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _fetchAddresses(); // Refresh the list
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

  },
  itemBuilder: (context) => [
    const PopupMenuItem(
      value: 'edit',
      child: Row(
        children: [
          Icon(Icons.edit, size: 18, color: Color(0xFF757575)),
          SizedBox(width: 12),
          Text('Edit'),
        ],
      ),
    ),
    const PopupMenuItem(
      value: 'delete',
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


// import 'package:flutter/material.dart';

// class SavedAddressesScreen extends StatelessWidget {
//   const SavedAddressesScreen({super.key});

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
//           'Saved Addresses',
//           style: TextStyle(
//             color: Color(0xFF2D2D2D),
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           _buildAddressCard(
//             context,
//             'Home',
//             '123 Main Street, Apt 4B, New York, NY 10001',
//             Icons.home,
//           ),
//           _buildAddressCard(
//             context,
//             'Work',
//             '456 Business Avenue, Suite 305, New York, NY 10022',
//             Icons.work,
//           ),
//           _buildAddressCard(
//             context,
//             'Gym',
//             '789 Fitness Blvd, New York, NY 10018',
//             Icons.fitness_center,
//           ),
//           _buildAddressCard(
//             context,
//             'Mom\'s Place',
//             '321 Family Road, Queens, NY 11101',
//             Icons.favorite,
//           ),
//           const SizedBox(height: 24),
//           SizedBox(
//             height: 56,
//             child: OutlinedButton.icon(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/add-address');
//               },
//               icon: const Icon(Icons.add, color: Color(0xFFE53935)),
//               label: const Text(
//                 'Add New Address',
//                 style: TextStyle(
//                   color: Color(0xFFE53935),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: Color(0xFFE53935)),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddressCard(
//     BuildContext context,
//     String label,
//     String address,
//     IconData icon,
//   ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFFE0E0E0)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFFE53935).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFFE53935),
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2D2D2D),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   address,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     color: Color(0xFF757575),
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuButton(
//             icon: const Icon(Icons.more_vert, color: Color(0xFF9E9E9E)),
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 child: Row(
//                   children: [
//                     const Icon(Icons.edit, size: 18, color: Color(0xFF757575)),
//                     const SizedBox(width: 12),
//                     const Text('Edit'),
//                   ],
//                 ),
//                 onTap: () {
//                   Future.delayed(Duration.zero, () {
//                     Navigator.pushNamed(context, '/add-address');
//                   });
//                 },
//               ),
//               const PopupMenuItem(
//                 child: Row(
//                   children: [
//                     Icon(Icons.delete, size: 18, color: Color(0xFFE53935)),
//                     SizedBox(width: 12),
//                     Text(
//                       'Delete',
//                       style: TextStyle(color: Color(0xFFE53935)),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
