import 'package:core/core/constants/app_constants.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/utils/utils.dart';
import 'package:core/core/widgets/custom_text_field.dart';
import 'package:core/core/widgets/url_screen.dart';
import 'package:core/core/widgets/overlay_loader.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_event.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Wraps the sign-up form and dispatches events after client-side validation.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

/// Holds controllers and terms-consent state for the sign-up form.
class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validates input, enforces terms consent, and dispatches SignUpRequested.
  void _submit(BuildContext context) {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (name.isEmpty) {
      AppUtils.showToast('Please enter your name');
      return;
    }
    if (email.isEmpty) {
      AppUtils.showToast('Please enter your email');
      return;
    }
    if (password.length < 6) {
      AppUtils.showToast('Password must be at least 6 characters');
      return;
    }
    if (password != confirmPassword) {
      AppUtils.showToast('Passwords do not match');
      return;
    }
    if (!_acceptedTerms) {
      AppUtils.showToast('Please accept Terms & Conditions');
      return;
    }

    context.read<AuthBloc>().add(
      SignUpRequested(email: email, password: password, name: name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              AppUtils.showToast('Account created');
              Navigator.of(context).maybePop();
            } else if (state is AuthFailure) {
              AppUtils.showToast('Error: ${state.error}');
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return OverlayLoader(
                isLoading: isLoading,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      InputField(controller: nameController, hintText: 'Name'),
                      const SizedBox(height: 16),
                      InputField(controller: emailController, hintText: 'Email'),
                      const SizedBox(height: 16),
                      InputField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      InputField(
                        controller: confirmPasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: (value) {
                              setState(() => _acceptedTerms = value ?? false);
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
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : () => _submit(context),
                          child: Text(isLoading ? 'Creating...' : 'Create account'),
                        ),
                      ),
                    ],
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
