import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:income_tracker/model/expense.dart';
import 'package:flutter/foundation.dart';

class ExpenseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  double get totalExpenses {
    return _expenses.fold(0, (acc, expense) => acc + expense.amount);
  }

  List<Expense> get recentExpenses {
    var sortedExpenses = List<Expense>.from(_expenses);
    sortedExpenses.sort((a, b) => b.date.compareTo(a.date));
    return sortedExpenses.take(5).toList();
  }

  final List<String> defaultCategories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Fuel',
    'Groceries',
    'Health',
    'Rent',
  ];

  List<String> _customCategories = [];
  List<String> get categories => [...defaultCategories, ..._customCategories];

  Future<void> fetchExpenses() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('expenses')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('date', descending: true)
          .get();

      _expenses = snapshot.docs
          .map((doc) => Expense.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomCategories() async {
    if (_auth.currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('customCategories')
          .get();

      _customCategories = snapshot.docs.map((doc) => doc.data()['name'] as String).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching custom categories: $e');
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _firestore.collection('expenses').add(expense.toMap());
      await fetchExpenses();
    } catch (e) {
      debugPrint('Error adding expense: $e');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _firestore
          .collection('expenses')
          .doc(expense.id)
          .update(expense.toMap());
      await fetchExpenses();
    } catch (e) {
      debugPrint('Error updating expense: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _firestore.collection('expenses').doc(id).delete();
      await fetchExpenses();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
    }
  }

  Future<void> addCustomCategory(String categoryName) async {
    if (_auth.currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('customCategories')
          .add({'name': categoryName});
      
      await fetchCustomCategories();
    } catch (e) {
      debugPrint('Error adding custom category: $e');
    }
  }

  Future<void> deleteCustomCategory(String categoryName) async {
    if (_auth.currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('customCategories')
          .where('name', isEqualTo: categoryName)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      
      await fetchCustomCategories();
    } catch (e) {
      debugPrint('Error deleting custom category: $e');
    }
  }
} 