import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>?> getLatestGitHubRelease() async {
  final response = await http.get(Uri.parse(
    "https://api.github.com/repos/jydv402/memno/releases/latest",
  ));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return null;
  }
}

bool isNewerVersion(String latest, String current, String buildNumber) {
  //print("Comparing versions: Latest: $latest, Current: $current");
  // eg latest = "1.2.3+11", current = "1.2.2"
  // Remove after '+' if present in latest version
  final latestParts = latest.split('+')[0].split('.').map(int.parse).toList() +
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
