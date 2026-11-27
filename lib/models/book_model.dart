class BookModel {
  final int? id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final int stock;
  final String category;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.stock,
    required this.category,
  });

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      description: map['description'],
      coverUrl: map['coverUrl'],
      stock: map['stock'],
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'stock': stock,
      'category': category,
    };
  }
}