import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

enum StatusTone { green, orange, red, blue, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.label, {super.key, this.tone = StatusTone.green});
  final String label;
  final StatusTone tone;
  @override
  Widget build(BuildContext context) {
    final (foreground, background) = switch (tone) {
      StatusTone.green => (AppColors.green, AppColors.greenSoft),
      StatusTone.orange => (AppColors.orange, AppColors.orangeSoft),
      StatusTone.red => (AppColors.red, AppColors.redSoft),
      StatusTone.blue => (AppColors.blue, AppColors.blueSoft),
      StatusTone.neutral => (AppColors.muted, AppColors.background),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        '●  $label',
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
