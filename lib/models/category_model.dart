class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> data, String id) {
    return CategoryModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }
}
