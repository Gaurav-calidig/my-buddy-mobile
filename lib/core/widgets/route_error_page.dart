import 'package:core/core/constants/app_constants.dart';
import 'package:flutter/material.dart';


/// Error page displayed when navigation to an invalid route is attempted.
///
/// Shows the attempted route and keeps the app shell brand-aware.
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key, required this.routeName});

  /// The invalid route name that was attempted.
  final String routeName;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(AppConstants.appName)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No Route Found',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                routeName,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
