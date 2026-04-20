import 'dart:developer';

import 'package:core/core/biometric/biometric_auth.dart';
import 'package:core/core/constants/app_constants.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:core/core/utils/utils.dart';
import 'package:core/core/widgets/app_progress_indicator.dart';
import 'package:core/core/widgets/custom_text_field.dart';
import 'package:core/core/widgets/url_screen.dart';
import 'package:core/features/auth/domain/entities/user_entity.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_event.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Entry point for the auth feature, wiring form inputs, biometrics, and social login through AuthBloc.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Maintains controllers, consent state, and dispatches AuthBloc events for login flows.
class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final BiometricService _biometricService = BiometricService();
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _navigateToVideoCallUsers(UserEntity user) {
    final String userId = user.id.trim();
    final String location = AppRoutes.videoCallUsersLocation(
      myUserId: userId.isEmpty ? null : userId,
    );
    context.go(location);
  }

  Future<void> _handleBiometricLogin() async {
    final bool isAvailable = await _biometricService.canCheckBiometrics();
    if (!isAvailable) {
      return;
    }

    final bool isAuthenticated = await _biometricService.authenticate();
    if (!isAuthenticated || !mounted) {
      return;
    }

    final data = await SharedPref().readJson(
      PrefKeys.biometricLoginCredentials,
    );
    log('local auth : $data');

    if (!mounted || data == null) {
      AppUtils.showToast('No biometric credentials found');
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(username: data['email'], password: data['password']),
    );
  }

  Future<void> _navigateToPhoneAuthWithBiometric() async {
    final bool isAvailable = await _biometricService.canCheckBiometrics();
    if (!isAvailable) {
      AppUtils.showToast('Biometric authentication is not available');
      return;
    }

    final bool isAuthenticated = await _biometricService.authenticate(
      localizedReason: 'Authenticate to open Phone Auth test',
    );
    if (!isAuthenticated || !mounted) {
      AppUtils.showToast('Biometric authentication required');
      return;
    }

    context.push(AppRoutes.phoneAuthTest);
  }

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
              _navigateToVideoCallUsers(state.user);
            } else if (state is AuthAccountDeleted) {
              AppUtils.showToast('Account deleted successfully');
            } else if (state is AuthFailure) {
              AppUtils.showToast('Error: ${state.error}');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  InputField(
                    controller: emailController,
                    hintText: 'Email or Username',
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('I agree to the '),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const UrlScreen(
                                      title: 'Terms & Conditions',
                                      url: AppConstants.termsConditionsUrl,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Terms & Conditions'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _acceptedTerms
                                  ? () async {
                                      AppProgressIndicator.show(context);
                                      await Future.delayed(
                                        const Duration(seconds: 4),
                                      );
                                      if (!context.mounted) return;
                                      context.read<AuthBloc>().add(
                                        LoginRequested(
                                          username: emailController.text.trim(),
                                          password: passwordController.text
                                              .trim(),
                                        ),
                                      );
                                      if (!context.mounted) return;
                                      AppProgressIndicator.dismiss(context);
                                    }
                                  : null,
                              child: const Text('Login'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _acceptedTerms
                                  ? _handleBiometricLogin
                                  : null,
                              child: const Text('biometric'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              onPressed: _acceptedTerms
                                  ? () {
                                      context.read<AuthBloc>().add(
                                        const SignInWithGoogle(),
                                      );
                                    }
                                  : null,
                              child: const Text(
                                'Sign in with Google',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(
                                AppRoutes.paymentLocation(
                                  amount: '10.00',
                                  currency: 'USD',
                                  email: 'test@email.com',
                                ),
                              );
                            },
                            child: const Text('payment'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(AppRoutes.notificationInbox);
                            },
                            child: const Text('Notification Inbox'),
                          ),
                          TextButton(
                            onPressed: () {
                              _navigateToPhoneAuthWithBiometric();
                            },
                            child: const Text('Test Phone Auth'),
                          ),
                          if (state is AuthLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: CircularProgressIndicator(),
                            ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () async {
                              log(
                                'user data : ${await SharedPref().read(PrefKeys.user)}',
                              );
                            },
                            child: const Text('Get user data'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                const SignOutWithGoogle(),
                              );
                            },
                            child: const Text('Logout'),
                          ),
                          TextButton(
                            onPressed: () async {
                              final bool? shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: const Text('Delete Account'),
                                    content: const Text(
                                      'Are you sure you want to delete your account? This action cannot be undone.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop(false);
                                        },
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop(true);
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldDelete == true && context.mounted) {
                                context.read<AuthBloc>().add(
                                  const DeleteAccountRequested(),
                                );
                              }
                            },
                            child: const Text(
                              'Delete Account',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(
                                AppRoutes.paymentLocation(
                                  amount: '10.00',
                                  currency: 'USD',
                                  email: '',
                                ),
                              );
                            },
                            child: const Text('Payment'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(AppRoutes.chat);
                            },
                            child: const Text('Test Chat'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.push(AppRoutes.signUp);
                            },
                            child: const Text('Create account'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SignInWithAppleButton(
                    onPressed: _acceptedTerms
                        ? () {
                            context.read<AuthBloc>().add(AppleLoginRequested());
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
