import 'package:flutter/material.dart';

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: Colors.white,
        ),),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class AppDialogOption {
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  AppDialogOption({
    required this.text,
    required this.onPressed,
    this.color,
  });
}

class AppDialog extends StatelessWidget {
  final String title;
  final String? caption;
  final List<AppDialogOption> options;
  final Color? backgroundColor;
  final double borderRadius;

  const AppDialog({
    super.key,
    required this.title,
    this.caption,
    required this.options,
    this.backgroundColor,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      content: caption != null ? Text(caption!) : null,
      actions: options.map((option) {
        return TextButton(
          onPressed: option.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: option.color,
          ),
          child: Text(option.text),
        );
      }).toList(),
    );
  }
} 