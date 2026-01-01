import 'package:flutter/material.dart';
import 'package:memno/functionality/check_update.dart';
import 'package:memno/functionality/import_export.dart';
import 'package:memno/theme/app_colors.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showDialog(BuildContext context, String title, String content,
      AppColors colors, VoidCallback onPressed) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.box,
        title: Text(title,
            style: TextStyle(
                fontFamily: 'Product', fontSize: 20, color: colors.textClr)),
        content: Text(content,
            style: TextStyle(
                fontFamily: 'Product', fontSize: 18, color: colors.textClr)),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: Text(
              "OK",
              style: TextStyle(
                  fontFamily: 'Product', fontSize: 16, color: colors.textClr),
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
                SwitchListTile(
                  trackColor: WidgetStateProperty.all(
                      colors.accnt.withValues(alpha: 0.3)),
                  overlayColor: WidgetStateProperty.all(colors.accnt),
                  thumbColor: WidgetStateProperty.all(colors.thumbClr),
                  title: Text("Dark Mode",
                      style: TextStyle(
                          fontFamily: 'Product',
                          fontSize: 18,
                          color: colors.textClr)),
                  value: context.watch<AppColors>().isDarkMode,
                  onChanged: (_) async {
                    await colors.toggleTheme();
                  },
                ),
                colors,
              ),
              settingsContainer(
                SwitchListTile(
                  trackColor: WidgetStateProperty.all(
                      colors.accnt.withValues(alpha: 0.3)),
                  overlayColor: WidgetStateProperty.all(colors.accnt),
                  thumbColor: WidgetStateProperty.all(colors.thumbClr),
                  trackOutlineColor:
                      WidgetStateProperty.all(colors.switchTrackOutlineClr),
                  title: Text("Compact Header",
                      style: TextStyle(
                          fontFamily: 'Product',
                          fontSize: 18,
                          color: colors.textClr)),
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
                          color: colors.textClr),
                    ),
                    trailing:
                        Icon(Icons.arrow_upward_rounded, color: colors.textClr),
                  ),
                  colors),
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
                          color: colors.textClr),
                    ),
                    trailing: Icon(Icons.arrow_downward_rounded,
                        color: colors.textClr),
                  ),
                  colors),
              settingsTitle("Updates", colors),
              settingsContainer(
                  ListTile(
                      onTap: () async {
                        final info = await PackageInfo.fromPlatform();
                        final currVer = info.version; // Get current app version
                        final buildNumber =
                            info.buildNumber; // Get build number
                        if (currVer.isEmpty || buildNumber.isEmpty) {
                          _showDialog(
                            context.mounted ? context : context,
                            "Version Check Failed",
                            "Could not retrieve current version.",
                            colors,
                            () {
                              Navigator.pop(context);
                            },
                          );
                          return;
                        }
                        // Get latest release data from GitHub
                        final release = await getLatestGitHubRelease();
                        if (release == null) {
                          _showDialog(
                              context.mounted ? context : context,
                              "Update Check Failed",
                              "Could not check for updates.",
                              colors, () {
                            Navigator.pop(context);
                          });
                          return;
                        }

                        final latestVer = release['tag_name']
                            as String; // Obtain latest version on GitHub
                        final browserUrl = release['assets'][0]
                                ['browser_download_url']
                            as String; // Obtain download link for the latest version
                        if (browserUrl.isEmpty || latestVer.isEmpty) {
                          _showDialog(
                              context.mounted ? context : context,
                              "Update Check Failed",
                              "Could not find download link for the latest version.",
                              colors, () {
                            Navigator.pop(context);
                          });
                          return;
                        }
                        // Compare versions
                        if (isNewerVersion(latestVer, currVer, buildNumber)) {
                          _showDialog(
                            context.mounted ? context : context,
                            "Update Available",
                            "A new version ($latestVer) is available. Please update to enjoy the latest features.",
                            colors,
                            () {
                              Navigator.pop(context);
                              launchUrl(Uri.parse(browserUrl));
                            },
                          );
                        } else {
                          _showDialog(
                            context.mounted ? context : context,
                            "No Updates",
                            "You are using the latest version ($currVer).",
                            colors,
                            () {
                              Navigator.pop(context);
                            },
                          );
                        }
                      },
                      trailing: Icon(Icons.file_download_outlined,
                          color: colors.textClr),
                      title: Text(
                        "Check for updates",
                        style: TextStyle(
                            fontFamily: 'Product',
                            fontSize: 18,
                            color: colors.textClr),
                      )),
                  colors),
              settingsTitle("About", colors),
              settingsContainer(
                  ListTile(
                      onTap: () {
                        launchUrl(
                            Uri.parse("https://github.com/jydv402/memno"));
                      },
                      trailing: Icon(Icons.arrow_outward_rounded,
                          color: colors.textClr),
                      title: Text(
                        "Find us on GitHub",
                        style: TextStyle(
                            fontFamily: 'Product',
                            fontSize: 18,
                            color: colors.textClr),
                      )),
                  colors),
              // Bottom padding
              const SizedBox(height: 100),
            ],
          )),
    );
  }

  Padding settingsTitle(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 0, 16),
      child: Text(title,
          style: TextStyle(
              fontFamily: 'Product', fontSize: 28, color: colors.textClr)),
    );
  }

  Container settingsContainer(Widget child, AppColors colors) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(2, 4, 2, 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50), color: colors.box),
      child: child,
    );
  }
}
