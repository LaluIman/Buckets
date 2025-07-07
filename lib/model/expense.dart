import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String userId;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.userId,
  });

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      amount: (map['amount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }
} 