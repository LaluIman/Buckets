import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:income_tracker/utils/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderWidth,
  });

  final String text;
  final VoidCallback onPressed;
  final String? icon;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? secondaryColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          minimumSize: Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: borderColor != null 
                ? BorderSide(
                    color: borderColor!,
                    width: borderWidth ?? 1.0,
                  )
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) SvgPicture.asset(icon!, width: 20, height: 20),
            SizedBox(width: 10),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
