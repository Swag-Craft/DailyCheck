import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class JsonStore {
  static final JsonStore instance = JsonStore._();
  factory JsonStore() => instance;
  JsonStore._();

  String? _basePath;

  Future<String> get basePath async {
    if (_basePath != null) return _basePath!;
    final dir = await getApplicationDocumentsDirectory();
    _basePath = p.join(dir.path, 'richang_data');
    await Directory(_basePath!).create(recursive: true);
    return _basePath!;
  }

  Future<File> _file(String name) async {
    final bp = await basePath;
    final f = File(p.join(bp, '$name.json'));
    if (!await f.exists()) {
      await f.writeAsString('[]');
    }
    return f;
  }

  Future<List<Map<String, dynamic>>> _readAll(String name) async {
    final f = await _file(name);
    final content = await f.readAsString();
    final list = json.decode(content) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _writeAll(String name, List<Map<String, dynamic>> data) async {
    final f = await _file(name);
    await f.writeAsString(json.encode(data));
  }

  // ---- Tasks ----
  Future<List<Map<String, dynamic>>> getTasksByDate(String date) async {
    final tasks = await _readAll('tasks');
    return tasks.where((t) => t['date'] == date).toList()
      ..sort((a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int));
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    final tasks = await _readAll('tasks');
    final id = tasks.isEmpty ? 1 : (tasks.map((t) => t['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
    task['id'] = id;
    tasks.add(task);
    await _writeAll('tasks', tasks);
    return id;
  }

  Future<void> updateTask(int id, Map<String, dynamic> updates) async {
    final tasks = await _readAll('tasks');
    final idx = tasks.indexWhere((t) => t['id'] == id);
    if (idx != -1) {
      tasks[idx] = {...tasks[idx], ...updates};
      await _writeAll('tasks', tasks);
    }
  }

  Future<void> deleteTask(int id) async {
    final tasks = await _readAll('tasks');
    tasks.removeWhere((t) => t['id'] == id);
    await _writeAll('tasks', tasks);
  }

  // ---- Habits ----
  Future<List<Map<String, dynamic>>> getAllHabits() async {
    final habits = await _readAll('habits');
    habits.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
    return habits;
  }

  Future<int> insertHabit(Map<String, dynamic> habit) async {
    final habits = await _readAll('habits');
    final id = habits.isEmpty ? 1 : (habits.map((h) => h['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
    habit['id'] = id;
    habits.add(habit);
    await _writeAll('habits', habits);
    return id;
  }

  Future<void> deleteHabit(int id) async {
    final habits = await _readAll('habits');
    habits.removeWhere((h) => h['id'] == id);
    await _writeAll('habits', habits);
    // Clean up related habit dates
    final dates = await _readAll('habit_dates');
    dates.removeWhere((d) => d['habit_id'] == id);
    await _writeAll('habit_dates', dates);
  }

  // ---- HabitDates ----
  Future<Map<String, dynamic>?> getHabitDate(int habitId, String date) async {
    final dates = await _readAll('habit_dates');
    try {
      return dates.firstWhere((d) => d['habit_id'] == habitId && d['date'] == date);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertHabitDate(int habitId, String date, int count) async {
    final dates = await _readAll('habit_dates');
    final idx = dates.indexWhere((d) => d['habit_id'] == habitId && d['date'] == date);
    if (idx != -1) {
      dates[idx]['count'] = count;
    } else {
      final newId = dates.isEmpty ? 1 : (dates.map((d) => d['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
      dates.add({'id': newId, 'habit_id': habitId, 'date': date, 'count': count});
    }
    await _writeAll('habit_dates', dates);
  }

  Future<List<Map<String, dynamic>>> getHabitDatesByHabit(int habitId) async {
    final dates = await _readAll('habit_dates');
    return dates.where((d) => d['habit_id'] == habitId).toList();
  }

  Future<List<Map<String, dynamic>>> getAllHabitDates() async {
    return _readAll('habit_dates');
  }

  // ---- Mood ----
  Future<Map<String, dynamic>?> getMoodByDate(String date) async {
    final moods = await _readAll('mood_entries');
    try {
      return moods.firstWhere((m) => m['date'] == date);
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertMood(Map<String, dynamic> entry) async {
    final moods = await _readAll('mood_entries');
    final idx = moods.indexWhere((m) => m['date'] == entry['date']);
    if (idx != -1) {
      entry['id'] = moods[idx]['id'];
      moods[idx] = entry;
    } else {
      final newId = moods.isEmpty ? 1 : (moods.map((m) => m['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
      entry['id'] = newId;
      moods.add(entry);
    }
    await _writeAll('mood_entries', moods);
  }

  Future<List<Map<String, dynamic>>> getMoodRange(String start, String end) async {
    final moods = await _readAll('mood_entries');
    moods.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    return moods.where((m) {
      final d = m['date'] as String;
      return d.compareTo(start) >= 0 && d.compareTo(end) <= 0;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAllMoods() async {
    final moods = await _readAll('mood_entries');
    moods.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return moods;
  }
}
