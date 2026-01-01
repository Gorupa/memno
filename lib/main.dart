import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:memno/database/preview_data.dart';
import 'package:memno/functionality/code_gen.dart';
import 'package:memno/functionality/preview_map.dart';
import 'package:memno/home.dart';
import 'package:memno/theme/app_colors.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive and register adapters
  try {
    await Hive.initFlutter();

    Hive.registerAdapter(PreviewDataModelAdapter());
    await Hive.openBox<PreviewDataModel>('previewsBox');
  } catch (e, st) {
    debugPrint('Error: $e\nStacktrace: $st');
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => CodeGen()),
    ChangeNotifierProvider(create: (context) => PreviewMap()),
    ChangeNotifierProvider(create: (context) => AppColors()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Provider.of<AppColors>(context);
    return MaterialApp(
      title: 'Memno',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: colors.accnt),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                overlayColor: WidgetStateProperty.all(
                    colors.accnt.withValues(alpha: 0.025)))),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: colors.fgClr,
          selectionColor: colors.accnt.withValues(alpha: 0.25),
          selectionHandleColor: colors.fgClr,
        ),
      ),
    );
  }
}
