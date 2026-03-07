/// عنصر تسوق مضاف ضمن شحنة (سلعة واحدة).
class ShoppingItem {
  final String productName;
  final String? productLink;
  final int quantity;
  final double? pricePerItem;
  final double weightPerItem;
  final String weightUnit;
  final String category; // type: documents, fragile, electronics, clothing, food, other

  const ShoppingItem({
    required this.productName,
    this.productLink,
    required this.quantity,
    this.pricePerItem,
    required this.weightPerItem,
    this.weightUnit = 'kg',
    this.category = 'other',
  });
}
