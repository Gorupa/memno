import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:hive/hive.dart';
import 'package:memno/database/preview_data.dart';

class PreviewMap extends ChangeNotifier {
  // final Box _previewBox = Hive.box('previewsBox');
  final Map<String, LinkPreviewData> cache = {};

  Box<PreviewDataModel>? _previewBox;

  bool _isInit = false;

  PreviewMap() {
    _init();
  }

  /// Returns a Hive-safe key for the given link.
  /// Hive string keys must be <= 255 chars; long URLs are SHA-256 hashed.
  String _hiveKey(String link) {
    if (link.length <= 255) return link;
    return sha256.convert(utf8.encode(link)).toString();
  }

  Future<void> _init() async {
    try {
      if (!Hive.isBoxOpen('previewsBox')) {
        _previewBox = await Hive.openBox<PreviewDataModel>('previewsBox');
      } else {
        _previewBox = Hive.box<PreviewDataModel>('previewsBox');
      }
      _isInit = true;
    } catch (e, st) {
      debugPrint('PreviewMap init error: $e\n$st');
      _previewBox = null;
    }
    notifyListeners();
  }

  // Save a preview
  Future<void> savePreview(String link, LinkPreviewData data) async {
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
      await _previewBox!.put(_hiveKey(link), model);
      cache[link] = data;
    } catch (e) {
      debugPrint('savePreview error: $e');
    }
  }

  // Load a preview
  LinkPreviewData? loadPreviewSync(String link) {
    try {
      if (_previewBox != null && _previewBox!.isOpen) {
        final model = _previewBox!.get(_hiveKey(link));
        if (model == null) return null;
        final preview = LinkPreviewData(
          title: model.title,
          description: model.description,
          link: model.link!,
          image: model.image != null
              ? ImagePreviewData(
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
  Future<LinkPreviewData?> loadPreview(String link) async {
    try {
      if (!_isInit) await _init();
      if (_previewBox == null) return null;
      final model = _previewBox!.get(_hiveKey(link));
      if (model == null) return null;
      final preview = LinkPreviewData(
        title: model.title,
        description: model.description,
        link: model.link!,
        image: model.image != null
            ? ImagePreviewData(
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
