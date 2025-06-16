import 'package:flutter/material.dart';
import 'package:memno/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
              settingsContainer(
                  ListTile(
                      trailing:
                          Icon(Icons.download_rounded, color: colors.textClr),
                      title: Text(
                        "Check for updates",
                        style: TextStyle(
                            fontFamily: 'Product',
                            fontSize: 18,
                            color: colors.textClr),
                      )),
                  colors)
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
