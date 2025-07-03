import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:income_tracker/model/income.dart';
import 'package:income_tracker/screens/add_screen.dart';
import 'package:income_tracker/services/income_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:income_tracker/widgets/app_snackbar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final NumberFormat currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    final incomeProvider = Provider.of<IncomeProvider>(context);
    final filteredIncomes = _getFilteredIncomes(incomeProvider.incomes);

    return Scaffold(
      appBar: AppBar(
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
                  Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 5),
                  Text('Back', style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                  )),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
        leadingWidth: 120,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(incomeProvider),
          Expanded(
            child: RefreshIndicator(
              color: primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () => incomeProvider.fetchIncomes(),
              child: filteredIncomes.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredIncomes.length,
                      itemBuilder: (context, index) {
                        final income = filteredIncomes[index];
                        return _buildIncomeCard(income, incomeProvider);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(IncomeProvider incomeProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search income...',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset('assets/icons/search_icon.svg'),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Semua'),
                ...incomeProvider.categories.map(_buildFilterChip),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String category) {
    final isSelected = _selectedCategory == category;
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        showCheckmark: false,
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: primaryColor,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
        ),
      ),
    );
  }

  List<Income> _getFilteredIncomes(List<Income> incomes) {
    return incomes.where((income) {
      final matchesSearch =
          income.description.toLowerCase().contains(_searchQuery) ||
          income.category.toLowerCase().contains(_searchQuery);
      final matchesCategory =
          _selectedCategory == 'Semua' || income.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 10),
          Text(
            'No income yet',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(Income income, IncomeProvider incomeProvider) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(color: Colors.grey.shade300),
        )
      ),
      child: InkWell(
        onTap: () => _showIncomeDetails(income, incomeProvider),
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
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
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
      ),
    );
  }

  String _getCategoryIcon(String category) {
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
      case 'Other':
        return 'assets/icons/other_icon.svg';
      default:
        return 'assets/icons/other_icon.svg';
    }
  }

  void _showIncomeDetails(Income income, IncomeProvider incomeProvider) {
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
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SvgPicture.asset(
                          _getCategoryIcon(income.category),
                          width: 28,
                          height: 28,
                          colorFilter: ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
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
                            income.category,
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
                _buildDetailRow('Jumlah', currencyFormat.format(income.amount)),
                _buildDetailRow(
                  'Tanggal',
                  DateFormat('dd MMMM yyyy').format(income.date),
                ),
                _buildDetailRow('Kategori', income.category),
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
                        label: Text('Edit', style: Theme.of(context).textTheme.titleSmall!.copyWith(
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
                        onPressed: () => _deleteIncome(income, incomeProvider),
                        icon: SvgPicture.asset('assets/icons/delete_icon.svg', width: 20, height: 20, colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),),
                        label: Text('Delete', style: Theme.of(context).textTheme.titleSmall!.copyWith(
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

  void _deleteIncome(Income income, IncomeProvider incomeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Pendapatan'),
        content: Text('Apakah Anda yakin ingin menghapus pendapatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet

              try {
                await incomeProvider.deleteIncome(income.id);
                AppSnackbar.show(
                  context,
                  message: 'Income deleted successfully',
                  backgroundColor: Colors.green,
                );
              } catch (e) {
                AppSnackbar.show(
                  context,
                  message: 'Failed to delete income',
                  backgroundColor: Colors.red,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
