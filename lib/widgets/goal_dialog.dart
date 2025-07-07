import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:income_tracker/model/income.dart';
import 'package:income_tracker/utils/constants.dart';
import 'package:intl/intl.dart';
import 'package:income_tracker/utils/app_localizations.dart';
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

class GoalDialog extends StatefulWidget {
  final Goal? currentGoal;
  final Function(double, DateTime) onGoalSet;
  final VoidCallback? onGoalDelete;

  const GoalDialog({
    super.key,
    required this.currentGoal,
    required this.onGoalSet,
    this.onGoalDelete,
  });

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(Duration(days: 30));

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentGoal != null) {
      _amountController.text = _formatCurrency(widget.currentGoal!.targetAmount);
      _selectedDate = widget.currentGoal!.targetDate;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SvgPicture.asset(
            'assets/icons/target_icon.svg',
            width: 25,
            height: 25,
            colorFilter: ColorFilter.mode(
              primaryColor,
              BlendMode.srcIn,
            ),
          ),
          SizedBox(width: 10),
            Text(l10n.get('set_goal'),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: primaryColor,
            ),
          ),
            ],
          ),
          if (widget.currentGoal != null && widget.onGoalDelete != null)
          TextButton(
            onPressed: _showDeleteConfirmation,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red.shade600,
            ),
            child: SvgPicture.asset(
              'assets/icons/delete_icon.svg',
              width: 25,
              height: 25,
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.get('goal_amount'),
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: primaryColor),
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
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade600),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.get('date'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy').format(_selectedDate),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.get('cancel'), style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Colors.red.shade600,
            fontWeight: FontWeight.w600,
          ),),
        ),
        ElevatedButton(
          onPressed: _saveGoal,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(widget.currentGoal != null ? l10n.get('edit') : l10n.get('save')),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
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

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    String amountText = _amountController.text.replaceAll('.', '');
    double amount = double.parse(amountText);
    widget.onGoalSet(amount, _selectedDate);
    Navigator.pop(context);
  }

  void _showDeleteConfirmation() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: l10n.get('confirm_delete'),
        caption: l10n.get('delete_message'),
        options: [
          AppDialogOption(
            text: l10n.get('cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          AppDialogOption(
            text: l10n.get('delete'),
            onPressed: _handleDelete,
            color: Colors.red.shade600,
          ),
        ],
      ),
    );
  }

  void _handleDelete() {
    widget.onGoalDelete!();
    Navigator.pop(context);
    Navigator.pop(context); // Close the main dialog as well
  }
}