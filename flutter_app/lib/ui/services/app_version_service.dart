import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/app_debug.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionService {
  static const String _appName = 'ZuDoKu';
  static const String _buildName = String.fromEnvironment('FLUTTER_BUILD_NAME');
  static const String _buildNumber = String.fromEnvironment(
    'FLUTTER_BUILD_NUMBER',
  );
  static bool _logged = false;

  const AppVersionService();

  String initialDisplayVersion() {
    final label = _formatDisplayVersion(_buildName, _buildNumber) ?? _appName;
    _logOnce(
      source: label == _appName ? 'fallback' : 'flutter-build-env',
      label: label,
      buildName: _buildName,
      buildNumber: _buildNumber,
    );
    return label;
  }

  Future<String> loadDisplayVersion() async {
    final initial = initialDisplayVersion();
    if (initial != _appName) {
      return initial;
    }

    try {
      final info = await PackageInfo.fromPlatform();
      final label =
          _formatDisplayVersion(info.version, info.buildNumber) ?? _appName;
      _logOnce(
        source: 'package-info-plus',
        label: label,
        buildName: info.version,
        buildNumber: info.buildNumber,
      );
      return label;
    } on Exception catch (error) {
      AppDebug.log('Failed to load package info: $error');
      return _appName;
    }
  }

  String? _formatDisplayVersion(String version, String buildNumber) {
    final cleanVersion = version.trim();
    final cleanBuild = buildNumber.trim();
    if (cleanVersion.isEmpty || cleanBuild.isEmpty) {
      return null;
    }
    return '$_appName $cleanVersion build $cleanBuild';
  }

  void _logOnce({
    required String source,
    required String label,
    required String buildName,
    required String buildNumber,
  }) {
    if (_logged) {
      return;
    }
    _logged = true;
    AppDebug.log(
      'App version resolved [$source]: $label '
      '(buildName=$buildName, buildNumber=$buildNumber)',
    );
  }
}
