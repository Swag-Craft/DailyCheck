import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/title_bar.dart';
import 'today_view.dart';
import 'history_view.dart';
import 'settings_page.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _showToday = true;

  static const _cuteTaskIcons = [
    '✅','📝','🎯','⭐','💼','📋','🔖','📌','✍️','💡',
    '🔥','🌈','🎵','📚','💪','🏃','🧘','🍎','☕','🎮',
  ];

  static const _cuteHabitIcons = [
    '⭐','💧','🏃','📚','🧘','💤','🍎','✍️','🎯','🌈',
    '🔥','💪','🎵','🌸','📝','☕','🎮','🫧','🌿','🍃',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        CustomTitleBar(
          center: _toggleInline(),
          onSettingsTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
          },
        ),
        Expanded(
          child: _showToday
              ? TodayView(
                  onAddTask: () => _quickAdd('task'),
                  onAddHabit: () => _quickAdd('habit'),
                )
              : const HistoryView(),
        ),
      ]),
    );
  }

  Widget _toggleInline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _tab('今日', _showToday, () => setState(() => _showToday = true)),
        _tab('过往', !_showToday, () => setState(() => _showToday = false)),
      ]),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: active ? cs.onPrimary : cs.onSurface.withAlpha(120),
        )),
      ),
    );
  }

  // ============================================
  //  Add dialog with icon picker + count
  // ============================================
  void _quickAdd(String type) {
    final ctrl = TextEditingController();
    final icons = type == 'task' ? _cuteTaskIcons : _cuteHabitIcons;
    String selectedIcon = type == 'task' ? '✅' : '⭐';
    int count = 1;

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final cs = Theme.of(ctx).colorScheme;
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(
                  color: cs.onSurface.withAlpha(50), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Text(type == 'task' ? '添加任务' : '添加习惯',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface)),
                const SizedBox(height: 16),

                // Icon picker
                Text('选择图标', style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(150))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: icons.map((e) => GestureDetector(
                    onTap: () => setSheetState(() => selectedIcon = e),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: selectedIcon == e ? cs.primary.withAlpha(40) : cs.surfaceContainerHighest.withAlpha(60),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selectedIcon == e ? cs.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: ctrl, autofocus: true,
                  decoration: InputDecoration(hintText: type == 'task' ? '任务名称...' : '习惯名称...'),
                ),
                const SizedBox(height: 14),

                // Count selector
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('每日目标次数', style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(150))),
                  const SizedBox(width: 12),
                  _countBtn(cs, Icons.remove, () {
                    if (count > 1) setSheetState(() => count--);
                  }),
                  const SizedBox(width: 8),
                  Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.primary)),
                  const SizedBox(width: 8),
                  _countBtn(cs, Icons.add, () {
                    if (count < 99) setSheetState(() => count++);
                  }),
                ]),
                const SizedBox(height: 16),

                SizedBox(width: double.infinity, child: FilledButton(
                  onPressed: () {
                    if (ctrl.text.trim().isNotEmpty) {
                      _doAdd(type, ctrl.text.trim(), selectedIcon, count, ctx);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('确定', style: TextStyle(fontSize: 16)),
                )),
                const SizedBox(height: 8),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _countBtn(ColorScheme cs, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: cs.primary.withAlpha(12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: cs.primary),
      ),
    );
  }

  void _doAdd(String type, String text, String icon, int targetCount, BuildContext ctx) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (type == 'task') {
      ref.read(taskProvider.notifier).addTask(today, text);
    } else {
      ref.read(habitProvider.notifier).addHabit(text, icon, targetCount);
    }
    if (ctx.mounted) Navigator.pop(ctx);
  }
}
