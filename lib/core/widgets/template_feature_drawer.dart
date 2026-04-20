import 'package:core/core/constants/app_constants.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/navigation/app_router.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/widgets/app_drawer.dart';
import 'package:core/core/utils/screenshot_service.dart';

class TemplateFeatureDrawer extends StatelessWidget {
  const TemplateFeatureDrawer({super.key});

  void _open(BuildContext context, String location) {
    Scaffold.of(context).closeDrawer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.router.go(location);
    });
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDrawer(
      backgroundColor: AppColors.kcSecondaryColorLight,
      header: Container(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.kcPrimaryColor, AppColors.kcSecondaryColorLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BrandLogo(profile: branding, size: 48),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      menuItems: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(
            'Test Modules',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _menuTile(
          context,
          icon: Icons.palette_outlined,
          title: 'Branding Lab',
          subtitle: 'Preview white-label colors, logos, and text.',
          onTap: () => _open(context, AppRoutes.brandingLabLocation()),
        ),
        _menuTile(
          context,
          icon: Icons.home_outlined,
          title: 'Login Home',
          subtitle: 'Return to the auth landing screen.',
          onTap: () => _open(context, AppRoutes.login),
        ),
        _menuTile(
          context,
          icon: Icons.share_outlined,
          title: 'Share Test',
          subtitle: 'Open the share sample screen.',
          onTap: () => _open(context, AppRoutes.shareTest),
        ),
        _menuTile(
          context,
          icon: Icons.calendar_month_outlined,
          title: 'Custom Calendar',
          subtitle: 'Open customizable month-view calendar demo.',
          onTap: () => _open(context, AppRoutes.calendarTest),
        ),
        _menuTile(
          context,
          icon: Icons.security_outlined,
          title: 'Screenshot Protection',
          subtitle: 'Test screenshot blocking + screenshot-detection toast.',
          onTap: () => _open(context, AppRoutes.screenshotProtectionTest),
        ),
        _menuTile(
          context,
          icon: Icons.cloud_upload_outlined,
          title: 'Media Uploader',
          subtitle: 'Open media uploader test screen.',
          onTap: () => _open(context, AppRoutes.mediaUploader),
        ),
        _menuTile(
          context,
          icon: Icons.camera_alt_outlined,
          title: 'Share Screenshot',
          subtitle: 'Capture and share the entire screen.',
          onTap: () async {
            Scaffold.of(context).closeDrawer();
            // Wait for drawer to close
            await Future.delayed(const Duration(milliseconds: 400));
            await ScreenshotService.captureAndShare(
              text: 'Check out this screenshot!',
              subject: 'App Screenshot',
            );
          },
        ),
        _menuTile(
          context,
          icon: Icons.save_alt_outlined,
          title: 'Save Screenshot',
          subtitle: 'Save current screen to your gallery.',
          onTap: () async {
            Scaffold.of(context).closeDrawer();
            // Wait for drawer to close
            await Future.delayed(const Duration(milliseconds: 400));
            final success = await ScreenshotService.saveToGallery();
            if (success && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Screenshot saved to gallery!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
        _menuTile(
          context,
          icon: Icons.rocket_launch_outlined,
          title: 'Onboarding',
          subtitle: 'Open onboarding test screen.',
          onTap: () => _open(context, AppRoutes.onboardingTest),
        ),
        _menuTile(
          context,
          icon: Icons.slideshow_outlined,
          title: 'Onboarding Slider',
          subtitle: 'Open Flutter onboarding slider UI demo.',
          onTap: () => _open(context, AppRoutes.flutterOnboardingSliderTest),
        ),

        _menuTile(
          context,
          icon: Icons.auto_awesome_outlined,
          title: 'Showcase Tutorial',
          subtitle: 'Open guided in-app tutorial demo.',
          onTap: () => _open(context, AppRoutes.showcaseTest),
        ),

        _menuTile(
          context,
          icon: Icons.video_call_outlined,
          title: 'Video Call',
          subtitle: 'Open contacts and start a video call.',
          onTap: () => _open(context, AppRoutes.videoCallUsers),
        ),
        _menuTile(
          context,
          icon: Icons.hub_outlined,
          title: 'Video Call (WebSocket)',
          subtitle: 'Open WebSocket signaling based video call.',
          onTap: () => _open(context, AppRoutes.videoCallWsUsers),
        ),
        _menuTile(
          context,
          icon: Icons.map_outlined,
          title: 'Location Picker',
          subtitle: 'Open the Google Maps location picker.',
          onTap: () => _open(context, AppRoutes.locationPicker),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'Deep Link Tests',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _menuTile(
          context,
          icon: Icons.image_outlined,
          title: 'Image Compress',
          subtitle: 'Test the image compression flow.',
          onTap: () => _open(context, AppRoutes.imageCompress),
        ),
      ],
    );
  }
}
