import 'package:flutter/material.dart';
import 'package:memno/functionality/check_update.dart';
import 'package:memno/components/update_bottom_sheet.dart';
import 'package:memno/functionality/import_export.dart';
import 'package:memno/theme/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showDialog(
    BuildContext context,
    String title,
    String content,
    AppColors colors,
    VoidCallback onPressed,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.box,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Product',
            fontSize: 20,
            color: colors.textClr,
          ),
        ),
        content: Text(
          content,
          style: TextStyle(
            fontFamily: 'Product',
            fontSize: 18,
            color: colors.textClr,
          ),
        ),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: Text(
              "OK",
              style: TextStyle(
                fontFamily: 'Product',
                fontSize: 16,
                color: colors.textClr,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    return Hero(
      tag: 'fab_to_page',
      child: Scaffold(
        backgroundColor: colors.bgClr,
        appBar: AppBar(
          backgroundColor: colors.bgClr,
          foregroundColor: colors.fgClr,
        ),
        body: ListView(
          children: [
            settingsTitle("Settings", colors),
            settingsContainer(
              ListTile(
                onTap: () => colors.cycleThemeMode(),
                title: Text(
                  "Appearance",
                  style: TextStyle(
                    fontFamily: 'Product',
                    fontSize: 18,
                    color: colors.textClr,
                  ),
                ),
                trailing: Icon(
                  colors.themeMode == AppThemeMode.system
                      ? Icons.brightness_auto_rounded
                      : colors.themeMode == AppThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: colors.textClr,
                ),
              ),
              colors,
            ),
            settingsContainer(
              SwitchListTile(
                trackColor: WidgetStateProperty.all(
                  colors.accnt.withValues(alpha: 0.3),
                ),
                overlayColor: WidgetStateProperty.all(colors.accnt),
                thumbColor: WidgetStateProperty.all(colors.thumbClr),
                trackOutlineColor: WidgetStateProperty.all(
                  colors.switchTrackOutlineClr,
                ),
                title: Text(
                  "Compact Header",
                  style: TextStyle(
                    fontFamily: 'Product',
                    fontSize: 18,
                    color: colors.textClr,
                  ),
                ),
                value: context.watch<AppColors>().isCompactHeader,
                onChanged: (_) async {
                  await colors.toggleCompactHeader();
                },
              ),
              colors,
            ),
            settingsTitle("Data", colors),
            settingsContainer(
              ListTile(
                onTap: () {
                  ImportExport().exportToJSON(context);
                },
                title: Text(
                  "Export to JSON",
                  style: TextStyle(
                    fontFamily: 'Product',
                    fontSize: 18,
                    color: colors.textClr,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_upward_rounded,
                  color: colors.textClr,
                ),
              ),
              colors,
            ),
            settingsContainer(
              ListTile(
                onTap: () {
                  ImportExport().importFromJSON(context);
                },
                title: Text(
                  "Import from JSON",
                  style: TextStyle(
                    fontFamily: 'Product',
                    fontSize: 18,
                    color: colors.textClr,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_downward_rounded,
                  color: colors.textClr,
                ),
              ),
              colors,
            ),
            settingsTitle("Updates", colors),
            settingsContainer(
              ListTile(
                onTap: () async {
                  final info = await PackageInfo.fromPlatform();
                  final currVer = info.version; // Get current app version
                  final buildNumber = info.buildNumber; // Get build number
                  if (!context.mounted) return;
                  if (currVer.isEmpty || buildNumber.isEmpty) {
                    _showDialog(
                      context,
                      "Version Check Failed",
                      "Could not retrieve current version.",
                      colors,
                      () {
                        Navigator.pop(context);
                      },
                    );
                    return;
                  }
                  // Use the new update check service
                  final updateInfo = await checkUpdateAvailable();
                  if (!context.mounted) return;

                  if (updateInfo != null) {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => UpdateBottomSheet(
                        latestVersion: updateInfo['version'],
                        downloadUrl: updateInfo['url'],
                        releaseNotes: updateInfo['notes'],
                      ),
                    );
                  } else {
                    final info = await PackageInfo.fromPlatform();
                    if (!context.mounted) return;
                    _showDialog(
                      context,
                      "No Updates",
                      "You are using the latest version (${info.version}).",
                      colors,
                      () {
                        Navigator.pop(context);
                      },
                    );
                  }
                },
                trailing: Icon(
                  Icons.file_download_outlined,
                  color: colors.textClr,
                ),
                title: Text(
                  "Check for updates",
                  style: TextStyle(
                    fontFamily: 'Product',
                    fontSize: 18,
                    color: colors.textClr,
                  ),
                ),
              ),
              colors,
            ),
            settingsTitle("About", colors),
            settingsContainer(
              ListTile(
                onTap: () {
                  launchUrl(Uri.parse("https://github.com/jydv402/memno"));
                },
                trailing: Icon(
                  Icons.arrow_outward_rounded,
                  color: colors.textClr,
                ),
                title: Text(
                  "Find us on GitHub",
                  style: TextStyle(
                    fontFamily: 'Product',
                    fontSize: 18,
                    color: colors.textClr,
                  ),
                ),
              ),
              colors,
            ),
            // Bottom padding
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Padding settingsTitle(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 0, 16),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Product',
          fontSize: 28,
          color: colors.textClr,
        ),
      ),
    );
  }

  Container settingsContainer(Widget child, AppColors colors) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.fromLTRB(2, 4, 2, 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: colors.box,
      ),
      child: child,
    );
  }
}
