import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
        await _remoteConfig.setDefaults({
        'android_build_number': '1',
        'android_build_version': '1.0.0',
        'ios_build_number': '1',
        'ios_build_version': '1.0.0',
      });

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // for testing
      ),
    );

    await _remoteConfig.fetchAndActivate();
  }

  String get androidBuildNumber =>
      _remoteConfig.getString('android_build_number');

  String get androidBuildVersion =>
      _remoteConfig.getString('android_build_version');

  String get iosBuildNumber =>
      _remoteConfig.getString('ios_build_number');

  String get iosBuildVersion =>
      _remoteConfig.getString('ios_build_version');
}