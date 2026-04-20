import 'package:core/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';


/// Full-screen block shown when app update is mandatory.
class UpdateRequiredScreen extends StatelessWidget {
  const UpdateRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
         return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Center(child: BrandLogo(profile: profile, size: 80)),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.updateTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppConstants.updateMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed:  () async {
                            final Uri uri = Uri.parse( Platform.isIOS?  AppConstants.appStoreUrl : AppConstants.playStoreUrl);
                            if (!await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            )) {
                              // Keep the button functional even when the URL cannot be opened.
                            }
                          },
                    child: const Text('Update App'),
                  ),
             
                    const SizedBox(height: 12),
                    Text(
                      'Need help? ${AppConstants.supportEmail}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  
                ],
              ),
            ),
          ),
        );
    
  }
}
