import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_themes.dart';

class TodayView extends ConsumerStatefulWidget {
  final VoidCallback onAddTask;
  final VoidCallback onAddHabit;
  const TodayView({super.key, required this.onAddTask, required this.onAddHabit});

  @override
  ConsumerState<TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends ConsumerState<TodayView> with SingleTickerProviderStateMixin {
  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());
  Map<int, int> _counts = {}; // habit counts
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() { _bounce.dispose(); super.dispose(); }

  Future<void> _load() async {
    ref.read(taskProvider.notifier).loadDate(_today);
    await ref.read(habitProvider.notifier).loadHabits();
    final h = ref.read(habitProvider);
    final hc = <int, int>{};
    for (final x in h) {
      if (x.id != null) hc[x.id!] = await ref.read(habitProvider.notifier).getCount(x.id!, _today);
    }
    if (mounted) setState(() => _counts = hc);
  }

  // ---- helper: get task count from isDone ----
  int _taskCount(bool isDone) => isDone ? 1 : 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeId = ref.watch(themeProvider);
    final tasks = ref.watch(taskProvider)[_today] ?? [];
    final habits = ref.watch(habitProvider);
    final titleStyle = themeTitleStyle(themeId);
    final isVertical = ref.watch(layoutProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
      children: [
        // --- Cute animated logo ---
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Bouncing "日常"
            Row(mainAxisSize: MainAxisSize.min, children: [
              AnimatedBuilder(
                animation: _bounce,
                builder: (c, _) {
                  final b1 = math.sin(_bounce.value * math.pi);
                  return Transform.translate(
                    offset: Offset(0, b1 * -8),
                    child: Transform.rotate(
                      angle: b1 * 0.05,
                      child: Text('日',
                        style: TextStyle(fontFamily: 'serif', fontSize: 52,
                          fontWeight: FontWeight.w900, color: cs.primary, height: 1.0)),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              AnimatedBuilder(
                animation: _bounce,
                builder: (c, _) {
                  final b2 = math.sin((_bounce.value + 0.25) * math.pi);
                  return Transform.translate(
                    offset: Offset(b2 * 4, b2 * -8),
                    child: Transform.rotate(
                      angle: b2 * -0.05,
                      child: Text('常',
                        style: TextStyle(fontFamily: 'serif', fontSize: 52,
                          fontWeight: FontWeight.w900, color: cs.secondary, height: 1.0)),
                    ),
                  );
                },
              ),
            ]),
            // Daily Check — safely below the bouncing logo
            const SizedBox(height: 2),
            Text('Daily  ·  Check',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                color: cs.onSurface.withAlpha(180), letterSpacing: 2)),
          ]),
        ),
        const SizedBox(height: 4),
        Center(child: Text(
          DateFormat('M月d日 EEEE', 'zh_CN').format(DateTime.now()),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: cs.onSurface.withAlpha(220)))),
        const SizedBox(height: 28),

        // --- Quick add buttons ---
        Row(children: [
          Expanded(child: _quickBtn('＋ 添加任务', Icons.add_task_rounded, cs.primary, widget.onAddTask)),
          const SizedBox(width: 12),
          Expanded(child: _quickBtn('＋ 添加习惯', Icons.add_task_rounded, cs.secondary, widget.onAddHabit)),
        ]),
        const SizedBox(height: 28),

        // --- Sections: side-by-side when vertical, stacked when horizontal ---
        if (isVertical)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: _section(context, titleStyle, '今日任务', emoji: '📋',
              child: tasks.isEmpty
                ? _emptyHint('还没有任务哦 ✨')
                : _itemGrid(tasks.map((t) {
                    final cnt = _taskCount(t.isDone);
                    final target = 1;
                    final p = cnt / target;
                    final done = cnt >= target;
                    return _itemCard(
                      emoji: '📋',
                      name: t.title,
                      count: cnt,
                      target: target,
                      progress: p,
                      done: done,
                      onAdd: () => ref.read(taskProvider.notifier).setTaskDone(_today, tasks.indexOf(t), true),
                      onRemove: () => ref.read(taskProvider.notifier).setTaskDone(_today, tasks.indexOf(t), false),
                      onDelete: () => ref.read(taskProvider.notifier).deleteTask(_today, tasks.indexOf(t)),
                    );
                  }).toList()))),
            const SizedBox(width: 12),
            Expanded(child: _section(context, titleStyle, '习惯打卡', emoji: themeId == 'grass' ? '🍀' : '🌸',
              child: habits.isEmpty
                ? _emptyHint('还没有习惯哦 ✨')
                : _itemGrid(habits.map((h) {
                    final cnt = _counts[h.id] ?? 0;
                    final target = h.targetCount;
                    final p = target > 0 ? (cnt / target).clamp(0.0, 1.0) : 0.0;
                    final done = cnt >= target;
                    return _itemCard(
                      emoji: h.icon,
                      name: h.name,
                      count: cnt,
                      target: target,
                      progress: p,
                      done: done,
                      onAdd: () => _updateHabit(h.id!, cnt + 1),
                      onRemove: () => _updateHabit(h.id!, cnt - 1),
                      onDelete: () => ref.read(habitProvider.notifier).deleteHabit(h.id!),
                    );
                  }).toList()))),
          ])
        else ...[
          _section(context, titleStyle, '今日任务', emoji: '📋',
            child: tasks.isEmpty
              ? _emptyHint('还没有任务，点击上方按钮添加吧 ✨')
              : Column(children: tasks.map((t) {
                  final cnt = _taskCount(t.isDone);
                  final target = 1;
                  final p = cnt / target;
                  final done = cnt >= target;
                  return _itemRow(
                    icon: null,
                    emoji: null,
                    name: t.title,
                    count: cnt,
                    target: target,
                    progress: p,
                    done: done,
                    onAdd: () => ref.read(taskProvider.notifier).setTaskDone(_today, tasks.indexOf(t), true),
                    onRemove: () => ref.read(taskProvider.notifier).setTaskDone(_today, tasks.indexOf(t), false),
                    onDelete: () => ref.read(taskProvider.notifier).deleteTask(_today, tasks.indexOf(t)),
                  );
                }).toList())),
          const SizedBox(height: 20),
          _section(context, titleStyle, '习惯打卡', emoji: themeId == 'grass' ? '🍀' : '🌸',
            child: habits.isEmpty
              ? _emptyHint('还没有习惯，点击上方按钮添加吧 ✨')
              : Column(children: habits.map((h) {
                  final cnt = _counts[h.id] ?? 0;
                  final target = h.targetCount;
                  final p = target > 0 ? (cnt / target).clamp(0.0, 1.0) : 0.0;
                  final done = cnt >= target;
                  return _itemRow(
                    emoji: h.icon,
                    name: h.name,
                    count: cnt,
                    target: target,
                    progress: p,
                    done: done,
                    onAdd: () => _updateHabit(h.id!, cnt + 1),
                    onRemove: () => _updateHabit(h.id!, cnt - 1),
                    onDelete: () => ref.read(habitProvider.notifier).deleteHabit(h.id!),
                  );
                }).toList())),
        ],
      ],
    );
  }

  // ============================================
  //  UNIFIED item row (task & habit identical)
  // ============================================
  Widget _itemRow({
    IconData? icon,
    String? emoji,
    required String name,
    required int count,
    required int target,
    required double progress,
    required bool done,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required VoidCallback onDelete,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // icon / emoji
        if (emoji != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(emoji, style: const TextStyle(fontSize: 22)),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 22, color: cs.primary),
          ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(name, style: TextStyle(fontSize: 15, color: cs.onSurface)),
            Text('$count/$target', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: done ? cs.primary : cs.onSurface.withAlpha(130))),
          ]),
          const SizedBox(height: 5),
          ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 5,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: done ? cs.primary : cs.secondary)),
          const SizedBox(height: 8),
          Row(children: [
            _circleBtn(Icons.close, () => onRemove()),
            const SizedBox(width: 14),
            _circleBtn(Icons.check, () => onAdd()),
          ]),
        ])),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onDelete,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.close, size: 16, color: cs.onSurface.withAlpha(80)),
          ),
        ),
      ]),
    );
  }

  // ============================================
  //  Vertical card item (2-col grid, aligns with add buttons)
  // ============================================
  Widget _itemCard({
    required String emoji,
    required String name,
    required int count,
    required int target,
    required double progress,
    required bool done,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    required VoidCallback onDelete,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface.withAlpha(12), width: 0.5),
      ),
      child: Stack(children: [
        Column(mainAxisSize: MainAxisSize.min, children: [
          // Emoji
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          // Name
          Text(name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
            textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(value: progress, minHeight: 4,
                  backgroundColor: cs.surfaceContainerHighest,
                  color: done ? cs.primary : cs.secondary)),
          const SizedBox(height: 4),
          // Count
          Text('$count/$target', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
              color: done ? cs.primary : cs.onSurface.withAlpha(120))),
          const SizedBox(height: 8),
          // Buttons row
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _circleBtn(Icons.close, () => onRemove()),
            const SizedBox(width: 16),
            _circleBtn(Icons.check, () => onAdd()),
          ]),
        ]),
        // Delete button top-right
        Positioned(
          top: 0, right: 0,
          child: GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 14, color: cs.onSurface.withAlpha(60)),
          ),
        ),
      ]),
    );
  }

  Widget _itemGrid(List<Widget> cards) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        children: cards.map((card) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: card,
        )).toList(),
      ),
    );
  }

  // ============================================
  //  Habit update
  // ============================================
  Future<void> _updateHabit(int id, int nc) async {
    final c = nc.clamp(0, 999);
    _counts[id] = c;
    setState(() {});
    await ref.read(habitProvider.notifier).setCount(id, _today, c);
  }

  // ============================================
  //  Circle +/- button
  // ============================================
  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: cs.primary.withAlpha(10),
          shape: BoxShape.circle,
          border: Border.all(color: cs.primary.withAlpha(35), width: 1.2),
        ),
        child: Icon(icon, size: 14, color: cs.primary),
      ),
    );
  }

  // ============================================
  //  Quick add pill button
  // ============================================
  Widget _quickBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(55), width: 1),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }

  // ============================================
  //  Empty hint
  // ============================================
  Widget _emptyHint(String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(text, style: TextStyle(fontSize: 14, color: cs.onSurface.withAlpha(120))));
  }

  // ============================================
  //  Section wrapper with cute title
  // ============================================
  Widget _section(BuildContext context, String titleStyle, String title,
      {String emoji = '', required Widget child}) {
    final cs = Theme.of(context).colorScheme;
    final themeId = ref.watch(themeProvider);
    final cardR = themeCardRadius(themeId);
    final useShadow = themeUseShadows(themeId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(cardR),
        boxShadow: useShadow
            ? [BoxShadow(color: cs.shadow.withAlpha(18), blurRadius: 10, offset: const Offset(0, 3))]
            : null,
        border: Border.all(color: cs.onSurface.withAlpha(18), width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildTitle(cs, titleStyle, '$emoji  $title'),
        child,
      ]),
    );
  }

  // ============================================
  //  Title builders per style
  // ============================================
  Widget _buildTitle(ColorScheme cs, String style, String title) {
    switch (style) {
      case 'dash':     return _titleDash(cs, title);
      case 'heart':    return _titleHeart(cs, title);
      case 'accentBar':return _titleAccentBar(cs, title);
      case 'slash':    return _titleSlash(cs, title);
      case 'wave':     return _titleWave(cs, title);
      case 'neon':     return _titleNeon(cs, title);
      case 'stamp':    return _titleStamp(cs, title);
      case 'dotBar':   return _titleDotBar(cs, title);
      case 'plain':    return _titlePlain(cs, title);
      case 'leaf':     return _titleLeaf(cs, title);
      case 'center':   return _titleCenter(cs, title);
      default:         return _titleUnderline(cs, title);
    }
  }

  Widget _titleUnderline(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w800, color: cs.onSurface)),
      const SizedBox(height: 6),
      Container(width: 36, height: 3, decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(2))),
    ]));

  Widget _titleDash(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(width: 10),
      Expanded(child: Divider(color: cs.onSurface.withAlpha(30), thickness: 1)),
    ]));

  Widget _titleHeart(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      Text(title, style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w800, color: cs.primary)),
      const SizedBox(width: 6),
      Text('·', style: TextStyle(fontSize: 22, color: cs.secondary)),
    ]));

  Widget _titleAccentBar(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      Container(width: 4, height: 22, decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
    ]));

  Widget _titleSlash(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      Transform.rotate(angle: 0.3, child: Container(width: 3, height: 18, color: cs.primary)),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.primary, letterSpacing: 2)),
    ]));

  Widget _titleWave(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w800, color: cs.primary)),
      const SizedBox(height: 4),
      Row(children: List.generate(8, (i) => Container(
        width: 4, height: (4 + (i % 2) * 4).toDouble(),
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(color: cs.primary.withAlpha(80 + (i % 3) * 60), borderRadius: BorderRadius.circular(2))))),
    ]));

  Widget _titleNeon(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: cs.primary.withAlpha(180), blurRadius: 8, spreadRadius: 2)])),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.primary,
        shadows: [Shadow(color: cs.primary.withAlpha(100), blurRadius: 6)])),
    ]));

  Widget _titleStamp(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(children: [
      Text('■', style: TextStyle(fontSize: 12, color: cs.primary)),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w800, color: cs.onSurface,
        letterSpacing: 1)),
      const SizedBox(width: 8),
      Text('■', style: TextStyle(fontSize: 12, color: cs.primary)),
    ]));

  Widget _titleDotBar(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: 6),
      Row(children: List.generate(6, (i) => Container(
        width: 4, height: 4, margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(color: i == 0 ? cs.primary : cs.primary.withAlpha(40), shape: BoxShape.circle)))),
    ]));

  Widget _titlePlain(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)));

  Widget _titleLeaf(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Center(child: Text(title,
      style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w800, color: cs.primary))));

  Widget _titleCenter(ColorScheme cs, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Center(child: Column(children: [
      Text(title, style: TextStyle(fontFamily: 'serif', fontSize: 20, fontWeight: FontWeight.w800, color: cs.primary)),
      const SizedBox(height: 4),
      Container(width: 24, height: 2, decoration: BoxDecoration(color: cs.secondary, borderRadius: BorderRadius.circular(1))),
    ])));
}
