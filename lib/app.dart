import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'screens/main_shell.dart';
import '../providers/theme_provider.dart';
import '../theme/app_themes.dart';

class RichangApp extends ConsumerStatefulWidget {
  const RichangApp({super.key});
  @override
  ConsumerState<RichangApp> createState() => _RichangAppState();
}

class _RichangAppState extends ConsumerState<RichangApp> with TrayListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
    windowManager.focus();
  }

  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show') {
      windowManager.show();
      windowManager.focus();
    } else if (menuItem.key == 'quit') {
      windowManager.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeId = ref.watch(themeProvider);
    return MaterialApp(
      title: '日常',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(themeId),
      home: const MainShell(),
    );
  }
}
