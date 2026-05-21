import 'package:core/core/theme/app_colors.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingBottomCta extends StatelessWidget {
  const OnboardingBottomCta({super.key, required this.onCtaTap});

  final VoidCallback onCtaTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF0C2347), Color(0xFF0A1D3D)],
            ),
            border: Border.all(
              color: const Color(0xFF31507E).withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF3D8BFF),
                      size: 26,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ready to get started?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.08,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in with your Google account to access your secure workspace. Contact your admin if you need portal access.',
                style: TextStyle(
                  color: Color(0xFFDBE7FC),
                  fontSize: 18,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (){
                        context.read<AuthBloc>().add(
                              const SignInWithGoogle(),
                            );

                  },
                icon: Icon(Icons.arrow_forward, fontWeight: FontWeight.w700, color:AppColors.kcSecondaryColorLight),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: const Color(0xFF3D8BFF),
                    foregroundColor: const Color(0xFF031528),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  iconAlignment: IconAlignment.end,
                  label: const Text(
                    'Sign In Now',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.kcSecondaryColorLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
