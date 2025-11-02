class AddOn {
  final String name;
  final double price;

  AddOn({required this.name, required this.price});

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
      };

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
        name: json['name'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
      );
}

class CartItem {
  final String? cartId;
  final String foodId;
  final int quantity;
  final List<AddOn> selectedAddOns;

  CartItem({
    this.cartId,
    required this.foodId,
    required this.quantity,
    required this.selectedAddOns,
  });

  Map<String, dynamic> toJson() => {
        'cartId': cartId,
        'foodId': foodId,
        'quantity': quantity,
        'selectedAddOns': selectedAddOns.map((e) => e.toJson()).toList(),
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        cartId: json['cartId'],
        foodId: json['foodId'] ?? '',
        quantity: json['quantity'] ?? 1,
        selectedAddOns: (json['selectedAddOns'] as List<dynamic>? ?? [])
            .map((e) => AddOn.fromJson(e))
            .toList(),
      );
}
