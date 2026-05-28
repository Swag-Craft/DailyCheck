import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// ============================================
//  Shared settings file helper
// ============================================

String? _settingsPath;

Future<String> get _path async {
  if (_settingsPath != null) return _settingsPath!;
  final dir = await getApplicationDocumentsDirectory();
  final dataDir = p.join(dir.path, 'richang_data');
  await Directory(dataDir).create(recursive: true);
  _settingsPath = p.join(dataDir, 'settings.json');
  return _settingsPath!;
}

Future<Map<String, dynamic>> _readSettings() async {
  try {
    final f = File(await _path);
    if (await f.exists()) {
      return json.decode(await f.readAsString()) as Map<String, dynamic>;
    }
  } catch (_) {}
  return {};
}

Future<void> _writeSettings(Map<String, dynamic> data) async {
  try {
    final f = File(await _path);
    await f.writeAsString(json.encode(data));
  } catch (_) {}
}

// ============================================
//  Theme provider
// ============================================

class ThemeNotifier extends StateNotifier<String> {
  ThemeNotifier() : super('grass') {
    _load();
  }

  Future<void> _load() async {
    final data = await _readSettings();
    final v = data['theme'] as String?;
    if (v != null && v.isNotEmpty) state = v;
  }

  Future<void> set(String id) async {
    state = id;
    final data = await _readSettings();
    data['theme'] = id;
    await _writeSettings(data);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, String>((ref) => ThemeNotifier());

// ============================================
//  Layout provider (horizontal / vertical)
// ============================================

class LayoutNotifier extends StateNotifier<bool> {
  LayoutNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final data = await _readSettings();
    final v = data['vertical'] as bool?;
    if (v != null) state = v;
  }

  Future<void> toggle() async {
    state = !state;
    final data = await _readSettings();
    data['vertical'] = state;
    await _writeSettings(data);
  }
}

final layoutProvider = StateNotifierProvider<LayoutNotifier, bool>((ref) => LayoutNotifier());
