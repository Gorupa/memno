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

bool isNewerVersion(String latest, String current) {
  print("Comparing versions: Latest: $latest, Current: $current");
  final latestParts = latest.split('.').map(int.parse).toList();
  return false;
}
