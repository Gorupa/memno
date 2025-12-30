import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:hive/hive.dart';
import 'package:memno/database/preview_data.dart';

class PreviewMap extends ChangeNotifier {
  // final Box _previewBox = Hive.box('previewsBox');
  final Map<String, PreviewData> cache = {};

  Box<PreviewDataModel>? _previewBox;

  bool _isInit = false;

  PreviewMap() {
    _init();
  }

  Future<void> _init() async {
    try {
      if (!Hive.isBoxOpen('previewsBox')) {
        // Open the box if it is not already open
        _previewBox = await Hive.openBox<PreviewDataModel>('previewsBox');
      } else {
        // Get the box if it is already open
        _previewBox = Hive.box<PreviewDataModel>('previewsBox');
      }
      _isInit = true;
    } catch (e, st) {
      debugPrint('PreviewMap init error: $e\n$st');
      // Set _previewBox to null if initialization fails
      _previewBox = null;
    }
    notifyListeners();
  }

  // Save a preview
  Future<void> savePreview(String link, PreviewData data) async {
    try {
      if (!_isInit) await _init();
      if (_previewBox == null) return;
      final model = PreviewDataModel(
        title: data.title,
        description: data.description,
        link: data.link,
        image: data.image?.url,
        imageHeight: data.image?.height,
        imageWidth: data.image?.width,
      );
      await _previewBox!.put(link, model);
      cache[link] = data;
    } catch (e) {
      debugPrint('savePreview error: $e');
    }
  }

  // Load a preview
  PreviewData? loadPreviewSync(String link) {
    try {
      if (_previewBox != null && _previewBox!.isOpen) {
        final model = _previewBox!.get(link);
        if (model == null) return null;
        final preview = PreviewData(
          title: model.title,
          description: model.description,
          link: model.link,
          image: model.image != null
              ? PreviewDataImage(
                  url: model.image!,
                  height: model.imageHeight ?? 0,
                  width: model.imageWidth ?? 0,
                )
              : null,
        );
        cache[link] = preview;
        return preview;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('loadPreviewSync error: $e');
      return null;
    }
  }

  // Load all previews into cache (e.g., on startup)
  Future<PreviewData?> loadPreview(String link) async {
    try {
      if (!_isInit) await _init();
      if (_previewBox == null) return null;
      final model = _previewBox!.get(link);
      if (model == null) return null;
      final preview = PreviewData(
        title: model.title,
        description: model.description,
        link: model.link,
        image: model.image != null
            ? PreviewDataImage(
                url: model.image!,
                height: model.imageHeight ?? 0,
                width: model.imageWidth ?? 0,
              )
            : null,
      );
      cache[link] = preview;
      return preview;
    } catch (e) {
      debugPrint('loadPreview error: $e');
      return null;
    }
  }
}
