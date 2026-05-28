import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../storage/database.dart';

class HistoryView extends ConsumerStatefulWidget {
  const HistoryView({super.key});

  @override
  ConsumerState<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends ConsumerState<HistoryView> {
  late DateTime _month = DateTime.now();
  Map<String, Map<int, int>> _habitCounts = {}; // date -> {habitId: count}
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await ref.read(habitProvider.notifier).loadHabits();
    final habits = ref.read(habitProvider);
    final allDates = await JsonStore.instance.getAllHabitDates();
    final map = <String, Map<int, int>>{};
    for (final d in allDates) {
      final date = d['date'] as String;
      final hid = d['habit_id'] as int;
      final cnt = d['count'] as int;
      map[date] ??= {};
      map[date]![hid] = cnt;
    }
    if (mounted) setState(() { _habitCounts = map; _loaded = true; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final year = _month.year; final mon = _month.month;
    final daysInMonth = DateTime(year, mon + 1, 0).day;
    final days = List.generate(daysInMonth, (i) => DateTime(year, mon, i + 1));

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Row(children: [
          GestureDetector(
            onTap: () async {
              final p = await showDatePicker(context: context, initialDate: _month,
                  firstDate: DateTime(2024), lastDate: DateTime.now(), initialDatePickerMode: DatePickerMode.year);
              if (p != null) setState(() => _month = DateTime(p.year, p.month));
            },
            child: Row(children: [
              Text(DateFormat('yyyy年M月', 'zh_CN').format(_month),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: cs.onSurface)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_drop_down, size: 26, color: cs.primary),
            ]),
          ),
        ]),
      ),
      if (!_loaded)
        const Expanded(child: Center(child: CircularProgressIndicator()))
      else
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          itemCount: days.length,
          itemBuilder: (ctx, i) {
            final ds = DateFormat('yyyy-MM-dd').format(days[i]);
            final habitMap = _habitCounts[ds] ?? {};
            return _DayCard(date: ds, habitCounts: habitMap);
          },
        )),
    ]);
  }
}

class _DayCard extends ConsumerWidget {
  final String date;
  final Map<int, int> habitCounts;
  const _DayCard({required this.date, required this.habitCounts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tasks = ref.watch(taskProvider)[date] ?? [];
    final habits = ref.watch(habitProvider).where((h) {
      final cnt = habitCounts[h.id] ?? 0;
      return cnt > 0;
    }).toList();

    final total = tasks.length;
    final done = tasks.where((t) => t.isDone).length;
    final dateFmt = DateFormat('M月d日 EEE', 'zh_CN').format(DateTime.parse(date));

    if (total == 0 && habits.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: cs.shadow.withAlpha(15), blurRadius: 6, offset: const Offset(0, 3))],
        border: Border.all(color: cs.onSurface.withAlpha(20), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Date header
        Row(children: [
          Text(dateFmt, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),

        ]),
        // Tasks
        if (total > 0) ...[
          const SizedBox(height: 10),
          ...tasks.map((t) {
            final done = t.isDone;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Icon(done ? Icons.check_circle : Icons.circle_outlined, size: 16,
                    color: done ? cs.primary : cs.onSurface.withAlpha(80)),
                const SizedBox(width: 6),
                const Text('📋', style: TextStyle(fontSize: 15)),
                const SizedBox(width: 4),
                Text(t.title, style: TextStyle(fontSize: 14,
                    color: done ? cs.onSurface.withAlpha(120) : cs.onSurface)),
                if (!done) ...[
                  const SizedBox(width: 8),
                  Text('0/1', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: cs.onSurface.withAlpha(100))),
                ],
              ]),
            );
          }),
        ],
        // Habits
        if (habits.isNotEmpty) ...[
          if (total > 0) const SizedBox(height: 6),
          ...habits.map((h) {
            final cnt = habitCounts[h.id] ?? 0;
            final done = cnt >= h.targetCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Icon(done ? Icons.check_circle : Icons.circle_outlined, size: 16,
                    color: done ? cs.primary : cs.onSurface.withAlpha(80)),
                const SizedBox(width: 6),
                Text(h.icon, style: const TextStyle(fontSize: 15)),
                const SizedBox(width: 4),
                Text(h.name, style: TextStyle(fontSize: 14,
                    color: done ? cs.onSurface.withAlpha(120) : cs.onSurface)),
                if (!done) ...[
                  const SizedBox(width: 8),
                  Text('$cnt/${h.targetCount}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: cs.onSurface.withAlpha(100))),
                ],
              ]),
            );
          }),
        ],
      ]),
    );
  }
}
