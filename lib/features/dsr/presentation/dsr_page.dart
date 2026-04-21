import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/dsr_bloc.dart';
import 'bloc/dsr_event.dart';
import 'screens/my_dsr_screen.dart';

class DsrPage extends StatelessWidget {
  const DsrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DsrBloc()..add(const DsrInitialLoadRequested()),
      child: const MyDsrScreen(),
    );
  }
}
