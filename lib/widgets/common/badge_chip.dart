import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BadgeChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const BadgeChip({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor = AppColors.beigeLight,
    this.textColor = AppColors.black,
    this.borderColor,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  factory BadgeChip.matchScore(double score) {
    final percent = (score * 100).round();
    return BadgeChip(
      label: '$percent% Match',
      icon: Icons.auto_awesome,
      backgroundColor: AppColors.accentAmberSoft,
      textColor: AppColors.accentAmberDark,
      borderColor: AppColors.accentAmber.withOpacity(0.3),
    );
  }

  factory BadgeChip.status(String status, {bool isLive = false}) {
    if (isLive) {
      return BadgeChip(
        label: '● $status',
        backgroundColor: AppColors.black,
        textColor: AppColors.accentAmberLight,
        borderColor: AppColors.accentAmber,
      );
    }
    return BadgeChip(
      label: status,
      backgroundColor: AppColors.beigeMedium,
      textColor: AppColors.blackMuted,
    );
  }

  factory BadgeChip.eco(double kgSaved) {
    return BadgeChip(
      label: '-${kgSaved.toStringAsFixed(1)} kg CO₂',
      icon: Icons.eco_outlined,
      backgroundColor: AppColors.successSoft,
      textColor: AppColors.success,
      borderColor: AppColors.success.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? backgroundColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
