import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:hive/hive.dart';
import 'package:memno/database/preview_data.dart';

class PreviewMap extends ChangeNotifier {
  // final Box _previewBox = Hive.box('previewsBox');
  final Map<String, PreviewData> cache = {};

  late Box<PreviewDataModel> _previewBox;

  PreviewMap() {
    _previewBox = Hive.box<PreviewDataModel>('previewsBox');
    loadAllPreviews();
    notifyListeners();
  }

  // Save a preview
  Future<void> savePreview(String link, PreviewData data) async {
    final model = PreviewDataModel(
      title: data.title,
      description: data.description,
      link: data.link,
      image: data.image?.url,
      imageHeight: data.image?.height,
      imageWidth: data.image?.width,
    );
    await _previewBox.put(link, model);
    cache[link] = data;
  }

  // Load a preview
  PreviewData? loadPreview(String link) {
    final model = _previewBox.get(link);
    if (model == null) return null;
    return PreviewData(
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
  }

  // Load all previews into cache (e.g., on startup)
  void loadAllPreviews() {
    for (var key in _previewBox.keys) {
      final model = _previewBox.get(key);
      if (model != null) {
        cache[key] = PreviewData(
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
      }
    }
  }
}
