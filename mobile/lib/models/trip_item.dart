/// عنصر رحلة من API (قائمة الرحلات)
class TripItem {
  final int id;
  final String travelMethod;
  final String fromCity;
  final String fromCountry;
  final String toCity;
  final String toCountry;
  final String? departureFormatted;
  final String? departureDate;
  final double availableWeight;
  final String weightUnit;
  final double pricePerKg;
  final String currencySymbol;
  final String? notes;
  final String status;
  final int confirmedDeals;
  final String? userName;
  /// مالك الرحلة (لمنع «إرسال طلب» على رحلتك من البحث).
  final int? userId;
  final bool canPickupInCurrentCountry;
  final bool canDeliverInOtherCountry;
  final bool canReturnOnCancel;
  final int? returnBeforeDays;

  const TripItem({
    required this.id,
    required this.travelMethod,
    required this.fromCity,
    required this.fromCountry,
    required this.toCity,
    required this.toCountry,
    this.departureFormatted,
    this.departureDate,
    this.availableWeight = 0,
    this.weightUnit = 'kg',
    this.pricePerKg = 0,
    this.currencySymbol = '\$',
    this.notes,
    this.status = 'active',
    this.confirmedDeals = 0,
    this.userName,
    this.userId,
    this.canPickupInCurrentCountry = false,
    this.canDeliverInOtherCountry = false,
    this.canReturnOnCancel = false,
    this.returnBeforeDays,
  });

  factory TripItem.fromJson(Map<String, dynamic> json) {
    return TripItem(
      id: json['id'] as int,
      travelMethod: json['travel_method'] as String? ?? 'flight',
      fromCity: json['from_city'] as String? ?? '',
      fromCountry: json['from_country'] as String? ?? '',
      toCity: json['to_city'] as String? ?? '',
      toCountry: json['to_country'] as String? ?? '',
      departureFormatted: json['departure_formatted'] as String?,
      departureDate: json['departure_date'] as String?,
      availableWeight: (json['available_weight'] as num?)?.toDouble() ?? 0,
      weightUnit: json['weight_unit'] as String? ?? 'kg',
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble() ?? 0,
      currencySymbol: json['currency_symbol'] as String? ?? '\$',
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
      confirmedDeals: (json['confirmed_deals'] as num?)?.toInt() ?? 0,
      userName: json['user_name'] as String?,
      userId: (json['user_id'] as num?)?.toInt(),
      canPickupInCurrentCountry: json['can_pickup_in_current_country'] as bool? ?? false,
      canDeliverInOtherCountry: json['can_deliver_in_other_country'] as bool? ?? false,
      canReturnOnCancel: json['can_return_on_cancel'] as bool? ?? false,
      returnBeforeDays: (json['return_before_days'] as num?)?.toInt(),
    );
  }

  String get fromDisplay => fromCity.isNotEmpty ? fromCity : fromCountry;
  String get toDisplay => toCity.isNotEmpty ? toCity : toCountry;
  String get profitDisplay => '${currencySymbol}${pricePerKg.toStringAsFixed(1)}';
}

/// تفاصيل رحلة كاملة (من GET /api/trips/{id})
class TripDetails {
  final int id;
  final int? userId;
  final String? userName;
  final String travelMethod;
  final int? fromCountryId;
  final String fromCountry;
  final int? fromCityId;
  final String fromCity;
  final int? toCountryId;
  final String toCountry;
  final int? toCityId;
  final String toCity;
  final String? departureDate;
  final String? returnDate;
  final double availableWeight;
  final String weightUnit;
  final double pricePerKg;
  final int? currencyId;
  final String currencySymbol;
  final String? notes;
  final String status;
  final bool canPickupInCurrentCountry;
  final bool canDeliverInOtherCountry;
  final bool canReturnOnCancel;
  final int? returnBeforeDays;
  final bool userHasRequested;
  final int? existingRequestId;

  TripDetails({
    required this.id,
    this.userId,
    this.userName,
    this.travelMethod = 'flight',
    this.fromCountryId,
    this.fromCountry = '',
    this.fromCityId,
    this.fromCity = '',
    this.toCountryId,
    this.toCountry = '',
    this.toCityId,
    this.toCity = '',
    this.departureDate,
    this.returnDate,
    this.availableWeight = 0,
    this.weightUnit = 'kg',
    this.pricePerKg = 0,
    this.currencyId,
    this.currencySymbol = '\$',
    this.notes,
    this.status = 'active',
    this.canPickupInCurrentCountry = false,
    this.canDeliverInOtherCountry = false,
    this.canReturnOnCancel = false,
    this.returnBeforeDays,
    this.userHasRequested = false,
    this.existingRequestId,
  });

  factory TripDetails.fromJson(Map<String, dynamic> json) {
    return TripDetails(
      id: json['id'] as int,
      userId: (json['user_id'] as num?)?.toInt(),
      userName: json['user_name'] as String?,
      travelMethod: json['travel_method'] as String? ?? 'flight',
      fromCountryId: (json['from_country_id'] as num?)?.toInt(),
      fromCountry: json['from_country'] as String? ?? '',
      fromCityId: (json['from_city_id'] as num?)?.toInt(),
      fromCity: json['from_city'] as String? ?? '',
      toCountryId: (json['to_country_id'] as num?)?.toInt(),
      toCountry: json['to_country'] as String? ?? '',
      toCityId: (json['to_city_id'] as num?)?.toInt(),
      toCity: json['to_city'] as String? ?? '',
      departureDate: json['departure_date'] as String?,
      returnDate: json['return_date'] as String?,
      availableWeight: (json['available_weight'] as num?)?.toDouble() ?? 0,
      weightUnit: json['weight_unit'] as String? ?? 'kg',
      pricePerKg: (json['price_per_kg'] as num?)?.toDouble() ?? 0,
      currencyId: (json['currency_id'] as num?)?.toInt(),
      currencySymbol: json['currency_symbol'] as String? ?? '\$',
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
      canPickupInCurrentCountry: json['can_pickup_in_current_country'] as bool? ?? false,
      canDeliverInOtherCountry: json['can_deliver_in_other_country'] as bool? ?? false,
      canReturnOnCancel: json['can_return_on_cancel'] as bool? ?? false,
      returnBeforeDays: (json['return_before_days'] as num?)?.toInt(),
      userHasRequested: json['user_has_requested'] as bool? ?? false,
      existingRequestId: (json['existing_request_id'] as num?)?.toInt(),
    );
  }

  String get fromDisplay => fromCity.isNotEmpty ? '$fromCity، $fromCountry' : fromCountry;
  String get toDisplay => toCity.isNotEmpty ? '$toCity، $toCountry' : toCountry;
  String get travelMethodLabel {
    const map = {
      'flight': 'طيران',
      'car': 'سيارة',
      'train': 'قطار',
      'bus': 'حافلة',
      'ship': 'باخرة',
      'other': 'أخرى',
    };
    return map[travelMethod] ?? travelMethod;
  }
}
