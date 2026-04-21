import 'package:core/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:core/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:core/features/dashboard/presentation/widgets/dashboard_cards.dart';
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
    // TODO: implement initState
    super.initState();
    sl<ApiService>().get(ApiRoutes.projects);
  }

  @override
  Widget build(BuildContext context) {
    const Color pageTop = Color(0xFF101C34);
    const Color pageBottom = Color(0xFF0A1630);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[pageTop, pageBottom],
        ),
      ),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          final highlights = state.highlights;
          final amsOverview = state.amsLeaveOverview;

          return Stack(
            children: [
              SingleChildScrollView(
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
                    const SizedBox(height: 10),
                    DashboardAttendanceCard(overview: amsOverview),
                    const SizedBox(height: 10),
                    DashboardDailyStatusCard(highlights: highlights),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFFFB4AB),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (state.isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
