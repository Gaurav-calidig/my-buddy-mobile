import 'package:core/core/config/feature_flags.dart';
import 'package:core/core/dependency_injection/injection_container.dart';
import 'package:core/features/workmanager/service/workmanager_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Lets testers trigger Workmanager actions, request permissions, and review logs/snapshots.
class WorkmanagerTestScreen extends StatefulWidget {
  const WorkmanagerTestScreen({super.key});

  @override
  State<WorkmanagerTestScreen> createState() => _WorkmanagerTestScreenState();
}

/// Invokes WorkmanagerService methods, refreshes snapshots, and displays log output.
class _WorkmanagerTestScreenState extends State<WorkmanagerTestScreen> {
  late final WorkmanagerService _workmanagerService;
  String? _lastLocation;
  String? _lastTimestamp;
  String? _lastStatus;
  bool _loadingSnapshot = true;

  @override
  void initState() {
    super.initState();
    _workmanagerService = sl<WorkmanagerService>();
    _loadSnapshot();
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      await _loadSnapshot();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workmanager action failed: $error')),
      );
    }
  }

  Future<void> _loadSnapshot() async {
    final snapshot = await _workmanagerService.readLastLocationSnapshot();
    if (!mounted) {
      return;
    }
    setState(() {
      _lastLocation = snapshot['location'];
      _lastTimestamp = snapshot['timestamp'];
      _lastStatus = snapshot['status'];
      _loadingSnapshot = false;
    });
  }

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      builder: (_) {
        return SizedBox(
          width: double.infinity,
          height: 500.h,
          child: const Center(child: Text('Hello')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workmanager Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!FeatureFlags.enableWorkmanager)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Workmanager is disabled. Enable it with --dart-define=ENABLE_WORKMANAGER=true.',
                  ),
                ),
              ),
            if (!FeatureFlags.enableWorkmanager) const SizedBox(height: 16),
            const Text(
              'Use this screen to grant background location access and schedule a location fetch every 15 minutes.',
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: FeatureFlags.enableWorkmanager
                  ? () => _runAction(
                      _workmanagerService.initialize,
                      'Workmanager initialized',
                    )
                  : null,
              child: const Text('Initialize Workmanager'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: FeatureFlags.enableWorkmanager
                  ? () => _runAction(() async {
                      await _workmanagerService
                          .requestBackgroundLocationPermission();
                    }, 'Background location permission checked')
                  : null,
              child: const Text('Request Background Location Permission'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: FeatureFlags.enableWorkmanager
                  ? () => _runAction(
                      _workmanagerService.registerOneOffTask,
                      'One-off location task scheduled',
                    )
                  : null,
              child: const Text('Schedule One-off Task'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: FeatureFlags.enableWorkmanager
                  ? () => _runAction(
                      _workmanagerService.registerPeriodicTask,
                      'Periodic location task scheduled',
                    )
                  : null,
              child: const Text('Schedule 15-Min Location Task'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: FeatureFlags.enableWorkmanager
                  ? () => _runAction(
                      _workmanagerService.cancelAllTasks,
                      'All tasks cancelled',
                    )
                  : null,
              child: const Text('Cancel All Tasks'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _openBottomSheet,
              child: const Text('open bottomsheet'),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _loadingSnapshot
                    ? const CircularProgressIndicator()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Last status: ${_lastStatus ?? 'No background execution yet'}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last location: ${_lastLocation ?? 'No location saved'}',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Last update: ${_lastTimestamp ?? 'No timestamp saved'}',
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: _loadSnapshot,
                            child: const Text('Refresh Snapshot'),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Logs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: _workmanagerService.taskLogs,
                builder: (context, logs, _) {
                  if (logs.isEmpty) {
                    return const Card(
                      child: Center(child: Text('No Workmanager actions yet.')),
                    );
                  }

                  return ListView.separated(
                    itemCount: logs.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return ListTile(dense: true, title: Text(logs[index]));
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
