import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> getLatestGitHubRelease() async {
  try {
    final response = await http.get(
      Uri.parse("https://api.github.com/repos/jydv402/memno/releases/latest"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

/// Returns the correct APK download URL for the device's CPU architecture.
/// Falls back to the first .apk asset if no arch-specific match is found.
String? getDownloadUrlForDevice(Map<String, dynamic> release) {
  final assets = release['assets'] as List<dynamic>?;
  if (assets == null || assets.isEmpty) return null;

  // Map Dart's architecture strings to the APK filename conventions
  final arch = _getDeviceArch();

  // Try to find an asset matching this device's architecture
  for (final asset in assets) {
    final name = (asset['name'] as String?)?.toLowerCase() ?? '';
    if (name.endsWith('.apk') && name.contains(arch)) {
      return asset['browser_download_url'] as String?;
    }
  }

  // Fallback: return the first .apk asset
  for (final asset in assets) {
    final name = (asset['name'] as String?)?.toLowerCase() ?? '';
    if (name.endsWith('.apk')) {
      return asset['browser_download_url'] as String?;
    }
  }

  return null;
}

/// Detects the device CPU architecture and maps it to standard APK ABI names.
String _getDeviceArch() {
  // SysInfo.kernelArchitecture returns values like "aarch64", "armv7l", "x86_64"
  final machine = _getMachineArch();

  if (machine.contains('aarch64') || machine.contains('arm64')) {
    return 'arm64-v8a';
  } else if (machine.contains('arm')) {
    return 'armeabi-v7a';
  } else if (machine.contains('x86_64') || machine.contains('amd64')) {
    return 'x86_64';
  }

  // Default fallback for unknown architectures
  return 'arm64-v8a';
}

/// Gets the machine architecture string from the OS.
String _getMachineArch() {
  try {
    // On Android/Linux, `uname -m` returns the architecture
    final result = Process.runSync('uname', ['-m']);
    return (result.stdout as String).trim().toLowerCase();
  } catch (_) {
    // Fallback: most Android devices are arm64
    return 'aarch64';
  }
}

bool isNewerVersion(String latest, String current, String buildNumber) {
  //print("Comparing versions: Latest: $latest, Current: $current");
  // eg latest = "1.2.3+11", current = "1.2.2"
  // Remove after '+' if present in latest version
  final latestParts =
      latest.split('+')[0].split('.').map(int.parse).toList() +
      (latest.contains('+') ? [int.parse(latest.split('+')[1])] : []);
  final currentParts =
      current.split('.').map(int.parse).toList() + [int.parse(buildNumber)];

  //print("Latest parts: $latestParts, Current parts: $currentParts");

  for (int i = 0; i < latestParts.length; i++) {
    if (i >= currentParts.length || latestParts[i] > currentParts[i]) {
      return true;
    } else if (latestParts[i] < currentParts[i]) {
      return false;
    }
  }
  return false;
}
