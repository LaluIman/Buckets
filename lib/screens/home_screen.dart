import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:income_tracker/screens/add_screen.dart';
import 'package:income_tracker/screens/history_screen.dart';
import 'package:income_tracker/services/auth_service.dart';
import 'package:income_tracker/services/income_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:income_tracker/widgets/custom_button.dart';
import 'package:income_tracker/widgets/goal_dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:income_tracker/widgets/app_snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Add supported currencies
  final List<Map<String, String>> currencies = [
    {'code': 'IDR', 'symbol': 'Rp '},
    {'code': 'USD', 'symbol': '\$'},
    {'code': 'EUR', 'symbol': '€'},
    {'code': 'JPY', 'symbol': '¥'},
    {'code': 'GBP', 'symbol': '£'},
  ];

  String selectedCurrencyCode = 'IDR';
  String selectedCurrencySymbol = 'Rp ';
  late NumberFormat currencyFormat;

  @override
  void initState() {
    super.initState();
    currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: selectedCurrencySymbol,
      decimalDigits: 0,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final incomeProvider = Provider.of<IncomeProvider>(
        context,
        listen: false,
      );
      incomeProvider.fetchIncomes();
      incomeProvider.fetchGoal();
    });
  }

  void _onCurrencyChanged(String? code) {
    if (code == null) return;
    final currency = currencies.firstWhere((c) => c['code'] == code);
    setState(() {
      selectedCurrencyCode = code;
      selectedCurrencySymbol = currency['symbol']!;
      currencyFormat = NumberFormat.currency(
        locale: code == 'IDR' ? 'id_ID' : code == 'USD' ? 'en_US' : code == 'EUR' ? 'en_IE' : code == 'JPY' ? 'ja_JP' : code == 'GBP' ? 'en_GB' : 'en_US',
        symbol: selectedCurrencySymbol,
        decimalDigits: 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);

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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCurrencyCode,
                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                items: currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency['code'],
                    child: Text(currency['code']!, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: _onCurrencyChanged,
                dropdownColor: Colors.white,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: primaryColor),
              ),
            ),
          ),
          SizedBox(width: 15),
          Container(
            margin: EdgeInsets.only(right: 15),
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              onPressed: () async {
                final shouldSignOut = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 25),
                      ],
                    ),
                    content: Text(
                      'Are you sure you want to sign out?',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          'Cancel',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Sign Out', style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Colors.white,
                        ),),
                      ),
                    ],
                  ),
                );
                if (shouldSignOut == true) {
                  authProvider.signOut();
                }
              },
              icon: Icon(Icons.logout, color: Colors.red,),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await incomeProvider.fetchIncomes();
          await incomeProvider.fetchGoal();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTotalIncomeCard(incomeProvider),
              SizedBox(height: 20),
              _buildRecentIncomesCard(incomeProvider),
              SizedBox(height: 20),
              CustomButton(
                text: "See more",
                icon: "assets/icons/history_icon.svg",
                textColor: primaryColor,
                color: Colors.grey.shade50,
                borderColor: Colors.grey.shade300,
                borderWidth: 2,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HistoryScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddScreen()),
          );
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTotalIncomeCard(IncomeProvider incomeProvider) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: primaryColor,
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total income',
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              currencyFormat.format(incomeProvider.totalIncome),
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (incomeProvider.goal != null) ...[
              SizedBox(height: 20),
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
                  Text(incomeProvider.goal != null ? 'Edit Goal' : 'Set Goal'),
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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Target: ${currencyFormat.format(goal.targetAmount)}',
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
                  ? '$daysLeft days left'
                  : daysLeft == 0
                  ? 'Target today!'
                  : 'Target passed',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: daysLeft < 0 ? Colors.red.shade200 : Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentIncomesCard(IncomeProvider incomeProvider) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Recent Income',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: primaryColor),
                ),
              ],
            ),
            SizedBox(height: 12),
            if (incomeProvider.isLoading)
              Center(child: CircularProgressIndicator(color: primaryColor))
            else if (incomeProvider.recentIncomes.isEmpty)
              _buildEmptyState()
            else
              ...incomeProvider.recentIncomes.take(3).map(_buildIncomeItem),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 10),
          Text(
            'No income yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: Colors.grey.shade400),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildIncomeItem(income) {
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
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                _getCategoryIcon(income.category),
                width: 25,
                height: 25,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
                      income.category,
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
            currencyFormat.format(income.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  _getCategoryIcon(String category) {
    switch (category) {
      case 'Salary':
        return 'assets/icons/work_icon.svg';
      case 'Project':
        return 'assets/icons/project_icon.svg';
      case 'Competition':
        return 'assets/icons/competition_icon.svg';
      case 'Award':
        return 'assets/icons/award_icon.svg';
      case 'Freelance':
        return 'assets/icons/freelance_icon.svg';
      default:
        return 'assets/icons/other_icon.svg';
    }
  }

  void _showGoalDialog(BuildContext context, IncomeProvider incomeProvider) {
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
            message: 'Goal deleted successfully',
            backgroundColor: Colors.green,
          );
        },
      ),
    );
  }
}
