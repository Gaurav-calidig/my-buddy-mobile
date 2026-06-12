import 'package:core/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:core/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:core/features/attendance/presentation/screens/leaves_screen.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AttendanceBloc>()..add(const AttendanceStarted()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final isMember = authState is AuthSuccess && authState.user.portalRole == 'member';
          if (isMember) {
            return const LeavesScreen();
          }
          return const AttendanceScreen();
        },
      ),
    );
  }
}
