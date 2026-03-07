/// مكان (بلد فقط أو مدينة + بلد) للاقتراح في حقول من/إلى
class Place {
  final int countryId;
  final int? cityId;
  final String display;

  const Place({
    required this.countryId,
    this.cityId,
    required this.display,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      countryId: (json['country_id'] as num).toInt(),
      cityId: json['city_id'] != null ? (json['city_id'] as num).toInt() : null,
      display: json['display'] as String? ?? '',
    );
  }
}
