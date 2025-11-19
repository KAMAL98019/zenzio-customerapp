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

// class CartItem {
  
//   final String foodId;
//   final int quantity;
//   final List<AddOn> selectedAddOns;

//   CartItem({
//     required this.foodId, 
//     required this.quantity,
//     required this.selectedAddOns,
//   });

//   Map<String, dynamic> toJson() => {
//         'foodId': foodId,
//         'quantity': quantity,
//         'selectedAddOns': selectedAddOns.map((e) => e.toJson()).toList(),
//       };

//   factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
//         foodId: json['foodId'] ?? '',
//         quantity: json['quantity'] ?? 1,
//         selectedAddOns: (json['selectedAddOns'] as List<dynamic>? ?? [])
//             .map((e) => AddOn.fromJson(e))
//             .toList(),
//       );
// }

class CartItem {
  final String restaurantUid;
  final String menuUid;
  final String menuName;
  final double price;
  final int qty;

  CartItem({
    required this.restaurantUid,
    required this.menuUid,
    required this.menuName,
    required this.price,
    required this.qty,
  });

  Map<String, dynamic> toJson() => {
        "restaurant_uid": restaurantUid,
        "menu_uid": menuUid,
        "menu_name": menuName,
        "price": price,
        "qty": qty,
      };

      
factory CartItem.fromJson(Map<String, dynamic> json) {
  return CartItem(
    restaurantUid: json['restaurant_uid'] ?? '',
    menuUid: json['menu_uid'] ?? '',
    menuName: json['menu_name'] ?? '',
    price: (json['price'] is int)
        ? (json['price'] as int).toDouble()
        : (json['price'] ?? 0.0).toDouble(),
    qty: json['qty'] ?? 1,
  );
}

}




// class CartItem {
//   final String restaurantUid;
//   final String menuUid;
//   final String menuName;
//   final double price;
//   final int qty;

//   CartItem({
//     required this.restaurantUid,
//     required this.menuUid,
//     required this.menuName,
//     required this.price,
//     required this.qty,
//   });

//   Map<String, dynamic> toJson() => {
//         "restaurant_uid": restaurantUid,
//         "menu_uid": menuUid,
//         "menu_name": menuName,
//         "price": price,
//         "qty": qty,
//       };

//   factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
//         restaurantUid: json["restaurant_uid"] ?? "",
//         menuUid: json["menu_uid"] ?? "",
//         menuName: json["menu_name"] ?? "",
//         price: (json["price"] ?? 0).toDouble(),
//         qty: json["qty"] ?? 1,
//       );
// }
