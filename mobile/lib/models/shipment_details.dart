class ShipmentDetails {
  final int id;
  final String title;
  final String? description;
  final String? productLink;
  final double weight;
  final String weightUnit;
  final int quantity;
  final String type;
  final String typeLabelEn;
  final int? fromCountryId;
  final int? fromCityId;
  final int? toCountryId;
  final int? toCityId;
  final String fromCode;
  final String fromName;
  final String? fromCityName;
  final String toCode;
  final String toName;
  final String? toCityName;
  final String? deadlineFormatted;
  final ShipmentDetailsUser? user;
  final double priceMin;
  final String currencySymbol;
  final String? imageUrl;

  const ShipmentDetails({
    required this.id,
    required this.title,
    this.description,
    this.productLink,
    required this.weight,
    required this.weightUnit,
    required this.quantity,
    required this.type,
    required this.typeLabelEn,
    this.fromCountryId,
    this.fromCityId,
    this.toCountryId,
    this.toCityId,
    required this.fromCode,
    required this.fromName,
    this.fromCityName,
    required this.toCode,
    required this.toName,
    this.toCityName,
    this.deadlineFormatted,
    this.user,
    required this.priceMin,
    required this.currencySymbol,
    this.imageUrl,
  });

  factory ShipmentDetails.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>?;
    return ShipmentDetails(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      productLink: json['product_link'] as String?,
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      weightUnit: json['weight_unit'] as String? ?? 'kg',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      type: json['type'] as String? ?? 'other',
      typeLabelEn: json['type_label_en'] as String? ?? 'Other',
      fromCountryId: (json['from_country_id'] as num?)?.toInt(),
      fromCityId: (json['from_city_id'] as num?)?.toInt(),
      toCountryId: (json['to_country_id'] as num?)?.toInt(),
      toCityId: (json['to_city_id'] as num?)?.toInt(),
      fromCode: json['from_code'] as String? ?? '',
      fromName: json['from_name'] as String? ?? '',
      fromCityName: json['from_city'] as String?,
      toCode: json['to_code'] as String? ?? '',
      toName: json['to_name'] as String? ?? '',
      toCityName: json['to_city'] as String?,
      deadlineFormatted: json['deadline_formatted'] as String?,
      user: userJson != null ? ShipmentDetailsUser.fromJson(userJson) : null,
      priceMin: (json['price_min'] as num?)?.toDouble() ?? 0,
      currencySymbol: json['currency_symbol'] as String? ?? '\$',
      imageUrl: json['image_url'] as String?,
    );
  }
}

class ShipmentDetailsUser {
  final int? id;
  final String name;
  final String? profilePhoto;
  final double rating;

  const ShipmentDetailsUser({
    this.id,
    required this.name,
    this.profilePhoto,
    this.rating = 0,
  });

  factory ShipmentDetailsUser.fromJson(Map<String, dynamic> json) {
    return ShipmentDetailsUser(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      profilePhoto: (json['profile_photo'] as String?)?.replaceAll(RegExp(r'\s'), '').trim(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
    );
  }
}
