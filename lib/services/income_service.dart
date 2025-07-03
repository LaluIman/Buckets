import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:income_tracker/model/income.dart';
import 'package:flutter/foundation.dart';

class IncomeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Income> _incomes = [];
  Goal? _goal;
  bool _isLoading = false;

  List<Income> get incomes => _incomes;
  Goal? get goal => _goal;
  bool get isLoading => _isLoading;

  double get totalIncome {
    return _incomes.fold(0, (acc, income) => acc + income.amount);
  }

  List<Income> get recentIncomes {
    var sortedIncomes = List<Income>.from(_incomes);
    sortedIncomes.sort((a, b) => b.date.compareTo(a.date));
    return sortedIncomes.take(5).toList();
  }

  final List<String> categories = [
    'Salary',
    'Project', 
    'Competition',
    'Award',
    'Freelance',
  ];

  Future<void> fetchIncomes() async {
    if (_auth.currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('incomes')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('date', descending: true)
          .get();

      _incomes = snapshot.docs
          .map((doc) => Income.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching incomes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGoal() async {
    if (_auth.currentUser == null) return;

    try {
      final snapshot = await _firestore
          .collection('goals')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _goal = Goal.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching goal: $e');
    }
  }

  Future<void> addIncome(Income income) async {
    try {
      await _firestore.collection('incomes').add(income.toMap());
      await fetchIncomes();
    } catch (e) {
      debugPrint('Error adding income: $e');
    }
  }

  Future<void> updateIncome(Income income) async {
    try {
      await _firestore
          .collection('incomes')
          .doc(income.id)
          .update(income.toMap());
      await fetchIncomes();
    } catch (e) {
      debugPrint('Error updating income: $e');
    }
  }

  Future<void> deleteIncome(String id) async {
    try {
      await _firestore.collection('incomes').doc(id).delete();
      await fetchIncomes();
    } catch (e) {
      debugPrint('Error deleting income: $e');
    }
  }

  Future<void> setGoal(double targetAmount, DateTime targetDate) async {
    if (_auth.currentUser == null) return;

    try {
      final goalData = Goal(
        id: '',
        targetAmount: targetAmount,
        targetDate: targetDate,
        userId: _auth.currentUser!.uid,
      );

      if (_goal != null) {
        await _firestore
            .collection('goals')
            .doc(_goal!.id)
            .update(goalData.toMap());
      } else {
        await _firestore.collection('goals').add(goalData.toMap());
      }
      
      await fetchGoal();
    } catch (e) {
      debugPrint('Error setting goal: $e');
    }
  }

  Future<void> deleteGoal() async {
    if (_auth.currentUser == null || _goal == null) return;

    try {
      await _firestore
          .collection('goals')
          .doc(_goal!.id)
          .delete();
      
      _goal = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }
}