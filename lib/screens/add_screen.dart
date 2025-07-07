import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:income_tracker/model/income.dart';
import 'package:income_tracker/services/income_service.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:income_tracker/utils/app_localizations.dart';
import 'package:income_tracker/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:income_tracker/widgets/app_snackbar.dart';
import '../services/currency_provider.dart';

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

class AddScreen extends StatefulWidget {
  final Income? income;

  const AddScreen({super.key, this.income});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  String _selectedCategory = 'Salary';
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
    if (widget.income != null) {
      _amountController.text = _formatCurrency(widget.income!.amount);
      _descriptionController.text = widget.income!.description;
      _selectedCategory = widget.income!.category;
      _selectedDate = widget.income!.date;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
      incomeProvider.fetchCustomCategories();
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
    final l10n = AppLocalizations.of(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        leadingWidth: 150,
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
                        widget.income != null ? l10n.get('edit_income') : l10n.get('add_income'),
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
                          prefixText: '${currencyProvider.currencySymbol} ',
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
                        maxLines: 3,
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
                              items: incomeProvider.categories.map((category) {
                                final isCustom = !incomeProvider.defaultCategories.contains(category);
                                Widget row = Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.getCategoryName(category),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                );
                                if (isCustom) {
                                  row = GestureDetector(
                                    onLongPress: () async {
                                      final shouldDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AppDialog(
                                          title: l10n.get('delete_category'),
                                          caption: l10n.get('delete_category_confirm'),
                                          options: [
                                            AppDialogOption(
                                              text: l10n.get('cancel'),
                                              onPressed: () => Navigator.of(context).pop(false),
                                            ),
                                            AppDialogOption(
                                              text: l10n.get('delete'),
                                              color: Colors.red,
                                              onPressed: () => Navigator.of(context).pop(true),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (shouldDelete == true) {
                                        await Provider.of<IncomeProvider>(context, listen: false).deleteCustomCategory(category);
                                        if (_selectedCategory == category) {
                                          setState(() {
                                            _selectedCategory = incomeProvider.defaultCategories.first;
                                          });
                                        }
                                      }
                                    },
                                    child: row,
                                  );
                                }
                                return DropdownMenuItem(
                                  value: category,
                                  child: row,
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
                          TextButton(
                            onPressed: () {
                              _showAddCategoryDialog(context);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Icon(Icons.add, color: primaryColor),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey.shade600,
                              ),
                              SizedBox(width: 12),
                              Text(
                                DateFormat(
                                  'dd MMMM yyyy',
                                ).format(_selectedDate),
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              _isLoading
                  ? SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: null,
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : CustomButton(
                      text: widget.income != null
                          ? l10n.get('update_income')
                          : l10n.get('add_income'),
                      color: primaryColor,
                      textColor: Colors.white,
                      onPressed: _saveIncome,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context, 
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
        title: Text(l10n.get('add_custom_category'), style: TextTheme.of(context).titleLarge,),
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
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(l10n.get('cancel'), style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_categoryController.text.isNotEmpty) {
                final incomeProvider = Provider.of<IncomeProvider>(context, listen: false);
                await incomeProvider.addCustomCategory(_categoryController.text);
                setState(() {
                  _selectedCategory = _categoryController.text;
                });
                _categoryController.clear();
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Future<void> _saveIncome() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final incomeProvider = Provider.of<IncomeProvider>(
        context,
        listen: false,
      );
      final user = FirebaseAuth.instance.currentUser!;

      String amountText = _amountController.text.replaceAll('.', '');
      double amount = double.parse(amountText);

      final income = Income(
        id: widget.income?.id ?? '',
        amount: amount,
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        date: _selectedDate,
        userId: user.uid,
      );

      if (widget.income != null) {
        await incomeProvider.updateIncome(income);
      } else {
        await incomeProvider.addIncome(income);
      }

      Navigator.pop(context);
      AppSnackbar.show(
        context,
        message: widget.income != null
            ? l10n.get('income_updated_success')
            : l10n.get('income_added_success'),
        backgroundColor: Colors.green,
      );
    } catch (e) {
      AppSnackbar.show(
        context,
        message: l10n.get('error_occurred').replaceAll('{error}', e.toString()),
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
