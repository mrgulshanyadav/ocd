import 'dart:convert';

//void main() {
//  final String encodedData = CartItem.encodeCartItems([
//    CartItem(id: 1),
//    CartItem(id: 2),
//    CartItem(id: 3),
//  ]);
//
//  final List<CartItem> decodedData = CartItem.decodeCartItems(encodedData);
//
//  print(decodedData);
//}

class CartItem {
  final String id;
  final String title, description, total_amount, image, quantity, price;

  CartItem({
    this.id,
    this.total_amount,
    this.description,
    this.title,
    this.image,
    this.quantity,
    this.price
  });

  factory CartItem.fromJson(Map<String, dynamic> jsonData) {
    return CartItem(
      id: jsonData['id'],
      total_amount: jsonData['amount'],
      description: jsonData['description'],
      title: jsonData['title'],
      image: jsonData['image'],
      quantity: jsonData['quantity'],
      price: jsonData['price'],
    );
  }

  static Map<String, dynamic> toMap(CartItem item) => {
    'id': item.id,
    'amount': item.total_amount,
    'description': item.description,
    'title': item.title,
    'image': item.image,
    'quantity': item.quantity,
    'price': item.price
  };

  static String encodeCartItems(List<CartItem> items) => json.encode(
    items
        .map<Map<String, dynamic>>((music) => CartItem.toMap(music))
        .toList(),
  );

  static List<CartItem> decodeCartItems(String items) =>
      (json.decode(items) as List<dynamic>)
          .map<CartItem>((item) => CartItem.fromJson(item))
          .toList();
}