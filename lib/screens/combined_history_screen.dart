import 'package:flutter/material.dart';
import 'package:income_tracker/model/income.dart';
import 'package:income_tracker/model/expense.dart';
import 'package:income_tracker/services/income_service.dart';
import 'package:income_tracker/services/expense_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:income_tracker/utils/app_localizations.dart';

import 'package:provider/provider.dart';
import '../services/currency_provider.dart';
import 'package:intl/intl.dart';
import 'package:income_tracker/widgets/app_snackbar.dart';
import 'package:income_tracker/screens/add_screen.dart';
import 'package:income_tracker/screens/add_expense_screen.dart';

class CombinedHistoryScreen extends StatefulWidget {
  const CombinedHistoryScreen({super.key});

  @override
  State<CombinedHistoryScreen> createState() => _CombinedHistoryScreenState();
}

class _CombinedHistoryScreenState extends State<CombinedHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  final List<String> _filterOptions = [
    'all',
    'this_month',
    'last_month',
    'this_year',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      incomeProvider.fetchCustomCategories();
      expenseProvider.fetchExpenses();
      expenseProvider.fetchCustomCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Income> _getFilteredIncomes(List<Income> incomes) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);
    final currentYear = DateTime(now.year);

    switch (_selectedFilter) {
      case 'this_month':
        return incomes
            .where(
              (income) =>
                  income.date.isAfter(currentMonth.subtract(Duration(days: 1))),
            )
            .toList();
      case 'last_month':
        return incomes
            .where(
              (income) =>
                  income.date.isAfter(lastMonth.subtract(Duration(days: 1))) &&
                  income.date.isBefore(currentMonth),
            )
            .toList();
      case 'this_year':
        return incomes
            .where(
              (income) =>
                  income.date.isAfter(currentYear.subtract(Duration(days: 1))),
            )
            .toList();
      default:
        return incomes;
    }
  }

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);
    final currentYear = DateTime(now.year);

    switch (_selectedFilter) {
      case 'this_month':
        return expenses
            .where(
              (expense) => expense.date.isAfter(
                currentMonth.subtract(Duration(days: 1)),
              ),
            )
            .toList();
      case 'last_month':
        return expenses
            .where(
              (expense) =>
                  expense.date.isAfter(lastMonth.subtract(Duration(days: 1))) &&
                  expense.date.isBefore(currentMonth),
            )
            .toList();
      case 'this_year':
        return expenses
            .where(
              (expense) =>
                  expense.date.isAfter(currentYear.subtract(Duration(days: 1))),
            )
            .toList();
      default:
        return expenses;
    }
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    l10n.get('back'),
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium!.copyWith(color: Colors.white),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
        leadingWidth: 150,
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: primaryColor,
          tabs: [
            Tab(text: l10n.get('income')),
            Tab(text: l10n.get('expanse')),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter Dropdown
          Container(
            padding: EdgeInsets.all(16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  items: _filterOptions.map((filter) {
                    return DropdownMenuItem<String>(
                      value: filter,
                      child: Text(l10n.get(filter), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                ),
              ),
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildIncomeTab(), _buildExpenseTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeTab() {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Consumer<IncomeProvider>(
      builder: (context, incomeProvider, child) {
        if (incomeProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final filteredIncomes = _getFilteredIncomes(incomeProvider.incomes);
        final totalAmount = filteredIncomes.fold(
          0.0,
          (sum, income) => sum + income.amount,
        );
        final currencySymbol = currencyProvider.currencySymbol;

        return Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.trending_up,
                          color: Colors.green,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total ${l10n.get('income')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '$currencySymbol ${NumberFormat('#,###').format(totalAmount)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Income List
            Expanded(
              child: filteredIncomes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            l10n.get('no_income_found'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            l10n.get('add_first_income'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: filteredIncomes.length,
                      itemBuilder: (context, index) {
                        final income = filteredIncomes[index];
                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _showIncomeDetails(context, income),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getCategoryIcon(income.category),
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          income.description,
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              l10n.getCategoryName(income.category),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              ' • ${DateFormat('dd MMM yyyy').format(income.date)}',
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
                                    '$currencySymbol ${NumberFormat('#,###').format(income.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseTab() {
    final l10n = AppLocalizations.of(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        if (expenseProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: Colors.red));
        }

        final filteredExpenses = _getFilteredExpenses(expenseProvider.expenses);
        final totalAmount = filteredExpenses.fold(
          0.0,
          (sum, expense) => sum + expense.amount,
        );
        final currencySymbol = currencyProvider.currencySymbol;

        return Column(
          children: [
            // Summary Card
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.trending_down,
                          color: Colors.red,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.get('total_expenses'),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '$currencySymbol ${NumberFormat('#,###').format(totalAmount)}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Expense List
            Expanded(
              child: filteredExpenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            l10n.get('no_expenses_found'),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            l10n.get('add_first_expense'),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: filteredExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = filteredExpenses[index];
                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _showExpenseDetails(context, expense),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getExpenseCategoryIcon(expense.category),
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.description,
                                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              l10n.getCategoryName(expense.category),
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              ' • ${DateFormat('dd MMM yyyy').format(expense.date)}',
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
                                    '$currencySymbol ${NumberFormat('#,###').format(expense.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteIncomeDialog(BuildContext context, Income income) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: l10n.get('confirm_delete'),
        caption: l10n.get('delete_message'),
        options: [
          AppDialogOption(
            text: l10n.get('cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppDialogOption(
            text: l10n.get('delete'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet
              final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
              await incomeProvider.deleteIncome(income.id);
              AppSnackbar.show(
                context,
                message: l10n.get('data_deleted'),
                backgroundColor: Colors.green,
              );
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  void _showDeleteExpenseDialog(BuildContext context, Expense expense) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: l10n.get('confirm_delete'),
        caption: l10n.get('delete_message'),
        options: [
          AppDialogOption(
            text: l10n.get('cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppDialogOption(
            text: l10n.get('delete'),
            onPressed: () async {
              Navigator.of(context).pop(); 
              Navigator.of(context).pop(); 
              final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
              await expenseProvider.deleteExpense(expense.id);
              AppSnackbar.show(
                context,
                message: l10n.get('data_deleted'),
                backgroundColor: Colors.green,
              );
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  void _showIncomeDetails(BuildContext context, Income income) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _getCategoryIcon(income.category),
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            income.description,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            l10n.getCategoryName(income.category),
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildDetailRow(l10n.get('amount'), currencyFormat.format(income.amount)),
                _buildDetailRow(l10n.get('date'), DateFormat('dd MMMM yyyy').format(income.date)),
                _buildDetailRow(l10n.get('category'), l10n.getCategoryName(income.category)),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddScreen(income: income),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit),
                        label: Text(l10n.get('edit'), style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Colors.blue.shade600,
                        ),),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.blue.shade600,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteIncomeDialog(context, income),
                        icon: Icon(Icons.delete, color: Colors.white, size: 20),
                        label: Text(l10n.get('delete'), style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Colors.white,
                        ),),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    final l10n = AppLocalizations.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _getExpenseCategoryIcon(expense.category),
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.description,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            l10n.getCategoryName(expense.category),
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildDetailRow(l10n.get('amount'), currencyFormat.format(expense.amount)),
                _buildDetailRow(l10n.get('date'), DateFormat('dd MMMM yyyy').format(expense.date)),
                _buildDetailRow(l10n.get('category'), l10n.getCategoryName(expense.category)),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddExpenseScreen(expense: expense),
                            ),
                          );
                        },
                        icon: Icon(Icons.edit),
                        label: Text(l10n.get('edit'), style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Colors.blue.shade600,
                        ),),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.blue.shade600,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteExpenseDialog(context, expense),
                        icon: Icon(Icons.delete, color: Colors.white, size: 20),
                        label: Text(l10n.get('delete'), style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Colors.white,
                        ),),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
