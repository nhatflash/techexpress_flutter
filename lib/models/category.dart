class Category {
  String id;
  String name;
  String? parentCategoryId;
  String description;
  String? imageUrl;
  bool isDeleted;
  DateTime createdAt;
  DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    this.parentCategoryId,
    required this.description,
    this.imageUrl,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      parentCategoryId: json['parentCategoryId'] as String?,
      description: json['description'],
      imageUrl: json['imageUrl'],
      isDeleted: json['isDeleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt'])
    );
  }

  Map<String, dynamic> toJson(Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'parentCategoryId': category.parentCategoryId,
      'description': category.description,
      'imageUrl': category.imageUrl,
      'isDeleted': category.isDeleted,
      'createdAt': category.createdAt,
      'updatedAt': category.updatedAt,
    };
  }
}

