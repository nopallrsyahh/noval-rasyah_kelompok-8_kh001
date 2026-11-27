class BorrowingModel {
  final int? id;
  final int userId;
  final int bookId;
  final String borrowDate;
  final String returnDate;
  final String status;

  BorrowingModel({
    this.id,
    required this.userId,
    required this.bookId,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
  });

  factory BorrowingModel.fromMap(Map<String, dynamic> map) {
    return BorrowingModel(
      id: map['id'],
      userId: map['userId'],
      bookId: map['bookId'],
      borrowDate: map['borrowDate'],
      returnDate: map['returnDate'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookId': bookId,
      'borrowDate': borrowDate,
      'returnDate': returnDate,
      'status': status,
    };
  }
}