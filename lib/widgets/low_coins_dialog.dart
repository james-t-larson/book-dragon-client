import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'button.dart';

class LowCoinsDialog extends StatelessWidget {
  const LowCoinsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.shimmer.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      title: Row(
        children: [
          const Icon(
            Icons.lock_clock_rounded,
            color: AppColors.shimmer,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Insufficient Coins',
            style: GoogleFonts.medievalSharp(
              color: AppColors.shimmer,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(
            'You can’t participate yet, you need 50 coins to ante up',
            style: GoogleFonts.rosarivo(
              color: AppColors.onSurface,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Decorative divider
          Container(
            height: 1,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.shimmer.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        AppButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: Text(
            'Understood',
            style: GoogleFonts.medievalSharp(
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
