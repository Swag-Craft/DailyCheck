import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatefulWidget {
  final Widget? center;
  final VoidCallback? onSettingsTap;
  const CustomTitleBar({super.key, this.center, this.onSettingsTap});

  @override
  State<CustomTitleBar> createState() => _CustomTitleBarState();
}

class _CustomTitleBarState extends State<CustomTitleBar> with WindowListener {
  bool _maximized = false;

  @override
  void initState() { super.initState(); windowManager.addListener(this); }
  @override
  void dispose() { windowManager.removeListener(this); super.dispose(); }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);
  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(bottom: BorderSide(color: cs.onSurface.withAlpha(25), width: 1)),
        ),
        child: Stack(children: [
          if (widget.center != null) Center(child: widget.center!),
          Positioned(
            right: 4, top: 0, bottom: 0,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (widget.onSettingsTap != null) ...[
                _btn(cs, Icons.settings_rounded, widget.onSettingsTap!, alpha: 150),
                const SizedBox(width: 8),
              ],
              _btn(cs, Icons.minimize_rounded, () => windowManager.minimize(), alpha: 90),
              const SizedBox(width: 4),
              _btn(cs, _maximized ? Icons.filter_none_rounded : Icons.crop_square_rounded,
                  () => _maximized ? windowManager.unmaximize() : windowManager.maximize(), alpha: 90),
              const SizedBox(width: 4),
              _btn(cs, Icons.close_rounded, () => windowManager.hide(), isClose: true),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _btn(ColorScheme cs, IconData icon, VoidCallback onTap, {bool isClose = false, int alpha = 150}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 32, height: 28,
        child: Center(
          child: Icon(icon, size: 16,
            color: isClose ? cs.onSurface.withAlpha(alpha) : cs.onSurface.withAlpha(alpha)),
        ),
      ),
    );
  }
}
