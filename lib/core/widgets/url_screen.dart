import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_colors.dart';


/// Full-screen web view for displaying external URLs.
/// 
/// Provides a WebView with loading progress indicator, error handling,
/// and custom app bar with back navigation. Supports RTL layouts.
class UrlScreen extends StatefulWidget {

  const UrlScreen({
    super.key,
    required this.title,
    required this.url,
  });
  
  /// Title to display in the app bar
  final String title;
  
  /// URL to load in the web view
  final String url;

  @override
  State<UrlScreen> createState() => _UrlScreenState();
}

class _UrlScreenState extends State<UrlScreen> {
  late final WebViewController _controller;
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<int> _progress = ValueNotifier(0);

  @override
  void initState() {
    super.initState();

    // Initialize WebView controller with navigation delegates
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _isLoading.value = true;
            _progress.value = 0;
          },
          onProgress: (int progress) {
            _progress.value = progress;
            if (progress >= 100) {
              _isLoading.value = false;
            }
          },
          onPageFinished: (String url) {
            _isLoading.value = false;
            _progress.value = 100;
          },
          // Show error snackbar when web resource fails to load
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to load page: ${error.description}'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    // Clean up ValueNotifiers
    _isLoading.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70.w,
        // Custom back button with bordered container design
        leading: Container(
          margin: EdgeInsets.only(
            left: 12.w,
            bottom: 2.h,
            top: 2.h,
            right: 12.w,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.kcLightGreyColor),
            borderRadius: BorderRadius.circular(10.w),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loading progress indicator with percentage
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, _) => ValueListenableBuilder<int>(
                      valueListenable: _progress,
                      builder: (context, progress, _) {
                        if (isLoading || progress < 100) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Column(
                              children: [
                                LinearProgressIndicator(
                                  value: (progress > 0 && progress < 100)
                                      ? progress / 100.0
                                      : null, // Indeterminate when no progress
                                  minHeight: 4.h,
                                ),
                                SizedBox(height: 6.h),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    '$progress%',
                                    style: TextStyle(fontSize: 12.sp),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox(height: 8);
                        }
                      },
                    ),
                ),
                // WebView widget
                Expanded(
                  child: WebViewWidget(controller: _controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
