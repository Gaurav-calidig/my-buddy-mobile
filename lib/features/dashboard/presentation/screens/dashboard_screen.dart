import 'package:core/core/widgets/custom_app_bar.dart';
import 'package:core/core/widgets/template_feature_drawer.dart';
import 'package:core/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:core/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:core/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_cards.dart';
import 'package:core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardBloc>().add(const DashboardLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
           drawer: const TemplateFeatureDrawer(),
      appBar: const CustomAppBar(title: 'Dashboard'),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppColors.kcDarkGradientTop, AppColors.kcDarkGradientBottom],
          ),
        ),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              );
            }
      
            final highlights = state.highlights;
            final amsOverview = state.amsLeaveOverview;
      
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DashboardSummaryCard(
                          icon: Icons.folder_copy_outlined,
                          label: 'My Projects',
                          value: (highlights?.stats.totalProjects ?? 0).toString(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DashboardSummaryCard(
                          icon: Icons.lock_outline_rounded,
                          label: 'My Assets',
                          value: (highlights?.stats.totalAssets ?? 0).toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  DashboardAttendanceCard(overview: amsOverview),
                  const SizedBox(height: 15),
                  DashboardDailyStatusCard(highlights: highlights),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: AppColors.kcDarkErrorText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
