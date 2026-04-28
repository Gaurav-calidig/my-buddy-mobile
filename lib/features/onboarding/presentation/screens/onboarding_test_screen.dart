import 'package:core/core/constants/assets_paths.dart';
import 'package:core/core/constants/pref_keys.dart';
import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/core/navigation/app_router.dart';
import 'package:core/core/navigation/app_routes.dart';
import 'package:core/core/utils/shared_pref.dart';
import 'package:core/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/features/auth/presentation/bloc/auth_state.dart';
import 'package:core/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:core/core/widgets/overlay_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OnboardingTestScreen extends StatefulWidget {
  const OnboardingTestScreen({super.key, this.nextLocation});

  final String? nextLocation;

  @override
  State<OnboardingTestScreen> createState() => _OnboardingTestScreenState();
}

class _OnboardingTestScreenState extends State<OnboardingTestScreen> {
  late final PageController _pageController;
  int _pageIndex = 0;

  static const int _totalPages = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await SharedPref().writeBool(PrefKeys.onboardingSeen, true);
    if (!mounted) return;

    final String next = (widget.nextLocation ?? '').trim();
    if (next.isNotEmpty) {
      context.go(next);
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _next() {
    if (_pageIndex == _totalPages - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  List<Widget> _pages() {
    return <Widget>[
      const OnboardingPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[OnboardingHeroSection()],
        ),
      ),
      const OnboardingPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[OnboardingModulesSection()],
        ),
      ),
      const OnboardingPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            OnboardingFeatureSection(
              title: 'Built for Teams That Move Fast',
              description:
                  'From kanban boards to sprint planning, from daily status reports to encrypted asset storage - SecureOps gives your team the tools to collaborate effectively.',
              bullets: <String>[
                'Kanban & Sprint boards per project',
                'AES-256 encrypted credentials',
                'Daily work hour tracking & summaries',
                'Full audit trail of all actions',
              ],
              animationAssetPath: AssetPaths.teamWorkAnimation,
            ),
            OnboardingFeatureSection(
              title: 'Flexible Task Management',
              description:
                  'Choose Kanban, Sprint, or both modes per project. Create sprints, assign tasks with priorities, link parent-child relationships, attach files, and track everything with auto-numbered tickets.',
              bullets: <String>[
                'Drag-and-drop task boards',
                'Assign to team members',
                'Sprint planning & backlog',
                'Custom columns & priorities',
              ],
              animationAssetPath: AssetPaths.taskManagementAnimation,
              reversed: true,
            ),
          ],
        ),
      ),
      const OnboardingPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[OnboardingSecurityControlSection()],
        ),
      ),
      OnboardingPageShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const OnboardingFeatureSection(
              title: 'Track Progress & Performance',
              description:
                  'Get clear visibility into team performance with daily status reports, project-level summaries, and comprehensive audit logs. Know who did what, when, and how much time was spent.',
              bullets: <String>[
                'Member & project summaries',
                'Detailed audit trail',
                'Hours tracking per day',
                'Sales pipeline management',
              ],
              animationAssetPath: AssetPaths.heroAnimation,
              reversed: true,
            ),
            OnboardingBottomCta(onCtaTap: _finish),
            const OnboardingFooter(),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final Widget body = MediaQuery(
      data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF061A3B),
              Color(0xFF05142F),
              Color(0xFF041127),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (int value) =>
                      setState(() => _pageIndex = value),
                  children: _pages(),
                ),
              ),
              OnboardingPagerBar(
                pageIndex: _pageIndex,
                totalPages: _totalPages,
                onSkip: _finish,
                onNext: _next,
              ),
            ],
          ),
        ),
      ),
    );

    final bool canUseAuthBloc =
        FeatureFlags.enableAuth && sl.isRegistered<AuthBloc>();

    if (!canUseAuthBloc) {
      return Scaffold(body: body);
    }

    return Scaffold(
      body: BlocProvider(
        create: (context) => sl<AuthBloc>(),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppRouter.router.go(AppRoutes.dashboard);
              });
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return OverlayLoader(
                isLoading: state is AuthLoading,
                child: body,
              );
            },
          ),
        ),
      ),
    );
  }
}
