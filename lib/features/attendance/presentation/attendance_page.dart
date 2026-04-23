import 'package:core/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:core/features/attendance/presentation/bloc/attendance_event.dart';
import 'package:core/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceBloc(apiService: sl())..add(const AttendanceStarted()),
      child: const AttendanceScreen(),
    );
  }
}
