import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/app_themes.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cur = ref.watch(themeProvider);
    final isVertical = ref.watch(layoutProvider);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // --- Layout toggle ---
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text('显示模式', style: Theme.of(context).textTheme.headlineMedium),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.onSurface.withAlpha(15), width: 1),
            boxShadow: [BoxShadow(color: cs.shadow.withAlpha(10), blurRadius: 6)],
          ),
          child: Row(children: [
            Icon(isVertical ? Icons.grid_view_rounded : Icons.view_list_rounded,
              size: 24, color: cs.primary),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isVertical ? '竖版卡片' : '横版列表',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(isVertical ? '双列卡片，对齐添加按钮' : '单列横向排列',
                style: Theme.of(context).textTheme.bodyMedium),
            ])),
            Switch(value: isVertical,
              onChanged: (_) => ref.read(layoutProvider.notifier).toggle()),
          ]),
        ),

        // --- Themes ---
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text('主题风格', style: Theme.of(context).textTheme.headlineMedium),
        ),
        ...allThemes.map((t) {
          final active = cur == t.id;
          return GestureDetector(
            onTap: () => ref.read(themeProvider.notifier).set(t.id),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active ? cs.primary : cs.onSurface.withAlpha(15),
                  width: active ? 2 : 1,
                ),
                boxShadow: [BoxShadow(
                  color: cs.shadow.withAlpha(10),
                  blurRadius: 6,
                )],
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: t.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: active
                        ? [BoxShadow(color: t.color.withAlpha(80), blurRadius: 8, spreadRadius: 1)]
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(t.desc, style: Theme.of(context).textTheme.bodyMedium),
                ])),
                if (active)
                  Icon(Icons.check_circle, color: cs.primary, size: 22),
              ]),
            ),
          );
        }),
        const SizedBox(height: 40),
        Center(
          child: Text('日常 Daily Check  v1.0',
            style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(80))),
        ),
        const SizedBox(height: 20),
      ]),
    );
  }
}
