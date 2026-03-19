import 'package:flutter/material.dart';
import 'package:memno/theme/app_colors.dart';
import 'package:provider/provider.dart';

class InnerPageButton extends StatelessWidget {
  const InnerPageButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? colors.btnClr,
        foregroundColor: colors.btnIcon,
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: label != null ? 16 : 14,
          vertical: 12,
        ),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: icon == Icons.favorite_rounded ? Colors.red : colors.btnIcon,
            size: 20,
          ),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(
              label!,
              style: const TextStyle(
                fontFamily: 'Product',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
