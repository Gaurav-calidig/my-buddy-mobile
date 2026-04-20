import 'package:flutter/material.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'SecureOps - Secure operations platform for teams',
            style: TextStyle(color: Color(0xFF8AA5CA), fontSize: 14),
          ),
          SizedBox(height: 4),
          Center(
            child: Text(
              'Powered by calidig',
              style: TextStyle(color: Color(0xFF8AA5CA), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
