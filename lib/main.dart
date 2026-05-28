import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN', null);

  // Window setup
  await windowManager.ensureInitialized();
  await windowManager.setSize(const Size(960, 820));
  await windowManager.center();
  await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  await windowManager.setPreventClose(true);
  await windowManager.show();

  // Tray setup — use asset path, tray_manager auto-resolves
  await trayManager.setIcon('assets/app_icon.ico');
  await trayManager.setToolTip('日常 DailyCheck');
  final menu = Menu(
    items: [
      MenuItem(key: 'show', label: '显示'),
      MenuItem.separator(),
      MenuItem(key: 'quit', label: '退出'),
    ],
  );
  await trayManager.setContextMenu(menu);

  runApp(const ProviderScope(child: RichangApp()));
}
