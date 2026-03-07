class ShipmentListItem {
  final int id;
  final String title;
  final double weight;
  final String weightUnit;
  final String fromCode;
  final String toCode;
  final String? deadlineFormatted;
  final ShipmentUser? user;
  final double priceMin;
  final String currencySymbol;
  final String? imageUrl;

  const ShipmentListItem({
    required this.id,
    required this.title,
    required this.weight,
    required this.weightUnit,
    required this.fromCode,
    required this.toCode,
    this.deadlineFormatted,
    this.user,
    required this.priceMin,
    required this.currencySymbol,
    this.imageUrl,
  });

  factory ShipmentListItem.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    return ShipmentListItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      weightUnit: json['weight_unit'] as String? ?? 'kg',
      fromCode: json['from_code'] as String? ?? '',
      toCode: json['to_code'] as String? ?? '',
      deadlineFormatted: json['deadline_formatted'] as String?,
      user: userJson != null ? ShipmentUser.fromJson(userJson) : null,
      priceMin: (json['price_min'] as num?)?.toDouble() ?? 0,
      currencySymbol: json['currency_symbol'] as String? ?? '\$',
      imageUrl: json['image_url'] as String?,
    );
  }
}

class ShipmentUser {
  final int? id;
  final String name;
  final String? profilePhoto;
  final double rating;

  const ShipmentUser({
    this.id,
    required this.name,
    this.profilePhoto,
    this.rating = 0,
  });

  factory ShipmentUser.fromJson(Map<String, dynamic> json) {
    return ShipmentUser(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      profilePhoto: json['profile_photo'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
    );
  }
}
