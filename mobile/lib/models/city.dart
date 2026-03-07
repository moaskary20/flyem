class City {
  final int id;
  final String nameAr;
  final String nameEn;
  final int countryId;

  const City({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.countryId,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      countryId: json['country_id'] as int,
    );
  }

  String get displayName => nameAr;
}
