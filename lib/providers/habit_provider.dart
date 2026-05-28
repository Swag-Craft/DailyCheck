import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../storage/database.dart';

class HabitNotifier extends StateNotifier<List<Habit>> {
  HabitNotifier() : super([]);

  final _store = JsonStore.instance;
  final Map<int, Map<String, int>> _dateCache = {};

  Future<void> loadHabits() async {
    final rows = await _store.getAllHabits();
    state = rows.map((r) => Habit.fromMap(r)).toList();
  }

  Future<void> addHabit(String name, String icon, int targetCount) async {
    final now = DateTime.now().toIso8601String().substring(0, 10);
    final habit = Habit(
      name: name,
      icon: icon,
      targetCount: targetCount,
      createdAt: now,
    );
    final id = await _store.insertHabit(habit.toMap());
    state = [...state, habit.copyWith(id: id)];
  }

  Future<void> deleteHabit(int id) async {
    await _store.deleteHabit(id);
    state = state.where((h) => h.id != id).toList();
  }

  Future<int> getCount(int habitId, String date) async {
    if (_dateCache[habitId]?.containsKey(date) ?? false) {
      return _dateCache[habitId]![date]!;
    }
    final row = await _store.getHabitDate(habitId, date);
    final count = row != null ? row['count'] as int : 0;
    _dateCache[habitId] ??= {};
    _dateCache[habitId]![date] = count;
    return count;
  }

  Future<void> setCount(int habitId, String date, int count) async {
    final clamped = count.clamp(0, 999);
    await _store.upsertHabitDate(habitId, date, clamped);
    _dateCache[habitId] ??= {};
    _dateCache[habitId]![date] = clamped;
  }

  Future<int> getStreak(int habitId, {String? untilDate}) async {
    final date = untilDate ?? DateTime.now().toIso8601String().substring(0, 10);
    final rows = await _store.getHabitDatesByHabit(habitId);
    final dates = rows
        .where((r) => (r['count'] as int) > 0)
        .map((r) => r['date'] as String)
        .toSet();

    int streak = 0;
    var current = DateTime.parse(date);
    while (dates.contains(_fmt(current))) {
      streak++;
      current = current.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<Map<String, int>> getHotmap(int habitId) async {
    final rows = await _store.getHabitDatesByHabit(habitId);
    final map = <String, int>{};
    for (final r in rows) {
      map[r['date'] as String] = r['count'] as int;
    }
    return map;
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier();
});
