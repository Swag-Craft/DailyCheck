import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../storage/database.dart';

class TaskNotifier extends StateNotifier<Map<String, List<Task>>> {
  TaskNotifier() : super({});

  final _store = JsonStore.instance;

  Future<void> loadDate(String date) async {
    if (state.containsKey(date)) return;
    final rows = await _store.getTasksByDate(date);
    final tasks = rows.map((r) => Task.fromMap(r)).toList();
    state = {...state, date: tasks};
  }

  Future<void> addTask(String date, String title) async {
    final tasks = List<Task>.from(state[date] ?? []);
    final sortOrder = tasks.length;
    final task = Task(title: title, date: date, sortOrder: sortOrder);
    final id = await _store.insertTask(task.toMap());
    tasks.add(task.copyWith(id: id));
    state = {...state, date: tasks};
  }

  Future<void> setTaskDone(String date, int index, bool done) async {
    final tasks = List<Task>.from(state[date] ?? []);
    final task = tasks[index];
    if (task.isDone == done) return; // no change
    final updated = task.copyWith(isDone: done);
    await _store.updateTask(task.id!, updated.toMap());
    tasks[index] = updated;
    state = {...state, date: tasks};
  }

  Future<void> toggleTask(String date, int index) async {
    final tasks = List<Task>.from(state[date] ?? []);
    final task = tasks[index];
    final updated = task.copyWith(isDone: !task.isDone);
    await _store.updateTask(task.id!, updated.toMap());
    tasks[index] = updated;
    state = {...state, date: tasks};
  }

  Future<void> deleteTask(String date, int index) async {
    final tasks = List<Task>.from(state[date] ?? []);
    final task = tasks[index];
    await _store.deleteTask(task.id!);
    tasks.removeAt(index);
    state = {...state, date: tasks};
  }

  Future<void> reorderTask(String date, int oldIndex, int newIndex) async {
    final tasks = List<Task>.from(state[date] ?? []);
    final task = tasks.removeAt(oldIndex);
    tasks.insert(newIndex, task);
    for (int i = 0; i < tasks.length; i++) {
      final updated = tasks[i].copyWith(sortOrder: i);
      tasks[i] = updated;
      await _store.updateTask(updated.id!, {'sort_order': i});
    }
    state = {...state, date: tasks};
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, Map<String, List<Task>>>((ref) {
  return TaskNotifier();
});
