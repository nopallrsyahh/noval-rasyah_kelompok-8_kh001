class FavoriteModel {
  final int? id;
  final int userId;
  final int bookId;

  FavoriteModel({
    this.id,
    required this.userId,
    required this.bookId,
  });

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    return FavoriteModel(
      id: map['id'],
      userId: map['userId'],
      bookId: map['bookId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
    };
  }
}