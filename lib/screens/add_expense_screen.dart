import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:income_tracker/model/expense.dart';
import 'package:income_tracker/services/expense_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:income_tracker/utils/app_localizations.dart';
import 'package:income_tracker/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:income_tracker/widgets/app_snackbar.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return TextEditingValue(text: '');
    }

    // Format with thousands separator
    String formatted = _formatWithThousandsSeparator(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithThousandsSeparator(String value) {
    if (value.length <= 3) {
      return value;
    }

    String result = '';
    int count = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result = '.$result';
      }
      result = value[i] + result;
      count++;
    }

    return result;
  }
}

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _amountController.text = _formatCurrency(widget.expense!.amount);
      _descriptionController.text = widget.expense!.description;
      _selectedCategory = widget.expense!.category;
      _selectedDate = widget.expense!.date;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.fetchCustomCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.expense != null ? l10n.get('edit_expense') : l10n.get('add_expense'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          prefixText: 'Rp ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.get('amount_required');
                          }
                          String digitsOnly = value.replaceAll('.', '');
                          if (double.tryParse(digitsOnly) == null) {
                            return l10n.get('invalid_amount');
                          }
                          if (double.parse(digitsOnly) <= 0) {
                            return l10n.get('amount_must_be_positive');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: l10n.get('description'),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.get('description_required');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: InputDecoration(
                                labelText: l10n.get('category'),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: primaryColor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              items: expenseProvider.categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(l10n.getCategoryName(category)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              _showAddCategoryDialog(context);
                            },
                            icon: Icon(Icons.add, color: primaryColor),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: primaryColor),
                              SizedBox(width: 12),
                              Text(
                                '${l10n.get('date')}: ${DateFormat('dd MMM yyyy').format(_selectedDate)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              CustomButton(
                text: widget.expense != null ? l10n.get('update_expense') : l10n.get('add_expense'),
                icon: null,
                textColor: Colors.white,
                color: primaryColor,
                borderColor: primaryColor,
                onPressed: _isLoading ? () {} : () => _submitForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(l10n.get('add_custom_category')),
        content: TextField(
          controller: _categoryController,
          decoration: InputDecoration(
            labelText: l10n.get('category_name'),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
                      TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.get('cancel')),
            ),
          ElevatedButton(
            onPressed: () async {
              if (_categoryController.text.isNotEmpty) {
                final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
                await expenseProvider.addCustomCategory(_categoryController.text);
                setState(() {
                  _selectedCategory = _categoryController.text;
                });
                _categoryController.clear();
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n.get('add')),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 1)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String digitsOnly = _amountController.text.replaceAll('.', '');
      double amount = double.parse(digitsOnly);

      final expense = Expense(
        id: widget.expense?.id ?? '',
        amount: amount,
        description: _descriptionController.text,
        category: _selectedCategory,
        date: _selectedDate,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

      if (widget.expense != null) {
        await expenseProvider.updateExpense(expense);
        AppSnackbar.show(context, message: l10n.get('expense_updated_success'), backgroundColor: Colors.green);
      } else {
        await expenseProvider.addExpense(expense);
        AppSnackbar.show(context, message: l10n.get('expense_added_success'), backgroundColor: Colors.green);
      }

      Navigator.pop(context);
    } catch (e) {
      AppSnackbar.show(context, message: l10n.get('error_occurred').replaceAll('{error}', e.toString()), backgroundColor: Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 