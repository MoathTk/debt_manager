import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DownloadResult { success, failed }

class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final Map<String, String> apkUrls;
  final String deviceAbi;
  final bool forceUpdate;
  final String releaseNotes;

  const UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    required this.apkUrls,
    required this.deviceAbi,
    required this.forceUpdate,
    required this.releaseNotes,
  });

  String? get apkUrl => apkUrls[deviceAbi];

  static const _fallbackAbi = 'arm64-v8a';

  factory UpdateInfo.fromJson(
    Map<String, dynamic> json,
    String currentVersion,
    String deviceAbi,
  ) {
    final version = json['latest_version'] as String?;
    if (version == null || version.isEmpty) {
      throw FormatException('Missing latest_version');
    }
    final urls = <String, String>{};
    final rawUrls = json['apk_urls'] as Map<String, dynamic>?;
    if (rawUrls == null || rawUrls.isEmpty) {
      throw FormatException('Missing or empty apk_urls');
    }
    for (final entry in rawUrls.entries) {
      final url = entry.value as String?;
      if (url != null && url.startsWith('https://')) {
        urls[entry.key] = url;
      }
    }
    if (urls.isEmpty) {
      throw FormatException('No valid HTTPS URLs in apk_urls');
    }
    final resolvedAbi = urls.containsKey(deviceAbi) ? deviceAbi : _fallbackAbi;
    return UpdateInfo(
      latestVersion: version,
      currentVersion: currentVersion,
      apkUrls: urls,
      deviceAbi: resolvedAbi,
      forceUpdate: json['force_update'] == true,
      releaseNotes: (json['release_notes'] as String?) ?? '',
    );
  }
}

class UpdateService {
  static const _dismissedAtKey = 'update_dismissed_at';
  static const _dismissWindow = Duration(hours: 24);
  static const versionUrl =
    'https://raw.githubusercontent.com/MoathTk/debt_manager/main/version.json';

  static Future<UpdateInfo?> checkForUpdate() async {
    final response = await http
        .get(Uri.parse(versionUrl))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return null;
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final packageInfo = await PackageInfo.fromPlatform();
    final current = packageInfo.version;
    final abi = await _getDeviceAbi();
    final info = UpdateInfo.fromJson(json, current, abi);
    if (info.apkUrl == null) return null;
    if (!_isNewer(info.latestVersion, current)) return null;
    return info;
  }

  static Future<String> _getDeviceAbi() async {
    try {
      final result = await Process.run('getprop', ['ro.product.cpu.abi']);
      if (result.exitCode == 0) {
        final abi = (result.stdout as String).trim();
        if (abi.isNotEmpty) return abi;
      }
    } catch (_) {}
    try {
      final result = await Process.run('getprop', ['ro.product.cpu.abi2']);
      if (result.exitCode == 0) {
        final abi = (result.stdout as String).trim();
        if (abi.isNotEmpty) return abi;
      }
    } catch (_) {}
    return 'arm64-v8a';
  }

  static bool _isNewer(String latest, String current) {
    final last = _parseVersion(latest);
    final currentVersion = _parseVersion(current);
    for (var i = 0; i < 3; i++) {
      if (last[i] > currentVersion[i]) return true;
      if (last[i] < currentVersion[i]) return false;
    }
    return false;
  }

  static List<int> _parseVersion(String v) {
    final parts = v.split('.');
    return List.generate(3, (i) => int.tryParse(parts.elementAtOrNull(i) ?? '0') ?? 0);
  }

  static Future<bool> wasRecentlyDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_dismissedAtKey);
    if (ts == null) return false;
    final dismissedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(dismissedAt) < _dismissWindow;
  }

  static Future<void> markDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dismissedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<DownloadResult> downloadAndInstall(
    String apkUrl, {
    void Function(double)? onProgress,
  }) async {
    try {
      final ota = OtaUpdate();
      await for (final event in ota.execute(
        apkUrl,
        androidProviderAuthority: 'com.example.local_debt_management.fileProvider',
        usePackageInstaller: true,
      )) {
        if (event.status == OtaStatus.DOWNLOADING && event.value != null) {
          final progress = double.tryParse(event.value!) ?? 0;
          onProgress?.call((progress / 100).clamp(0.0, 1.0));
        } else if (event.status == OtaStatus.INSTALLING ||
            event.status == OtaStatus.INSTALLATION_DONE) {
          return DownloadResult.success;
        } else if (event.status == OtaStatus.INSTALLATION_ERROR ||
            event.status == OtaStatus.DOWNLOAD_ERROR ||
            event.status == OtaStatus.INTERNAL_ERROR ||
            event.status == OtaStatus.CHECKSUM_ERROR) {
          return DownloadResult.failed;
        }
      }
      return DownloadResult.success;
    } catch (_) {
      return DownloadResult.failed;
    }
  }
}
