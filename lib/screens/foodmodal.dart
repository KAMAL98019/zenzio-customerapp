import 'package:customer_app/core/constants/appcolors.dart';
import 'package:customer_app/services/api_service.dart';
import 'package:customer_app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_service.dart';

class FoodItemDetailModal extends StatefulWidget {
  final Map<String, dynamic> foodItem;

  const FoodItemDetailModal({super.key, required this.foodItem});

  @override
  State<FoodItemDetailModal> createState() => _FoodItemDetailModalState();
}

class _FoodItemDetailModalState extends State<FoodItemDetailModal> {
  int _quantity = 1;
  String? _selectedSize;
  List<String> _selectedExtras = [];
  final TextEditingController _specialInstructionsController =
      TextEditingController();
  String? _userId;

  final List<String> _sizes = ["Small", "Medium", "Large"];
  final Map<String, double> _sizePrices = {
    "Small": -30.0,
    "Medium": 0.0,
    "Large": 40.0,
  };
  final Map<String, double> _extraItems = {
    "Add extra cheese": 30.0,
    "Add extra sauce": 20.0,
    "Add garlic bread": 50.0,
  };
  final List<String> _spiceLevels = ["Mild", "Medium", "Hot"];
  String? _selectedSpiceLevel;

  double _calculateTotalCost() {
    double basePrice = double.parse(widget.foodItem["price"].toString());
    double currentTotal = basePrice * _quantity;

    if (_selectedSize != null && _sizePrices.containsKey(_selectedSize)) {
      currentTotal += _sizePrices[_selectedSize]! * _quantity;
    }

    for (String extra in _selectedExtras) {
      if (_extraItems.containsKey(extra)) {
        currentTotal += _extraItems[extra]! * _quantity;
      }
    }
    return currentTotal;
  }

  @override
  void initState() {
    super.initState();
    _selectedSize = _sizes[1];
    _selectedSpiceLevel = _spiceLevels[1];
  }

  @override
  void dispose() {
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double currentTotal = _calculateTotalCost();

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 15, 26, 26),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  widget.foodItem["name"],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "₹${widget.foodItem["price"]}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quantity Selector
          const Text("Quantity", style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle, color: AppColors.primary, size: 36),
                onPressed: () {
                  setState(() {
                    if (_quantity > 1) _quantity--;
                  });
                },
              ),
              Text("$_quantity",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 36),
                onPressed: () {
                  setState(() => _quantity++);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Choose size
          const Text("Choose your size",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ..._sizes.map(
            (size) => RadioListTile<String>(
              title: Text(size),
              value: size,
              groupValue: _selectedSize,
              onChanged: (value) {
                setState(() => _selectedSize = value);
              },
              dense: true,
              visualDensity: VisualDensity.compact,
              controlAffinity: ListTileControlAffinity.trailing,
              secondary: Text(
                _sizePrices[size] != 0
                    ? "₹${_sizePrices[size]! > 0 ? '+' : ''}${_sizePrices[size]!.toStringAsFixed(0)}"
                    : "",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Extras
          const Text("Add extra items",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ..._extraItems.keys.map(
            (extra) => CheckboxListTile(
              title: Text(extra),
              value: _selectedExtras.contains(extra),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedExtras.add(extra);
                  } else {
                    _selectedExtras.remove(extra);
                  }
                });
              },
              dense: true,
              visualDensity: VisualDensity.compact,
              controlAffinity: ListTileControlAffinity.trailing,
              secondary: Text(
                "₹${_extraItems[extra]!.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Spice level
          const Text("Choose your spice level",
              style: TextStyle(fontWeight: FontWeight.bold)),
          ..._spiceLevels.map(
            (level) => RadioListTile<String>(
              title: Text(level),
              value: level,
              groupValue: _selectedSpiceLevel,
              onChanged: (value) {
                setState(() => _selectedSpiceLevel = value);
              },
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 20),

          // Special instructions
          const Text("Special instructions",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _specialInstructionsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Any special requests? (e.g., no onions)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 24),

          // Add to Cart Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_userId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("User not logged in. Please log in to add items to cart."),
                    ),
                  );
                  return;
                }

                final List<Map<String, dynamic>> apiAddOns = _selectedExtras.map((extra) {
                  return {
                    "name": extra,
                    "price": _extraItems[extra],
                  };
                }).toList();

                final String foodId = widget.foodItem["_id"]; // Assuming _id is the foodId
                final String restaurantId = widget.foodItem["rest_id"]; // Assuming rest_id is the restaurantId

                final Map<String, dynamic> cartItem = {
                  "cartId": _userId,
                  "foodId": foodId,
                  "quantity": _quantity,
                  "selectedAddOns": apiAddOns,
                  // Add other customization options if the API supports them
                };

                try {
                  await ApiService.addToCart(cartItem);
                  context.read<CartService>().addToCart(
                        widget.foodItem,
                        _quantity,
                        selectedSize: _selectedSize,
                        selectedExtras: _selectedExtras,
                        selectedSpiceLevel: _selectedSpiceLevel,
                        specialInstructions: _specialInstructionsController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "${widget.foodItem["name"]} ($_quantity) added to cart for ₹${currentTotal.toStringAsFixed(0)}",
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to add to cart: $e"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "Add to Cart - ₹${currentTotal.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}
