import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:memno/components/show_toast.dart';
import 'package:memno/database/code_data.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ImportExport {
// TODO: Add import and export functionality using JSON file

  late Box<CodeData>? _codeBox;
  bool _isLoaded = false;

  ImportExport() {
    _loadCodeBox();
  }

  // Load the code box
  Future<void> _loadCodeBox() async {
    try {
      if (!Hive.isBoxOpen('codeData')) {
        _codeBox = await Hive.openBox<CodeData>('codeData');
      } else {
        _codeBox = Hive.box<CodeData>('codeData');
      }
      _isLoaded = true;
    } catch (e) {
      debugPrint('ImportExport _loadCodeBox error: $e');
    }
  }

  // Export to JSON function
  Future<void> exportToJSON(BuildContext context) async {
    try {
      await _loadCodeBox();
      if (_codeBox == null) return;

      // Collect the notes
      final notes = _codeBox!.values.map((note) => note.toJSON()).toList();

      // Get app data
      final pkgInfo = await PackageInfo.fromPlatform();

      final appDetails = {
        "app": "Memno",
        "version": pkgInfo.version,
        "schema_version": 1,
        "exported_at": DateTime.now().toUtc().toIso8601String(),
        "notes": notes,
      };

      // Encode JSON
      final json = const JsonEncoder.withIndent('  ').convert(appDetails);
      // Convert the JSON to UTF8 bytes, returns a list of int
      // Then convert the int list to Uint8List as SAF (Storage Access Framework) demands it
      final bytes = Uint8List.fromList(utf8.encode(json));

      // Get the save destination
      // Write the file
      await FilePicker.platform.saveFile(
        dialogTitle: 'Export Memno Notes',
        fileName: 'memno_notes.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      // final bytes = utf8.encode(json);
      // final file = File(userPath);
      // await file.writeAsBytes(bytes, flush: true);

      // Show success message
      if (context.mounted) {
        showToastMsg(context, 'Successfully Exported to JSON');
      }
    } catch (e) {
      debugPrint('ExportToJSON error: $e');
      if (context.mounted) {
        showToastMsg(context, e.toString());
      }
    }
  }
}
