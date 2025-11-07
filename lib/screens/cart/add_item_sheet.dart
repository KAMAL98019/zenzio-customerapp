import 'package:flutter/material.dart';

// Temporary model for food item
class Food {
  final String id;
  final String foodName;
  final double price;
  final bool veg;
  final String? description;

  Food({
    required this.id,
    required this.foodName,
    required this.price,
    required this.veg,
    this.description,
  });
}

class AddItemSheet extends StatefulWidget {
  final Food food;

  const AddItemSheet({super.key, required this.food});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  int quantity = 1;
  String selectedSize = "Regular";
  String selectedSpice = "Medium";

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 5,
              width: 60,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(food.foodName,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 8),
          Text(food.description ?? "Delicious and freshly prepared.",
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 16),

          // Size selector
          const Text("Select Size",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: ["Small", "Regular", "Large"]
                .map((size) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(size),
                        selected: selectedSize == size,
                        onSelected: (_) {
                          setState(() => selectedSize = size);
                        },
                        selectedColor: const Color(0xFFE53935),
                        labelStyle: TextStyle(
                            color: selectedSize == size
                                ? Colors.white
                                : const Color(0xFF2D2D2D)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Spice level
          const Text("Spice Level",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: ["Mild", "Medium", "Hot"]
                .map((spice) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(spice),
                        selected: selectedSpice == spice,
                        onSelected: (_) {
                          setState(() => selectedSpice = spice);
                        },
                        selectedColor: const Color(0xFFE53935),
                        labelStyle: TextStyle(
                            color: selectedSpice == spice
                                ? Colors.white
                                : const Color(0xFF2D2D2D)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Quantity selector
          const Text("Quantity",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (quantity > 1) setState(() => quantity--);
                },
                icon: const Icon(Icons.remove_circle_outline,
                    color: Color(0xFFE53935)),
              ),
              Text(quantity.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              IconButton(
                onPressed: () {
                  setState(() => quantity++);
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: Color(0xFFE53935)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Add to cart button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("${food.foodName} added to cart"),
                backgroundColor: const Color(0xFF4CAF50),
                duration: const Duration(seconds: 1),
              ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text("Add to Cart",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
