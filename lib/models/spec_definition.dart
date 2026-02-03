class SpecDefinition {
  final String id;
  final String code;
  final String name;
  final String categoryId;
  final String categoryName;
  final String unit;
  final String acceptValueType;
  final String description;
  final bool isRequired;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  SpecDefinition({
    required this.id,
    required this.code,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.unit,
    required this.acceptValueType,
    required this.description,
    required this.isRequired,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt
  });

  factory SpecDefinition.fromJson(Map<String, dynamic> json) {
    return SpecDefinition(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
      unit: json['unit'] ?? '',
      acceptValueType: json['acceptValueType'] ?? '',
      description: json['description'] ?? '',
      isRequired: json['isRequired'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt'])
    );
  }

  Map<String, dynamic> toJson(SpecDefinition spec) {
    return {
      'id': spec.id,
      'code': spec.code,
      'name': spec.name,
      'categoryId': spec.categoryId,
      'categoryName': spec.categoryName,
      'unit': spec.unit,
      'acceptValueType': spec.acceptValueType,
      'description': spec.description,
      'isRequired': spec.isRequired,
      'isDeleted': spec.isDeleted,
      'createdAt': spec.createdAt,
      'updatedAt': spec.updatedAt,
    };
  }
}