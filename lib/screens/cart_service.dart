import 'package:flutter/foundation.dart';

class CartService with ChangeNotifier {
  static final CartService _instance = CartService._internal();
  
  factory CartService() {
    return _instance;
  }
  
  CartService._internal();

  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }

  void addToCart(
    Map<String, dynamic> foodItem,
    int quantity, {
    String? selectedSize,
    List<String>? selectedExtras,
    String? selectedSpiceLevel,
    String? specialInstructions,
  }) {
    // Check if item already exists in cart with same customization
    final existingIndex = _cartItems.indexWhere((item) =>
        item['name'] == foodItem['name'] &&
        item['selectedSize'] == selectedSize &&
        listEquals(item['selectedExtras'], selectedExtras) &&
        item['selectedSpiceLevel'] == selectedSpiceLevel &&
        item['specialInstructions'] == specialInstructions);

    if (existingIndex != -1) {
      // Update quantity if item exists
      _cartItems[existingIndex]['quantity'] =
          (_cartItems[existingIndex]['quantity'] ?? 1) + quantity;
    } else {
      // Add new item
      _cartItems.add({
        ...foodItem,
        "quantity": quantity,
        "selectedSize": selectedSize,
        "selectedExtras": selectedExtras ?? [],
        "selectedSpiceLevel": selectedSpiceLevel,
        "specialInstructions": specialInstructions,
      });
    }
    
    notifyListeners();
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (newQuantity <= 0) {
        removeItem(index);
      } else {
        _cartItems[index]['quantity'] = newQuantity;
        notifyListeners();
      }
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void placeOrder() {
    _cartItems.clear();
    notifyListeners();
  }
}