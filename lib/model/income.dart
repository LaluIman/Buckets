import 'package:cloud_firestore/cloud_firestore.dart';

class Income {
  final String id;
  final double amount;
  final String description;
  final String category;
  final DateTime date;
  final String userId;

  Income({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.date,
    required this.userId,
  });

  factory Income.fromMap(Map<String, dynamic> map, String id) {
    return Income(
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

class Goal {
  final String id;
  final double targetAmount;
  final DateTime targetDate;
  final String userId;

  Goal({
    required this.id,
    required this.targetAmount,
    required this.targetDate,
    required this.userId,
  });

  factory Goal.fromMap(Map<String, dynamic> map, String id) {
    return Goal(
      id: id,
      targetAmount: (map['targetAmount'] ?? 0.0).toDouble(),
      targetDate: (map['targetDate'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetAmount': targetAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'userId': userId,
    };
  }
}
