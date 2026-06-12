import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/utils/utils.dart';
import 'package:core/core/widgets/overlay_loader.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_event.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              AppUtils.showToast('Login Successful');
              if (kDebugMode) {
                print('User: ${state.user.fullName}, Role: ${state.user.portalRole}');
              }
              // Route based on portal role
              if (state.user.portalRole != 'super_admin' &&
                  state.user.portalRole != 'admin') {
                context.go(AppRoutes.memberHome);
              } else {
                context.go(AppRoutes.dashboard);
              }
            } else if (state is AuthFailure) {
              AppUtils.showToast('Error: ${state.error}');
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return OverlayLoader(
                isLoading: state is AuthLoading,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.account_circle, size: 80, color: Colors.blue),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.grey),
                              ),
                            ),
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                const SignInWithGoogle(),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.g_mobiledata, color: Colors.black, size: 32),
                                SizedBox(width: 8),
                                Text(
                                  'Sign in with Google',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
