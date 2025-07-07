import 'package:flutter/material.dart';
import 'package:income_tracker/screens/add_screen.dart';
import 'package:income_tracker/screens/add_expense_screen.dart';

import 'package:income_tracker/screens/combined_history_screen.dart';
import 'package:income_tracker/services/income_service.dart';
import 'package:income_tracker/services/expense_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:income_tracker/utils/app_localizations.dart';
import 'package:income_tracker/widgets/custom_button.dart';
import 'package:income_tracker/widgets/goal_dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:income_tracker/widgets/app_snackbar.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late NumberFormat currencyFormat;

  @override
  void initState() {
    super.initState();
    currencyFormat = NumberFormat.currency(
      symbol: 'Rp ',
      decimalDigits: 0,
      locale: 'id_ID',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final incomeProvider = Provider.of<IncomeProvider>(
        context,
        listen: false,
      );
      final expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );
      incomeProvider.fetchIncomes();
      incomeProvider.fetchGoal();
      expenseProvider.fetchExpenses();
      expenseProvider.fetchCustomCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final incomeProvider = Provider.of<IncomeProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Padding(
          padding: EdgeInsets.only(left: 8),
          child: Row(
            children: [
              SvgPicture.asset('assets/icons/logo.svg', width: 35, height: 35, colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn),),
              SizedBox(width: 7),
              Text(
                "Buckets",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: primaryColor),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor),
            tooltip: l10n.get('settings'),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          SizedBox(width: 8),
          
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await incomeProvider.fetchIncomes();
          await incomeProvider.fetchGoal();
          await expenseProvider.fetchExpenses();
          await expenseProvider.fetchCustomCategories();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFinancialSummaryCard(incomeProvider, expenseProvider, l10n),
              SizedBox(height: 20),
              _buildRecentTransactionsCard(incomeProvider, expenseProvider, l10n),
              SizedBox(height: 20),
              CustomButton(
                text: l10n.get('all_transactions'),
                icon: "assets/icons/history_icon.svg",
                textColor: primaryColor,
                color: Colors.grey.shade50,
                borderColor: Colors.grey.shade300,
                borderWidth: 2,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CombinedHistoryScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddOptionsDialog(context);
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(IncomeProvider incomeProvider, ExpenseProvider expenseProvider, AppLocalizations l10n) {
    final netIncome = incomeProvider.totalIncome - expenseProvider.totalExpenses;
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('bucket_summary'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.get('income'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        currencyFormat.format(incomeProvider.totalIncome),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.get('expense'),
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        currencyFormat.format(expenseProvider.totalExpenses),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    netIncome >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${l10n.get('balance')}: ${currencyFormat.format(netIncome)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (incomeProvider.goal != null) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildGoalProgress(incomeProvider),
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showGoalDialog(context, incomeProvider),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                backgroundColor: secondaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icons/target_icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(incomeProvider.goal != null ? l10n.get('edit') : l10n.get('set_goal')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(IncomeProvider incomeProvider) {
    final goal = incomeProvider.goal!;
    final progress = incomeProvider.totalIncome / goal.targetAmount;
    final clampedProgress = progress.clamp(0.0, 1.0);

    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${l10n.get('goal_amount')}: ${currencyFormat.format(goal.targetAmount)}',
              style: Theme.of(
                context,
              ).textTheme.titleSmall!.copyWith(color: Colors.white),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          borderRadius: BorderRadius.circular(10),
          minHeight: 10,
          value: clampedProgress,
          backgroundColor: Colors.white30,
          valueColor: AlwaysStoppedAnimation<Color>(const Color.fromARGB(255, 0, 242, 8)),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              daysLeft > 0
                  ? '$daysLeft ${l10n.get('days_left')}'
                  : daysLeft == 0
                  ? l10n.get('goal_achieved')
                  : l10n.get('goal_passed'),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: daysLeft < 0 ? Colors.red.shade200 : Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactionsCard(IncomeProvider incomeProvider, ExpenseProvider expenseProvider, AppLocalizations l10n) {
    // Combine and sort all transactions by date
    List<Map<String, dynamic>> allTransactions = [];
    
    // Add incomes
    for (var income in incomeProvider.recentIncomes) {
      allTransactions.add({
        'type': 'income',
        'data': income,
        'date': income.date,
      });
    }
    
    // Add expenses
    for (var expense in expenseProvider.recentExpenses) {
      allTransactions.add({
        'type': 'expense',
        'data': expense,
        'date': expense.date,
      });
    }
    
    // Sort by date (most recent first)
    allTransactions.sort((a, b) => b['date'].compareTo(a['date']));
    
    // Take the most recent 5 transactions
    final recentTransactions = allTransactions.take(3).toList();

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('recent_transactions'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.grey.shade800),
            ),
            SizedBox(height: 12),
            if (incomeProvider.isLoading || expenseProvider.isLoading)
              Center(child: CircularProgressIndicator(color: primaryColor))
            else if (recentTransactions.isEmpty)
              _buildEmptyTransactionsState(l10n)
            else
              ...recentTransactions.map((transaction) => _buildTransactionItem(transaction, l10n)),
          ],
        ),
      ),
    );
  }



  Widget _buildEmptyTransactionsState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 10),
          Text(
            l10n.get('no_transactions'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.grey.shade400),
          ),
          SizedBox(height: 8),
          Text(
            l10n.get('add_first_transaction'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, AppLocalizations l10n) {
    final isIncome = transaction['type'] == 'income';
    final data = transaction['data'];
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                isIncome ? _getCategoryIcon(data.category) : _getExpenseCategoryIcon(data.category),
                style: TextStyle(fontSize: 25),
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.description,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      l10n.getCategoryName(data.category),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      ' • ${DateFormat('dd MMM yyyy').format(data.date)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${currencyFormat.format(data.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green.shade600 : Colors.red.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'Salary':
        return '💼';
      case 'Project':
        return '📋';
      case 'Competition':
        return '🏆';
      case 'Award':
        return '🏅';
      case 'Freelance':
        return '💻';
      case 'Sale':
        return '📈';
      default:
        return '💰';
    }
  }

  String _getExpenseCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return '🍽️';
      case 'transportation':
        return '🚗';
      case 'entertainment':
        return '🎬';
      case 'fuel':
        return '⛽';
      case 'groceries':
        return '🛒';
      case 'health':
        return '🏥';
      case 'rent':
        return '🏠';
      default:
        return '💰';
    }
  }

  void _showGoalDialog(BuildContext context, IncomeProvider incomeProvider) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => GoalDialog(
        currentGoal: incomeProvider.goal,
        onGoalSet: (amount, date) async {
          await incomeProvider.setGoal(amount, date);
        },
        onGoalDelete: () async {
          await incomeProvider.deleteGoal();
          AppSnackbar.show(
            context,
            message: l10n.get('goal_deleted'),
            backgroundColor: Colors.green,
          );
        },
      ),
    );
  }

  void _showAddOptionsDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.get('add'), style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey.shade800),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              tileColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(Icons.trending_up, color: Colors.green),
              title: Text(l10n.get('add_income'), style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey.shade800),),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddScreen()),
                );
              },
            ),
            SizedBox(height: 10),
            ListTile(
              tileColor: Colors.grey.shade100,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: Icon(Icons.trending_down, color: Colors.red),
              title: Text(l10n.get('add_expense'), style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.grey.shade800),),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddExpenseScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
