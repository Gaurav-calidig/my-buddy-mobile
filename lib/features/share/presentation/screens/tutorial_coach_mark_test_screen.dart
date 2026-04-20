import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:core/features/share/presentation/widgets/tutorial_coach_content_widget.dart';

class TutorialCoachMarkTestScreen extends StatefulWidget {
  const TutorialCoachMarkTestScreen({super.key});

  @override
  State<TutorialCoachMarkTestScreen> createState() =>
      _TutorialCoachMarkTestScreenState();
}

class _TutorialCoachMarkTestScreenState
    extends State<TutorialCoachMarkTestScreen> {
  final GlobalKey _profileKey = GlobalKey();
  final GlobalKey _callButtonKey = GlobalKey();
  final GlobalKey _settingsKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  TutorialCoachMark? _tutorial;
  bool _hasStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasStarted) {
      return;
    }
    _hasStarted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) {
          return;
        }
        _showTutorial();
      });
    });
  }

  TargetContent _content(String message, ContentAlign align) {
    return TargetContent(
      align: align,
      child: TutorialCoachContentWidget(message: message),
    );
  }

  List<TargetFocus> _targets() {
    return <TargetFocus>[
      TargetFocus(
        identify: 'profile',
        keyTarget: _profileKey,
        contents: <TargetContent>[
          _content('This is your profile section.', ContentAlign.bottom),
        ],
      ),
      TargetFocus(
        identify: 'call_button',
        keyTarget: _callButtonKey,
        contents: <TargetContent>[
          _content('Click here to start a video call.', ContentAlign.bottom),
        ],
      ),
      TargetFocus(
        identify: 'settings',
        keyTarget: _settingsKey,
        contents: <TargetContent>[
          _content('Open settings from here.', ContentAlign.top),
        ],
      ),
      TargetFocus(
        identify: 'fab',
        keyTarget: _fabKey,
        shape: ShapeLightFocus.Circle,
        contents: <TargetContent>[
          _content('Floating button action.', ContentAlign.top),
        ],
      ),
    ];
  }

  void _showTutorial() {
    _tutorial?.finish();

    _tutorial = TutorialCoachMark(
      targets: _targets(),
      colorShadow: Colors.black,
      opacityShadow: 0.8,
      paddingFocus: 8,
      hideSkip: false,
      textSkip: 'SKIP',
      onSkip: () => true,
      onFinish: () {},
    )..show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              CircleAvatar(
                key: _profileKey,
                radius: 30,
                child: const Icon(Icons.person),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                key: _callButtonKey,
                onPressed: () {},
                child: const Text('Start Call'),
              ),
              const SizedBox(height: 40),
              Icon(Icons.settings, key: _settingsKey, size: 40),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: _showTutorial,
                child: const Text('Replay Tutorial'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
