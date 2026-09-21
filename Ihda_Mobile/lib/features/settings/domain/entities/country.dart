class Country {
  final String name;
  final int code;
  final int id;

  Country({required this.name, required this.code, required this.id});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String? ?? '',
      code: json['code'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
    );
  }
}
