import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/widgets/custom_text_field.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_event.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Test harness for sending/verifying OTP flows exposed via the auth repository.
class PhoneAuthTestScreen extends StatefulWidget {
  const PhoneAuthTestScreen({super.key});

  @override
  State<PhoneAuthTestScreen> createState() => _PhoneAuthTestScreenState();
}

class _PhoneAuthTestScreenState extends State<PhoneAuthTestScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String? verificationId;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            setState(() {
              verificationId = state.verificationId;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP sent successfully')),
            );
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login successful: ${state.user.email}')),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            appBar: AppBar(title: const Text('Phone Auth Test')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InputField(
                    controller: phoneController,
                    hintText: 'Phone Number (e.g., +1234567890)',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            final phone = phoneController.text.trim();
                            if (phone.isEmpty) return;
                            context.read<AuthBloc>().add(
                                  SendOtpRequested(phoneNumber: phone),
                                );
                          },
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Send OTP'),
                  ),
                  if ((verificationId ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Verification ID: $verificationId'),
                    const SizedBox(height: 16),
                    InputField(
                      controller: otpController,
                      hintText: 'Enter OTP',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final code = otpController.text.trim();
                              if (code.isEmpty) return;
                              context.read<AuthBloc>().add(
                                    VerifyOtpRequested(
                                      verificationId: verificationId!,
                                      smsCode: code,
                                    ),
                                  );
                            },
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Verify OTP'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
