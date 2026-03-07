class Country {
  final int id;
  final String nameAr;
  final String nameEn;
  final String code;

  const Country({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as int,
      nameAr: json['name_ar'] as String? ?? '',
      nameEn: json['name_en'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }

  String get displayName => nameAr;
}
