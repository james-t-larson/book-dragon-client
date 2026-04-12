import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../config/app_config.dart';
import 'button.dart';

class UnsupportedScreen extends StatelessWidget {
  final String message;
  final bool showAppStoreLink;

  const UnsupportedScreen({
    super.key,
    required this.message,
    this.showAppStoreLink = false,
  });

  Future<void> _launchAppStore() async {
    final String link = defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS
        ? AppConfig.appStoreLinkApple
        : AppConfig.appStoreLinkAndroid;
    
    final Uri url = Uri.parse(link);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.medievalSharp(
                  fontSize: 24,
                  color: AppColors.onBackground,
                  height: 1.4,
                ),
              ),
              if (showAppStoreLink) ...[
                const SizedBox(height: 48),
                AppButton.icon(
                  onPressed: _launchAppStore,
                  icon: const Icon(Icons.download, color: AppColors.onPrimary),
                  label: Text(
                    'Open App Store',
                    style: GoogleFonts.medievalSharp(
                      fontSize: 18,
                      color: AppColors.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
